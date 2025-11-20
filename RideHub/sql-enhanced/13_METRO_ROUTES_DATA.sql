-- =====================================================
-- METRO ROUTES DATA TABLE
-- Pre-calculated routes with actual distance, time, stations, and fare
-- This table contains real route data that will be directly displayed
-- =====================================================

USE TransportBookingSystem;

-- Drop existing table if exists
DROP TABLE IF EXISTS MetroRoutes;

-- =====================================================
-- METRO ROUTES TABLE (Pre-calculated Route Data)
-- =====================================================

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
-- INSERT SAMPLE ROUTES (PURPLE LINE - SAME LINE ROUTES)
-- =====================================================

-- Vajarahalli to Whitefield (Full Purple Line)
INSERT INTO MetroRoutes (FromStation, ToStation, Distance, EstimatedTime, NumberOfStops, EstimatedFare, InterchangeAt, RouteInstructions, LineColor) VALUES
('Vajarahalli', 'Whitefield', 34.5, 46, 22, 50, NULL, 
'Take the Purple Line from Vajarahalli towards Whitefield. Direct route with no interchange required.', 
'Purple');

-- Whitefield to Vajarahalli (Reverse)
INSERT INTO MetroRoutes (FromStation, ToStation, Distance, EstimatedTime, NumberOfStops, EstimatedFare, InterchangeAt, RouteInstructions, LineColor) VALUES
('Whitefield', 'Vajarahalli', 34.5, 46, 22, 50, NULL, 
'Take the Purple Line from Whitefield towards Vajarahalli. Direct route with no interchange required.', 
'Purple');

-- Indiranagar to Marathahalli
INSERT INTO MetroRoutes (FromStation, ToStation, Distance, EstimatedTime, NumberOfStops, EstimatedFare, InterchangeAt, RouteInstructions, LineColor) VALUES
('Indiranagar', 'Marathahalli', 3.0, 4, 2, 10, NULL, 
'Take the Purple Line from Indiranagar towards Marathahalli. Direct route with no interchange required.', 
'Purple');

-- Marathahalli to Indiranagar (Reverse)
INSERT INTO MetroRoutes (FromStation, ToStation, Distance, EstimatedTime, NumberOfStops, EstimatedFare, InterchangeAt, RouteInstructions, LineColor) VALUES
('Marathahalli', 'Indiranagar', 3.0, 4, 2, 10, NULL, 
'Take the Purple Line from Marathahalli towards Indiranagar. Direct route with no interchange required.', 
'Purple');

-- Baiyappanahalli to Whitefield
INSERT INTO MetroRoutes (FromStation, ToStation, Distance, EstimatedTime, NumberOfStops, EstimatedFare, InterchangeAt, RouteInstructions, LineColor) VALUES
('Baiyappanahalli', 'Whitefield', 18.0, 24, 12, 30, NULL, 
'Take the Purple Line from Baiyappanahalli towards Whitefield. Direct route with no interchange required.', 
'Purple');

-- Whitefield to Baiyappanahalli (Reverse)
INSERT INTO MetroRoutes (FromStation, ToStation, Distance, EstimatedTime, NumberOfStops, EstimatedFare, InterchangeAt, RouteInstructions, LineColor) VALUES
('Whitefield', 'Baiyappanahalli', 18.0, 24, 12, 30, NULL, 
'Take the Purple Line from Whitefield towards Baiyappanahalli. Direct route with no interchange required.', 
'Purple');

-- Challaghatta to Mysuru Road
INSERT INTO MetroRoutes (FromStation, ToStation, Distance, EstimatedTime, NumberOfStops, EstimatedFare, InterchangeAt, RouteInstructions, LineColor) VALUES
('Challaghatta', 'Mysuru Road', 4.5, 6, 3, 10, NULL, 
'Take the Purple Line from Challaghatta towards Mysuru Road. Direct route with no interchange required.', 
'Purple');

-- Mysuru Road to Challaghatta (Reverse)
INSERT INTO MetroRoutes (FromStation, ToStation, Distance, EstimatedTime, NumberOfStops, EstimatedFare, InterchangeAt, RouteInstructions, LineColor) VALUES
('Mysuru Road', 'Challaghatta', 4.5, 6, 3, 10, NULL, 
'Take the Purple Line from Mysuru Road towards Challaghatta. Direct route with no interchange required.', 
'Purple');

-- =====================================================
-- INSERT SAMPLE ROUTES (GREEN LINE - SAME LINE ROUTES)
-- =====================================================

-- Nagasandra to Puttenahalli (Full Green Line)
INSERT INTO MetroRoutes (FromStation, ToStation, Distance, EstimatedTime, NumberOfStops, EstimatedFare, InterchangeAt, RouteInstructions, LineColor) VALUES
('Nagasandra', 'Puttenahalli', 39.0, 52, 29, 50, NULL, 
'Take the Green Line from Nagasandra towards Puttenahalli. Direct route with no interchange required.', 
'Green');

-- Puttenahalli to Nagasandra (Reverse)
INSERT INTO MetroRoutes (FromStation, ToStation, Distance, EstimatedTime, NumberOfStops, EstimatedFare, InterchangeAt, RouteInstructions, LineColor) VALUES
('Puttenahalli', 'Nagasandra', 39.0, 52, 29, 50, NULL, 
'Take the Green Line from Puttenahalli towards Nagasandra. Direct route with no interchange required.', 
'Green');

-- Majestic to Jayanagar
INSERT INTO MetroRoutes (FromStation, ToStation, Distance, EstimatedTime, NumberOfStops, EstimatedFare, InterchangeAt, RouteInstructions, LineColor) VALUES
('Majestic', 'Jayanagar', 7.8, 10, 6, 20, NULL, 
'Take the Green Line from Majestic towards Jayanagar. Direct route with no interchange required.', 
'Green');

-- Jayanagar to Majestic (Reverse)
INSERT INTO MetroRoutes (FromStation, ToStation, Distance, EstimatedTime, NumberOfStops, EstimatedFare, InterchangeAt, RouteInstructions, LineColor) VALUES
('Jayanagar', 'Majestic', 7.8, 10, 6, 20, NULL, 
'Take the Green Line from Jayanagar towards Majestic. Direct route with no interchange required.', 
'Green');

-- Yeshwanthpur to Majestic
INSERT INTO MetroRoutes (FromStation, ToStation, Distance, EstimatedTime, NumberOfStops, EstimatedFare, InterchangeAt, RouteInstructions, LineColor) VALUES
('Yeshwanthpur', 'Majestic', 9.1, 12, 7, 20, NULL, 
'Take the Green Line from Yeshwanthpur towards Majestic. Direct route with no interchange required.', 
'Green');

-- Majestic to Yeshwanthpur (Reverse)
INSERT INTO MetroRoutes (FromStation, ToStation, Distance, EstimatedTime, NumberOfStops, EstimatedFare, InterchangeAt, RouteInstructions, LineColor) VALUES
('Majestic', 'Yeshwanthpur', 9.1, 12, 7, 20, NULL, 
'Take the Green Line from Majestic towards Yeshwanthpur. Direct route with no interchange required.', 
'Green');

-- Rajajinagar to Sampige Road
INSERT INTO MetroRoutes (FromStation, ToStation, Distance, EstimatedTime, NumberOfStops, EstimatedFare, InterchangeAt, RouteInstructions, LineColor) VALUES
('Rajajinagar', 'Sampige Road', 3.9, 5, 3, 10, NULL, 
'Take the Green Line from Rajajinagar towards Sampige Road. Direct route with no interchange required.', 
'Green');

-- Sampige Road to Rajajinagar (Reverse)
INSERT INTO MetroRoutes (FromStation, ToStation, Distance, EstimatedTime, NumberOfStops, EstimatedFare, InterchangeAt, RouteInstructions, LineColor) VALUES
('Sampige Road', 'Rajajinagar', 3.9, 5, 3, 10, NULL, 
'Take the Green Line from Sampige Road towards Rajajinagar. Direct route with no interchange required.', 
'Green');

-- =====================================================
-- INSERT INTERCHANGE ROUTES (PURPLE TO GREEN)
-- =====================================================

-- Vajarahalli (Green) to Whitefield (Purple) - Via Majestic
INSERT INTO MetroRoutes (FromStation, ToStation, Distance, EstimatedTime, NumberOfStops, EstimatedFare, InterchangeAt, RouteInstructions, LineColor) VALUES
('Vajarahalli', 'Whitefield', 42.0, 61, 25, 60, 'Majestic', 
'1. Take the Green Line from Vajarahalli towards Majestic.
2. Alight at Majestic (Interchange Station).
3. Change to the Purple Line towards Whitefield.
(Platform numbers vary, please check signs at the station)', 
'Both');

-- Whitefield (Purple) to Vajarahalli (Green) - Via Majestic
INSERT INTO MetroRoutes (FromStation, ToStation, Distance, EstimatedTime, NumberOfStops, EstimatedFare, InterchangeAt, RouteInstructions, LineColor) VALUES
('Whitefield', 'Vajarahalli', 42.0, 61, 25, 60, 'Majestic', 
'1. Take the Purple Line from Whitefield towards Majestic.
2. Alight at Majestic (Interchange Station).
3. Change to the Green Line towards Vajarahalli.
(Platform numbers vary, please check signs at the station)', 
'Both');

-- Indiranagar (Purple) to Jayanagar (Green) - Via Majestic
INSERT INTO MetroRoutes (FromStation, ToStation, Distance, EstimatedTime, NumberOfStops, EstimatedFare, InterchangeAt, RouteInstructions, LineColor) VALUES
('Indiranagar', 'Jayanagar', 15.0, 25, 12, 30, 'Majestic', 
'1. Take the Purple Line from Indiranagar towards Majestic.
2. Alight at Majestic (Interchange Station).
3. Change to the Green Line towards Jayanagar.
(Platform numbers vary, please check signs at the station)', 
'Both');

-- Jayanagar (Green) to Indiranagar (Purple) - Via Majestic
INSERT INTO MetroRoutes (FromStation, ToStation, Distance, EstimatedTime, NumberOfStops, EstimatedFare, InterchangeAt, RouteInstructions, LineColor) VALUES
('Jayanagar', 'Indiranagar', 15.0, 25, 12, 30, 'Majestic', 
'1. Take the Green Line from Jayanagar towards Majestic.
2. Alight at Majestic (Interchange Station).
3. Change to the Purple Line towards Indiranagar.
(Platform numbers vary, please check signs at the station)', 
'Both');

-- Mysuru Road (Purple) to Yeshwanthpur (Green) - Via Majestic
INSERT INTO MetroRoutes (FromStation, ToStation, Distance, EstimatedTime, NumberOfStops, EstimatedFare, InterchangeAt, RouteInstructions, LineColor) VALUES
('Mysuru Road', 'Yeshwanthpur', 18.0, 30, 15, 40, 'Majestic', 
'1. Take the Purple Line from Mysuru Road towards Majestic.
2. Alight at Majestic (Interchange Station).
3. Change to the Green Line towards Yeshwanthpur.
(Platform numbers vary, please check signs at the station)', 
'Both');

-- Yeshwanthpur (Green) to Mysuru Road (Purple) - Via Majestic
INSERT INTO MetroRoutes (FromStation, ToStation, Distance, EstimatedTime, NumberOfStops, EstimatedFare, InterchangeAt, RouteInstructions, LineColor) VALUES
('Yeshwanthpur', 'Mysuru Road', 18.0, 30, 15, 40, 'Majestic', 
'1. Take the Green Line from Yeshwanthpur towards Majestic.
2. Alight at Majestic (Interchange Station).
3. Change to the Purple Line towards Mysuru Road.
(Platform numbers vary, please check signs at the station)', 
'Both');

-- Marathahalli (Purple) to Rajajinagar (Green) - Via Majestic
INSERT INTO MetroRoutes (FromStation, ToStation, Distance, EstimatedTime, NumberOfStops, EstimatedFare, InterchangeAt, RouteInstructions, LineColor) VALUES
('Marathahalli', 'Rajajinagar', 16.5, 28, 14, 40, 'Majestic', 
'1. Take the Purple Line from Marathahalli towards Majestic.
2. Alight at Majestic (Interchange Station).
3. Change to the Green Line towards Rajajinagar.
(Platform numbers vary, please check signs at the station)', 
'Both');

-- Rajajinagar (Green) to Marathahalli (Purple) - Via Majestic
INSERT INTO MetroRoutes (FromStation, ToStation, Distance, EstimatedTime, NumberOfStops, EstimatedFare, InterchangeAt, RouteInstructions, LineColor) VALUES
('Rajajinagar', 'Marathahalli', 16.5, 28, 14, 40, 'Majestic', 
'1. Take the Green Line from Rajajinagar towards Majestic.
2. Alight at Majestic (Interchange Station).
3. Change to the Purple Line towards Marathahalli.
(Platform numbers vary, please check signs at the station)', 
'Both');

-- Baiyappanahalli (Purple) to Puttenahalli (Green) - Via Majestic
INSERT INTO MetroRoutes (FromStation, ToStation, Distance, EstimatedTime, NumberOfStops, EstimatedFare, InterchangeAt, RouteInstructions, LineColor) VALUES
('Baiyappanahalli', 'Puttenahalli', 35.0, 55, 28, 50, 'Majestic', 
'1. Take the Purple Line from Baiyappanahalli towards Majestic.
2. Alight at Majestic (Interchange Station).
3. Change to the Green Line towards Puttenahalli.
(Platform numbers vary, please check signs at the station)', 
'Both');

-- Puttenahalli (Green) to Baiyappanahalli (Purple) - Via Majestic
INSERT INTO MetroRoutes (FromStation, ToStation, Distance, EstimatedTime, NumberOfStops, EstimatedFare, InterchangeAt, RouteInstructions, LineColor) VALUES
('Puttenahalli', 'Baiyappanahalli', 35.0, 55, 28, 50, 'Majestic', 
'1. Take the Green Line from Puttenahalli towards Majestic.
2. Alight at Majestic (Interchange Station).
3. Change to the Purple Line towards Baiyappanahalli.
(Platform numbers vary, please check signs at the station)', 
'Both');

-- Challaghatta (Purple) to Nagasandra (Green) - Via Majestic
INSERT INTO MetroRoutes (FromStation, ToStation, Distance, EstimatedTime, NumberOfStops, EstimatedFare, InterchangeAt, RouteInstructions, LineColor) VALUES
('Challaghatta', 'Nagasandra', 40.0, 60, 32, 60, 'Majestic', 
'1. Take the Purple Line from Challaghatta towards Majestic.
2. Alight at Majestic (Interchange Station).
3. Change to the Green Line towards Nagasandra.
(Platform numbers vary, please check signs at the station)', 
'Both');

-- Nagasandra (Green) to Challaghatta (Purple) - Via Majestic
INSERT INTO MetroRoutes (FromStation, ToStation, Distance, EstimatedTime, NumberOfStops, EstimatedFare, InterchangeAt, RouteInstructions, LineColor) VALUES
('Nagasandra', 'Challaghatta', 40.0, 60, 32, 60, 'Majestic', 
'1. Take the Green Line from Nagasandra towards Majestic.
2. Alight at Majestic (Interchange Station).
3. Change to the Purple Line towards Challaghatta.
(Platform numbers vary, please check signs at the station)', 
'Both');

-- Mysuru Road (Purple) to Goraguntepalya (Green) - Via Majestic
INSERT INTO MetroRoutes (FromStation, ToStation, Distance, EstimatedTime, NumberOfStops, EstimatedFare, InterchangeAt, RouteInstructions, LineColor) VALUES
('Mysuru Road', 'Goraguntepalya', 15.6, 26, 13, 40, 'Majestic', 
'1. Take the Purple Line from Mysuru Road towards Majestic.
2. Alight at Majestic (Interchange Station).
3. Change to the Green Line towards Goraguntepalya.
(Platform numbers vary, please check signs at the station)', 
'Both');

-- Goraguntepalya (Green) to Mysuru Road (Purple) - Via Majestic
INSERT INTO MetroRoutes (FromStation, ToStation, Distance, EstimatedTime, NumberOfStops, EstimatedFare, InterchangeAt, RouteInstructions, LineColor) VALUES
('Goraguntepalya', 'Mysuru Road', 15.6, 26, 13, 40, 'Majestic', 
'1. Take the Green Line from Goraguntepalya towards Majestic.
2. Alight at Majestic (Interchange Station).
3. Change to the Purple Line towards Mysuru Road.
(Platform numbers vary, please check signs at the station)', 
'Both');

-- =====================================================
-- VERIFICATION QUERIES
-- =====================================================

SELECT '✅ Metro Routes Data Table Created!' AS Status;
SELECT CONCAT('Total Routes: ', COUNT(*)) AS Info FROM MetroRoutes;
SELECT CONCAT('Same Line Routes: ', COUNT(*)) AS Info FROM MetroRoutes WHERE InterchangeAt IS NULL;
SELECT CONCAT('Interchange Routes: ', COUNT(*)) AS Info FROM MetroRoutes WHERE InterchangeAt IS NOT NULL;

-- Sample route lookup
SELECT * FROM MetroRoutes WHERE FromStation = 'Vajarahalli' AND ToStation = 'Whitefield';
