-- =====================================================
-- FILE 1: ENHANCED SCHEMA WITH MULTI-MODAL SUPPORT
-- =====================================================
-- This file creates the database structure with:
-- - Multi-modal booking support
-- - Segment-based journeys
-- - Bounce centers
-- - Bus routes
-- - Real password authentication
-- =====================================================

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
    PasswordHash VARCHAR(255) NOT NULL,
    NotificationPreference ENUM('SMS', 'Email', 'Push', 'All') DEFAULT 'All',
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    IsActive BOOLEAN DEFAULT TRUE,
    IsProvider BOOLEAN DEFAULT FALSE,
    INDEX idx_email (Email),
    INDEX idx_phone (Phone)
) ENGINE=InnoDB;

-- Service Provider Table
CREATE TABLE ServiceProvider (
    ProviderID INT PRIMARY KEY AUTO_INCREMENT,
    UserID INT UNIQUE NOT NULL,
    ProviderType ENUM('Ola', 'Uber', 'Individual', 'Metro', 'Namma Yatri', 'Rapido', 'Bounce', 'BMTC') NOT NULL,
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

-- Provider Documents (Enhanced with BLOB/CLOB storage)
CREATE TABLE ProviderDocuments (
    DocumentID INT PRIMARY KEY AUTO_INCREMENT,
    ProviderID INT NOT NULL,
    DocumentType ENUM(
        'Driving_License',
        'Aadhaar_Card',
        'PAN_Card',
        'Vehicle_Registration',
        'Vehicle_Insurance',
        'Pollution_Certificate',
        'Fitness_Certificate',
        'Permit',
        'Photo'
    ) NOT NULL,
    DocumentName VARCHAR(200) NOT NULL,
    DocumentData LONGBLOB COMMENT 'Image/PDF stored as BLOB',
    DocumentText LONGTEXT COMMENT 'Extracted text/metadata as CLOB',
    MimeType VARCHAR(100) NOT NULL,
    FileSize INT,
    VerificationStatus ENUM('Pending', 'Approved', 'Rejected') DEFAULT 'Pending',
    RejectionReason TEXT,
    UploadedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    VerifiedAt TIMESTAMP NULL,
    VerifiedBy INT NULL,
    FOREIGN KEY (ProviderID) REFERENCES ServiceProvider(ProviderID) ON DELETE CASCADE,
    INDEX idx_provider_docs (ProviderID),
    INDEX idx_doc_type (DocumentType),
    INDEX idx_verification (VerificationStatus)
) ENGINE=InnoDB;

-- Vehicle Table (Enhanced with Bus support)
CREATE TABLE Vehicle (
    VehicleID INT PRIMARY KEY AUTO_INCREMENT,
    ProviderID INT NOT NULL,
    VehicleNumber VARCHAR(20) UNIQUE NOT NULL,
    Model VARCHAR(100) NOT NULL,
    VehicleType ENUM('Auto', 'Cab', 'Bike', 'Metro', 'Scooter', 'Bus') NOT NULL,
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

-- Route Table
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
    EndPoint POINT NULL,
    INDEX idx_locations (StartLocation, EndLocation)
) ENGINE=InnoDB;

CREATE SPATIAL INDEX idx_startpoint ON Route(StartPoint);
CREATE SPATIAL INDEX idx_endpoint ON Route(EndPoint);

-- Booking Table (Enhanced for multi-modal)
CREATE TABLE Booking (
    BookingID INT PRIMARY KEY AUTO_INCREMENT,
    UserID INT NOT NULL,
    StartLocation VARCHAR(200) NOT NULL,
    EndLocation VARCHAR(200) NOT NULL,
    TotalDistance DECIMAL(10, 2) NOT NULL,
    TotalTime INT NOT NULL,
    RouteType ENUM('Shortest', 'Fastest', 'Cheapest') NOT NULL,
    TotalFare DECIMAL(10, 2) NOT NULL,
    BookingStatus ENUM('Pending', 'Confirmed', 'InProgress', 'Completed', 'Cancelled') DEFAULT 'Confirmed',
    BookingTime TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CompletedAt TIMESTAMP NULL,
    IsMultiModal BOOLEAN DEFAULT FALSE,
    SegmentCount INT DEFAULT 1,
    FOREIGN KEY (UserID) REFERENCES User(UserID) ON DELETE CASCADE,
    INDEX idx_user_booking (UserID),
    INDEX idx_booking_status (BookingStatus),
    INDEX idx_booking_time (BookingTime)
) ENGINE=InnoDB;

-- Booking Segments (NEW - Core of multi-modal system)
CREATE TABLE BookingSegment (
    SegmentID INT PRIMARY KEY AUTO_INCREMENT,
    BookingID INT NOT NULL,
    SegmentOrder INT NOT NULL,
    VehicleID INT NULL,
    ProviderID INT NULL,
    ServiceType ENUM('Ola', 'Uber', 'Metro', 'Namma Yatri', 'Rapido', 'Bounce', 'BMTC', 'Individual', 'Walk') NOT NULL,
    VehicleType ENUM('Auto', 'Cab', 'Bike', 'Metro', 'Scooter', 'Bus', 'Walk') NOT NULL,
    StartLocation VARCHAR(200) NOT NULL,
    EndLocation VARCHAR(200) NOT NULL,
    Distance DECIMAL(10, 2) NOT NULL,
    EstimatedTime INT NOT NULL,
    SegmentFare DECIMAL(10, 2) NOT NULL,
    VehicleNumber VARCHAR(20) NULL,
    VehicleModel VARCHAR(100) NULL,
    ProviderName VARCHAR(100) NULL,
    ProviderPhone VARCHAR(15) NULL,
    FOREIGN KEY (BookingID) REFERENCES Booking(BookingID) ON DELETE CASCADE,
    FOREIGN KEY (VehicleID) REFERENCES Vehicle(VehicleID) ON DELETE SET NULL,
    FOREIGN KEY (ProviderID) REFERENCES ServiceProvider(ProviderID) ON DELETE SET NULL,
    INDEX idx_booking_segment (BookingID, SegmentOrder)
) ENGINE=InnoDB;

-- Fare Table
CREATE TABLE Fare (
    FareID INT PRIMARY KEY AUTO_INCREMENT,
    ServiceType ENUM('Ola', 'Uber', 'Metro', 'Individual', 'Namma Yatri', 'Rapido', 'Bounce', 'BMTC') NOT NULL,
    VehicleType ENUM('Auto', 'Cab', 'Bike', 'Metro', 'Scooter', 'Bus') NOT NULL,
    BaseFare DECIMAL(10, 2) NOT NULL,
    PerKmRate DECIMAL(10, 2) NOT NULL,
    PerMinuteRate DECIMAL(10, 2) DEFAULT 0.00,
    SurgeMultiplier DECIMAL(3, 2) DEFAULT 1.00,
    UNIQUE KEY unique_service_vehicle (ServiceType, VehicleType)
) ENGINE=InnoDB;

-- Notification Table
CREATE TABLE Notification (
    NotificationID INT PRIMARY KEY AUTO_INCREMENT,
    UserID INT NOT NULL,
    Status ENUM('Pending', 'Sent', 'Read') DEFAULT 'Pending',
    Message TEXT NOT NULL,
    NotificationType ENUM('Booking', 'GetIn', 'GetDown', 'VehicleChange', 'Alert', 'Earnings') NOT NULL,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (UserID) REFERENCES User(UserID) ON DELETE CASCADE,
    INDEX idx_notification_user (UserID),
    INDEX idx_notification_status (Status)
) ENGINE=InnoDB;

-- =====================================================
-- BOUNCE CENTERS TABLE
-- =====================================================

CREATE TABLE BounceCenter (
    CenterID INT PRIMARY KEY AUTO_INCREMENT,
    CenterName VARCHAR(200) NOT NULL,
    Location VARCHAR(200) NOT NULL,
    Area VARCHAR(100) NOT NULL,
    Latitude DECIMAL(10, 8) NOT NULL,
    Longitude DECIMAL(11, 8) NOT NULL,
    AvailableScooters INT DEFAULT 10,
    IsActive BOOLEAN DEFAULT TRUE,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Coordinates POINT NULL,
    INDEX idx_location (Location),
    INDEX idx_active (IsActive)
) ENGINE=InnoDB;

CREATE SPATIAL INDEX idx_bounce_coords ON BounceCenter(Coordinates);

-- =====================================================
-- BUS ROUTES TABLE
-- =====================================================

CREATE TABLE BusRoute (
    BusRouteID INT PRIMARY KEY AUTO_INCREMENT,
    RouteNumber VARCHAR(20) NOT NULL,
    RouteName VARCHAR(200) NOT NULL,
    StartLocation VARCHAR(200) NOT NULL,
    EndLocation VARCHAR(200) NOT NULL,
    Distance DECIMAL(10, 2) NOT NULL,
    EstimatedTime INT NOT NULL,
    Fare DECIMAL(10, 2) NOT NULL,
    Frequency INT DEFAULT 15,
    BusType ENUM('Ordinary', 'Volvo', 'AC', 'Non-AC') DEFAULT 'Ordinary',
    IsActive BOOLEAN DEFAULT TRUE,
    INDEX idx_start_location (StartLocation),
    INDEX idx_route_number (RouteNumber)
) ENGINE=InnoDB;

-- =====================================================
-- ADDITIONAL TABLES
-- =====================================================

CREATE TABLE Payment (
    PaymentID INT PRIMARY KEY AUTO_INCREMENT,
    BookingID INT,
    UserID INT,
    Amount DECIMAL(10,2) NOT NULL,
    Status ENUM('Pending','Completed','Failed') DEFAULT 'Pending',
    PaymentMethod ENUM('Cash','Card','UPI','Wallet') DEFAULT 'UPI',
    TransactionTime TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (BookingID) REFERENCES Booking(BookingID) ON DELETE CASCADE,
    FOREIGN KEY (UserID) REFERENCES User(UserID) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE Rating (
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
) ENGINE=InnoDB;

CREATE TABLE ChatMessage (
    ChatID INT PRIMARY KEY AUTO_INCREMENT,
    BookingID INT,
    SenderID INT,
    Message TEXT NOT NULL,
    Timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (BookingID) REFERENCES Booking(BookingID) ON DELETE CASCADE,
    FOREIGN KEY (SenderID) REFERENCES User(UserID) ON DELETE CASCADE
) ENGINE=InnoDB;

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

SELECT '✅ Schema created successfully!' AS Status;
SELECT 'Total Tables Created: 15' AS Info;
