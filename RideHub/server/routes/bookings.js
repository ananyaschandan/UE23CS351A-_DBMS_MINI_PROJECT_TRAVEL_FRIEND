import express from 'express';
import { pool } from '../config/database.js';

const router = express.Router();

// Create a new booking with vehicle assignment
router.post('/confirm', async (req, res) => {
  try {
    const { userId, startLocation, endLocation, routeType, estimatedFare, distance, estimatedTime, serviceType, vehicleType } = req.body;

    if (!userId || !startLocation || !endLocation || !routeType || !estimatedFare) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    // Use stored procedure to create booking with vehicle assignment
    const [result] = await pool.query(
      `CALL CreateConfirmedBooking(?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        userId, 
        startLocation, 
        endLocation, 
        distance || 5.0, 
        estimatedTime || 20, 
        estimatedFare, 
        routeType, 
        serviceType || 'Individual', 
        vehicleType || 'Auto'
      ]
    );

    const bookingInfo = result[0][0];
    
    // Get vehicle and provider details
    let vehicleDetails = null;
    if (bookingInfo.VehicleID) {
      const [vehicles] = await pool.query(
        `SELECT 
          v.VehicleID, v.VehicleNumber, v.Model, v.VehicleType,
          sp.ProviderType, sp.Rating,
          u.FullName as ProviderName, u.Phone as ProviderPhone
        FROM Vehicle v
        JOIN ServiceProvider sp ON v.ProviderID = sp.ProviderID
        JOIN User u ON sp.UserID = u.UserID
        WHERE v.VehicleID = ?`,
        [bookingInfo.VehicleID]
      );
      
      if (vehicles.length > 0) {
        vehicleDetails = vehicles[0];
      }
    }

    res.status(201).json({
      bookingId: bookingInfo.BookingID,
      status: 'Confirmed',
      message: 'Booking confirmed successfully!',
      vehicleDetails: vehicleDetails ? {
        vehicleNumber: vehicleDetails.VehicleNumber,
        model: vehicleDetails.Model,
        vehicleType: vehicleDetails.VehicleType,
        providerName: vehicleDetails.ProviderName,
        providerPhone: vehicleDetails.ProviderPhone,
        providerType: vehicleDetails.ProviderType,
        rating: vehicleDetails.Rating
      } : null
    });
  } catch (error) {
    console.error('Error creating booking:', error);
    res.status(500).json({ error: 'Failed to create booking', details: error.message });
  }
});

// Get user's bookings with vehicle details
router.get('/user/:userId', async (req, res) => {
  try {
    const { userId } = req.params;

    const [bookings] = await pool.query(
      `SELECT 
        b.BookingID as id,
        b.StartLocation as startLocation,
        b.EndLocation as endLocation,
        b.Distance as distance,
        b.RouteType as selectedRouteType,
        b.ServiceType as serviceType,
        b.VehicleType as vehicleType,
        b.TotalFare as totalFare,
        b.BookingStatus as status,
        b.BookingTime as bookingTime,
        v.VehicleNumber as vehicleNumber,
        v.Model as vehicleModel,
        sp.ProviderType as providerType,
        sp.Rating as providerRating,
        u.FullName as providerName,
        u.Phone as providerPhone
      FROM Booking b
      LEFT JOIN Vehicle v ON b.VehicleID = v.VehicleID
      LEFT JOIN ServiceProvider sp ON b.ProviderID = sp.ProviderID
      LEFT JOIN User u ON sp.UserID = u.UserID
      WHERE b.UserID = ?
      ORDER BY b.BookingTime DESC`,
      [userId]
    );

    // Format bookings with provider details
    const formattedBookings = bookings.map(booking => ({
      id: booking.id,
      startLocation: booking.startLocation,
      endLocation: booking.endLocation,
      distance: booking.distance,
      selectedRouteType: booking.selectedRouteType,
      serviceType: booking.serviceType,
      vehicleType: booking.vehicleType,
      totalFare: booking.totalFare,
      status: booking.status,
      bookingTime: booking.bookingTime,
      providerDetails: {
        name: booking.providerName || 'Assigned Driver',
        phone: booking.providerPhone || 'N/A',
        vehicleNumber: booking.vehicleNumber || 'N/A',
        model: booking.vehicleModel || 'N/A',
        providerType: booking.providerType || booking.serviceType,
        rating: booking.providerRating || 4.5
      }
    }));

    res.json(formattedBookings);
  } catch (error) {
    console.error('Error fetching bookings:', error);
    res.status(500).json({ error: 'Failed to fetch bookings' });
  }
});

// Update booking status
router.patch('/:bookingId/status', async (req, res) => {
  try {
    const { bookingId } = req.params;
    const { status } = req.body;

    if (!['Pending', 'Confirmed', 'InProgress', 'Completed', 'Cancelled'].includes(status)) {
      return res.status(400).json({ error: 'Invalid status' });
    }

    // If completing booking, use stored procedure to update earnings
    if (status === 'Completed') {
      await pool.query('CALL CompleteBooking(?)', [bookingId]);
    } else {
      await pool.query(
        'UPDATE Booking SET BookingStatus = ? WHERE BookingID = ?',
        [status, bookingId]
      );
    }

    res.json({ message: 'Booking status updated successfully', status });
  } catch (error) {
    console.error('Error updating booking status:', error);
    res.status(500).json({ error: 'Failed to update booking status' });
  }
});

// Get provider bookings and earnings
router.get('/provider/:providerId', async (req, res) => {
  try {
    const { providerId } = req.params;

    const [bookings] = await pool.query(
      `SELECT 
        b.BookingID as id,
        b.StartLocation as startLocation,
        b.EndLocation as endLocation,
        b.Distance as distance,
        b.TotalFare as totalFare,
        b.BookingStatus as status,
        b.BookingTime as bookingTime,
        b.CompletedAt as completedAt,
        ROUND(b.TotalFare * 0.80, 2) as providerEarning,
        u.FullName as userName,
        u.Phone as userPhone,
        v.VehicleNumber as vehicleNumber,
        v.Model as vehicleModel
      FROM Booking b
      JOIN User u ON b.UserID = u.UserID
      LEFT JOIN Vehicle v ON b.VehicleID = v.VehicleID
      WHERE b.ProviderID = ?
      ORDER BY b.BookingTime DESC`,
      [providerId]
    );

    // Get provider stats
    const [stats] = await pool.query(
      `SELECT 
        TotalRides,
        TotalEarnings,
        Rating
      FROM ServiceProvider
      WHERE ProviderID = ?`,
      [providerId]
    );

    res.json({
      bookings,
      stats: stats[0] || { TotalRides: 0, TotalEarnings: 0, Rating: 4.5 }
    });
  } catch (error) {
    console.error('Error fetching provider bookings:', error);
    res.status(500).json({ error: 'Failed to fetch provider bookings' });
  }
});

// Cancel/Delete booking
router.delete('/:bookingId', async (req, res) => {
  try {
    const { bookingId } = req.params;

    // Update status to Cancelled instead of hard delete (keeps history)
    await pool.query(
      'UPDATE Booking SET BookingStatus = ? WHERE BookingID = ?',
      ['Cancelled', bookingId]
    );

    res.json({ message: 'Booking cancelled successfully', status: 'Cancelled' });
  } catch (error) {
    console.error('Error cancelling booking:', error);
    res.status(500).json({ error: 'Failed to cancel booking', details: error.message });
  }
});

export default router;
