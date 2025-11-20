-- =====================================================
-- MULTI-MODAL TRANSPORT BOOKING SYSTEM DATABASE
-- =====================================================

-- Drop existing database if exists
DROP DATABASE IF EXISTS TransportBookingSystem;
CREATE DATABASE TransportBookingSystem;
USE TransportBookingSystem;

-- =====================================================
-- CORE TABLES
-- =====================================================

-- User Table (Can be both rider and service provider)
CREATE TABLE User (
    UserID INT PRIMARY KEY AUTO_INCREMENT,
    Phone VARCHAR(15) UNIQUE NOT NULL,
    Username VARCHAR(50) UNIQUE NOT NULL,
    FullName VARCHAR(100) NOT NULL,
    LastName VARCHAR(50),
    Email VARCHAR(100) UNIQUE NOT NULL,
    Age INT CHECK (Age >= 18),
    NotificationPreference ENUM('SMS', 'Email', 'Push', 'All') DEFAULT 'All',
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    IsActive BOOLEAN DEFAULT TRUE
);

-- Job/Occupation Table
CREATE TABLE Job (
    JobID INT PRIMARY KEY AUTO_INCREMENT,
    UserID INT,
    Occupation VARCHAR(100),
    CompanyName VARCHAR(100),
    FOREIGN KEY (UserID) REFERENCES User(UserID) ON DELETE CASCADE
);

-- Service Provider Table (Users who provide vehicles)
CREATE TABLE ServiceProvider (
    ProviderID INT PRIMARY KEY AUTO_INCREMENT,
    UserID INT UNIQUE,
    ProviderType ENUM('Ola', 'Uber', 'Individual', 'Metro', 'Auto', 'Namma Yatri', 'Rapido', 'Bounce') NOT NULL,
    RatePerHour DECIMAL(10, 2),
    Rating DECIMAL(3, 2) DEFAULT 0.00,
    IsApproved BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (UserID) REFERENCES User(UserID) ON DELETE CASCADE
);

-- Vehicle Table
CREATE TABLE Vehicle (
    VehicleID INT PRIMARY KEY AUTO_INCREMENT,
    ProviderID INT,
    VehicleNumber VARCHAR(20) UNIQUE NOT NULL,
    VehicleType ENUM('Auto', 'Cab', 'Bike', 'Metro', 'Rideshare', 'Scooter') NOT NULL,
    Capacity INT NOT NULL,
    IsAvailable BOOLEAN DEFAULT TRUE,
    HourlyRate DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (ProviderID) REFERENCES ServiceProvider(ProviderID) ON DELETE CASCADE
);

-- Route Table
CREATE TABLE Route (
    RouteID INT PRIMARY KEY AUTO_INCREMENT,
    RouteName VARCHAR(100),
    StartLocation VARCHAR(200) NOT NULL,
    EndLocation VARCHAR(200) NOT NULL,
    Distance DECIMAL(10, 2) NOT NULL, -- in KM
    EstimatedTime INT NOT NULL, -- in minutes
    RouteType ENUM('Shortest', 'Fastest', 'Cheapest', 'Custom') DEFAULT 'Shortest',
    TrafficCondition ENUM('Low', 'Medium', 'High') DEFAULT 'Medium'
);

-- Metro Station Table
CREATE TABLE MetroStation (
    StationID INT PRIMARY KEY AUTO_INCREMENT,
    StationName VARCHAR(100) UNIQUE NOT NULL,
    Location VARCHAR(200) NOT NULL,
    LineColor VARCHAR(50),
    IsInterchange BOOLEAN DEFAULT FALSE
);

-- Schedule Table (for Metro/Bus timings)
CREATE TABLE Schedule (
    ScheduleID INT PRIMARY KEY AUTO_INCREMENT,
    RouteID INT,
    VehicleType ENUM('Metro', 'Bus') NOT NULL,
    DepartureTime TIME NOT NULL,
    ArrivalTime TIME NOT NULL,
    Frequency INT, -- in minutes
    FOREIGN KEY (RouteID) REFERENCES Route(RouteID) ON DELETE CASCADE
);

-- Notification Table
CREATE TABLE Notification (
    NotificationID INT PRIMARY KEY AUTO_INCREMENT,
    UserID INT,
    Status ENUM('Pending', 'Sent', 'Read') DEFAULT 'Pending',
    Message TEXT NOT NULL,
    NotificationType ENUM('Booking', 'GetIn', 'GetDown', 'LaneChange', 'Alert') NOT NULL,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (UserID) REFERENCES User(UserID) ON DELETE CASCADE
);

-- Booking Table
CREATE TABLE Booking (
    BookingID INT PRIMARY KEY AUTO_INCREMENT,
    UserID INT,
    BookingStatus ENUM('Pending', 'Confirmed', 'InProgress', 'Completed', 'Cancelled') DEFAULT 'Pending',
    TotalFare DECIMAL(10, 2),
    BookingTime TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    StartLocation VARCHAR(200) NOT NULL,
    EndLocation VARCHAR(200) NOT NULL,
    FOREIGN KEY (UserID) REFERENCES User(UserID) ON DELETE CASCADE
);

-- Traffic Condition Table
CREATE TABLE TrafficCondition (
    TrafficID INT PRIMARY KEY AUTO_INCREMENT,
    RouteID INT,
    Condition ENUM('Low', 'Medium', 'High') DEFAULT 'Medium',
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (RouteID) REFERENCES Route(RouteID) ON DELETE CASCADE
);

-- Fare Table (Base fares for different services)
CREATE TABLE Fare (
    FareID INT PRIMARY KEY AUTO_INCREMENT,
    ServiceType ENUM('Ola', 'Uber', 'Auto', 'Metro', 'Individual', 'Namma Yatri', 'Rapido', 'Bounce') NOT NULL,
    VehicleType ENUM('Auto', 'Cab', 'Bike', 'Metro', 'Rideshare', 'Scooter') NOT NULL,
    BaseFare DECIMAL(10, 2) NOT NULL,
    PerKmRate DECIMAL(10, 2) NOT NULL,
    PerMinuteRate DECIMAL(10, 2),
    SurgeMultiplier DECIMAL(3, 2) DEFAULT 1.00
);

-- Bounce Center Table (Bike/Scooter rental centers)
CREATE TABLE BounceCenter (
    CenterID INT PRIMARY KEY AUTO_INCREMENT,
    CenterName VARCHAR(200) NOT NULL,
    Location VARCHAR(200) NOT NULL,
    Latitude DECIMAL(10, 8),
    Longitude DECIMAL(11, 8),
    IsActive BOOLEAN DEFAULT TRUE,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Offers/Discounts Table
CREATE TABLE Offers (
    OfferID INT PRIMARY KEY AUTO_INCREMENT,
    OfferCode VARCHAR(50) UNIQUE NOT NULL,
    DiscountPercentage DECIMAL(5, 2),
    DiscountAmount DECIMAL(10, 2),
    ValidFrom DATE,
    ValidUntil DATE,
    IsActive BOOLEAN DEFAULT TRUE
);

-- Preferred Road Table (User's custom routes)
CREATE TABLE PreferredRoad (
    PreferredRoadID INT PRIMARY KEY AUTO_INCREMENT,
    UserID INT,
    RouteID INT,
    RoadName VARCHAR(200),
    FOREIGN KEY (UserID) REFERENCES User(UserID) ON DELETE CASCADE,
    FOREIGN KEY (RouteID) REFERENCES Route(RouteID) ON DELETE CASCADE
);

-- Recommendation Table
CREATE TABLE Recommendation (
    RecommendationID INT PRIMARY KEY AUTO_INCREMENT,
    UserID INT,
    RouteID INT,
    RecommendationType ENUM('Cheapest', 'Fastest', 'Shortest', 'MultiModal') NOT NULL,
    TotalFare DECIMAL(10, 2),
    TotalTime INT, -- in minutes
    RankScore DECIMAL(5, 2), -- For ranking recommendations
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (UserID) REFERENCES User(UserID) ON DELETE CASCADE,
    FOREIGN KEY (RouteID) REFERENCES Route(RouteID) ON DELETE CASCADE
);

-- =====================================================
-- JUNCTION TABLES (Many-to-Many Relationships)
-- =====================================================

-- Booking-Vehicle Junction (Multi-modal bookings)
CREATE TABLE BookingVehicle (
    BookingVehicleID INT PRIMARY KEY AUTO_INCREMENT,
    BookingID INT,
    VehicleID INT,
    SequenceOrder INT NOT NULL, -- Order of vehicles in multi-modal trip
    PickupLocation VARCHAR(200),
    DropLocation VARCHAR(200),
    PickupTime DATETIME,
    DropTime DATETIME,
    SegmentFare DECIMAL(10, 2),
    FOREIGN KEY (BookingID) REFERENCES Booking(BookingID) ON DELETE CASCADE,
    FOREIGN KEY (VehicleID) REFERENCES Vehicle(VehicleID) ON DELETE CASCADE
);

-- Booking-Route Junction
CREATE TABLE BookingRoute (
    BookingRouteID INT PRIMARY KEY AUTO_INCREMENT,
    BookingID INT,
    RouteID INT,
    FOREIGN KEY (BookingID) REFERENCES Booking(BookingID) ON DELETE CASCADE,
    FOREIGN KEY (RouteID) REFERENCES Route(RouteID) ON DELETE CASCADE
);

-- Recommended Services (Part of recommendation)
CREATE TABLE RecommendedServices (
    RecServiceID INT PRIMARY KEY AUTO_INCREMENT,
    RecommendationID INT,
    ServiceType ENUM('Ola', 'Uber', 'Auto', 'Metro', 'Individual', 'Namma Yatri', 'Rapido', 'Bounce') NOT NULL,
    VehicleType ENUM('Auto', 'Cab', 'Bike', 'Metro', 'Rideshare', 'Scooter') NOT NULL,
    SegmentOrder INT NOT NULL,
    SegmentFare DECIMAL(10, 2),
    SegmentDistance DECIMAL(10, 2),
    SegmentTime INT,
    FOREIGN KEY (RecommendationID) REFERENCES Recommendation(RecommendationID) ON DELETE CASCADE
);

-- =====================================================
-- STORED PROCEDURES
-- =====================================================

DELIMITER //

-- Procedure 1: Calculate Fare for Single Service
CREATE PROCEDURE CalculateSingleServiceFare(
    IN p_ServiceType VARCHAR(20),
    IN p_VehicleType VARCHAR(20),
    IN p_Distance DECIMAL(10,2),
    IN p_Time INT,
    OUT p_TotalFare DECIMAL(10,2)
)
BEGIN
    DECLARE v_BaseFare DECIMAL(10,2);
    DECLARE v_PerKmRate DECIMAL(10,2);
    DECLARE v_PerMinuteRate DECIMAL(10,2);
    DECLARE v_SurgeMultiplier DECIMAL(3,2);
    
    -- Get fare details
    SELECT BaseFare, PerKmRate, PerMinuteRate, SurgeMultiplier
    INTO v_BaseFare, v_PerKmRate, v_PerMinuteRate, v_SurgeMultiplier
    FROM Fare
    WHERE ServiceType = p_ServiceType AND VehicleType = p_VehicleType
    LIMIT 1;
    
    -- Calculate total fare
    SET p_TotalFare = (v_BaseFare + (v_PerKmRate * p_Distance) + (v_PerMinuteRate * p_Time)) * v_SurgeMultiplier;
END //

-- Procedure 2: Find Best Multi-Modal Route
CREATE PROCEDURE FindBestMultiModalRoute(
    IN p_UserID INT,
    IN p_StartLocation VARCHAR(200),
    IN p_EndLocation VARCHAR(200),
    IN p_PreferenceType ENUM('Cheapest', 'Fastest', 'Shortest')
)
BEGIN
    DECLARE v_RecommendationID INT;
    
    -- Create new recommendation
    INSERT INTO Recommendation (UserID, RecommendationType)
    VALUES (p_UserID, p_PreferenceType);
    
    SET v_RecommendationID = LAST_INSERT_ID();
    
    -- Logic for finding combinations
    -- This is a simplified version - actual implementation would be more complex
    
    IF p_PreferenceType = 'Cheapest' THEN
        -- Find cheapest combination (Auto -> Metro -> Auto)
        INSERT INTO RecommendedServices (RecommendationID, ServiceType, VehicleType, SegmentOrder, SegmentFare, SegmentDistance, SegmentTime)
        SELECT 
            v_RecommendationID,
            'Auto',
            'Auto',
            1,
            50.00,
            2.5,
            10
        UNION ALL
        SELECT 
            v_RecommendationID,
            'Metro',
            'Metro',
            2,
            30.00,
            10.0,
            25
        UNION ALL
        SELECT 
            v_RecommendationID,
            'Auto',
            'Auto',
            3,
            40.00,
            2.0,
            8;
            
    ELSEIF p_PreferenceType = 'Fastest' THEN
        -- Find fastest option (Usually Cab/Ola/Uber)
        INSERT INTO RecommendedServices (RecommendationID, ServiceType, VehicleType, SegmentOrder, SegmentFare, SegmentDistance, SegmentTime)
        SELECT 
            v_RecommendationID,
            'Uber',
            'Cab',
            1,
            180.00,
            15.0,
            20;
    END IF;
    
    -- Calculate total fare and time
    UPDATE Recommendation r
    SET r.TotalFare = (SELECT SUM(SegmentFare) FROM RecommendedServices WHERE RecommendationID = v_RecommendationID),
        r.TotalTime = (SELECT SUM(SegmentTime) FROM RecommendedServices WHERE RecommendationID = v_RecommendationID)
    WHERE r.RecommendationID = v_RecommendationID;
    
    -- Return recommendation details
    SELECT * FROM Recommendation WHERE RecommendationID = v_RecommendationID;
    SELECT * FROM RecommendedServices WHERE RecommendationID = v_RecommendationID ORDER BY SegmentOrder;
END //

-- Procedure 3: Create Booking with Multi-Modal Transport
CREATE PROCEDURE CreateMultiModalBooking(
    IN p_UserID INT,
    IN p_StartLocation VARCHAR(200),
    IN p_EndLocation VARCHAR(200),
    IN p_TotalFare DECIMAL(10,2)
)
BEGIN
    DECLARE v_BookingID INT;
    
    INSERT INTO Booking (UserID, StartLocation, EndLocation, TotalFare, BookingStatus)
    VALUES (p_UserID, p_StartLocation, p_EndLocation, p_TotalFare, 'Confirmed');
    
    SET v_BookingID = LAST_INSERT_ID();
    
    SELECT v_BookingID AS BookingID, 'Booking created successfully' AS Message;
END //

DELIMITER ;

-- =====================================================
-- TRIGGERS
-- =====================================================

DELIMITER //

-- Trigger 1: Send Get-In Notification
CREATE TRIGGER trg_SendGetInNotification
AFTER UPDATE ON BookingVehicle
FOR EACH ROW
BEGIN
    IF OLD.PickupTime IS NULL AND NEW.PickupTime IS NOT NULL THEN
        INSERT INTO Notification (UserID, Message, NotificationType, Status)
        SELECT 
            b.UserID,
            CONCAT('Time to get in! Your ', 
                   (SELECT VehicleType FROM Vehicle WHERE VehicleID = NEW.VehicleID),
                   ' is ready at ', NEW.PickupLocation),
            'GetIn',
            'Sent'
        FROM Booking b
        WHERE b.BookingID = NEW.BookingID;
    END IF;
END //

-- Trigger 2: Send Get-Down Notification
CREATE TRIGGER trg_SendGetDownNotification
AFTER UPDATE ON BookingVehicle
FOR EACH ROW
BEGIN
    IF OLD.DropTime IS NULL AND NEW.DropTime IS NOT NULL THEN
        INSERT INTO Notification (UserID, Message, NotificationType, Status)
        SELECT 
            b.UserID,
            CONCAT('Approaching your destination at ', NEW.DropLocation, '. Please prepare to get down.'),
            'GetDown',
            'Sent'
        FROM Booking b
        WHERE b.BookingID = NEW.BookingID;
    END IF;
END //

-- Trigger 3: Metro Lane Change Notification
CREATE TRIGGER trg_MetroLaneChangeNotification
AFTER INSERT ON BookingVehicle
FOR EACH ROW
BEGIN
    DECLARE v_IsMetro BOOLEAN;
    DECLARE v_IsInterchange BOOLEAN;
    
    SELECT VehicleType = 'Metro' INTO v_IsMetro
    FROM Vehicle
    WHERE VehicleID = NEW.VehicleID;
    
    IF v_IsMetro THEN
        SELECT IsInterchange INTO v_IsInterchange
        FROM MetroStation
        WHERE Location = NEW.PickupLocation
        LIMIT 1;
        
        IF v_IsInterchange THEN
            INSERT INTO Notification (UserID, Message, NotificationType, Status)
            SELECT 
                b.UserID,
                CONCAT('Metro lane change required at ', NEW.PickupLocation),
                'LaneChange',
                'Sent'
            FROM Booking b
            WHERE b.BookingID = NEW.BookingID;
        END IF;
    END IF;
END //

DELIMITER ;

-- =====================================================
-- PEAK HOUR EVENT SCHEDULER (MySQL Event)
-- =====================================================
-- Note: This requires MySQL Event Scheduler to be enabled
-- Run: SET GLOBAL event_scheduler = ON;

-- Create event for peak hour notification (5 PM daily)
DELIMITER //
CREATE EVENT IF NOT EXISTS evt_PeakHourNotification
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_DATE + INTERVAL 17 HOUR
DO
BEGIN
    -- Send notification to all active users about peak hour
    INSERT INTO Notification (UserID, Message, NotificationType, Status)
    SELECT 
        UserID,
        '🚨 Peak Hour Alert: Peak hour (5 PM) is starting soon! Fares may increase. Would you like to book in advance?',
        'Alert',
        'Sent'
    FROM User
    WHERE IsActive = TRUE 
    AND NotificationPreference IN ('Push', 'All', 'SMS');
END //
DELIMITER ;

-- =====================================================
-- FUNCTIONS
-- =====================================================

DELIMITER //

-- Function 1: Calculate Distance Between Two Points
CREATE FUNCTION CalculateDistance(
    lat1 DECIMAL(10,8),
    lon1 DECIMAL(11,8),
    lat2 DECIMAL(10,8),
    lon2 DECIMAL(11,8)
)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE distance DECIMAL(10,2);
    -- Haversine formula simplified (approximate)
    SET distance = SQRT(POW(lat2 - lat1, 2) + POW(lon2 - lon1, 2)) * 111.12;
    RETURN distance;
END //

DELIMITER ;

-- =====================================================
-- VIEWS FOR COMPLEX QUERIES
-- =====================================================

-- View 1: Available Vehicles with Provider Info
CREATE VIEW AvailableVehicles AS
SELECT 
    v.VehicleID,
    v.VehicleNumber,
    v.VehicleType,
    v.HourlyRate,
    sp.ProviderType,
    sp.Rating,
    u.FullName AS ProviderName,
    u.Phone AS ProviderPhone
FROM Vehicle v
JOIN ServiceProvider sp ON v.ProviderID = sp.ProviderID
JOIN User u ON sp.UserID = u.UserID
WHERE v.IsAvailable = TRUE AND sp.IsApproved = TRUE;

-- View 2: User Booking History
CREATE VIEW UserBookingHistory AS
SELECT 
    b.BookingID,
    b.UserID,
    u.FullName,
    b.StartLocation,
    b.EndLocation,
    b.TotalFare,
    b.BookingStatus,
    b.BookingTime,
    GROUP_CONCAT(v.VehicleType ORDER BY bv.SequenceOrder) AS VehiclesCombination
FROM Booking b
JOIN User u ON b.UserID = u.UserID
LEFT JOIN BookingVehicle bv ON b.BookingID = bv.BookingID
LEFT JOIN Vehicle v ON bv.VehicleID = v.VehicleID
GROUP BY b.BookingID;

-- View 3: Service Comparison
CREATE VIEW ServiceComparison AS
SELECT 
    f.ServiceType,
    f.VehicleType,
    f.BaseFare,
    f.PerKmRate,
    f.PerMinuteRate,
    f.BaseFare + (f.PerKmRate * 10) + (f.PerMinuteRate * 30) AS EstimatedFare10Km,
    COUNT(DISTINCT v.VehicleID) AS AvailableVehicles
FROM Fare f
LEFT JOIN Vehicle v ON f.VehicleType = v.VehicleType AND v.IsAvailable = TRUE
GROUP BY f.FareID;

-- =====================================================
-- SAMPLE DATA INSERTION
-- =====================================================

-- Insert Users
INSERT INTO User (Phone, Username, FullName, LastName, Email, Age) VALUES
('9876543210', 'john_doe', 'John', 'Doe', 'john@example.com', 28),
('9876543211', 'jane_smith', 'Jane', 'Smith', 'jane@example.com', 25),
('9876543212', 'mike_wilson', 'Mike', 'Wilson', 'mike@example.com', 32),
('9876543213', 'driver_ram', 'Ram', 'Kumar', 'ram@example.com', 35),
('9876543214', 'driver_ahmed', 'Ahmed', 'Ali', 'ahmed@example.com', 40);

-- Insert Initial Service Providers (will add more later)
-- Note: Due to UNIQUE constraint on UserID, we'll add different users
INSERT INTO ServiceProvider (UserID, ProviderType, RatePerHour, Rating, IsApproved) VALUES
(4, 'Individual', 150.00, 4.5, TRUE);

-- Insert Vehicles
INSERT INTO Vehicle (ProviderID, VehicleNumber, VehicleType, Capacity, HourlyRate, IsAvailable) VALUES
(1, 'TN01AB1234', 'Auto', 3, 80.00, TRUE),
(1, 'TN01CD5678', 'Cab', 4, 150.00, TRUE),
(2, 'TN02EF9012', 'Cab', 4, 180.00, TRUE),
(2, 'TN02GH3456', 'Auto', 3, 70.00, TRUE);

-- Insert Fare Structure
INSERT INTO Fare (ServiceType, VehicleType, BaseFare, PerKmRate, PerMinuteRate, SurgeMultiplier) VALUES
('Ola', 'Cab', 50.00, 12.00, 1.50, 1.00),
('Ola', 'Auto', 30.00, 10.00, 1.00, 1.00),
('Uber', 'Cab', 55.00, 11.50, 1.50, 1.00),
('Uber', 'Auto', 35.00, 9.50, 1.00, 1.00),
('Metro', 'Metro', 10.00, 2.00, 0.00, 1.00),
('Individual', 'Cab', 40.00, 10.00, 1.20, 1.00),
('Individual', 'Auto', 25.00, 8.00, 0.80, 1.00);

-- Insert Metro Stations
INSERT INTO MetroStation (StationName, Location, LineColor, IsInterchange) VALUES
('Central Station', 'Chennai Central', 'Blue', TRUE),
('Airport Metro', 'Airport Road', 'Green', FALSE),
('T Nagar Station', 'T Nagar', 'Blue', TRUE),
('Egmore Station', 'Egmore', 'Red', TRUE);

-- Insert Sample Routes
INSERT INTO Route (RouteName, StartLocation, EndLocation, Distance, EstimatedTime, RouteType) VALUES
('Central to Airport', 'Chennai Central', 'Airport', 15.5, 35, 'Fastest'),
('T Nagar to Egmore', 'T Nagar', 'Egmore', 5.2, 18, 'Shortest'),
('Central to T Nagar', 'Chennai Central', 'T Nagar', 8.0, 25, 'Cheapest');

-- =====================================================
-- SAMPLE QUERIES
-- =====================================================

-- Query 1: Compare prices across all services for a route
SELECT 
    ServiceType,
    VehicleType,
    BaseFare + (PerKmRate * 10) AS FareFor10Km,
    BaseFare + (PerKmRate * 20) AS FareFor20Km
FROM Fare
ORDER BY FareFor10Km;

-- Query 2: Find available vehicles for specific type
SELECT * FROM AvailableVehicles WHERE VehicleType = 'Auto';

-- Query 3: Get user's booking history
SELECT * FROM UserBookingHistory WHERE UserID = 1;

-- Query 4: Service comparison with aggregate data
SELECT * FROM ServiceComparison ORDER BY EstimatedFare10Km;

-- =====================================================
-- INDEXES FOR PERFORMANCE
-- =====================================================

CREATE INDEX idx_booking_user ON Booking(UserID);
CREATE INDEX idx_booking_status ON Booking(BookingStatus);
CREATE INDEX idx_vehicle_type ON Vehicle(VehicleType);
CREATE INDEX idx_vehicle_available ON Vehicle(IsAvailable);
CREATE INDEX idx_route_locations ON Route(StartLocation, EndLocation);
CREATE INDEX idx_notification_user ON Notification(UserID);

-- =====================================================
-- USER PERMISSIONS DEMONSTRATION
-- =====================================================

-- Create different user roles
CREATE USER IF NOT EXISTS 'admin_user'@'localhost' IDENTIFIED BY 'admin123';
CREATE USER IF NOT EXISTS 'booking_user'@'localhost' IDENTIFIED BY 'booking123';
CREATE USER IF NOT EXISTS 'provider_user'@'localhost' IDENTIFIED BY 'provider123';

-- Admin: Full access
GRANT ALL PRIVILEGES ON TransportBookingSystem.* TO 'admin_user'@'localhost';

-- Booking User: Can only book and view their bookings
GRANT SELECT, INSERT ON TransportBookingSystem.Booking TO 'booking_user'@'localhost';
GRANT SELECT ON TransportBookingSystem.Vehicle TO 'booking_user'@'localhost';
GRANT SELECT ON TransportBookingSystem.Fare TO 'booking_user'@'localhost';
GRANT SELECT ON TransportBookingSystem.Route TO 'booking_user'@'localhost';
GRANT EXECUTE ON PROCEDURE TransportBookingSystem.FindBestMultiModalRoute TO 'booking_user'@'localhost';
GRANT EXECUTE ON PROCEDURE TransportBookingSystem.CreateMultiModalBooking TO 'booking_user'@'localhost';

-- Provider User: Can manage their vehicles and view bookings
GRANT SELECT, INSERT, UPDATE ON TransportBookingSystem.Vehicle TO 'provider_user'@'localhost';
GRANT SELECT ON TransportBookingSystem.BookingVehicle TO 'provider_user'@'localhost';
GRANT SELECT, UPDATE ON TransportBookingSystem.ServiceProvider TO 'provider_user'@'localhost';

FLUSH PRIVILEGES;

-- =====================================================
-- EXTRA TABLES FOR ENHANCED DBMS FEATURES
-- =====================================================

-- Admins Table (for admin panel login/control)
CREATE TABLE IF NOT EXISTS Admin (
  AdminID INT PRIMARY KEY AUTO_INCREMENT,
  Username VARCHAR(50) UNIQUE NOT NULL,
  PasswordHash VARCHAR(255) NOT NULL,
  Email VARCHAR(100) NOT NULL,
  CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  IsSuperAdmin BOOLEAN DEFAULT FALSE
);

-- Payments Table (tracks fare payments, status)
CREATE TABLE IF NOT EXISTS Payment (
  PaymentID INT PRIMARY KEY AUTO_INCREMENT,
  BookingID INT,
  UserID INT,
  Amount DECIMAL(10,2) NOT NULL,
  Status ENUM('Pending','Completed','Failed') DEFAULT 'Pending',
  PaymentMethod ENUM('Cash','Card','UPI','Wallet','Credit'),
  TransactionTime TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (BookingID) REFERENCES Booking(BookingID) ON DELETE CASCADE,
  FOREIGN KEY (UserID) REFERENCES User(UserID) ON DELETE CASCADE
);

-- Ratings Table (for users to rate their trip/provider)
CREATE TABLE IF NOT EXISTS Rating (
  RatingID INT PRIMARY KEY AUTO_INCREMENT,
  BookingID INT,
  UserID INT,
  ProviderID INT,
  Score INT CHECK (Score >= 1 AND Score <= 5),
  Comment TEXT,
  CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (BookingID) REFERENCES Booking(BookingID) ON DELETE CASCADE,
  FOREIGN KEY (UserID) REFERENCES User(UserID) ON DELETE CASCADE,
  FOREIGN KEY (ProviderID) REFERENCES ServiceProvider(ProviderID) ON DELETE CASCADE
);

-- Chat Table (for simple ride support chat)
CREATE TABLE IF NOT EXISTS ChatMessage (
  ChatID INT PRIMARY KEY AUTO_INCREMENT,
  BookingID INT,
  SenderID INT,
  Message TEXT NOT NULL,
  Timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (BookingID) REFERENCES Booking(BookingID) ON DELETE CASCADE
);

-- Reviews Table (After ride, long text, public)
CREATE TABLE IF NOT EXISTS Review (
  ReviewID INT PRIMARY KEY AUTO_INCREMENT,
  ProviderID INT,
  UserID INT,
  BookingID INT,
  Text TEXT,
  Rating INT,
  CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (ProviderID) REFERENCES ServiceProvider(ProviderID) ON DELETE CASCADE,
  FOREIGN KEY (UserID) REFERENCES User(UserID) ON DELETE CASCADE,
  FOREIGN KEY (BookingID) REFERENCES Booking(BookingID) ON DELETE CASCADE
);

-- Example Admin Creation
INSERT INTO Admin (Username, PasswordHash, Email, IsSuperAdmin) VALUES 
('admin', '$2b$10$hashhashhash', 'admin@demo.com', TRUE);

-- =====================================================
-- ADD PASSWORD HASH COLUMN TO USER TABLE
-- =====================================================
ALTER TABLE User ADD COLUMN IF NOT EXISTS PasswordHash VARCHAR(255) NULL AFTER Age;

-- =====================================================
-- BANGALORE ROUTES & COMPLETE SERVICE DATA
-- =====================================================

-- Insert Bangalore Routes (Majestic to all destinations)
INSERT INTO Route (RouteName, StartLocation, EndLocation, Distance, EstimatedTime, RouteType, TrafficCondition) VALUES
('Majestic to Lalbagh', 'Majestic', 'Lalbagh Botanical Garden', 5.2, 22, 'Shortest', 'Medium'),
('Majestic to Basavanagudi', 'Majestic', 'Basavanagudi', 4.8, 20, 'Shortest', 'Low'),
('Majestic to Jayanagar', 'Majestic', 'Jayanagar', 6.5, 28, 'Shortest', 'Medium'),
('Majestic to J.P. Nagar', 'Majestic', 'J.P. Nagar', 8.3, 35, 'Shortest', 'High'),
('Majestic to Rajajinagar', 'Majestic', 'Rajajinagar', 7.1, 30, 'Shortest', 'Medium'),
('Majestic to Bengaluru Palace', 'Majestic', 'Bengaluru Palace', 4.5, 18, 'Shortest', 'Low'),
('Majestic to MG Road', 'Majestic', 'MG Road', 3.2, 15, 'Shortest', 'High'),
('Majestic to ISKCON Temple', 'Majestic', 'ISKCON Temple', 9.8, 38, 'Shortest', 'Medium'),
('Majestic to Malleshwaram', 'Majestic', 'Malleshwaram', 5.5, 23, 'Shortest', 'Medium'),
('Majestic to Srinagar', 'Majestic', 'Srinagar', 7.9, 32, 'Shortest', 'Medium'),
('Majestic to Yeshwanthpur', 'Majestic', 'Yeshwanthpur', 6.8, 28, 'Shortest', 'Medium');

-- Insert Complete Fare Structure for All Services
INSERT INTO Fare (ServiceType, VehicleType, BaseFare, PerKmRate, PerMinuteRate, SurgeMultiplier) VALUES
-- Ola Services
('Ola', 'Cab', 50.00, 12.00, 1.50, 1.00),
('Ola', 'Auto', 30.00, 10.00, 1.00, 1.00),
('Ola', 'Rideshare', 25.00, 7.50, 1.20, 1.00),
-- Uber Services  
('Uber', 'Cab', 55.00, 11.50, 1.50, 1.00),
('Uber', 'Auto', 35.00, 9.50, 1.00, 1.00),
('Uber', 'Rideshare', 28.00, 8.00, 1.30, 1.00),
-- Namma Yatri Services
('Namma Yatri', 'Cab', 45.00, 10.50, 1.40, 1.00),
('Namma Yatri', 'Auto', 28.00, 9.00, 0.95, 1.00),
-- Rapido Services
('Rapido', 'Bike', 20.00, 5.00, 0.50, 1.00),
('Rapido', 'Auto', 25.00, 8.50, 0.90, 1.00),
('Rapido', 'Rideshare', 18.00, 6.00, 0.80, 1.00),
-- Bounce Services
('Bounce', 'Scooter', 10.00, 2.50, 0.30, 1.00),
-- Metro
('Metro', 'Metro', 10.00, 2.00, 0.00, 1.00),
-- Individual Services
('Individual', 'Cab', 40.00, 10.00, 1.20, 1.00),
('Individual', 'Auto', 25.00, 8.00, 0.80, 1.00);

-- Insert Bounce Centers near destinations
INSERT INTO BounceCenter (CenterName, Location, Latitude, Longitude) VALUES
('Bounce Hub - Lalbagh', 'Lalbagh Botanical Garden', 12.9507, 77.5848),
('Bounce Station - Jayanagar 4th Block', 'Jayanagar', 12.9243, 77.5888),
('Bounce Hub - JP Nagar', 'J.P. Nagar', 12.9070, 77.5842),
('Bounce Center - MG Road Metro', 'MG Road', 12.9716, 77.5946),
('Bounce Hub - Malleshwaram', 'Malleshwaram', 13.0076, 77.5727),
('Bounce Station - Rajajinagar', 'Rajajinagar', 13.0092, 77.5553),
('Bounce Hub - Basavanagudi', 'Basavanagudi', 12.9395, 77.5639),
('Bounce Center - ISKCON Temple', 'ISKCON Temple', 13.0162, 77.5516),
('Bounce Station - Srinagar', 'Srinagar', 12.9692, 77.5444),
('Bounce Hub - Yeshwanthpur', 'Yeshwanthpur', 13.0224, 77.5501);

-- Insert Additional Service Providers  
INSERT INTO ServiceProvider (UserID, ProviderType, RatePerHour, Rating, IsApproved) VALUES
(5, 'Ola', 200.00, 4.8, TRUE);

-- =====================================================
-- END OF DATABASE SCHEMA
-- =====================================================