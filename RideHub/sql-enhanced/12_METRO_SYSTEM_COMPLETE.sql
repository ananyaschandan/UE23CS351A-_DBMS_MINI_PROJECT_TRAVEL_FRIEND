-- =====================================================
-- COMPREHENSIVE BANGALORE METRO SYSTEM
-- ONLY Purple Line and Green Line (NO Pink Line)
-- Complete station data with connections and route finding
-- =====================================================

USE TransportBookingSystem;

-- Drop existing metro tables if they exist
DROP TABLE IF EXISTS MetroMapImage;
DROP TABLE IF EXISTS MetroConnection;
DROP TABLE IF EXISTS MetroRoute;
DROP TABLE IF EXISTS MetroStation;

-- =====================================================
-- METRO STATION TABLE (Enhanced)
-- =====================================================

CREATE TABLE MetroStation (
    StationID INT PRIMARY KEY AUTO_INCREMENT,
    StationName VARCHAR(100) UNIQUE NOT NULL,
    StationCode VARCHAR(10) UNIQUE NOT NULL,
    LineColor ENUM('Purple', 'Green') NOT NULL,
    Location VARCHAR(200) NOT NULL,
    Latitude DECIMAL(10, 8),
    Longitude DECIMAL(11, 8),
    IsInterchange BOOLEAN DEFAULT FALSE,
    StationOrder INT NOT NULL,
    FirstTrain TIME DEFAULT '05:00:00',
    LastTrain TIME DEFAULT '23:00:00',
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_line (LineColor),
    INDEX idx_interchange (IsInterchange),
    INDEX idx_order (LineColor, StationOrder)
) ENGINE=InnoDB;

-- =====================================================
-- METRO CONNECTION TABLE (Station to Station)
-- =====================================================

CREATE TABLE MetroConnection (
    ConnectionID INT PRIMARY KEY AUTO_INCREMENT,
    FromStationID INT NOT NULL,
    ToStationID INT NOT NULL,
    LineColor ENUM('Purple', 'Green') NOT NULL,
    Distance DECIMAL(5, 2) NOT NULL COMMENT 'Distance in km',
    TravelTime INT NOT NULL COMMENT 'Time in minutes',
    Fare DECIMAL(5, 2) NOT NULL COMMENT 'Fare in rupees',
    FOREIGN KEY (FromStationID) REFERENCES MetroStation(StationID),
    FOREIGN KEY (ToStationID) REFERENCES MetroStation(StationID),
    INDEX idx_from_station (FromStationID),
    INDEX idx_to_station (ToStationID),
    INDEX idx_line (LineColor)
) ENGINE=InnoDB;

-- =====================================================
-- METRO ROUTE TABLE (Pre-calculated routes)
-- =====================================================

CREATE TABLE MetroRoute (
    RouteID INT PRIMARY KEY AUTO_INCREMENT,
    FromStationID INT NOT NULL,
    ToStationID INT NOT NULL,
    TotalDistance DECIMAL(6, 2) NOT NULL,
    TotalTime INT NOT NULL,
    TotalFare DECIMAL(6, 2) NOT NULL,
    NumStops INT NOT NULL,
    InterchangeStation VARCHAR(200),
    RouteInstructions TEXT,
    StationSequence JSON COMMENT 'Array of station IDs in order',
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (FromStationID) REFERENCES MetroStation(StationID),
    FOREIGN KEY (ToStationID) REFERENCES MetroStation(StationID),
    INDEX idx_from_to (FromStationID, ToStationID)
) ENGINE=InnoDB;

-- =====================================================
-- METRO MAP IMAGES TABLE (BLOB Storage)
-- =====================================================

CREATE TABLE MetroMapImage (
    MapID INT PRIMARY KEY AUTO_INCREMENT,
    MapName VARCHAR(100) NOT NULL,
    MapDescription TEXT,
    ImageData LONGBLOB NOT NULL COMMENT 'Metro map image stored as BLOB',
    ImageType VARCHAR(50) DEFAULT 'image/png',
    ImageSize INT COMMENT 'Size in bytes',
    UploadedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    IsActive BOOLEAN DEFAULT TRUE,
    INDEX idx_active (IsActive)
) ENGINE=InnoDB;

-- =====================================================
-- INSERT ALL PURPLE LINE STATIONS
-- =====================================================

INSERT INTO MetroStation (StationName, StationCode, LineColor, Location, IsInterchange, StationOrder, FirstTrain, LastTrain) VALUES
-- Purple Line (Whitefield to Challaghatta)
('Whitefield', 'WF01', 'Purple', 'Whitefield', FALSE, 1, '05:00:00', '23:00:00'),
('Kadugodi Tree Park', 'KD02', 'Purple', 'Kadugodi', FALSE, 2, '05:00:00', '23:00:00'),
('Pattandur Agrahara', 'PA03', 'Purple', 'Pattandur Agrahara', FALSE, 3, '05:00:00', '23:00:00'),
('Channasandra', 'CH04', 'Purple', 'Channasandra', FALSE, 4, '05:00:00', '23:00:00'),
('Hoodi', 'HO05', 'Purple', 'Hoodi', FALSE, 5, '05:00:00', '23:00:00'),
('Garudacharpalya', 'GA06', 'Purple', 'Garudacharpalya', FALSE, 6, '05:00:00', '23:00:00'),
('Doddanekundi', 'DD07', 'Purple', 'Doddanekundi', FALSE, 7, '05:00:00', '23:00:00'),
('Marathahalli', 'MA08', 'Purple', 'Marathahalli', FALSE, 8, '05:00:00', '23:00:00'),
('Halasuru', 'HA09', 'Purple', 'Halasuru', FALSE, 9, '05:00:00', '23:00:00'),
('Indiranagar', 'IN10', 'Purple', 'Indiranagar', FALSE, 10, '05:00:00', '23:00:00'),
('Swami Vivekananda Road', 'SV11', 'Purple', 'Swami Vivekananda Road', FALSE, 11, '05:00:00', '23:00:00'),
('Baiyappanahalli', 'BA12', 'Purple', 'Baiyappanahalli', FALSE, 12, '05:00:00', '23:00:00'),
('Vijayanagar', 'VJ13', 'Purple', 'Vijayanagar', FALSE, 13, '05:00:00', '23:00:00'),
('Hosahalli', 'HS14', 'Purple', 'Hosahalli', FALSE, 14, '05:00:00', '23:00:00'),
('Magadi Road', 'MR15', 'Purple', 'Magadi Road', FALSE, 15, '05:00:00', '23:00:00'),
('Hosahalli', 'HS16', 'Purple', 'Hosahalli', FALSE, 16, '05:00:00', '23:00:00'),
('Vijayanagar', 'VJ17', 'Purple', 'Vijayanagar', FALSE, 17, '05:00:00', '23:00:00'),
('Attiguppe', 'AT18', 'Purple', 'Attiguppe', FALSE, 18, '05:00:00', '23:00:00'),
('Deepanjali Nagar', 'DN19', 'Purple', 'Deepanjali Nagar', FALSE, 19, '05:00:00', '23:00:00'),
('Mysuru Road', 'MY20', 'Purple', 'Mysuru Road', FALSE, 20, '05:00:00', '23:00:00'),
('Kengeri Bus Terminal', 'KB21', 'Purple', 'Kengeri', FALSE, 21, '05:00:00', '23:00:00'),
('Kengeri', 'KE22', 'Purple', 'Kengeri', FALSE, 22, '05:00:00', '23:00:00'),
('Challaghatta', 'CG23', 'Purple', 'Challaghatta', FALSE, 23, '05:00:00', '23:00:00');

-- =====================================================
-- INSERT ALL GREEN LINE STATIONS
-- =====================================================

INSERT INTO MetroStation (StationName, StationCode, LineColor, Location, IsInterchange, StationOrder, FirstTrain, LastTrain) VALUES
-- Green Line (Nagasandra to Puttenahalli/RV Road Terminal)
('Nagasandra', 'NS01', 'Green', 'Nagasandra', FALSE, 1, '05:00:00', '23:00:00'),
('Dasarahalli', 'DA02', 'Green', 'Dasarahalli', FALSE, 2, '05:00:00', '23:00:00'),
('Jalahalli', 'JA03', 'Green', 'Jalahalli', FALSE, 3, '05:00:00', '23:00:00'),
('Peenya Industrial Area', 'PI04', 'Green', 'Peenya', FALSE, 4, '05:00:00', '23:00:00'),
('Peenya', 'PE05', 'Green', 'Peenya', FALSE, 5, '05:00:00', '23:00:00'),
('Goraguntepalya', 'GO06', 'Green', 'Goraguntepalya', FALSE, 6, '05:00:00', '23:00:00'),
('Yeshwanthpur', 'YE07', 'Green', 'Yeshwanthpur', FALSE, 7, '05:00:00', '23:00:00'),
('Sandal Soap Factory', 'SS08', 'Green', 'Sandal Soap Factory', FALSE, 8, '05:00:00', '23:00:00'),
('Mahalakshmi', 'ML09', 'Green', 'Mahalakshmi', FALSE, 9, '05:00:00', '23:00:00'),
('Rajajinagar', 'RJ10', 'Green', 'Rajajinagar', FALSE, 10, '05:00:00', '23:00:00'),
('Kuvempu Road', 'KR11', 'Green', 'Kuvempu Road', FALSE, 11, '05:00:00', '23:00:00'),
('Srirampura', 'SR12', 'Green', 'Srirampura', FALSE, 12, '05:00:00', '23:00:00'),
('Sampige Road', 'SM13', 'Green', 'Sampige Road', FALSE, 13, '05:00:00', '23:00:00'),
('Majestic', 'MJ14', 'Green', 'Majestic', TRUE, 14, '05:00:00', '23:00:00'),
('Chickpet', 'CK15', 'Green', 'Chickpet', FALSE, 15, '05:00:00', '23:00:00'),
('KR Market', 'KM16', 'Green', 'KR Market', FALSE, 16, '05:00:00', '23:00:00'),
('National College', 'NC17', 'Green', 'National College', FALSE, 17, '05:00:00', '23:00:00'),
('Lalbagh', 'LB18', 'Green', 'Lalbagh', FALSE, 18, '05:00:00', '23:00:00'),
('South End Circle', 'SE19', 'Green', 'South End Circle', FALSE, 19, '05:00:00', '23:00:00'),
('Jayanagar', 'JY20', 'Green', 'Jayanagar', FALSE, 20, '05:00:00', '23:00:00'),
('RV Road', 'RV21', 'Green', 'RV Road', FALSE, 21, '05:00:00', '23:00:00'),
('Banashankari', 'BS22', 'Green', 'Banashankari', FALSE, 22, '05:00:00', '23:00:00'),
('JP Nagar', 'JP23', 'Green', 'JP Nagar', FALSE, 23, '05:00:00', '23:00:00'),
('Yelachenahalli', 'YL24', 'Green', 'Yelachenahalli', FALSE, 24, '05:00:00', '23:00:00'),
('Konanakunte Cross', 'KC25', 'Green', 'Konanakunte', FALSE, 25, '05:00:00', '23:00:00'),
('Doddakallasandra', 'DK26', 'Green', 'Doddakallasandra', FALSE, 26, '05:00:00', '23:00:00'),
('Vajarahalli', 'VH27', 'Green', 'Vajarahalli', FALSE, 27, '05:00:00', '23:00:00'),
('Talaghattapura', 'TG28', 'Green', 'Talaghattapura', FALSE, 28, '05:00:00', '23:00:00'),
('Silk Institute', 'SI29', 'Green', 'Silk Institute', FALSE, 29, '05:00:00', '23:00:00'),
('Puttenahalli', 'PU30', 'Green', 'Puttenahalli', FALSE, 30, '05:00:00', '23:00:00');

-- Update Interchange Stations (Majestic is the main interchange between Purple and Green lines)
UPDATE MetroStation SET IsInterchange = TRUE WHERE StationName = 'Majestic';

-- =====================================================
-- CREATE METRO CONNECTIONS (Adjacent Stations)
-- =====================================================

-- Purple Line Connections (Bidirectional)
INSERT INTO MetroConnection (FromStationID, ToStationID, LineColor, Distance, TravelTime, Fare) 
SELECT s1.StationID, s2.StationID, 'Purple', 1.5, 2, 10
FROM MetroStation s1
JOIN MetroStation s2 ON s2.StationOrder = s1.StationOrder + 1
WHERE s1.LineColor = 'Purple' AND s2.LineColor = 'Purple';

INSERT INTO MetroConnection (FromStationID, ToStationID, LineColor, Distance, TravelTime, Fare) 
SELECT s2.StationID, s1.StationID, 'Purple', 1.5, 2, 10
FROM MetroStation s1
JOIN MetroStation s2 ON s2.StationOrder = s1.StationOrder + 1
WHERE s1.LineColor = 'Purple' AND s2.LineColor = 'Purple';

-- Green Line Connections (Bidirectional)
INSERT INTO MetroConnection (FromStationID, ToStationID, LineColor, Distance, TravelTime, Fare) 
SELECT s1.StationID, s2.StationID, 'Green', 1.3, 2, 10
FROM MetroStation s1
JOIN MetroStation s2 ON s2.StationOrder = s1.StationOrder + 1
WHERE s1.LineColor = 'Green' AND s2.LineColor = 'Green';

INSERT INTO MetroConnection (FromStationID, ToStationID, LineColor, Distance, TravelTime, Fare) 
SELECT s2.StationID, s1.StationID, 'Green', 1.3, 2, 10
FROM MetroStation s1
JOIN MetroStation s2 ON s2.StationOrder = s1.StationOrder + 1
WHERE s1.LineColor = 'Green' AND s2.LineColor = 'Green';


-- =====================================================
-- STORED PROCEDURE: Find Metro Route
-- =====================================================

DELIMITER //

DROP PROCEDURE IF EXISTS FindMetroRoute//

CREATE PROCEDURE FindMetroRoute(
    IN p_FromStation VARCHAR(100),
    IN p_ToStation VARCHAR(100)
)
BEGIN
    DECLARE v_FromStationID INT;
    DECLARE v_ToStationID INT;
    DECLARE v_FromLine VARCHAR(10);
    DECLARE v_ToLine VARCHAR(10);
    DECLARE v_SameLine BOOLEAN;
    DECLARE v_Distance DECIMAL(6,2);
    DECLARE v_Time INT;
    DECLARE v_Fare DECIMAL(6,2);
    DECLARE v_Stops INT;
    DECLARE v_InterchangeStation VARCHAR(200);
    DECLARE v_RouteInstructions TEXT;
    
    -- Get station IDs and lines
    SELECT StationID, LineColor INTO v_FromStationID, v_FromLine
    FROM MetroStation WHERE StationName = p_FromStation LIMIT 1;
    
    SELECT StationID, LineColor INTO v_ToStationID, v_ToLine
    FROM MetroStation WHERE StationName = p_ToStation LIMIT 1;
    
    -- Check if stations exist
    IF v_FromStationID IS NULL OR v_ToStationID IS NULL THEN
        SELECT 'Error: Station not found' AS Message;
    ELSE
        -- Check if same line
        SET v_SameLine = (v_FromLine = v_ToLine);
        
        IF v_SameLine THEN
            -- Direct route on same line
            SELECT 
                ABS(s1.StationOrder - s2.StationOrder) INTO v_Stops
            FROM MetroStation s1, MetroStation s2
            WHERE s1.StationID = v_FromStationID AND s2.StationID = v_ToStationID;
            
            SET v_Distance = v_Stops * 1.5;
            SET v_Time = v_Stops * 2;
            SET v_Fare = CASE 
                WHEN v_Stops <= 2 THEN 10
                WHEN v_Stops <= 5 THEN 20
                WHEN v_Stops <= 10 THEN 30
                ELSE 40
            END;
            
            SET v_RouteInstructions = CONCAT(
                'Take the ', v_FromLine, ' Line from ', p_FromStation, 
                ' towards ', p_ToStation, '. Direct route with no interchange required.'
            );
            SET v_InterchangeStation = NULL;
            
        ELSE
            -- Interchange required
            SET v_InterchangeStation = 'Majestic';
            
            -- Calculate via Majestic (simplified)
            SELECT 
                (ABS(s1.StationOrder - s2.StationOrder) + ABS(s3.StationOrder - s4.StationOrder)) INTO v_Stops
            FROM MetroStation s1, MetroStation s2, MetroStation s3, MetroStation s4
            WHERE s1.StationID = v_FromStationID 
                AND s2.StationName = 'Majestic' AND s2.LineColor = v_FromLine
                AND s3.StationName = 'Majestic' AND s3.LineColor = v_ToLine
                AND s4.StationID = v_ToStationID;
            
            SET v_Distance = v_Stops * 1.5;
            SET v_Time = v_Stops * 2 + 5; -- +5 min for interchange
            SET v_Fare = CASE 
                WHEN v_Stops <= 5 THEN 20
                WHEN v_Stops <= 10 THEN 30
                WHEN v_Stops <= 15 THEN 40
                ELSE 50
            END;
            
            SET v_RouteInstructions = CONCAT(
                '1. Take the ', v_FromLine, ' Line from ', p_FromStation, ' towards Majestic.\n',
                '2. Alight at Majestic (Interchange Station).\n',
                '3. Change to the ', v_ToLine, ' Line towards ', p_ToStation, '.\n',
                '(Platform numbers vary, please check signs at the station)'
            );
        END IF;
        
        -- Return route details
        SELECT 
            p_FromStation AS FromStation,
            p_ToStation AS ToStation,
            v_Distance AS Distance_KM,
            v_Time AS EstimatedTime_Minutes,
            v_Stops AS NumberOfStops,
            v_InterchangeStation AS InterchangeAt,
            v_Fare AS EstimatedFare_Rupees,
            v_RouteInstructions AS RouteInstructions,
            '05:00 AM (07:00 AM on Sundays)' AS FirstTrain,
            '11:00 PM' AS LastTrain;
    END IF;
END//

DELIMITER ;

-- =====================================================
-- VERIFICATION QUERIES
-- =====================================================

SELECT '✅ Bangalore Metro System Created (Purple & Green Lines Only)!' AS Status;
SELECT CONCAT('Total Stations: ', COUNT(*)) AS Info FROM MetroStation;
SELECT CONCAT('Purple Line Stations: ', COUNT(*)) AS Info FROM MetroStation WHERE LineColor = 'Purple';
SELECT CONCAT('Green Line Stations: ', COUNT(*)) AS Info FROM MetroStation WHERE LineColor = 'Green';
SELECT CONCAT('Interchange Stations: ', COUNT(*)) AS Info FROM MetroStation WHERE IsInterchange = TRUE;
SELECT CONCAT('Total Connections: ', COUNT(*)) AS Info FROM MetroConnection;

-- Test the route finder
CALL FindMetroRoute('Mysuru Road', 'Goraguntepalya');
