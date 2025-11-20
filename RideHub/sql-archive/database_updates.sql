-- =====================================================
-- DATABASE UPDATES FOR GEOSPATIAL & ENHANCED FEATURES
-- =====================================================

USE TransportBookingSystem;

-- =====================================================
-- 1. ADD NEW COLUMNS (Without IF NOT EXISTS)
-- =====================================================

-- Add IsProvider flag to User table
ALTER TABLE User 
ADD COLUMN IsProvider BOOLEAN DEFAULT FALSE AFTER IsActive;

-- Add geospatial columns to Route table
ALTER TABLE Route 
ADD COLUMN StartPoint POINT NULL AFTER EndLocation,
ADD COLUMN EndPoint POINT NULL AFTER StartPoint;

-- Add Model column to Vehicle table
ALTER TABLE Vehicle 
ADD COLUMN Model VARCHAR(100) NULL AFTER VehicleType;

-- Add SelectedRouteType to Booking table
ALTER TABLE Booking 
ADD COLUMN SelectedRouteType ENUM('Shortest', 'Fastest', 'Cheapest') NULL AFTER EndLocation;

-- =====================================================
-- 2. CREATE PROVIDER DOCUMENTS TABLE
-- =====================================================

CREATE TABLE IF NOT EXISTS ProviderDocuments (
    DocumentID INT PRIMARY KEY AUTO_INCREMENT,
    ProviderID INT,
    DocumentType ENUM('ID_Proof', 'Vehicle_Registration', 'License', 'Partnership_Agreement') NOT NULL,
    DocumentURL VARCHAR(500),
    VerificationStatus ENUM('Pending', 'Approved', 'Rejected') DEFAULT 'Pending',
    UploadedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ProviderID) REFERENCES ServiceProvider(ProviderID) ON DELETE CASCADE
);

-- =====================================================
-- 3. CREATE SPATIAL INDEXES FOR GEOLOCATION
-- =====================================================

CREATE SPATIAL INDEX idx_startpoint ON Route(StartPoint);
CREATE SPATIAL INDEX idx_endpoint ON Route(EndPoint);

-- =====================================================
-- 4. UPDATE EXISTING ROUTES WITH REAL BANGALORE COORDINATES
-- =====================================================

-- Update Majestic to Lalbagh
UPDATE Route 
SET StartPoint = ST_GeomFromText('POINT(77.5733 12.9767)', 4326),
    EndPoint = ST_GeomFromText('POINT(77.5848 12.9507)', 4326),
    Distance = ROUND(ST_Distance_Sphere(
        ST_GeomFromText('POINT(77.5733 12.9767)', 4326),
        ST_GeomFromText('POINT(77.5848 12.9507)', 4326)
    ) / 1000, 2)
WHERE RouteName = 'Majestic to Lalbagh';

-- Update Majestic to Basavanagudi
UPDATE Route 
SET StartPoint = ST_GeomFromText('POINT(77.5733 12.9767)', 4326),
    EndPoint = ST_GeomFromText('POINT(77.5639 12.9395)', 4326),
    Distance = ROUND(ST_Distance_Sphere(
        ST_GeomFromText('POINT(77.5733 12.9767)', 4326),
        ST_GeomFromText('POINT(77.5639 12.9395)', 4326)
    ) / 1000, 2)
WHERE RouteName = 'Majestic to Basavanagudi';

-- Update Majestic to Jayanagar
UPDATE Route 
SET StartPoint = ST_GeomFromText('POINT(77.5733 12.9767)', 4326),
    EndPoint = ST_GeomFromText('POINT(77.5888 12.9243)', 4326),
    Distance = ROUND(ST_Distance_Sphere(
        ST_GeomFromText('POINT(77.5733 12.9767)', 4326),
        ST_GeomFromText('POINT(77.5888 12.9243)', 4326)
    ) / 1000, 2)
WHERE RouteName = 'Majestic to Jayanagar';

-- Update Majestic to J.P. Nagar
UPDATE Route 
SET StartPoint = ST_GeomFromText('POINT(77.5733 12.9767)', 4326),
    EndPoint = ST_GeomFromText('POINT(77.5842 12.9070)', 4326),
    Distance = ROUND(ST_Distance_Sphere(
        ST_GeomFromText('POINT(77.5733 12.9767)', 4326),
        ST_GeomFromText('POINT(77.5842 12.9070)', 4326)
    ) / 1000, 2)
WHERE RouteName = 'Majestic to J.P. Nagar';

-- Update Majestic to Rajajinagar
UPDATE Route 
SET StartPoint = ST_GeomFromText('POINT(77.5733 12.9767)', 4326),
    EndPoint = ST_GeomFromText('POINT(77.5553 13.0092)', 4326),
    Distance = ROUND(ST_Distance_Sphere(
        ST_GeomFromText('POINT(77.5733 12.9767)', 4326),
        ST_GeomFromText('POINT(77.5553 13.0092)', 4326)
    ) / 1000, 2)
WHERE RouteName = 'Majestic to Rajajinagar';

-- Update Majestic to Bengaluru Palace
UPDATE Route 
SET StartPoint = ST_GeomFromText('POINT(77.5733 12.9767)', 4326),
    EndPoint = ST_GeomFromText('POINT(77.5921 12.9983)', 4326),
    Distance = ROUND(ST_Distance_Sphere(
        ST_GeomFromText('POINT(77.5733 12.9767)', 4326),
        ST_GeomFromText('POINT(77.5921 12.9983)', 4326)
    ) / 1000, 2)
WHERE RouteName = 'Majestic to Bengaluru Palace';

-- Update Majestic to MG Road
UPDATE Route 
SET StartPoint = ST_GeomFromText('POINT(77.5733 12.9767)', 4326),
    EndPoint = ST_GeomFromText('POINT(77.5946 12.9716)', 4326),
    Distance = ROUND(ST_Distance_Sphere(
        ST_GeomFromText('POINT(77.5733 12.9767)', 4326),
        ST_GeomFromText('POINT(77.5946 12.9716)', 4326)
    ) / 1000, 2)
WHERE RouteName = 'Majestic to MG Road';

-- Update Majestic to ISKCON Temple
UPDATE Route 
SET StartPoint = ST_GeomFromText('POINT(77.5733 12.9767)', 4326),
    EndPoint = ST_GeomFromText('POINT(77.5516 13.0162)', 4326),
    Distance = ROUND(ST_Distance_Sphere(
        ST_GeomFromText('POINT(77.5733 12.9767)', 4326),
        ST_GeomFromText('POINT(77.5516 13.0162)', 4326)
    ) / 1000, 2)
WHERE RouteName = 'Majestic to ISKCON Temple';

-- Update Majestic to Malleshwaram
UPDATE Route 
SET StartPoint = ST_GeomFromText('POINT(77.5733 12.9767)', 4326),
    EndPoint = ST_GeomFromText('POINT(77.5727 13.0076)', 4326),
    Distance = ROUND(ST_Distance_Sphere(
        ST_GeomFromText('POINT(77.5733 12.9767)', 4326),
        ST_GeomFromText('POINT(77.5727 13.0076)', 4326)
    ) / 1000, 2)
WHERE RouteName = 'Majestic to Malleshwaram';

-- Update Majestic to Srinagar
UPDATE Route 
SET StartPoint = ST_GeomFromText('POINT(77.5733 12.9767)', 4326),
    EndPoint = ST_GeomFromText('POINT(77.5444 12.9692)', 4326),
    Distance = ROUND(ST_Distance_Sphere(
        ST_GeomFromText('POINT(77.5733 12.9767)', 4326),
        ST_GeomFromText('POINT(77.5444 12.9692)', 4326)
    ) / 1000, 2)
WHERE RouteName = 'Majestic to Srinagar';

-- Update Majestic to Yeshwanthpur
UPDATE Route 
SET StartPoint = ST_GeomFromText('POINT(77.5733 12.9767)', 4326),
    EndPoint = ST_GeomFromText('POINT(77.5501 13.0224)', 4326),
    Distance = ROUND(ST_Distance_Sphere(
        ST_GeomFromText('POINT(77.5733 12.9767)', 4326),
        ST_GeomFromText('POINT(77.5501 13.0224)', 4326)
    ) / 1000, 2)
WHERE RouteName = 'Majestic to Yeshwanthpur';

-- =====================================================
-- 5. CREATE ENHANCED FUNCTIONS FOR GEOSPATIAL
-- =====================================================

DROP FUNCTION IF EXISTS CalculateRealDistance;

DELIMITER //

CREATE FUNCTION CalculateRealDistance(
    startLat DECIMAL(10,8),
    startLon DECIMAL(11,8),
    endLat DECIMAL(10,8),
    endLon DECIMAL(11,8)
)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE distance DECIMAL(10,2);
    
    -- Using ST_Distance_Sphere for accurate calculation
    SET distance = ROUND(
        ST_Distance_Sphere(
            ST_GeomFromText(CONCAT('POINT(', startLon, ' ', startLat, ')'), 4326),
            ST_GeomFromText(CONCAT('POINT(', endLon, ' ', endLat, ')'), 4326)
        ) / 1000, 
        2
    );
    
    RETURN distance;
END //

DELIMITER ;

-- =====================================================
-- 6. CREATE PROCEDURE TO CALCULATE DYNAMIC ROUTE
-- =====================================================

DROP PROCEDURE IF EXISTS CalculateDynamicRoute;

DELIMITER //

CREATE PROCEDURE CalculateDynamicRoute(
    IN p_StartLat DECIMAL(10,8),
    IN p_StartLon DECIMAL(11,8),
    IN p_EndLat DECIMAL(10,8),
    IN p_EndLon DECIMAL(11,8),
    OUT p_Distance DECIMAL(10,2),
    OUT p_EstimatedTime INT
)
BEGIN
    -- Calculate real distance using geospatial function
    SET p_Distance = ROUND(
        ST_Distance_Sphere(
            ST_GeomFromText(CONCAT('POINT(', p_StartLon, ' ', p_StartLat, ')'), 4326),
            ST_GeomFromText(CONCAT('POINT(', p_EndLon, ' ', p_EndLat, ')'), 4326)
        ) / 1000, 
        2
    );
    
    -- Estimate time based on average speed of 25 km/h in Bangalore traffic
    SET p_EstimatedTime = CEIL((p_Distance / 25) * 60);
END //

DELIMITER ;

-- =====================================================
-- 7. UPDATE SERVICE COMPARISON VIEW (5KM BASE)
-- =====================================================

DROP VIEW IF EXISTS ServiceComparison5Km;

CREATE VIEW ServiceComparison5Km AS
SELECT 
    f.ServiceType,
    f.VehicleType,
    f.BaseFare,
    f.PerKmRate,
    ROUND(f.BaseFare + (f.PerKmRate * 5), 2) AS FareFor5Km
FROM Fare f
WHERE f.ServiceType IN ('Ola', 'Uber', 'Rapido', 'Namma Yatri', 'Individual')
  AND f.VehicleType IN ('Auto', 'Cab', 'Bike')
ORDER BY FareFor5Km ASC;

-- =====================================================
-- 8. CREATE PROCEDURE FOR MULTI-ROUTE RECOMMENDATION
-- =====================================================

DROP PROCEDURE IF EXISTS GetMultiRouteOptions;

DELIMITER //

CREATE PROCEDURE GetMultiRouteOptions(
    IN p_UserID INT,
    IN p_StartLocation VARCHAR(200),
    IN p_EndLocation VARCHAR(200)
)
BEGIN
    DECLARE v_Distance DECIMAL(10,2);
    DECLARE v_EstimatedTime INT;
    
    -- Get route details if exists
    SELECT Distance, EstimatedTime 
    INTO v_Distance, v_EstimatedTime
    FROM Route
    WHERE StartLocation = p_StartLocation AND EndLocation = p_EndLocation
    LIMIT 1;
    
    -- Return 3 route options
    SELECT 
        'Shortest' AS RouteType,
        v_Distance AS Distance,
        v_EstimatedTime AS EstimatedTime,
        ROUND(25 + (8 * v_Distance) + (0.8 * v_EstimatedTime), 2) AS EstimatedFare,
        'Individual Auto' AS RecommendedService
    
    UNION ALL
    
    SELECT 
        'Fastest' AS RouteType,
        v_Distance AS Distance,
        v_EstimatedTime - 5 AS EstimatedTime,
        ROUND(55 + (11.5 * v_Distance) + (1.5 * (v_EstimatedTime - 5)), 2) AS EstimatedFare,
        'Uber Cab' AS RecommendedService
    
    UNION ALL
    
    SELECT 
        'Cheapest' AS RouteType,
        v_Distance AS Distance,
        v_EstimatedTime + 10 AS EstimatedTime,
        ROUND(10 + (2 * v_Distance), 2) AS EstimatedFare,
        'Metro' AS RecommendedService;
END //

DELIMITER ;

-- =====================================================
-- 9. UPDATE BOOKING PROCEDURE WITH CONFIRMATION
-- =====================================================

DROP PROCEDURE IF EXISTS CreateConfirmedBooking;

DELIMITER //

CREATE PROCEDURE CreateConfirmedBooking(
    IN p_UserID INT,
    IN p_StartLocation VARCHAR(200),
    IN p_EndLocation VARCHAR(200),
    IN p_TotalFare DECIMAL(10,2),
    IN p_RouteType ENUM('Shortest', 'Fastest', 'Cheapest')
)
BEGIN
    DECLARE v_BookingID INT;
    
    -- Insert booking with Confirmed status
    INSERT INTO Booking (
        UserID, 
        StartLocation, 
        EndLocation, 
        TotalFare, 
        BookingStatus,
        SelectedRouteType
    )
    VALUES (
        p_UserID, 
        p_StartLocation, 
        p_EndLocation, 
        p_TotalFare, 
        'Confirmed',
        p_RouteType
    );
    
    SET v_BookingID = LAST_INSERT_ID();
    
    -- Return booking details
    SELECT 
        v_BookingID AS BookingID,
        'Booking confirmed successfully!' AS Message,
        p_RouteType AS RouteType,
        p_TotalFare AS TotalFare;
END //

DELIMITER ;

-- =====================================================
-- 10. ADD SAMPLE PROVIDER DATA WITH MODELS
-- =====================================================

-- Update existing vehicles with models
UPDATE Vehicle SET Model = 'Bajaj RE' WHERE VehicleType = 'Auto' AND VehicleID = 1;
UPDATE Vehicle SET Model = 'Maruti Swift Dzire' WHERE VehicleType = 'Cab' AND VehicleID = 2;
UPDATE Vehicle SET Model = 'Toyota Etios' WHERE VehicleType = 'Cab' AND VehicleID = 3;
UPDATE Vehicle SET Model = 'Bajaj Compact RE' WHERE VehicleType = 'Auto' AND VehicleID = 4;

-- =====================================================
-- 11. VERIFY UPDATES
-- =====================================================

-- Show updated routes with real distances
SELECT 
    RouteName,
    StartLocation,
    EndLocation,
    Distance AS RealDistanceKm,
    EstimatedTime
FROM Route
WHERE StartLocation = 'Majestic'
ORDER BY Distance;

-- Show service comparison for 5km
SELECT * FROM ServiceComparison5Km;

-- =====================================================
-- END OF DATABASE UPDATES
-- =====================================================