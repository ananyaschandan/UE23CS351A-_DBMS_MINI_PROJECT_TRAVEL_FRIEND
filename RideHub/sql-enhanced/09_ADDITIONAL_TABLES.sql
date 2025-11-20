-- =====================================================
-- FILE 9: ADDITIONAL TABLES (Missing from Enhanced Schema)
-- =====================================================
-- Tables from old DATABASE_COMPLETE.sql that weren't included:
-- - Job (User occupation)
-- - MetroStation
-- - Schedule (Metro/Bus timings)
-- - TrafficCondition
-- - Offers/Discounts
-- - PreferredRoad (User custom routes)
-- - Recommendation
-- - BookingVehicle (Junction table)
-- - BookingRoute (Junction table)
-- - RecommendedServices
-- - Admin
-- =====================================================

USE TransportBookingSystem;

-- =====================================================
-- JOB/OCCUPATION TABLE
-- =====================================================

CREATE TABLE Job (
    JobID INT PRIMARY KEY AUTO_INCREMENT,
    UserID INT,
    Occupation VARCHAR(100),
    FOREIGN KEY (UserID) REFERENCES User(UserID) ON DELETE CASCADE
) ENGINE=InnoDB;

-- =====================================================
-- METRO STATION TABLE
-- =====================================================

CREATE TABLE MetroStation (
    StationID INT PRIMARY KEY AUTO_INCREMENT,
    StationName VARCHAR(100) UNIQUE NOT NULL,
    Location VARCHAR(200) NOT NULL,
    LineColor VARCHAR(50),
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- =====================================================
-- SCHEDULE TABLE (Metro/Bus Timings)
-- =====================================================

CREATE TABLE Schedule (
    ScheduleID INT PRIMARY KEY AUTO_INCREMENT,
    RouteID INT,
    VehicleType ENUM('Metro', 'Bus') NOT NULL,
    DepartureTime TIME NOT NULL,
    ArrivalTime TIME NOT NULL,
    FOREIGN KEY (RouteID) REFERENCES Route(RouteID) ON DELETE CASCADE
) ENGINE=InnoDB;

-- =====================================================
-- TRAFFIC CONDITION TABLE
-- =====================================================

CREATE TABLE TrafficCondition (
    TrafficID INT PRIMARY KEY AUTO_INCREMENT,
    RouteID INT,
    Condition ENUM('Low', 'Medium', 'High') DEFAULT 'Medium',
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (RouteID) REFERENCES Route(RouteID) ON DELETE CASCADE
) ENGINE=InnoDB;

-- =====================================================
-- OFFERS/DISCOUNTS TABLE
-- =====================================================

CREATE TABLE Offers (
    OfferID INT PRIMARY KEY AUTO_INCREMENT,
    OfferCode VARCHAR(50) UNIQUE NOT NULL,
    DiscountPercentage DECIMAL(5, 2),
    MaxDiscountAmount DECIMAL(10, 2),
    ValidFrom DATE,
    ValidTo DATE,
    IsActive BOOLEAN DEFAULT TRUE
) ENGINE=InnoDB;

-- =====================================================
-- PREFERRED ROAD TABLE (User Custom Routes)
-- =====================================================

CREATE TABLE PreferredRoad (
    PreferredRoadID INT PRIMARY KEY AUTO_INCREMENT,
    UserID INT,
    RouteID INT,
    PreferenceName VARCHAR(100),
    FOREIGN KEY (UserID) REFERENCES User(UserID) ON DELETE CASCADE,
    FOREIGN KEY (RouteID) REFERENCES Route(RouteID) ON DELETE CASCADE
) ENGINE=InnoDB;

-- =====================================================
-- RECOMMENDATION TABLE
-- =====================================================

CREATE TABLE Recommendation (
    RecommendationID INT PRIMARY KEY AUTO_INCREMENT,
    UserID INT,
    RouteID INT,
    RecommendationType ENUM('Fastest', 'Cheapest', 'Shortest', 'Eco-Friendly') NOT NULL,
    EstimatedFare DECIMAL(10, 2),
    EstimatedTime INT,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (UserID) REFERENCES User(UserID) ON DELETE CASCADE,
    FOREIGN KEY (RouteID) REFERENCES Route(RouteID) ON DELETE CASCADE
) ENGINE=InnoDB;

-- =====================================================
-- JUNCTION TABLES
-- =====================================================

-- Booking-Vehicle Junction (Multi-modal bookings - Legacy support)
CREATE TABLE BookingVehicle (
    BookingVehicleID INT PRIMARY KEY AUTO_INCREMENT,
    BookingID INT,
    VehicleID INT,
    SegmentOrder INT DEFAULT 1,
    SegmentDistance DECIMAL(10, 2),
    SegmentFare DECIMAL(10, 2),
    FOREIGN KEY (BookingID) REFERENCES Booking(BookingID) ON DELETE CASCADE,
    FOREIGN KEY (VehicleID) REFERENCES Vehicle(VehicleID) ON DELETE SET NULL,
    INDEX idx_booking_vehicle (BookingID, SegmentOrder)
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
    ServiceType ENUM('Ola', 'Uber', 'Metro', 'Individual', 'Namma Yatri', 'Rapido', 'Bounce', 'BMTC') NOT NULL,
    VehicleType ENUM('Auto', 'Cab', 'Bike', 'Metro', 'Scooter', 'Bus') NOT NULL,
    EstimatedFare DECIMAL(10, 2),
    FOREIGN KEY (RecommendationID) REFERENCES Recommendation(RecommendationID) ON DELETE CASCADE
) ENGINE=InnoDB;

-- =====================================================
-- ADMIN TABLE
-- =====================================================

CREATE TABLE Admin (
    AdminID INT PRIMARY KEY AUTO_INCREMENT,
    Username VARCHAR(50) UNIQUE NOT NULL,
    PasswordHash VARCHAR(255) NOT NULL,
    IsSuperAdmin BOOLEAN DEFAULT FALSE,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- =====================================================
-- INSERT SAMPLE DATA
-- =====================================================

-- Sample Metro Stations (Bangalore Metro)
INSERT INTO MetroStation (StationName, Location, LineColor) VALUES
('Majestic Metro', 'Majestic', 'Purple'),
('MG Road Metro', 'MG Road', 'Purple'),
('Indiranagar Metro', 'Indiranagar', 'Purple'),
('Baiyappanahalli', 'Baiyappanahalli', 'Purple'),
('Swami Vivekananda Road', 'Swami Vivekananda Road', 'Purple'),
('Halasuru', 'Halasuru', 'Purple'),
('Trinity', 'Trinity', 'Purple'),
('Vidhana Soudha', 'Vidhana Soudha', 'Green'),
('Cubbon Park', 'Cubbon Park', 'Green'),
('Rajajinagar', 'Rajajinagar', 'Green'),
('Yeshwanthpur', 'Yeshwanthpur', 'Green'),
('Sandal Soap Factory', 'Sandal Soap Factory', 'Green'),
('Mahalakshmi', 'Mahalakshmi', 'Green'),
('Peenya Industry', 'Peenya Industry', 'Green'),
('Nagasandra', 'Nagasandra', 'Green');

-- Sample Metro Schedules
INSERT INTO Schedule (RouteID, VehicleType, DepartureTime, ArrivalTime) VALUES
(1, 'Metro', '06:00:00', '06:15:00'),
(1, 'Metro', '06:30:00', '06:45:00'),
(2, 'Metro', '06:15:00', '06:30:00'),
(3, 'Metro', '06:45:00', '07:05:00'),
(4, 'Metro', '07:00:00', '07:25:00');

-- Sample Traffic Conditions
INSERT INTO TrafficCondition (RouteID, Condition) VALUES
(1, 'Low'),
(2, 'Low'),
(3, 'Medium'),
(4, 'High'),
(5, 'Medium'),
(7, 'High'),
(8, 'Medium');

-- Sample Offers
INSERT INTO Offers (OfferCode, DiscountPercentage, MaxDiscountAmount, ValidFrom, ValidTo, IsActive) VALUES
('FIRST50', 50.00, 100.00, '2024-01-01', '2024-12-31', TRUE),
('WEEKEND20', 20.00, 50.00, '2024-01-01', '2024-12-31', TRUE),
('METRO15', 15.00, 30.00, '2024-01-01', '2024-12-31', TRUE),
('NEWUSER100', 100.00, 100.00, '2024-01-01', '2024-12-31', TRUE),
('SAVE25', 25.00, 75.00, '2024-01-01', '2024-12-31', TRUE);

-- Sample Admin User
INSERT INTO Admin (Username, PasswordHash, IsSuperAdmin) VALUES
('admin', '$2b$10$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', TRUE),
('support', '$2b$10$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', FALSE);

-- Sample Job/Occupation Data
INSERT INTO Job (UserID, Occupation) VALUES
(1, 'Software Engineer'),
(2, 'Teacher'),
(3, 'Business Analyst'),
(4, 'Driver'),
(5, 'Driver'),
(6, 'Driver');

SELECT '✅ Additional tables created!' AS Status;
SELECT 'Tables: Job, MetroStation, Schedule, TrafficCondition, Offers, PreferredRoad, Recommendation, BookingVehicle, BookingRoute, RecommendedServices, Admin' AS Info;
SELECT CONCAT('Metro Stations: ', COUNT(*)) AS Info FROM MetroStation;
SELECT CONCAT('Offers: ', COUNT(*)) AS Info FROM Offers;
SELECT CONCAT('Admins: ', COUNT(*)) AS Info FROM Admin;
