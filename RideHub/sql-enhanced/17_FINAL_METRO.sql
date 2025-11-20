-- =====================================================
-- COMPLETE BANGALORE METRO ROUTES GENERATOR
-- Generates ALL possible route combinations:
-- 1. Purple to Purple (same line)
-- 2. Green to Green (same line)
-- 3. Purple to Green (with interchange)
-- 4. Green to Purple (with interchange)
-- 5. Same station check (returns error)
-- =====================================================

USE TransportBookingSystem;

-- Drop and recreate the routes table
DROP TABLE IF EXISTS MetroRoutes;

CREATE TABLE MetroRoutes (
    RouteID INT PRIMARY KEY AUTO_INCREMENT,
    FromStation VARCHAR(100) NOT NULL,
    ToStation VARCHAR(100) NOT NULL,
    Distance DECIMAL(6, 2) NOT NULL COMMENT 'Distance in kilometers',
    EstimatedTime INT NOT NULL COMMENT 'Time in minutes',
    NumberOfStops INT NOT NULL COMMENT 'Number of stations between source and destination',
    EstimatedFare DECIMAL(6, 2) NOT NULL COMMENT 'Fare in rupees',
    InterchangeAt VARCHAR(100) NULL COMMENT 'Interchange station if required',
    RouteInstructions TEXT NOT NULL,
    LineColor VARCHAR(50) NOT NULL COMMENT 'Purple, Green, or Both (for interchange)',
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY unique_route (FromStation, ToStation),
    INDEX idx_from (FromStation),
    INDEX idx_to (ToStation),
    INDEX idx_line (LineColor)
) ENGINE=InnoDB;

-- =====================================================
-- PART 1: PURPLE LINE TO PURPLE LINE (SAME LINE ROUTES)
-- =====================================================

INSERT INTO MetroRoutes (FromStation, ToStation, Distance, EstimatedTime, NumberOfStops, EstimatedFare, InterchangeAt, RouteInstructions, LineColor)
SELECT 
    s1.StationName AS FromStation,
    s2.StationName AS ToStation,
    ABS(s1.StationOrder - s2.StationOrder) * 1.5 AS Distance,
    ABS(s1.StationOrder - s2.StationOrder) * 2 AS EstimatedTime,
    ABS(s1.StationOrder - s2.StationOrder) AS NumberOfStops,
    CASE 
        WHEN ABS(s1.StationOrder - s2.StationOrder) <= 2 THEN 10
        WHEN ABS(s1.StationOrder - s2.StationOrder) <= 5 THEN 20
        WHEN ABS(s1.StationOrder - s2.StationOrder) <= 10 THEN 30
        WHEN ABS(s1.StationOrder - s2.StationOrder) <= 15 THEN 40
        ELSE 50
    END AS EstimatedFare,
    NULL AS InterchangeAt,
    CONCAT('Take the Purple Line from ', s1.StationName, ' towards ', s2.StationName, '. Direct route with no interchange required.') AS RouteInstructions,
    'Purple' AS LineColor
FROM MetroStation s1
CROSS JOIN MetroStation s2
WHERE s1.LineColor = 'Purple' 
    AND s2.LineColor = 'Purple'
    AND s1.StationID != s2.StationID;

-- =====================================================
-- PART 2: GREEN LINE TO GREEN LINE (SAME LINE ROUTES)
-- =====================================================

INSERT INTO MetroRoutes (FromStation, ToStation, Distance, EstimatedTime, NumberOfStops, EstimatedFare, InterchangeAt, RouteInstructions, LineColor)
SELECT 
    s1.StationName AS FromStation,
    s2.StationName AS ToStation,
    ABS(s1.StationOrder - s2.StationOrder) * 1.3 AS Distance,
    ABS(s1.StationOrder - s2.StationOrder) * 2 AS EstimatedTime,
    ABS(s1.StationOrder - s2.StationOrder) AS NumberOfStops,
    CASE 
        WHEN ABS(s1.StationOrder - s2.StationOrder) <= 2 THEN 10
        WHEN ABS(s1.StationOrder - s2.StationOrder) <= 5 THEN 20
        WHEN ABS(s1.StationOrder - s2.StationOrder) <= 10 THEN 30
        WHEN ABS(s1.StationOrder - s2.StationOrder) <= 15 THEN 40
        ELSE 50
    END AS EstimatedFare,
    NULL AS InterchangeAt,
    CONCAT('Take the Green Line from ', s1.StationName, ' towards ', s2.StationName, '. Direct route with no interchange required.') AS RouteInstructions,
    'Green' AS LineColor
FROM MetroStation s1
CROSS JOIN MetroStation s2
WHERE s1.LineColor = 'Green' 
    AND s2.LineColor = 'Green'
    AND s1.StationID != s2.StationID;

-- =====================================================
-- PART 3: PURPLE TO GREEN (WITH INTERCHANGE AT MAJESTIC)
-- =====================================================

INSERT INTO MetroRoutes (FromStation, ToStation, Distance, EstimatedTime, NumberOfStops, EstimatedFare, InterchangeAt, RouteInstructions, LineColor)
SELECT 
    purple.StationName AS FromStation,
    green.StationName AS ToStation,
    -- Calculate distance: Purple to Majestic + Green Majestic to destination
    (ABS(purple.StationOrder - purple_majestic.StationOrder) * 1.5 + 
     ABS(green_majestic.StationOrder - green.StationOrder) * 1.3) AS Distance,
    -- Calculate time: travel time + 5 min interchange
    (ABS(purple.StationOrder - purple_majestic.StationOrder) * 2 + 
     ABS(green_majestic.StationOrder - green.StationOrder) * 2 + 5) AS EstimatedTime,
    -- Total stops
    (ABS(purple.StationOrder - purple_majestic.StationOrder) + 
     ABS(green_majestic.StationOrder - green.StationOrder)) AS NumberOfStops,
    -- Calculate fare based on total stops
    CASE 
        WHEN (ABS(purple.StationOrder - purple_majestic.StationOrder) + 
              ABS(green_majestic.StationOrder - green.StationOrder)) <= 5 THEN 20
        WHEN (ABS(purple.StationOrder - purple_majestic.StationOrder) + 
              ABS(green_majestic.StationOrder - green.StationOrder)) <= 10 THEN 30
        WHEN (ABS(purple.StationOrder - purple_majestic.StationOrder) + 
              ABS(green_majestic.StationOrder - green.StationOrder)) <= 15 THEN 40
        WHEN (ABS(purple.StationOrder - purple_majestic.StationOrder) + 
              ABS(green_majestic.StationOrder - green.StationOrder)) <= 20 THEN 50
        ELSE 60
    END AS EstimatedFare,
    'Majestic' AS InterchangeAt,
    CONCAT(
        '1. Take the Purple Line from ', purple.StationName, ' towards Majestic.\n',
        '2. Alight at Majestic (Interchange Station).\n',
        '3. Change to the Green Line towards ', green.StationName, '.\n',
        '(Platform numbers vary, please check signs at the station)'
    ) AS RouteInstructions,
    'Both' AS LineColor
FROM MetroStation purple
CROSS JOIN MetroStation green
CROSS JOIN (SELECT * FROM MetroStation WHERE LineColor = 'Purple' AND (StationName = 'Nadaprabhu Kempegowda Station Majestic' OR StationName LIKE '%Majestic%')) purple_majestic
CROSS JOIN (SELECT * FROM MetroStation WHERE LineColor = 'Green' AND StationName = 'Majestic') green_majestic
WHERE purple.LineColor = 'Purple'
    AND green.LineColor = 'Green'
    AND purple.StationName NOT LIKE '%Majestic%';

-- =====================================================
-- PART 4: GREEN TO PURPLE (WITH INTERCHANGE AT MAJESTIC)
-- =====================================================

INSERT INTO MetroRoutes (FromStation, ToStation, Distance, EstimatedTime, NumberOfStops, EstimatedFare, InterchangeAt, RouteInstructions, LineColor)
SELECT 
    green.StationName AS FromStation,
    purple.StationName AS ToStation,
    -- Calculate distance: Green to Majestic + Purple Majestic to destination
    (ABS(green.StationOrder - green_majestic.StationOrder) * 1.3 + 
     ABS(purple_majestic.StationOrder - purple.StationOrder) * 1.5) AS Distance,
    -- Calculate time: travel time + 5 min interchange
    (ABS(green.StationOrder - green_majestic.StationOrder) * 2 + 
     ABS(purple_majestic.StationOrder - purple.StationOrder) * 2 + 5) AS EstimatedTime,
    -- Total stops
    (ABS(green.StationOrder - green_majestic.StationOrder) + 
     ABS(purple_majestic.StationOrder - purple.StationOrder)) AS NumberOfStops,
    -- Calculate fare based on total stops
    CASE 
        WHEN (ABS(green.StationOrder - green_majestic.StationOrder) + 
              ABS(purple_majestic.StationOrder - purple.StationOrder)) <= 5 THEN 20
        WHEN (ABS(green.StationOrder - green_majestic.StationOrder) + 
              ABS(purple_majestic.StationOrder - purple.StationOrder)) <= 10 THEN 30
        WHEN (ABS(green.StationOrder - green_majestic.StationOrder) + 
              ABS(purple_majestic.StationOrder - purple.StationOrder)) <= 15 THEN 40
        WHEN (ABS(green.StationOrder - green_majestic.StationOrder) + 
              ABS(purple_majestic.StationOrder - purple.StationOrder)) <= 20 THEN 50
        ELSE 60
    END AS EstimatedFare,
    'Majestic' AS InterchangeAt,
    CONCAT(
        '1. Take the Green Line from ', green.StationName, ' towards Majestic.\n',
        '2. Alight at Majestic (Interchange Station).\n',
        '3. Change to the Purple Line towards ', purple.StationName, '.\n',
        '(Platform numbers vary, please check signs at the station)'
    ) AS RouteInstructions,
    'Both' AS LineColor
FROM MetroStation green
CROSS JOIN MetroStation purple
CROSS JOIN (SELECT * FROM MetroStation WHERE LineColor = 'Green' AND StationName = 'Majestic') green_majestic
CROSS JOIN (SELECT * FROM MetroStation WHERE LineColor = 'Purple' AND (StationName = 'Nadaprabhu Kempegowda Station Majestic' OR StationName LIKE '%Majestic%')) purple_majestic
WHERE green.LineColor = 'Green'
    AND purple.LineColor = 'Purple'
    AND green.StationName != 'Majestic'
    AND purple.StationName NOT LIKE '%Majestic%';

-- =====================================================
-- UPDATED STORED PROCEDURE WITH SAME STATION CHECK
-- =====================================================

DELIMITER //

DROP PROCEDURE IF EXISTS FindMetroRoute//

CREATE PROCEDURE FindMetroRoute(
    IN p_FromStation VARCHAR(100),
    IN p_ToStation VARCHAR(100)
)
BEGIN
    -- Check if source and destination are the same
    IF LOWER(TRIM(p_FromStation)) = LOWER(TRIM(p_ToStation)) THEN
        SELECT 
            'ERROR' AS Status,
            'Source and destination stations cannot be the same' AS Message,
            p_FromStation AS FromStation,
            p_ToStation AS ToStation,
            NULL AS Distance_KM,
            NULL AS EstimatedTime_Minutes,
            NULL AS NumberOfStops,
            NULL AS InterchangeAt,
            NULL AS EstimatedFare_Rupees,
            NULL AS RouteInstructions;
    ELSE
        -- Try to find the route
        SELECT 
            'SUCCESS' AS Status,
            'Route found' AS Message,
            FromStation,
            ToStation,
            Distance AS Distance_KM,
            EstimatedTime AS EstimatedTime_Minutes,
            NumberOfStops,
            InterchangeAt,
            EstimatedFare AS EstimatedFare_Rupees,
            RouteInstructions
        FROM MetroRoutes
        WHERE LOWER(TRIM(FromStation)) = LOWER(TRIM(p_FromStation))
            AND LOWER(TRIM(ToStation)) = LOWER(TRIM(p_ToStation))
        LIMIT 1;
        
        -- If no route found, return error
        IF ROW_COUNT() = 0 THEN
            SELECT 
                'ERROR' AS Status,
                'Route not found. Please check station names.' AS Message,
                p_FromStation AS FromStation,
                p_ToStation AS ToStation,
                NULL AS Distance_KM,
                NULL AS EstimatedTime_Minutes,
                NULL AS NumberOfStops,
                NULL AS InterchangeAt,
                NULL AS EstimatedFare_Rupees,
                NULL AS RouteInstructions;
        END IF;
    END IF;
END//

DELIMITER ;

-- =====================================================
-- VERIFICATION QUERIES
-- =====================================================

SELECT '✅ All Metro Routes Generated Successfully!' AS Status;
SELECT '' AS Separator;

SELECT 'ROUTE STATISTICS' AS Category, '' AS Value
UNION ALL
SELECT '─────────────────────────────', '─────────────'
UNION ALL
SELECT 'Total Routes', CAST(COUNT(*) AS CHAR) FROM MetroRoutes
UNION ALL
SELECT 'Purple Line Routes', CAST(COUNT(*) AS CHAR) FROM MetroRoutes WHERE LineColor = 'Purple'
UNION ALL
SELECT 'Green Line Routes', CAST(COUNT(*) AS CHAR) FROM MetroRoutes WHERE LineColor = 'Green'
UNION ALL
SELECT 'Interchange Routes', CAST(COUNT(*) AS CHAR) FROM MetroRoutes WHERE InterchangeAt = 'Majestic'
UNION ALL
SELECT 'Direct Routes', CAST(COUNT(*) AS CHAR) FROM MetroRoutes WHERE InterchangeAt IS NULL;

SELECT '' AS Separator;

-- =====================================================
-- TEST CASES
-- =====================================================

SELECT '🧪 RUNNING TEST CASES' AS TestSection;
SELECT '' AS Separator;

-- Test 1: Same station (should return error)
SELECT '1. Testing same station (Indiranagar to Indiranagar):' AS TestCase;
CALL FindMetroRoute('Indiranagar', 'Indiranagar');
SELECT '' AS Separator;

-- Test 2: Same line route (Purple to Purple)
SELECT '2. Testing Purple Line (Whitefield to Marathahalli):' AS TestCase;
CALL FindMetroRoute('Whitefield', 'Marathahalli');
SELECT '' AS Separator;

-- Test 3: Same line route (Green to Green)
SELECT '3. Testing Green Line (Majestic to Jayanagar):' AS TestCase;
CALL FindMetroRoute('Majestic', 'Jayanagar');
SELECT '' AS Separator;

-- Test 4: Interchange route (Purple to Green)
SELECT '4. Testing Purple to Green (Whitefield to Jayanagar):' AS TestCase;
CALL FindMetroRoute('Whitefield', 'Jayanagar');
SELECT '' AS Separator;

-- Test 5: Interchange route (Green to Purple)
SELECT '5. Testing Green to Purple (Jayanagar to Whitefield):' AS TestCase;
CALL FindMetroRoute('Jayanagar', 'Whitefield');
SELECT '' AS Separator;

-- Test 6: Invalid station
SELECT '6. Testing invalid station:' AS TestCase;
CALL FindMetroRoute('Invalid Station', 'Jayanagar');

SELECT '' AS Separator;
SELECT '✅ ALL TESTS COMPLETED!' AS FinalStatus;