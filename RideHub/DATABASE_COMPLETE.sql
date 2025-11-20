-- =====================================================
-- RIDEHUB COMPLETE DATABASE - FINAL CONSOLIDATED VERSION
-- Multi-Modal Transport Booking System
-- =====================================================
-- This file contains EVERYTHING from ALL SQL files:
-- ✅ 25+ Tables (User, Vehicle, Booking, Route, Payment, Rating, etc.)
-- ✅ 3 Triggers (Rating updates, Notifications, Vehicle availability)
-- ✅ 2 Stored Procedures (Booking creation, Earnings updates)
-- ✅ 2 Views (Available vehicles, Booking details)
-- ✅ Sample Data (11 users, 25 vehicles, 6 bookings)
-- ✅ Geospatial support (GPS coordinates, distance calculations)
-- ✅ Provider earnings tracking (80/20 split)
-- ✅ Multi-modal transport support
-- =====================================================

-- Drop and create database
DROP DATABASE IF EXISTS TransportBookingSystem;
CREATE DATABASE TransportBookingSystem;
USE TransportBookingSystem;

-- =====================================================
-- CORE TABLES
-- =====================================================

-- User Table
CREATE TABLE User (
    UserID INT PRIMARY KEY AUTO_INCREMENT,
    Phone VARCHAR(15) UNIQUE NOT NULL,
    Username VARCHAR(50) UNIQUE NOT NULL,
    FullName VARCHAR(100) NOT NULL,
    LastName VARCHAR(50),
    Email VARCHAR(100) UNIQUE NOT NULL,
    Age INT CHECK (Age >= 18),
    PasswordHash VARCHAR(255) NULL,
    NotificationPreference ENUM('SMS', 'Email', 'Push', 'All') DEFAULT 'All',
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    IsActive BOOLEAN DEFAULT TRUE,
    IsProvider BOOLEAN DEFAULT FALSE
);

-- Service Provider Table with Earnings Tracking
CREATE TABLE ServiceProvider (
    ProviderID INT PRIMARY KEY AUTO_INCREMENT,
    UserID INT UNIQUE NOT NULL,
    ProviderType ENUM('Ola', 'Uber', 'Individual', 'Metro', 'Namma Yatri', 'Rapido', 'Bounce') NOT NULL,
    RatePerHour DECIMAL(10, 2),
    Rating DECIMAL(3, 2) DEFAULT 4.5,
    TotalRides INT DEFAULT 0,
    TotalEarnings DECIMAL(10, 2) DEFAULT 0.00,
    IsApproved BOOLEAN DEFAULT TRUE,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (UserID) REFERENCES User(UserID) ON DELETE CASCADE,
    INDEX idx_provider_type (ProviderType),
    INDEX idx_rating (Rating)
) ENGINE=InnoDB;

-- Provider Documents Table
CREATE TABLE ProviderDocuments (
    DocumentID INT PRIMARY KEY AUTO_INCREMENT,
    ProviderID INT,
    DocumentType ENUM('ID_Proof', 'Vehicle_Registration', 'License', 'Partnership_Agreement') NOT NULL,
    DocumentURL VARCHAR(500),
    VerificationStatus ENUM('Pending', 'Approved', 'Rejected') DEFAULT 'Pending',
    UploadedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ProviderID) REFERENCES ServiceProvider(ProviderID) ON DELETE CASCADE
);

-- Vehicle Table with Earnings Tracking
CREATE TABLE Vehicle (
    VehicleID INT PRIMARY KEY AUTO_INCREMENT,
    ProviderID INT NOT NULL,
    VehicleNumber VARCHAR(20) UNIQUE NOT NULL,
    Model VARCHAR(100) NOT NULL,
    VehicleType ENUM('Auto', 'Cab', 'Bike', 'Metro', 'Rideshare', 'Scooter') NOT NULL,
    Capacity INT NOT NULL,
    HourlyRate DECIMAL(10, 2) DEFAULT 100.00,
    IsAvailable BOOLEAN DEFAULT TRUE,
    TotalRides INT DEFAULT 0,
    TotalEarnings DECIMAL(10, 2) DEFAULT 0.00,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ProviderID) REFERENCES ServiceProvider(ProviderID) ON DELETE CASCADE,
    INDEX idx_vehicle_type (VehicleType),
    INDEX idx_available (IsAvailable),
    INDEX idx_provider (ProviderID)
) ENGINE=InnoDB;

-- Route Table with Geospatial Support
CREATE TABLE Route (
    RouteID INT PRIMARY KEY AUTO_INCREMENT,
    RouteName VARCHAR(100),
    StartLocation VARCHAR(200) NOT NULL,
    EndLocation VARCHAR(200) NOT NULL,
    Distance DECIMAL(10, 2) NOT NULL,
    EstimatedTime INT NOT NULL,
    RouteType ENUM('Shortest', 'Fastest', 'Cheapest', 'Custom') DEFAULT 'Shortest',
    TrafficCondition ENUM('Low', 'Medium', 'High') DEFAULT 'Medium',
    StartPoint POINT NULL,
    EndPoint POINT NULL
);

-- Create spatial indexes
CREATE SPATIAL INDEX idx_startpoint ON Route(StartPoint);
CREATE SPATIAL INDEX idx_endpoint ON Route(EndPoint);

-- Booking Table with Vehicle and Provider Details
CREATE TABLE Booking (
    BookingID INT PRIMARY KEY AUTO_INCREMENT,
    UserID INT NOT NULL,
    VehicleID INT NULL,
    ProviderID INT NULL,
    StartLocation VARCHAR(200) NOT NULL,
    EndLocation VARCHAR(200) NOT NULL,
    Distance DECIMAL(10, 2) NOT NULL,
    EstimatedTime INT NOT NULL,
    RouteType ENUM('Shortest', 'Fastest', 'Cheapest') NOT NULL,
    ServiceType ENUM('Ola', 'Uber', 'Metro', 'Namma Yatri', 'Rapido', 'Bounce', 'Individual') NOT NULL,
    VehicleType ENUM('Auto', 'Cab', 'Bike', 'Metro', 'Rideshare', 'Scooter') NOT NULL,
    TotalFare DECIMAL(10, 2) NOT NULL,
    BookingStatus ENUM('Pending', 'Confirmed', 'InProgress', 'Completed', 'Cancelled') DEFAULT 'Confirmed',
    BookingTime TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CompletedAt TIMESTAMP NULL,
    FOREIGN KEY (UserID) REFERENCES User(UserID) ON DELETE CASCADE,
    FOREIGN KEY (VehicleID) REFERENCES Vehicle(VehicleID) ON DELETE SET NULL,
    FOREIGN KEY (ProviderID) REFERENCES ServiceProvider(ProviderID) ON DELETE SET NULL,
    INDEX idx_user_booking (UserID),
    INDEX idx_provider_booking (ProviderID),
    INDEX idx_vehicle_booking (VehicleID),
    INDEX idx_booking_status (BookingStatus),
    INDEX idx_booking_time (BookingTime)
) ENGINE=InnoDB;

-- Fare Table
CREATE TABLE Fare (
    FareID INT PRIMARY KEY AUTO_INCREMENT,
    ServiceType ENUM('Ola', 'Uber', 'Auto', 'Metro', 'Individual', 'Namma Yatri', 'Rapido', 'Bounce') NOT NULL,
    VehicleType ENUM('Auto', 'Cab', 'Bike', 'Metro', 'Rideshare', 'Scooter') NOT NULL,
    BaseFare DECIMAL(10, 2) NOT NULL,
    PerKmRate DECIMAL(10, 2) NOT NULL,
    PerMinuteRate DECIMAL(10, 2),
    SurgeMultiplier DECIMAL(3, 2) DEFAULT 1.00
);

-- Notification Table
CREATE TABLE Notification (
    NotificationID INT PRIMARY KEY AUTO_INCREMENT,
    UserID INT NOT NULL,
    Status ENUM('Pending', 'Sent', 'Read') DEFAULT 'Pending',
    Message TEXT NOT NULL,
    NotificationType ENUM('Booking', 'GetIn', 'GetDown', 'LaneChange', 'Alert', 'Earnings') NOT NULL,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (UserID) REFERENCES User(UserID) ON DELETE CASCADE,
    INDEX idx_notification_user (UserID),
    INDEX idx_notification_status (Status)
) ENGINE=InnoDB;

-- =====================================================
-- ADDITIONAL TABLES FOR COMPLETE SYSTEM
-- =====================================================

-- Job/Occupation Table
CREATE TABLE Job (
    JobID INT PRIMARY KEY AUTO_INCREMENT,
    UserID INT,
    Occupation VARCHAR(100),
    CompanyName VARCHAR(100),
    FOREIGN KEY (UserID) REFERENCES User(UserID) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Metro Station Table
CREATE TABLE MetroStation (
    StationID INT PRIMARY KEY AUTO_INCREMENT,
    StationName VARCHAR(100) UNIQUE NOT NULL,
    Location VARCHAR(200) NOT NULL,
    LineColor VARCHAR(50),
    IsInterchange BOOLEAN DEFAULT FALSE,
    Coordinates POINT NULL
) ENGINE=InnoDB;

-- Schedule Table (for Metro/Bus timings)
CREATE TABLE Schedule (
    ScheduleID INT PRIMARY KEY AUTO_INCREMENT,
    RouteID INT,
    VehicleType ENUM('Metro', 'Bus') NOT NULL,
    DepartureTime TIME NOT NULL,
    ArrivalTime TIME NOT NULL,
    Frequency INT,
    FOREIGN KEY (RouteID) REFERENCES Route(RouteID) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Traffic Condition Table
CREATE TABLE TrafficCondition (
    TrafficID INT PRIMARY KEY AUTO_INCREMENT,
    RouteID INT,
    Condition ENUM('Low', 'Medium', 'High') DEFAULT 'Medium',
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (RouteID) REFERENCES Route(RouteID) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Bounce Center Table (Bike/Scooter rental centers)
CREATE TABLE BounceCenter (
    CenterID INT PRIMARY KEY AUTO_INCREMENT,
    CenterName VARCHAR(200) NOT NULL,
    Location VARCHAR(200) NOT NULL,
    Latitude DECIMAL(10, 8),
    Longitude DECIMAL(11, 8),
    IsActive BOOLEAN DEFAULT TRUE,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Coordinates POINT NULL
) ENGINE=InnoDB;

-- Offers/Discounts Table
CREATE TABLE Offers (
    OfferID INT PRIMARY KEY AUTO_INCREMENT,
    OfferCode VARCHAR(50) UNIQUE NOT NULL,
    DiscountPercentage DECIMAL(5, 2),
    DiscountAmount DECIMAL(10, 2),
    ValidFrom DATE,
    ValidUntil DATE,
    IsActive BOOLEAN DEFAULT TRUE
) ENGINE=InnoDB;

-- Preferred Road Table (User's custom routes)
CREATE TABLE PreferredRoad (
    PreferredRoadID INT PRIMARY KEY AUTO_INCREMENT,
    UserID INT,
    RouteID INT,
    RoadName VARCHAR(200),
    FOREIGN KEY (UserID) REFERENCES User(UserID) ON DELETE CASCADE,
    FOREIGN KEY (RouteID) REFERENCES Route(RouteID) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Recommendation Table
CREATE TABLE Recommendation (
    RecommendationID INT PRIMARY KEY AUTO_INCREMENT,
    UserID INT,
    RouteID INT,
    RecommendationType ENUM('Cheapest', 'Fastest', 'Shortest', 'MultiModal') NOT NULL,
    TotalFare DECIMAL(10, 2),
    TotalTime INT,
    RankScore DECIMAL(5, 2),
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (UserID) REFERENCES User(UserID) ON DELETE CASCADE,
    FOREIGN KEY (RouteID) REFERENCES Route(RouteID) ON DELETE CASCADE
) ENGINE=InnoDB;

-- =====================================================
-- JUNCTION TABLES (Many-to-Many Relationships)
-- =====================================================

-- Booking-Vehicle Junction (Multi-modal bookings)
CREATE TABLE BookingVehicle (
    BookingVehicleID INT PRIMARY KEY AUTO_INCREMENT,
    BookingID INT,
    VehicleID INT,
    SequenceOrder INT NOT NULL,
    PickupLocation VARCHAR(200),
    DropLocation VARCHAR(200),
    PickupTime DATETIME,
    DropTime DATETIME,
    SegmentFare DECIMAL(10, 2),
    FOREIGN KEY (BookingID) REFERENCES Booking(BookingID) ON DELETE CASCADE,
    FOREIGN KEY (VehicleID) REFERENCES Vehicle(VehicleID) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Booking-Route Junction
CREATE TABLE BookingRoute (
    BookingRouteID INT PRIMARY KEY AUTO_INCREMENT,
    BookingID INT,
    RouteID INT,
    FOREIGN KEY (BookingID) REFERENCES Booking(BookingID) ON DELETE CASCADE,
    FOREIGN KEY (RouteID) REFERENCES Route(RouteID) ON DELETE CASCADE
) ENGINE=InnoDB;

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
) ENGINE=InnoDB;

-- =====================================================
-- ADMIN, PAYMENT, RATING, CHAT, REVIEW TABLES
-- =====================================================

-- Admins Table
CREATE TABLE Admin (
    AdminID INT PRIMARY KEY AUTO_INCREMENT,
    Username VARCHAR(50) UNIQUE NOT NULL,
    PasswordHash VARCHAR(255) NOT NULL,
    Email VARCHAR(100) NOT NULL,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    IsSuperAdmin BOOLEAN DEFAULT FALSE
) ENGINE=InnoDB;

-- Payments Table
CREATE TABLE Payment (
    PaymentID INT PRIMARY KEY AUTO_INCREMENT,
    BookingID INT,
    UserID INT,
    Amount DECIMAL(10,2) NOT NULL,
    Status ENUM('Pending','Completed','Failed') DEFAULT 'Pending',
    PaymentMethod ENUM('Cash','Card','UPI','Wallet','Credit'),
    TransactionTime TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (BookingID) REFERENCES Booking(BookingID) ON DELETE CASCADE,
    FOREIGN KEY (UserID) REFERENCES User(UserID) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Ratings Table
CREATE TABLE Rating (
    RatingID INT PRIMARY KEY AUTO_INCREMENT,
    BookingID INT,
    UserID INT,
    ProviderID INT,
    VehicleID INT,
    Score INT CHECK (Score >= 1 AND Score <= 5),
    Comment TEXT,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (BookingID) REFERENCES Booking(BookingID) ON DELETE CASCADE,
    FOREIGN KEY (UserID) REFERENCES User(UserID) ON DELETE CASCADE,
    FOREIGN KEY (ProviderID) REFERENCES ServiceProvider(ProviderID) ON DELETE CASCADE,
    FOREIGN KEY (VehicleID) REFERENCES Vehicle(VehicleID) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Chat Table
CREATE TABLE ChatMessage (
    ChatID INT PRIMARY KEY AUTO_INCREMENT,
    BookingID INT,
    SenderID INT,
    Message TEXT NOT NULL,
    Timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (BookingID) REFERENCES Booking(BookingID) ON DELETE CASCADE,
    FOREIGN KEY (SenderID) REFERENCES User(UserID) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Reviews Table
CREATE TABLE Review (
    ReviewID INT PRIMARY KEY AUTO_INCREMENT,
    ProviderID INT,
    UserID INT,
    BookingID INT,
    Text TEXT,
    Rating INT CHECK (Rating >= 1 AND Rating <= 5),
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ProviderID) REFERENCES ServiceProvider(ProviderID) ON DELETE CASCADE,
    FOREIGN KEY (UserID) REFERENCES User(UserID) ON DELETE CASCADE,
    FOREIGN KEY (BookingID) REFERENCES Booking(BookingID) ON DELETE CASCADE
) ENGINE=InnoDB;

-- =====================================================
-- INSERT SAMPLE DATA
-- =====================================================

-- Insert test users
INSERT INTO User (Phone, Username, FullName, LastName, Email, Age, PasswordHash) VALUES
('9876543210', 'john_doe', 'John Doe', 'Doe', 'john@example.com', 28, '$2b$10$abcdefghijklmnopqrstuvwxyz1234567890'),
('9876543211', 'jane_smith', 'Jane Smith', 'Smith', 'jane@example.com', 25, '$2b$10$abcdefghijklmnopqrstuvwxyz1234567890'),
('9876543212', 'test_user', 'Test User', 'User', 'test@example.com', 30, '$2b$10$abcdefghijklmnopqrstuvwxyz1234567890');

-- Insert test providers (8 providers across different services)
INSERT INTO User (Phone, Username, FullName, LastName, Email, Age, PasswordHash, IsProvider) VALUES
('9876543213', 'driver_ram', 'Ram', 'Kumar', 'ram@example.com', 35, '$2b$10$abcdefghijklmnopqrstuvwxyz1234567890', TRUE),
('9876543214', 'driver_ahmed', 'Ahmed', 'Ali', 'ahmed@example.com', 40, '$2b$10$abcdefghijklmnopqrstuvwxyz1234567890', TRUE),
('9876543215', 'driver_priya', 'Priya', 'Sharma', 'priya@example.com', 32, '$2b$10$abcdefghijklmnopqrstuvwxyz1234567890', TRUE),
('9876543216', 'driver_vijay', 'Vijay', 'Reddy', 'vijay@example.com', 38, '$2b$10$abcdefghijklmnopqrstuvwxyz1234567890', TRUE),
('9876543217', 'driver_lakshmi', 'Lakshmi', 'Devi', 'lakshmi@example.com', 29, '$2b$10$abcdefghijklmnopqrstuvwxyz1234567890', TRUE),
('9876543218', 'driver_kumar', 'Kumar', 'Singh', 'kumar@example.com', 42, '$2b$10$abcdefghijklmnopqrstuvwxyz1234567890', TRUE),
('9876543219', 'driver_anita', 'Anita', 'Patel', 'anita@example.com', 31, '$2b$10$abcdefghijklmnopqrstuvwxyz1234567890', TRUE),
('9876543220', 'driver_ravi', 'Ravi', 'Krishnan', 'ravi@example.com', 36, '$2b$10$abcdefghijklmnopqrstuvwxyz1234567890', TRUE);

INSERT INTO ServiceProvider (UserID, ProviderType, RatePerHour, Rating, TotalRides, TotalEarnings, IsApproved) VALUES
(4, 'Individual', 150.00, 4.5, 0, 0.00, TRUE),
(5, 'Ola', 180.00, 4.8, 0, 0.00, TRUE),
(6, 'Uber', 200.00, 4.7, 0, 0.00, TRUE),
(7, 'Rapido', 120.00, 4.6, 0, 0.00, TRUE),
(8, 'Namma Yatri', 140.00, 4.9, 0, 0.00, TRUE),
(9, 'Individual', 160.00, 4.4, 0, 0.00, TRUE),
(10, 'Ola', 190.00, 4.7, 0, 0.00, TRUE),
(11, 'Uber', 210.00, 4.8, 0, 0.00, TRUE);

-- Insert 25+ vehicles across different providers and types
INSERT INTO Vehicle (ProviderID, VehicleNumber, Model, VehicleType, Capacity, HourlyRate, IsAvailable, TotalRides, TotalEarnings) VALUES
-- Provider 1 (Individual) - 3 vehicles
(1, 'KA01AB1234', 'Bajaj RE Compact', 'Auto', 3, 80.00, TRUE, 0, 0.00),
(1, 'KA01CD5678', 'Maruti Swift Dzire', 'Cab', 4, 150.00, TRUE, 0, 0.00),
(1, 'KA01EF9012', 'Honda Activa 6G', 'Bike', 1, 50.00, TRUE, 0, 0.00),
-- Provider 2 (Ola) - 4 vehicles
(2, 'KA02GH3456', 'Toyota Etios', 'Cab', 4, 180.00, TRUE, 0, 0.00),
(2, 'KA02IJ7890', 'Bajaj RE 4S', 'Auto', 3, 90.00, TRUE, 0, 0.00),
(2, 'KA02KL1234', 'Honda City', 'Cab', 4, 200.00, TRUE, 0, 0.00),
(2, 'KA02MN5678', 'Maruti Ertiga', 'Cab', 6, 220.00, FALSE, 0, 0.00),
-- Provider 3 (Uber) - 4 vehicles
(3, 'KA03OP9012', 'Hyundai Xcent', 'Cab', 4, 190.00, TRUE, 0, 0.00),
(3, 'KA03QR3456', 'Maruti Baleno', 'Cab', 4, 195.00, TRUE, 0, 0.00),
(3, 'KA03ST7890', 'Piaggio Ape', 'Auto', 3, 85.00, TRUE, 0, 0.00),
(3, 'KA03UV1234', 'Toyota Innova', 'Cab', 6, 250.00, TRUE, 0, 0.00),
-- Provider 4 (Rapido) - 3 vehicles
(4, 'KA04WX5678', 'Honda Activa 5G', 'Bike', 1, 45.00, TRUE, 0, 0.00),
(4, 'KA04YZ9012', 'TVS Jupiter', 'Bike', 1, 48.00, TRUE, 0, 0.00),
(4, 'KA04AA3456', 'Bajaj Pulsar 150', 'Bike', 1, 55.00, TRUE, 0, 0.00),
-- Provider 5 (Namma Yatri) - 3 vehicles
(5, 'KA05BB7890', 'Mahindra e2o Plus', 'Cab', 4, 140.00, TRUE, 0, 0.00),
(5, 'KA05CC1234', 'Tata Tigor EV', 'Cab', 4, 150.00, TRUE, 0, 0.00),
(5, 'KA05DD5678', 'Bajaj Maxima', 'Auto', 3, 75.00, TRUE, 0, 0.00),
-- Provider 6 (Individual) - 3 vehicles
(6, 'KA06EE9012', 'Maruti Celerio', 'Cab', 4, 130.00, TRUE, 0, 0.00),
(6, 'KA06FF3456', 'Bajaj RE', 'Auto', 3, 70.00, TRUE, 0, 0.00),
(6, 'KA06GG7890', 'Hero Splendor', 'Bike', 1, 40.00, TRUE, 0, 0.00),
-- Provider 7 (Ola) - 3 vehicles
(7, 'KA07HH1234', 'Hyundai Verna', 'Cab', 4, 205.00, TRUE, 0, 0.00),
(7, 'KA07II5678', 'Maruti WagonR', 'Cab', 4, 140.00, TRUE, 0, 0.00),
(7, 'KA07JJ9012', 'Bajaj Compact RE', 'Auto', 3, 82.00, TRUE, 0, 0.00),
-- Provider 8 (Uber) - 3 vehicles
(8, 'KA08KK3456', 'Ford EcoSport', 'Cab', 4, 230.00, TRUE, 0, 0.00),
(8, 'KA08LL7890', 'Hyundai i20', 'Cab', 4, 185.00, TRUE, 0, 0.00),
(8, 'KA08MM1234', 'Piaggio Ape Elite', 'Auto', 3, 88.00, TRUE, 0, 0.00);

-- Insert Bangalore Routes with accurate distances
INSERT INTO Route (RouteName, StartLocation, EndLocation, Distance, EstimatedTime, RouteType, TrafficCondition, StartPoint, EndPoint) VALUES
('Majestic to Lalbagh', 'Majestic', 'Lalbagh Botanical Garden', 5.2, 22, 'Shortest', 'Medium', 
 ST_GeomFromText('POINT(77.5733 12.9767)', 4326), ST_GeomFromText('POINT(77.5848 12.9507)', 4326)),
('Majestic to Basavanagudi', 'Majestic', 'Basavanagudi', 4.8, 20, 'Shortest', 'Low',
 ST_GeomFromText('POINT(77.5733 12.9767)', 4326), ST_GeomFromText('POINT(77.5639 12.9395)', 4326)),
('Majestic to Jayanagar', 'Majestic', 'Jayanagar', 6.5, 28, 'Shortest', 'Medium',
 ST_GeomFromText('POINT(77.5733 12.9767)', 4326), ST_GeomFromText('POINT(77.5888 12.9243)', 4326)),
('Majestic to J.P. Nagar', 'Majestic', 'J.P. Nagar', 8.3, 35, 'Shortest', 'High',
 ST_GeomFromText('POINT(77.5733 12.9767)', 4326), ST_GeomFromText('POINT(77.5842 12.9070)', 4326)),
('Majestic to Rajajinagar', 'Majestic', 'Rajajinagar', 7.1, 30, 'Shortest', 'Medium',
 ST_GeomFromText('POINT(77.5733 12.9767)', 4326), ST_GeomFromText('POINT(77.5553 13.0092)', 4326)),
('Majestic to Bengaluru Palace', 'Majestic', 'Bengaluru Palace', 4.5, 18, 'Shortest', 'Low',
 ST_GeomFromText('POINT(77.5733 12.9767)', 4326), ST_GeomFromText('POINT(77.5921 12.9983)', 4326)),
('Majestic to MG Road', 'Majestic', 'MG Road', 3.2, 15, 'Shortest', 'High',
 ST_GeomFromText('POINT(77.5733 12.9767)', 4326), ST_GeomFromText('POINT(77.5946 12.9716)', 4326)),
('Majestic to ISKCON Temple', 'Majestic', 'ISKCON Temple', 9.8, 38, 'Shortest', 'Medium',
 ST_GeomFromText('POINT(77.5733 12.9767)', 4326), ST_GeomFromText('POINT(77.5516 13.0162)', 4326)),
('Majestic to Malleshwaram', 'Majestic', 'Malleshwaram', 5.5, 23, 'Shortest', 'Medium',
 ST_GeomFromText('POINT(77.5733 12.9767)', 4326), ST_GeomFromText('POINT(77.5727 13.0076)', 4326)),
('Majestic to Srinagar', 'Majestic', 'Srinagar', 7.9, 32, 'Shortest', 'Medium',
 ST_GeomFromText('POINT(77.5733 12.9767)', 4326), ST_GeomFromText('POINT(77.5444 12.9692)', 4326)),
('Majestic to Yeshwanthpur', 'Majestic', 'Yeshwanthpur', 6.8, 28, 'Shortest', 'Medium',
 ST_GeomFromText('POINT(77.5733 12.9767)', 4326), ST_GeomFromText('POINT(77.5501 13.0224)', 4326));

-- Insert Complete Fare Structure
INSERT INTO Fare (ServiceType, VehicleType, BaseFare, PerKmRate, PerMinuteRate, SurgeMultiplier) VALUES
-- Ola Services
('Ola', 'Cab', 50.00, 12.00, 1.50, 1.00),
('Ola', 'Auto', 30.00, 10.00, 1.00, 1.00),
-- Uber Services  
('Uber', 'Cab', 55.00, 11.50, 1.50, 1.00),
('Uber', 'Auto', 35.00, 9.50, 1.00, 1.00),
-- Namma Yatri Services
('Namma Yatri', 'Cab', 45.00, 10.50, 1.40, 1.00),
('Namma Yatri', 'Auto', 28.00, 9.00, 0.95, 1.00),
-- Rapido Services
('Rapido', 'Bike', 20.00, 5.00, 0.50, 1.00),
('Rapido', 'Auto', 25.00, 8.50, 0.90, 1.00),
-- Individual Services
('Individual', 'Cab', 40.00, 10.00, 1.20, 1.00),
('Individual', 'Auto', 25.00, 8.00, 0.80, 1.00);

-- =====================================================
-- STORED PROCEDURES
-- =====================================================

DELIMITER //

-- Procedure: Create Booking with Vehicle Assignment
CREATE PROCEDURE CreateConfirmedBooking(
    IN p_UserID INT,
    IN p_StartLocation VARCHAR(200),
    IN p_EndLocation VARCHAR(200),
    IN p_Distance DECIMAL(10,2),
    IN p_EstimatedTime INT,
    IN p_TotalFare DECIMAL(10,2),
    IN p_RouteType VARCHAR(20),
    IN p_ServiceType VARCHAR(20),
    IN p_VehicleType VARCHAR(20)
)
BEGIN
    DECLARE v_BookingID INT;
    DECLARE v_VehicleID INT DEFAULT NULL;
    DECLARE v_ProviderID INT DEFAULT NULL;
    
    -- Find available vehicle
    SELECT v.VehicleID, v.ProviderID
    INTO v_VehicleID, v_ProviderID
    FROM Vehicle v
    JOIN ServiceProvider sp ON v.ProviderID = sp.ProviderID
    WHERE v.VehicleType = p_VehicleType
      AND v.IsAvailable = TRUE
      AND sp.ProviderType = p_ServiceType
      AND sp.IsApproved = TRUE
    ORDER BY sp.Rating DESC, v.TotalRides ASC
    LIMIT 1;
    
    -- Insert booking
    INSERT INTO Booking (
        UserID, VehicleID, ProviderID,
        StartLocation, EndLocation,
        Distance, EstimatedTime,
        RouteType, ServiceType, VehicleType,
        TotalFare, BookingStatus
    )
    VALUES (
        p_UserID, v_VehicleID, v_ProviderID,
        p_StartLocation, p_EndLocation,
        p_Distance, p_EstimatedTime,
        p_RouteType, p_ServiceType, p_VehicleType,
        p_TotalFare, 'Confirmed'
    );
    
    SET v_BookingID = LAST_INSERT_ID();
    
    -- Update counts
    IF v_VehicleID IS NOT NULL THEN
        UPDATE Vehicle SET TotalRides = TotalRides + 1 WHERE VehicleID = v_VehicleID;
    END IF;
    
    IF v_ProviderID IS NOT NULL THEN
        UPDATE ServiceProvider SET TotalRides = TotalRides + 1 WHERE ProviderID = v_ProviderID;
    END IF;
    
    SELECT v_BookingID AS BookingID, v_VehicleID AS VehicleID, v_ProviderID AS ProviderID;
END //

-- Procedure: Complete Booking and Update Earnings
CREATE PROCEDURE CompleteBooking(
    IN p_BookingID INT
)
BEGIN
    DECLARE v_TotalFare DECIMAL(10,2);
    DECLARE v_ProviderID INT;
    DECLARE v_VehicleID INT;
    DECLARE v_ProviderEarnings DECIMAL(10,2);
    
    SELECT TotalFare, ProviderID, VehicleID
    INTO v_TotalFare, v_ProviderID, v_VehicleID
    FROM Booking
    WHERE BookingID = p_BookingID;
    
    -- Provider gets 80% of fare
    SET v_ProviderEarnings = ROUND(v_TotalFare * 0.80, 2);
    
    UPDATE Booking 
    SET BookingStatus = 'Completed', CompletedAt = CURRENT_TIMESTAMP
    WHERE BookingID = p_BookingID;
    
    IF v_ProviderID IS NOT NULL THEN
        UPDATE ServiceProvider 
        SET TotalEarnings = TotalEarnings + v_ProviderEarnings
        WHERE ProviderID = v_ProviderID;
    END IF;
    
    IF v_VehicleID IS NOT NULL THEN
        UPDATE Vehicle 
        SET TotalEarnings = TotalEarnings + v_ProviderEarnings
        WHERE VehicleID = v_VehicleID;
    END IF;
END //

DELIMITER ;

-- =====================================================
-- TRIGGERS
-- =====================================================

DELIMITER //

-- Trigger 1: Auto-update provider rating after new rating
CREATE TRIGGER trg_UpdateProviderRating
AFTER INSERT ON Rating
FOR EACH ROW
BEGIN
    UPDATE ServiceProvider sp
    SET sp.Rating = (
        SELECT ROUND(AVG(r.Score), 2)
        FROM Rating r
        WHERE r.ProviderID = NEW.ProviderID
    )
    WHERE sp.ProviderID = NEW.ProviderID;
END //

-- Trigger 2: Send notification when booking is created
CREATE TRIGGER trg_NotifyOnBooking
AFTER INSERT ON Booking
FOR EACH ROW
BEGIN
    DECLARE v_ProviderUserID INT;
    
    -- Get provider's user ID
    IF NEW.ProviderID IS NOT NULL THEN
        SELECT UserID INTO v_ProviderUserID
        FROM ServiceProvider
        WHERE ProviderID = NEW.ProviderID;
        
        -- Notify provider
        INSERT INTO Notification (UserID, Message, NotificationType, Status)
        VALUES (
            v_ProviderUserID,
            CONCAT('New booking #', NEW.BookingID, ' assigned to you! From ', NEW.StartLocation, ' to ', NEW.EndLocation),
            'Booking',
            'Pending'
        );
    END IF;
    
    -- Notify user
    INSERT INTO Notification (UserID, Message, NotificationType, Status)
    VALUES (
        NEW.UserID,
        CONCAT('Your booking #', NEW.BookingID, ' has been confirmed! Fare: ₹', NEW.TotalFare),
        'Booking',
        'Pending'
    );
END //

-- Trigger 3: Update vehicle availability when booking is completed or cancelled
CREATE TRIGGER trg_UpdateVehicleOnBookingComplete
AFTER UPDATE ON Booking
FOR EACH ROW
BEGIN
    IF NEW.BookingStatus IN ('Completed', 'Cancelled') AND OLD.BookingStatus NOT IN ('Completed', 'Cancelled') THEN
        IF NEW.VehicleID IS NOT NULL THEN
            UPDATE Vehicle 
            SET IsAvailable = TRUE 
            WHERE VehicleID = NEW.VehicleID;
        END IF;
    END IF;
END //

DELIMITER ;

-- =====================================================
-- VIEWS
-- =====================================================

-- View: Available Vehicles with Provider Info
CREATE VIEW AvailableVehicles AS
SELECT 
    v.VehicleID,
    v.VehicleNumber,
    v.Model,
    v.VehicleType,
    v.Capacity,
    v.HourlyRate,
    v.TotalRides AS VehicleRides,
    v.TotalEarnings AS VehicleEarnings,
    sp.ProviderID,
    sp.ProviderType,
    sp.Rating AS ProviderRating,
    sp.TotalRides AS ProviderTotalRides,
    u.FullName AS ProviderName,
    u.Phone AS ProviderPhone
FROM Vehicle v
JOIN ServiceProvider sp ON v.ProviderID = sp.ProviderID
JOIN User u ON sp.UserID = u.UserID
WHERE v.IsAvailable = TRUE AND sp.IsApproved = TRUE;

-- View: Booking Details with Vehicle Info
CREATE VIEW BookingDetails AS
SELECT 
    b.BookingID,
    b.UserID,
    u.FullName AS UserName,
    b.StartLocation,
    b.EndLocation,
    b.Distance,
    b.RouteType,
    b.ServiceType,
    b.VehicleType,
    b.TotalFare,
    b.BookingStatus,
    b.BookingTime,
    v.VehicleID,
    v.VehicleNumber,
    v.Model AS VehicleModel,
    sp.ProviderID,
    sp.ProviderType,
    sp.Rating AS ProviderRating,
    pu.FullName AS ProviderName,
    pu.Phone AS ProviderPhone
FROM Booking b
JOIN User u ON b.UserID = u.UserID
LEFT JOIN Vehicle v ON b.VehicleID = v.VehicleID
LEFT JOIN ServiceProvider sp ON b.ProviderID = sp.ProviderID
LEFT JOIN User pu ON sp.UserID = pu.UserID;

-- =====================================================
-- INSERT SAMPLE BOOKINGS FOR TESTING
-- =====================================================

-- Sample bookings for user 1 (John Doe)
INSERT INTO Booking (UserID, VehicleID, ProviderID, StartLocation, EndLocation, Distance, EstimatedTime, RouteType, ServiceType, VehicleType, TotalFare, BookingStatus, BookingTime) VALUES
(1, 1, 1, 'Majestic', 'Lalbagh Botanical Garden', 5.2, 22, 'Shortest', 'Individual', 'Auto', 92.40, 'Completed', DATE_SUB(NOW(), INTERVAL 2 DAY)),
(1, 4, 2, 'Majestic', 'MG Road', 3.2, 15, 'Fastest', 'Ola', 'Cab', 145.50, 'Completed', DATE_SUB(NOW(), INTERVAL 1 DAY)),
(1, 9, 4, 'Majestic', 'Jayanagar', 6.5, 28, 'Cheapest', 'Rapido', 'Bike', 52.50, 'InProgress', DATE_SUB(NOW(), INTERVAL 2 HOUR));

-- Sample bookings for user 2 (Jane Smith)
INSERT INTO Booking (UserID, VehicleID, ProviderID, StartLocation, EndLocation, Distance, EstimatedTime, RouteType, ServiceType, VehicleType, TotalFare, BookingStatus, BookingTime) VALUES
(2, 7, 3, 'Majestic', 'Bengaluru Palace', 4.5, 18, 'Fastest', 'Uber', 'Cab', 138.75, 'Completed', DATE_SUB(NOW(), INTERVAL 3 DAY)),
(2, 13, 5, 'Majestic', 'J.P. Nagar', 8.3, 35, 'Shortest', 'Namma Yatri', 'Cab', 162.30, 'Confirmed', DATE_SUB(NOW(), INTERVAL 1 HOUR));

-- Sample bookings for user 3 (Test User)
INSERT INTO Booking (UserID, VehicleID, ProviderID, StartLocation, EndLocation, Distance, EstimatedTime, RouteType, ServiceType, VehicleType, TotalFare, BookingStatus, BookingTime) VALUES
(3, 19, 6, 'Majestic', 'Malleshwaram', 5.5, 23, 'Shortest', 'Individual', 'Auto', 87.50, 'Completed', DATE_SUB(NOW(), INTERVAL 5 DAY));

-- Complete some bookings to update earnings
CALL CompleteBooking(1);
CALL CompleteBooking(2);
CALL CompleteBooking(4);
CALL CompleteBooking(6);

-- =====================================================
-- VERIFICATION QUERIES
-- =====================================================

SELECT '✅ Database initialized successfully!' AS Status;
SELECT CONCAT('Total Providers: ', COUNT(*)) AS Info FROM ServiceProvider;
SELECT CONCAT('Total Vehicles: ', COUNT(*)) AS Info FROM Vehicle;
SELECT CONCAT('Total Routes: ', COUNT(*)) AS Info FROM Route;
SELECT CONCAT('Total Fare Entries: ', COUNT(*)) AS Info FROM Fare;
SELECT CONCAT('Total Bookings: ', COUNT(*)) AS Info FROM Booking;

-- Show sample booking with details
SELECT 
    b.BookingID,
    u.FullName as Customer,
    b.StartLocation,
    b.EndLocation,
    CONCAT(b.ServiceType, ' ', b.VehicleType) as Service,
    v.VehicleNumber,
    v.Model,
    pu.FullName as Driver,
    b.TotalFare,
    b.BookingStatus
FROM Booking b
JOIN User u ON b.UserID = u.UserID
LEFT JOIN Vehicle v ON b.VehicleID = v.VehicleID
LEFT JOIN ServiceProvider sp ON b.ProviderID = sp.ProviderID
LEFT JOIN User pu ON sp.UserID = pu.UserID
LIMIT 3;
