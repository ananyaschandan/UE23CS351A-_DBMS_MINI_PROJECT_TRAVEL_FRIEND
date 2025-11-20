-- =====================================================
-- FILE 10: VIEWS (Database Views for Easy Queries)
-- =====================================================
-- Views from old DATABASE_COMPLETE.sql:
-- - AvailableVehicles
-- - BookingDetails
-- =====================================================

USE TransportBookingSystem;

-- =====================================================
-- VIEW 1: AVAILABLE VEHICLES WITH PROVIDER DETAILS
-- =====================================================

CREATE OR REPLACE VIEW AvailableVehicles AS
SELECT 
    v.VehicleID,
    v.VehicleNumber,
    v.Model,
    v.VehicleType,
    v.Capacity,
    v.HourlyRate,
    v.TotalRides,
    v.TotalEarnings,
    sp.ProviderType,
    sp.Rating AS ProviderRating,
    u.FullName AS ProviderName,
    u.Phone AS ProviderPhone,
    u.Email AS ProviderEmail
FROM Vehicle v
JOIN ServiceProvider sp ON v.ProviderID = sp.ProviderID
JOIN User u ON sp.UserID = u.UserID
WHERE v.IsAvailable = TRUE 
  AND sp.IsApproved = TRUE
  AND u.IsActive = TRUE
ORDER BY sp.Rating DESC, v.TotalRides ASC;

-- =====================================================
-- VIEW 2: BOOKING DETAILS WITH ALL INFORMATION
-- =====================================================

CREATE OR REPLACE VIEW BookingDetails AS
SELECT 
    b.BookingID,
    b.StartLocation,
    b.EndLocation,
    b.TotalDistance,
    b.TotalTime,
    b.RouteType,
    b.TotalFare,
    b.BookingStatus,
    b.BookingTime,
    b.CompletedAt,
    b.IsMultiModal,
    b.SegmentCount,
    u.UserID,
    u.FullName AS UserName,
    u.Phone AS UserPhone,
    u.Email AS UserEmail,
    -- Get first segment details (for single-vehicle bookings)
    (SELECT bs.ServiceType FROM BookingSegment bs WHERE bs.BookingID = b.BookingID ORDER BY bs.SegmentOrder LIMIT 1) AS PrimaryServiceType,
    (SELECT bs.VehicleType FROM BookingSegment bs WHERE bs.BookingID = b.BookingID ORDER BY bs.SegmentOrder LIMIT 1) AS PrimaryVehicleType,
    (SELECT bs.VehicleNumber FROM BookingSegment bs WHERE bs.BookingID = b.BookingID ORDER BY bs.SegmentOrder LIMIT 1) AS PrimaryVehicleNumber,
    (SELECT bs.ProviderName FROM BookingSegment bs WHERE bs.BookingID = b.BookingID ORDER BY bs.SegmentOrder LIMIT 1) AS PrimaryProviderName
FROM Booking b
JOIN User u ON b.UserID = u.UserID
ORDER BY b.BookingTime DESC;

-- =====================================================
-- VIEW 3: PROVIDER EARNINGS SUMMARY
-- =====================================================

CREATE OR REPLACE VIEW ProviderEarningsSummary AS
SELECT 
    sp.ProviderID,
    u.FullName AS ProviderName,
    u.Email AS ProviderEmail,
    u.Phone AS ProviderPhone,
    sp.ProviderType,
    sp.Rating,
    sp.TotalRides,
    sp.TotalEarnings,
    COUNT(DISTINCT v.VehicleID) AS TotalVehicles,
    SUM(v.TotalRides) AS VehicleTotalRides,
    SUM(v.TotalEarnings) AS VehicleTotalEarnings,
    ROUND(sp.TotalEarnings / NULLIF(sp.TotalRides, 0), 2) AS AvgEarningsPerRide
FROM ServiceProvider sp
JOIN User u ON sp.UserID = u.UserID
LEFT JOIN Vehicle v ON sp.ProviderID = v.ProviderID
WHERE sp.IsApproved = TRUE
GROUP BY sp.ProviderID, u.FullName, u.Email, u.Phone, sp.ProviderType, sp.Rating, sp.TotalRides, sp.TotalEarnings
ORDER BY sp.TotalEarnings DESC;

-- =====================================================
-- VIEW 4: USER BOOKING HISTORY
-- =====================================================

CREATE OR REPLACE VIEW UserBookingHistory AS
SELECT 
    u.UserID,
    u.FullName AS UserName,
    u.Email,
    COUNT(b.BookingID) AS TotalBookings,
    SUM(CASE WHEN b.BookingStatus = 'Completed' THEN 1 ELSE 0 END) AS CompletedBookings,
    SUM(CASE WHEN b.BookingStatus = 'Cancelled' THEN 1 ELSE 0 END) AS CancelledBookings,
    SUM(CASE WHEN b.BookingStatus = 'InProgress' THEN 1 ELSE 0 END) AS InProgressBookings,
    SUM(b.TotalFare) AS TotalSpent,
    ROUND(AVG(b.TotalFare), 2) AS AvgFarePerBooking,
    SUM(b.TotalDistance) AS TotalDistanceTraveled,
    MAX(b.BookingTime) AS LastBookingDate
FROM User u
LEFT JOIN Booking b ON u.UserID = b.UserID
WHERE u.IsProvider = FALSE
GROUP BY u.UserID, u.FullName, u.Email
ORDER BY TotalSpent DESC;

-- =====================================================
-- VIEW 5: MULTI-MODAL BOOKING SEGMENTS
-- =====================================================

CREATE OR REPLACE VIEW MultiModalBookingSegments AS
SELECT 
    b.BookingID,
    b.StartLocation AS BookingStart,
    b.EndLocation AS BookingEnd,
    b.RouteType,
    b.TotalFare AS BookingTotalFare,
    b.IsMultiModal,
    bs.SegmentID,
    bs.SegmentOrder,
    bs.ServiceType,
    bs.VehicleType,
    bs.StartLocation AS SegmentStart,
    bs.EndLocation AS SegmentEnd,
    bs.Distance AS SegmentDistance,
    bs.EstimatedTime AS SegmentTime,
    bs.SegmentFare,
    bs.VehicleNumber,
    bs.VehicleModel,
    bs.ProviderName,
    bs.ProviderPhone,
    u.FullName AS UserName,
    u.Email AS UserEmail
FROM Booking b
JOIN BookingSegment bs ON b.BookingID = bs.BookingID
JOIN User u ON b.UserID = u.UserID
WHERE b.IsMultiModal = TRUE
ORDER BY b.BookingID, bs.SegmentOrder;

-- =====================================================
-- VIEW 6: ROUTE POPULARITY
-- =====================================================

CREATE OR REPLACE VIEW RoutePopularity AS
SELECT 
    b.StartLocation,
    b.EndLocation,
    COUNT(*) AS TotalBookings,
    SUM(CASE WHEN b.RouteType = 'Shortest' THEN 1 ELSE 0 END) AS ShortestCount,
    SUM(CASE WHEN b.RouteType = 'Fastest' THEN 1 ELSE 0 END) AS FastestCount,
    SUM(CASE WHEN b.RouteType = 'Cheapest' THEN 1 ELSE 0 END) AS CheapestCount,
    ROUND(AVG(b.TotalFare), 2) AS AvgFare,
    ROUND(AVG(b.TotalDistance), 2) AS AvgDistance,
    ROUND(AVG(b.TotalTime), 2) AS AvgTime
FROM Booking b
GROUP BY b.StartLocation, b.EndLocation
HAVING COUNT(*) > 0
ORDER BY TotalBookings DESC;

-- =====================================================
-- VIEW 7: VEHICLE PERFORMANCE
-- =====================================================

CREATE OR REPLACE VIEW VehiclePerformance AS
SELECT 
    v.VehicleID,
    v.VehicleNumber,
    v.Model,
    v.VehicleType,
    v.IsAvailable,
    v.TotalRides,
    v.TotalEarnings,
    sp.ProviderType,
    sp.Rating AS ProviderRating,
    u.FullName AS ProviderName,
    ROUND(v.TotalEarnings / NULLIF(v.TotalRides, 0), 2) AS AvgEarningsPerRide,
    COUNT(DISTINCT bs.BookingID) AS SegmentBookings
FROM Vehicle v
JOIN ServiceProvider sp ON v.ProviderID = sp.ProviderID
JOIN User u ON sp.UserID = u.UserID
LEFT JOIN BookingSegment bs ON v.VehicleID = bs.VehicleID
GROUP BY v.VehicleID, v.VehicleNumber, v.Model, v.VehicleType, v.IsAvailable, 
         v.TotalRides, v.TotalEarnings, sp.ProviderType, sp.Rating, u.FullName
ORDER BY v.TotalEarnings DESC;

-- =====================================================
-- VIEW 8: BOUNCE CENTER USAGE
-- =====================================================

CREATE OR REPLACE VIEW BounceCenterUsage AS
SELECT 
    bc.CenterID,
    bc.CenterName,
    bc.Location,
    bc.Area,
    bc.AvailableScooters,
    COUNT(DISTINCT bs.BookingID) AS TotalBookingsFromCenter,
    SUM(bs.SegmentFare) AS TotalRevenueFromCenter
FROM BounceCenter bc
LEFT JOIN BookingSegment bs ON bs.StartLocation LIKE CONCAT('%', bc.CenterName, '%')
    AND bs.ServiceType = 'Bounce'
WHERE bc.IsActive = TRUE
GROUP BY bc.CenterID, bc.CenterName, bc.Location, bc.Area, bc.AvailableScooters
ORDER BY TotalBookingsFromCenter DESC;

SELECT '✅ Views created successfully!' AS Status;
SELECT 'Views: AvailableVehicles, BookingDetails, ProviderEarningsSummary, UserBookingHistory, MultiModalBookingSegments, RoutePopularity, VehiclePerformance, BounceCenterUsage' AS Info;

-- Test views
SELECT 'Testing AvailableVehicles view:' AS Test;
SELECT COUNT(*) AS AvailableVehicleCount FROM AvailableVehicles;

SELECT 'Testing BookingDetails view:' AS Test;
SELECT COUNT(*) AS TotalBookingsInView FROM BookingDetails;

SELECT 'Testing ProviderEarningsSummary view:' AS Test;
SELECT COUNT(*) AS TotalProviders FROM ProviderEarningsSummary;
