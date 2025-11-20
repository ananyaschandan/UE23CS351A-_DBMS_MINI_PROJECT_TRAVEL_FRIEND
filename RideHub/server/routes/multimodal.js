import express from 'express';
import { pool } from '../config/database.js';

const router = express.Router();

// Calculate multi-modal route options
router.post('/calculate-routes', async (req, res) => {
  try {
    const { startLocation, endLocation } = req.body;

    if (!startLocation || !endLocation) {
      return res.status(400).json({ error: 'Start and end locations are required' });
    }

    // Check if same location
    if (startLocation === endLocation) {
      return res.json([{
        routeType: 'Shortest',
        totalDistance: 0,
        totalTime: 0,
        totalFare: 0,
        segments: [],
        isMultiModal: false
      }]);
    }

    // Get base route info
    const [routes] = await pool.query(
      'SELECT Distance, EstimatedTime FROM Route WHERE StartLocation = ? AND EndLocation = ?',
      [startLocation, endLocation]
    );

    let baseDistance = routes.length > 0 ? parseFloat(routes[0].Distance) : 8.0;
    let baseTime = routes.length > 0 ? parseInt(routes[0].EstimatedTime) : 35;

    // Calculate 3 route options
    const routeOptions = [];

    // 1. SHORTEST ROUTE (Multi-modal with less distance)
    const shortestDistance = baseDistance * 0.92; // 8% less distance
    const shortestSegments = await calculateShortestRoute(startLocation, endLocation, shortestDistance, baseTime);
    routeOptions.push({
      routeType: 'Shortest',
      totalDistance: parseFloat(shortestSegments.reduce((sum, s) => sum + s.distance, 0).toFixed(2)),
      totalTime: shortestSegments.reduce((sum, s) => sum + s.estimatedTime, 0),
      totalFare: parseFloat(shortestSegments.reduce((sum, s) => sum + s.segmentFare, 0).toFixed(2)),
      segments: shortestSegments,
      isMultiModal: shortestSegments.length > 1
    });

    // 2. FASTEST ROUTE (Less time, may cost more)
    const fastestTime = Math.round(baseTime * 0.65); // 35% faster
    const fastestSegments = await calculateFastestRoute(startLocation, endLocation, baseDistance, fastestTime);
    routeOptions.push({
      routeType: 'Fastest',
      totalDistance: parseFloat(fastestSegments.reduce((sum, s) => sum + s.distance, 0).toFixed(2)),
      totalTime: fastestSegments.reduce((sum, s) => sum + s.estimatedTime, 0),
      totalFare: parseFloat(fastestSegments.reduce((sum, s) => sum + s.segmentFare, 0).toFixed(2)),
      segments: fastestSegments,
      isMultiModal: fastestSegments.length > 1
    });

    // 3. CHEAPEST ROUTE (Lowest price, may take longer)
    const cheapestTime = Math.round(baseTime * 1.15); // 15% slower
    const cheapestSegments = await calculateCheapestRoute(startLocation, endLocation, baseDistance + 0.5, cheapestTime);
    routeOptions.push({
      routeType: 'Cheapest',
      totalDistance: parseFloat(cheapestSegments.reduce((sum, s) => sum + s.distance, 0).toFixed(2)),
      totalTime: cheapestSegments.reduce((sum, s) => sum + s.estimatedTime, 0),
      totalFare: parseFloat(cheapestSegments.reduce((sum, s) => sum + s.segmentFare, 0).toFixed(2)),
      segments: cheapestSegments,
      isMultiModal: cheapestSegments.length > 1
    });

    res.json(routeOptions);
  } catch (error) {
    console.error('Error calculating routes:', error);
    res.status(500).json({ error: 'Failed to calculate routes' });
  }
});

// Helper: Calculate Shortest Route (Walk + Bounce + Rapido)
async function calculateShortestRoute(start, end, totalDistance, baseTime) {
  const segments = [];
  
  // Check if Bounce center nearby
  const [bounceCenters] = await pool.query(
    'SELECT CenterName, Location FROM BounceCenter WHERE IsActive = TRUE ORDER BY RAND() LIMIT 1'
  );

  if (bounceCenters.length > 0 && totalDistance > 3) {
    const bounceLocation = bounceCenters[0].Location;
    
    // Segment 1: Walk to Bounce (0.3 km, 4 min, ₹0)
    segments.push({
      segmentOrder: 1,
      serviceType: 'Walk',
      vehicleType: 'Walk',
      startLocation: start,
      endLocation: bounceLocation,
      distance: 0.3,
      estimatedTime: 4,
      segmentFare: 0
    });

    // Segment 2: Bounce Scooter (main ride)
    const bounceDistance = totalDistance * 0.5;
    const bounceTime = Math.round(bounceDistance * 3.5);
    const bounceFare = 10 + (bounceDistance * 3);
    const nearEnd = await getIntermediateLocation(start, end);
    
    segments.push({
      segmentOrder: 2,
      serviceType: 'Bounce',
      vehicleType: 'Scooter',
      startLocation: bounceLocation,
      endLocation: nearEnd,
      distance: parseFloat(bounceDistance.toFixed(2)),
      estimatedTime: bounceTime,
      segmentFare: parseFloat(bounceFare.toFixed(2))
    });

    // Segment 3: Ola Auto or Rapido Bike to final destination
    const finalDistance = totalDistance - 0.3 - bounceDistance;
    const finalTime = Math.round(baseTime * 0.2);
    let finalService, finalVehicle, finalFare;
    
    if (finalDistance < 2) {
      // Short final leg - Rapido Bike
      finalService = 'Rapido';
      finalVehicle = 'Bike';
      finalFare = 15 + (finalDistance * 8);
    } else {
      // Longer final leg - Ola Auto
      finalService = 'Ola';
      finalVehicle = 'Auto';
      finalFare = 25 + (finalDistance * 10);
    }
    
    segments.push({
      segmentOrder: 3,
      serviceType: finalService,
      vehicleType: finalVehicle,
      startLocation: nearEnd,
      endLocation: end,
      distance: parseFloat(finalDistance.toFixed(2)),
      estimatedTime: finalTime,
      segmentFare: parseFloat(finalFare.toFixed(2))
    });
  } else {
    // Direct route if no Bounce center or short distance
    // Choose between Ola Auto and Uber Auto based on distance
    let serviceType, vehicleType, fare;
    
    if (totalDistance < 4) {
      // Short distance - Ola Auto
      serviceType = 'Ola';
      vehicleType = 'Auto';
      fare = 30 + (totalDistance * 12);
    } else if (totalDistance < 8) {
      // Medium distance - Uber Auto
      serviceType = 'Uber';
      vehicleType = 'Auto';
      fare = 35 + (totalDistance * 11);
    } else {
      // Long distance - Namma Yatri Auto
      serviceType = 'Namma Yatri';
      vehicleType = 'Auto';
      fare = 40 + (totalDistance * 10);
    }
    
    segments.push({
      segmentOrder: 1,
      serviceType: serviceType,
      vehicleType: vehicleType,
      startLocation: start,
      endLocation: end,
      distance: parseFloat(totalDistance.toFixed(2)),
      estimatedTime: baseTime,
      segmentFare: parseFloat(fare.toFixed(2))
    });
  }

  return segments;
}

// Helper: Calculate Fastest Route (Direct Rapido Bike or Uber Cab based on distance)
async function calculateFastestRoute(start, end, distance, time) {
  const segments = [];
  
  // Choose service based on distance
  let serviceType, vehicleType, fare;
  
  if (distance < 5) {
    // Short distance - Rapido Bike (fastest for short distances)
    serviceType = 'Rapido';
    vehicleType = 'Bike';
    fare = 20 + (distance * 8) + (time * 0.5);
  } else if (distance < 10) {
    // Medium distance - Uber Cab
    serviceType = 'Uber';
    vehicleType = 'Cab';
    fare = 40 + (distance * 12) + (time * 0.8);
  } else {
    // Long distance - Ola Cab
    serviceType = 'Ola';
    vehicleType = 'Cab';
    fare = 50 + (distance * 11) + (time * 0.7);
  }
  
  segments.push({
    segmentOrder: 1,
    serviceType: serviceType,
    vehicleType: vehicleType,
    startLocation: start,
    endLocation: end,
    distance: parseFloat(distance.toFixed(2)),
    estimatedTime: time,
    segmentFare: parseFloat(fare.toFixed(2))
  });

  return segments;
}

// Helper: Calculate Cheapest Route (Bus or Bus + Walk)
async function calculateCheapestRoute(start, end, distance, time) {
  const segments = [];
  
  // Check if bus route available
  const [busRoutes] = await pool.query(
    'SELECT RouteNumber, Fare, EstimatedTime FROM BusRoute WHERE StartLocation = ? AND EndLocation = ? LIMIT 1',
    [start, end]
  );

  if (busRoutes.length > 0) {
    // Direct bus available
    segments.push({
      segmentOrder: 1,
      serviceType: 'BMTC',
      vehicleType: 'Bus',
      startLocation: start,
      endLocation: end,
      distance: parseFloat(distance.toFixed(2)),
      estimatedTime: busRoutes[0].EstimatedTime,
      segmentFare: parseFloat(busRoutes[0].Fare)
    });
  } else {
    // Bus + Walk combination
    const busDistance = distance * 0.92;
    const busFare = 5 + (busDistance * 1.5);
    const busTime = Math.round(time * 0.85);
    const nearEnd = await getIntermediateLocation(start, end);
    
    segments.push({
      segmentOrder: 1,
      serviceType: 'BMTC',
      vehicleType: 'Bus',
      startLocation: start,
      endLocation: nearEnd,
      distance: parseFloat(busDistance.toFixed(2)),
      estimatedTime: busTime,
      segmentFare: parseFloat(busFare.toFixed(2))
    });

    // Walk remaining
    segments.push({
      segmentOrder: 2,
      serviceType: 'Walk',
      vehicleType: 'Walk',
      startLocation: nearEnd,
      endLocation: end,
      distance: parseFloat((distance - busDistance).toFixed(2)),
      estimatedTime: Math.round(time * 0.15),
      segmentFare: 0
    });
  }

  return segments;
}

// Helper: Get intermediate location name
async function getIntermediateLocation(start, end) {
  const locations = ['Jayanagar', 'Basavanagudi', 'BTM Layout', 'Koramangala', 'Indiranagar'];
  return locations[Math.floor(Math.random() * locations.length)];
}

// Create booking with segments
router.post('/create-booking', async (req, res) => {
  const connection = await pool.getConnection();
  try {
    await connection.beginTransaction();

    const { userId, startLocation, endLocation, routeOption, offerData } = req.body;

    console.log('Creating booking:', { userId, startLocation, endLocation, routeOption, offerData });

    // Prepare discount information
    const offerCode = offerData?.offerCode || null;
    const discountPercentage = offerData?.discountPercentage || null;
    const discountAmount = offerData?.discountAmount || 0;
    const originalFare = offerData?.originalAmount || routeOption.totalFare;
    const finalFare = offerData?.finalAmount || routeOption.totalFare;

    console.log('💰 Booking amounts:', {
      original: originalFare,
      discount: discountAmount,
      final: finalFare,
      offer: offerCode
    });

    // Create main booking with discount information
    console.log('📝 Calling CreateMultiModalBooking stored procedure...');
    const [bookingResult] = await connection.query(
      `CALL CreateMultiModalBooking(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        userId,
        startLocation,
        endLocation,
        routeOption.totalDistance,
        routeOption.totalTime,
        finalFare,  // Use final fare (after discount)
        routeOption.routeType,
        routeOption.isMultiModal,
        routeOption.segments.length,
        offerCode,
        discountPercentage,
        discountAmount,
        originalFare
      ]
    );

    console.log('📊 Booking result:', bookingResult);
    
    // Extract BookingID from the stored procedure result
    let bookingId = null;
    
    if (bookingResult && bookingResult.length > 0) {
      // Check different possible result structures
      if (bookingResult[0][0] && bookingResult[0][0].BookingID) {
        bookingId = bookingResult[0][0].BookingID;
      } else if (bookingResult[0].BookingID) {
        bookingId = bookingResult[0].BookingID;
      }
    }

    // If stored procedure didn't return BookingID, get it manually
    if (!bookingId) {
      console.log('⚠️ Stored procedure did not return BookingID, fetching manually...');
      const [lastBooking] = await connection.query(
        `SELECT BookingID FROM Booking 
         WHERE UserID = ? 
         ORDER BY BookingTime DESC 
         LIMIT 1`,
        [userId]
      );
      
      if (lastBooking && lastBooking.length > 0) {
        bookingId = lastBooking[0].BookingID;
        console.log('✅ Found BookingID manually:', bookingId);
      }
    }

    // Validate bookingId exists
    if (!bookingId) {
      throw new Error('Failed to retrieve BookingID after creating booking');
    }

    console.log(`✅ Main booking created with ID: ${bookingId}`);

    // Add each segment
    console.log(`📦 Adding ${routeOption.segments.length} segments...`);
    for (const segment of routeOption.segments) {
      console.log(`  Adding segment ${segment.segmentOrder}: ${segment.serviceType} ${segment.vehicleType}`);
      
      await connection.query(
        `CALL AddBookingSegment(?, ?, ?, ?, ?, ?, ?, ?, ?)`,
        [
          bookingId,  // Now this should NOT be NULL
          segment.segmentOrder,
          segment.serviceType,
          segment.vehicleType,
          segment.startLocation,
          segment.endLocation,
          segment.distance,
          segment.estimatedTime,
          segment.segmentFare
        ]
      );
      
      console.log(`  ✓ Segment ${segment.segmentOrder} added successfully`);
    }

    await connection.commit();
    console.log(`✅ Booking ${bookingId} created successfully with ${routeOption.segments.length} segments`);

    // Check if triggers created notifications (wait a moment for triggers to fire)
    await new Promise(resolve => setTimeout(resolve, 100));
    
    const [existingNotifications] = await connection.query(
      'SELECT COUNT(*) as count FROM Notification WHERE UserID = ? AND Message LIKE ?',
      [userId, `%booking #${bookingId}%`]
    );

    const triggersFired = existingNotifications[0].count > 0;
    console.log(`Triggers fired: ${triggersFired ? 'YES ✅' : 'NO ❌'}`);

    // Only create notifications manually if triggers didn't fire
    if (!triggersFired) {
      console.log('⚠️ Triggers not active - creating notifications manually');
      try {
        const notificationMessage = `Your booking #${bookingId} has been confirmed! Total Fare: ₹${finalFare}. ${
          routeOption.isMultiModal 
            ? `Multi-modal journey with ${routeOption.segments.length} segments.` 
            : 'Single vehicle journey.'
        }`;
        
        await connection.query(
          'INSERT INTO Notification (UserID, Message, NotificationType, Status) VALUES (?, ?, ?, ?)',
          [userId, notificationMessage, 'Booking', 'Pending']
        );
        console.log(`📬 Booking notification created manually for user ${userId}`);

        // Create vehicle change notifications for multi-modal bookings
        if (routeOption.isMultiModal && routeOption.segments.length > 1) {
          for (let i = 1; i < routeOption.segments.length; i++) {
            const segment = routeOption.segments[i];
            const vehicleChangeMessage = `🚗 Vehicle Change Alert! Segment ${segment.segmentOrder}: Switch to ${segment.serviceType} ${segment.vehicleType} at ${segment.startLocation}`;
            
            await connection.query(
              'INSERT INTO Notification (UserID, Message, NotificationType, Status) VALUES (?, ?, ?, ?)',
              [userId, vehicleChangeMessage, 'VehicleChange', 'Pending']
            );
            console.log(`📬 Vehicle change notification created manually for segment ${segment.segmentOrder}`);
          }
        }
      } catch (notifError) {
        console.error('Error creating notifications manually:', notifError);
        // Don't fail the booking if notification creation fails
      }
    } else {
      console.log('✅ Triggers created notifications automatically - skipping manual creation');
    }

    // Get complete booking with segments
    const [bookingDetails] = await connection.query(
      `SELECT b.*, 
              (SELECT JSON_ARRAYAGG(
                JSON_OBJECT(
                  'segmentOrder', bs.SegmentOrder,
                  'serviceType', bs.ServiceType,
                  'vehicleType', bs.VehicleType,
                  'startLocation', bs.StartLocation,
                  'endLocation', bs.EndLocation,
                  'distance', bs.Distance,
                  'estimatedTime', bs.EstimatedTime,
                  'segmentFare', bs.SegmentFare,
                  'vehicleNumber', bs.VehicleNumber,
                  'vehicleModel', bs.VehicleModel,
                  'providerName', bs.ProviderName
                )
              ) FROM BookingSegment bs WHERE bs.BookingID = b.BookingID) as segments
       FROM Booking b WHERE b.BookingID = ?`,
      [bookingId]
    );

    // Format booking data to match frontend expectations
    const formattedBooking = {
      id: bookingId,
      userId: userId,
      startLocation: startLocation,
      endLocation: endLocation,
      totalDistance: routeOption.totalDistance,
      totalTime: routeOption.totalTime,
      totalFare: finalFare,
      originalFare: originalFare,
      discountAmount: discountAmount,
      offerCode: offerCode,
      selectedRouteType: routeOption.routeType,
      status: 'Confirmed',
      bookingTime: new Date().toISOString(),
      isMultiModal: routeOption.isMultiModal,
      segmentCount: routeOption.segments.length,
      segments: routeOption.segments
    };

    console.log('Returning booking:', {
      id: formattedBooking.id,
      userId: formattedBooking.userId,
      route: `${formattedBooking.startLocation} → ${formattedBooking.endLocation}`,
      fare: formattedBooking.totalFare
    });

    res.json({
      success: true,
      bookingId,
      booking: formattedBooking
    });

  } catch (error) {
    await connection.rollback();
    console.error('❌ Error creating booking:', error);
    console.error('Error details:', error.message);
    console.error('Error code:', error.code);
    console.error('Error stack:', error.stack);
    res.status(500).json({ 
      error: 'Failed to create booking',
      details: error.message,
      code: error.code
    });
  } finally {
    connection.release();
  }
});

// Get user bookings with segments
router.get('/user/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    console.log(`\n=== Fetching bookings for user ${userId} ===`);

    const [bookings] = await pool.query(
      `SELECT 
        b.BookingID,
        b.UserID,
        b.StartLocation,
        b.EndLocation,
        b.TotalDistance,
        b.TotalTime,
        b.TotalFare,
        b.OriginalFare,
        b.DiscountAmount,
        b.OfferCode,
        b.DiscountPercentage,
        b.RouteType,
        b.BookingStatus,
        b.BookingTime,
        b.IsMultiModal,
        b.SegmentCount,
        (SELECT JSON_ARRAYAGG(
          JSON_OBJECT(
            'segmentOrder', bs.SegmentOrder,
            'serviceType', bs.ServiceType,
            'vehicleType', bs.VehicleType,
            'startLocation', bs.StartLocation,
            'endLocation', bs.EndLocation,
            'distance', bs.Distance,
            'estimatedTime', bs.EstimatedTime,
            'segmentFare', bs.SegmentFare,
            'vehicleNumber', bs.VehicleNumber,
            'vehicleModel', bs.VehicleModel,
            'providerName', bs.ProviderName
          )
        ) FROM BookingSegment bs WHERE bs.BookingID = b.BookingID ORDER BY bs.SegmentOrder) as segments
       FROM Booking b 
       WHERE b.UserID = ? 
       ORDER BY b.BookingTime DESC`,
      [userId]
    );

    console.log(`Found ${bookings.length} bookings in database`);
    if (bookings.length > 0) {
      console.log('First booking:', {
        id: bookings[0].BookingID,
        start: bookings[0].StartLocation,
        end: bookings[0].EndLocation,
        fare: bookings[0].TotalFare,
        segmentsType: typeof bookings[0].segments,
        segments: bookings[0].segments
      });
    }

    // Format bookings to match frontend expectations
    const formattedBookings = bookings.map(booking => {
      // Check if segments is already an object or a string
      let parsedSegments = [];
      if (booking.segments) {
        if (typeof booking.segments === 'string') {
          parsedSegments = JSON.parse(booking.segments);
        } else if (Array.isArray(booking.segments)) {
          parsedSegments = booking.segments;
        } else {
          // It's an object, might need to be converted
          parsedSegments = booking.segments;
        }
      }

      return {
        id: booking.BookingID,
        userId: booking.UserID,
        startLocation: booking.StartLocation,
        endLocation: booking.EndLocation,
        totalDistance: booking.TotalDistance,
        totalTime: booking.TotalTime,
        totalFare: booking.TotalFare,
        originalFare: booking.OriginalFare,
        discountAmount: booking.DiscountAmount,
        offerCode: booking.OfferCode,
        discountPercentage: booking.DiscountPercentage,
        selectedRouteType: booking.RouteType,
        status: booking.BookingStatus,
        bookingTime: booking.BookingTime,
        isMultiModal: booking.IsMultiModal,
        segmentCount: booking.SegmentCount,
        segments: parsedSegments
      };
    });

    console.log(`Returning ${formattedBookings.length} formatted bookings`);
    console.log('=== End fetch bookings ===\n');
    res.json(formattedBookings);
  } catch (error) {
    console.error('Error fetching bookings:', error);
    console.error('Error stack:', error.stack);
    res.status(500).json({ error: 'Failed to fetch bookings' });
  }
});

export default router;