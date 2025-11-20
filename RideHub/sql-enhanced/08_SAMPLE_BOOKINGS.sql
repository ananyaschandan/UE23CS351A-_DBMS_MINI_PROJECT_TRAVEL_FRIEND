-- =====================================================
-- FILE 8: SAMPLE MULTI-MODAL BOOKINGS
-- =====================================================
-- Demonstrates Shortest, Fastest, Cheapest routes
-- =====================================================

USE TransportBookingSystem;

-- =====================================================
-- EXAMPLE 1: SHORTEST ROUTE (Multi-modal)
-- Majestic to Koramangala - 9.2 km, 40 min, ₹95
-- Segments: Walk to Bounce + Bounce Scooter + Rapido Bike
-- =====================================================

CALL CreateMultiModalBooking(
    1,  -- UserID (John)
    'Majestic',
    'Koramangala',
    9.2,  -- Total distance
    40,   -- Total time
    95.00,  -- Total fare
    'Shortest',
    TRUE,  -- IsMultiModal
    3      -- SegmentCount
);

-- Segment 1: Walk to Bounce Center (0.3 km, 4 min, ₹0)
CALL AddBookingSegment(
    LAST_INSERT_ID(),  -- BookingID
    1,  -- SegmentOrder
    'Walk',
    'Walk',
    'Majestic',
    'Majestic Bounce Hub',
    0.3,
    4,
    0.00
);

-- Segment 2: Bounce Scooter (5.0 km, 18 min, ₹25)
CALL AddBookingSegment(
    LAST_INSERT_ID() - 2,  -- BookingID
    2,
    'Bounce',
    'Scooter',
    'Majestic Bounce Hub',
    'Jayanagar',
    5.0,
    18,
    25.00
);

-- Segment 3: Rapido Bike (3.9 km, 18 min, ₹70)
CALL AddBookingSegment(
    LAST_INSERT_ID() - 4,  -- BookingID
    3,
    'Rapido',
    'Bike',
    'Jayanagar',
    'Koramangala',
    3.9,
    18,
    70.00
);

-- =====================================================
-- EXAMPLE 2: FASTEST ROUTE (Multi-modal)
-- Majestic to MG Road - 3.2 km, 12 min, ₹145
-- Segments: Rapido Bike (fastest single vehicle)
-- =====================================================

CALL CreateMultiModalBooking(
    2,  -- UserID (Jane)
    'Majestic',
    'MG Road',
    3.2,
    12,
    145.00,
    'Fastest',
    FALSE,  -- Single vehicle
    1
);

CALL AddBookingSegment(
    LAST_INSERT_ID(),
    1,
    'Rapido',
    'Bike',
    'Majestic',
    'MG Road',
    3.2,
    12,
    145.00
);

-- =====================================================
-- EXAMPLE 3: CHEAPEST ROUTE (Multi-modal)
-- Majestic to Jayanagar - 6.8 km, 38 min, ₹15
-- Segments: BMTC Bus (cheapest option)
-- =====================================================

CALL CreateMultiModalBooking(
    3,  -- UserID (Test User)
    'Majestic',
    'Jayanagar',
    6.5,
    35,
    15.00,
    'Cheapest',
    FALSE,
    1
);

CALL AddBookingSegment(
    LAST_INSERT_ID(),
    1,
    'BMTC',
    'Bus',
    'Majestic',
    'Jayanagar',
    6.5,
    35,
    15.00
);

-- =====================================================
-- EXAMPLE 4: SHORTEST with Uber Auto + Ola Cab
-- Majestic to JP Nagar - 7.8 km, 32 min, ₹165
-- =====================================================

CALL CreateMultiModalBooking(
    4,  -- UserID (Amit)
    'Majestic',
    'J.P. Nagar',
    7.8,
    32,
    165.00,
    'Shortest',
    TRUE,
    2
);

CALL AddBookingSegment(
    LAST_INSERT_ID(),
    1,
    'Uber',
    'Auto',
    'Majestic',
    'Jayanagar',
    4.5,
    18,
    75.00
);

CALL AddBookingSegment(
    LAST_INSERT_ID() - 1,
    2,
    'Ola',
    'Cab',
    'Jayanagar',
    'J.P. Nagar',
    3.3,
    14,
    90.00
);

-- =====================================================
-- EXAMPLE 5: FASTEST with Metro simulation
-- Majestic to Yeshwanthpur - 6.8 km, 18 min, ₹180
-- =====================================================

CALL CreateMultiModalBooking(
    5,  -- UserID (Priya)
    'Majestic',
    'Yeshwanthpur',
    6.8,
    18,
    180.00,
    'Fastest',
    FALSE,
    1
);

CALL AddBookingSegment(
    LAST_INSERT_ID(),
    1,
    'Uber',
    'Cab',
    'Majestic',
    'Yeshwanthpur',
    6.8,
    18,
    180.00
);

-- =====================================================
-- EXAMPLE 6: CHEAPEST with Bus + Walk
-- Majestic to Malleshwaram - 5.8 km, 35 min, ₹12
-- =====================================================

CALL CreateMultiModalBooking(
    6,  -- UserID (Rahul)
    'Majestic',
    'Malleshwaram',
    5.8,
    35,
    12.00,
    'Cheapest',
    TRUE,
    2
);

CALL AddBookingSegment(
    LAST_INSERT_ID(),
    1,
    'BMTC',
    'Bus',
    'Majestic',
    'Malleshwaram Main Road',
    5.5,
    30,
    12.00
);

CALL AddBookingSegment(
    LAST_INSERT_ID() - 1,
    2,
    'Walk',
    'Walk',
    'Malleshwaram Main Road',
    'Malleshwaram',
    0.3,
    5,
    0.00
);

-- Complete some bookings to update earnings
CALL CompleteBooking(1);
CALL CompleteBooking(3);
CALL CompleteBooking(5);

SELECT '✅ Sample bookings created!' AS Status;
SELECT CONCAT('Total Bookings: ', COUNT(*)) AS Info FROM Booking;
SELECT CONCAT('Total Segments: ', COUNT(*)) AS Info FROM BookingSegment;
SELECT CONCAT('Multi-modal Bookings: ', COUNT(*)) AS Info FROM Booking WHERE IsMultiModal = TRUE;

-- Show booking summary
SELECT 
    b.BookingID,
    u.FullName AS Customer,
    b.StartLocation,
    b.EndLocation,
    b.RouteType,
    CONCAT(b.TotalDistance, ' km') AS Distance,
    CONCAT(b.TotalTime, ' min') AS Time,
    CONCAT('₹', b.TotalFare) AS Fare,
    b.SegmentCount AS Segments,
    b.BookingStatus
FROM Booking b
JOIN User u ON b.UserID = u.UserID
ORDER BY b.BookingID;

-- Show segment details
SELECT 
    bs.BookingID,
    bs.SegmentOrder,
    bs.ServiceType,
    bs.VehicleType,
    bs.StartLocation,
    bs.EndLocation,
    CONCAT(bs.Distance, ' km') AS Distance,
    CONCAT(bs.EstimatedTime, ' min') AS Time,
    CONCAT('₹', bs.SegmentFare) AS Fare,
    bs.VehicleNumber
FROM BookingSegment bs
ORDER BY bs.BookingID, bs.SegmentOrder;
