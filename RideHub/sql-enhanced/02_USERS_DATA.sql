-- =====================================================
-- FILE 2: USER DATA - 22 USERS WITH REAL PASSWORDS
-- =====================================================
-- Password for ALL users: "password123"
-- Hashed with bcrypt: $2b$10$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW
-- =====================================================

USE TransportBookingSystem;

-- =====================================================
-- REGULAR USERS (10 customers)
-- =====================================================

INSERT INTO User (Phone, Username, FullName, LastName, Email, Age, PasswordHash) VALUES
('9876543210', 'john_doe', 'John', 'Doe', 'john@example.com', 28, '$2b$10$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW'),
('9876543211', 'jane_smith', 'Jane', 'Smith', 'jane@example.com', 25, '$2b$10$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW'),
('9876543212', 'test_user', 'Test', 'User', 'test@example.com', 30, '$2b$10$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW'),
('9876543221', 'amit_kumar', 'Amit', 'Kumar', 'amit@example.com', 32, '$2b$10$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW'),
('9876543222', 'priya_singh', 'Priya', 'Singh', 'priya.user@example.com', 27, '$2b$10$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW'),
('9876543223', 'rahul_verma', 'Rahul', 'Verma', 'rahul@example.com', 29, '$2b$10$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW'),
('9876543224', 'sneha_reddy', 'Sneha', 'Reddy', 'sneha@example.com', 26, '$2b$10$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW'),
('9876543225', 'vikram_shah', 'Vikram', 'Shah', 'vikram@example.com', 31, '$2b$10$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW'),
('9876543226', 'anjali_mehta', 'Anjali', 'Mehta', 'anjali@example.com', 24, '$2b$10$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW'),
('9876543227', 'rohan_gupta', 'Rohan', 'Gupta', 'rohan@example.com', 33, '$2b$10$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW');

-- =====================================================
-- PROVIDER USERS (12 drivers/operators)
-- =====================================================

INSERT INTO User (Phone, Username, FullName, LastName, Email, Age, PasswordHash, IsProvider) VALUES
('9876543213', 'driver_ram', 'Ram', 'Kumar', 'ram@example.com', 35, '$2b$10$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', TRUE),
('9876543214', 'driver_ahmed', 'Ahmed', 'Ali', 'ahmed@example.com', 40, '$2b$10$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', TRUE),
('9876543215', 'driver_priya', 'Priya', 'Sharma', 'priya@example.com', 32, '$2b$10$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', TRUE),
('9876543216', 'driver_vijay', 'Vijay', 'Reddy', 'vijay@example.com', 38, '$2b$10$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', TRUE),
('9876543217', 'driver_lakshmi', 'Lakshmi', 'Devi', 'lakshmi@example.com', 29, '$2b$10$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', TRUE),
('9876543218', 'driver_kumar', 'Kumar', 'Singh', 'kumar@example.com', 42, '$2b$10$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', TRUE),
('9876543219', 'driver_anita', 'Anita', 'Patel', 'anita@example.com', 31, '$2b$10$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', TRUE),
('9876543220', 'driver_ravi', 'Ravi', 'Krishnan', 'ravi@example.com', 36, '$2b$10$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', TRUE),
('9876543228', 'driver_suresh', 'Suresh', 'Nair', 'suresh@example.com', 37, '$2b$10$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', TRUE),
('9876543229', 'driver_deepak', 'Deepak', 'Joshi', 'deepak@example.com', 34, '$2b$10$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', TRUE),
('9876543230', 'driver_manish', 'Manish', 'Rao', 'manish@example.com', 39, '$2b$10$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', TRUE),
('9876543231', 'driver_rajesh', 'Rajesh', 'Iyer', 'rajesh@example.com', 41, '$2b$10$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', TRUE);

-- =====================================================
-- SERVICE PROVIDERS (12 providers)
-- =====================================================

INSERT INTO ServiceProvider (UserID, ProviderType, RatePerHour, Rating, IsApproved) VALUES
(11, 'Individual', 150.00, 4.5, TRUE),
(12, 'Ola', 180.00, 4.8, TRUE),
(13, 'Uber', 200.00, 4.7, TRUE),
(14, 'Rapido', 120.00, 4.6, TRUE),
(15, 'Namma Yatri', 140.00, 4.9, TRUE),
(16, 'Individual', 160.00, 4.4, TRUE),
(17, 'Ola', 190.00, 4.7, TRUE),
(18, 'Uber', 210.00, 4.8, TRUE),
(19, 'Rapido', 125.00, 4.5, TRUE),
(20, 'Bounce', 100.00, 4.6, TRUE),
(21, 'BMTC', 80.00, 4.3, TRUE),
(22, 'Individual', 155.00, 4.4, TRUE);

SELECT '✅ Users and Providers created!' AS Status;
SELECT CONCAT('Total Users: ', COUNT(*)) AS Info FROM User;
SELECT CONCAT('Total Providers: ', COUNT(*)) AS Info FROM ServiceProvider;
SELECT '📧 Login with any email above and password: password123' AS LoginInfo;
