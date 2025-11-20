-- ============================================
-- ADD ADMIN PRIVILEGES TO RIDEHUB DATABASE
-- ============================================

USE TransportBookingSystem;

-- Step 1: Add admin role column to User table
ALTER TABLE User 
ADD COLUMN UserRole ENUM('user', 'provider', 'admin') DEFAULT 'user' AFTER IsProvider;

-- Step 2: Update existing users based on IsProvider flag
UPDATE User 
SET UserRole = CASE 
    WHEN IsProvider = 1 THEN 'provider'
    ELSE 'user'
END;

-- Step 3: Create admin users
INSERT INTO User (FullName, Email, PasswordHash, PhoneNumber, UserRole, IsProvider, CreatedAt) VALUES
('Admin User', 'admin@ridehub.com', '$2b$10$rQJ8vQZ9Zm9Zm9Zm9Zm9ZuGKqJ8vQZ9Zm9Zm9Zm9Zm9Zm9Zm9Zm9Z', '9999999999', 'admin', 0, NOW()),
('Super Admin', 'superadmin@ridehub.com', '$2b$10$rQJ8vQZ9Zm9Zm9Zm9Zm9ZuGKqJ8vQZ9Zm9Zm9Zm9Zm9Zm9Zm9Zm9Z', '9999999998', 'admin', 0, NOW()),
('System Admin', 'system@ridehub.com', '$2b$10$rQJ8vQZ9Zm9Zm9Zm9Zm9ZuGKqJ8vQZ9Zm9Zm9Zm9Zm9Zm9Zm9Zm9Z', '9999999997', 'admin', 0, NOW());

-- Step 4: Create AdminActions table for audit logging
CREATE TABLE AdminActions (
    ActionID INT PRIMARY KEY AUTO_INCREMENT,
    AdminUserID INT NOT NULL,
    ActionType ENUM('user_management', 'provider_management', 'booking_management', 'offer_management', 'system_config', 'data_export') NOT NULL,
    ActionDescription TEXT NOT NULL,
    TargetTable VARCHAR(50),
    TargetRecordID INT,
    OldValues JSON,
    NewValues JSON,
    IPAddress VARCHAR(45),
    UserAgent TEXT,
    ActionTimestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (AdminUserID) REFERENCES User(UserID) ON DELETE CASCADE,
    INDEX idx_admin_actions_user (AdminUserID),
    INDEX idx_admin_actions_type (ActionType),
    INDEX idx_admin_actions_timestamp (ActionTimestamp)
);

-- Step 5: Create AdminSettings table for system configuration
CREATE TABLE AdminSettings (
    SettingID INT PRIMARY KEY AUTO_INCREMENT,
    SettingKey VARCHAR(100) UNIQUE NOT NULL,
    SettingValue TEXT NOT NULL,
    SettingDescription TEXT,
    ModifiedBy INT NOT NULL,
    ModifiedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (ModifiedBy) REFERENCES User(UserID),
    INDEX idx_admin_settings_key (SettingKey)
);

-- Step 6: Insert default admin settings
INSERT INTO AdminSettings (SettingKey, SettingValue, SettingDescription, ModifiedBy) VALUES
('system_maintenance_mode', 'false', 'Enable/disable system maintenance mode', 1),
('max_bookings_per_user_per_day', '10', 'Maximum bookings allowed per user per day', 1),
('default_booking_timeout_minutes', '15', 'Default booking timeout in minutes', 1),
('enable_new_user_registration', 'true', 'Allow new user registrations', 1),
('enable_provider_registration', 'true', 'Allow new provider registrations', 1),
('system_notification_email', 'admin@ridehub.com', 'System notification email address', 1),
('redis_cache_ttl_hours', '24', 'Redis cache TTL in hours', 1),
('ai_trip_quota_per_user_per_day', '20', 'AI trip suggestions quota per user per day', 1);

-- Step 7: Create stored procedure for admin actions logging
DELIMITER //
CREATE PROCEDURE LogAdminAction(
    IN p_AdminUserID INT,
    IN p_ActionType ENUM('user_management', 'provider_management', 'booking_management', 'offer_management', 'system_config', 'data_export'),
    IN p_ActionDescription TEXT,
    IN p_TargetTable VARCHAR(50),
    IN p_TargetRecordID INT,
    IN p_OldValues JSON,
    IN p_NewValues JSON,
    IN p_IPAddress VARCHAR(45),
    IN p_UserAgent TEXT
)
BEGIN
    INSERT INTO AdminActions (
        AdminUserID, ActionType, ActionDescription, TargetTable, 
        TargetRecordID, OldValues, NewValues, IPAddress, UserAgent
    ) VALUES (
        p_AdminUserID, p_ActionType, p_ActionDescription, p_TargetTable,
        p_TargetRecordID, p_OldValues, p_NewValues, p_IPAddress, p_UserAgent
    );
END //
DELIMITER ;

-- Step 8: Create admin analytics views
CREATE VIEW AdminDashboardStats AS
SELECT 
    (SELECT COUNT(*) FROM User WHERE UserRole = 'user') AS total_users,
    (SELECT COUNT(*) FROM User WHERE UserRole = 'provider') AS total_providers,
    (SELECT COUNT(*) FROM User WHERE UserRole = 'admin') AS total_admins,
    (SELECT COUNT(*) FROM Booking) AS total_bookings,
    (SELECT COUNT(*) FROM Booking WHERE BookingStatus = 'Confirmed') AS confirmed_bookings,
    (SELECT COUNT(*) FROM Booking WHERE BookingStatus = 'Cancelled') AS cancelled_bookings,
    (SELECT COUNT(*) FROM Vehicle WHERE IsActive = 1) AS active_vehicles,
    (SELECT COUNT(*) FROM Offers WHERE IsActive = 1) AS active_offers,
    (SELECT SUM(TotalFare) FROM Booking WHERE BookingStatus = 'Confirmed') AS total_revenue,
    (SELECT SUM(DiscountAmount) FROM Booking WHERE OfferCode IS NOT NULL) AS total_discounts_given,
    (SELECT COUNT(*) FROM AITripRequests WHERE DATE(RequestTimestamp) = CURDATE()) AS ai_requests_today,
    (SELECT COUNT(*) FROM Notifications WHERE DATE(CreatedAt) = CURDATE()) AS notifications_today;

CREATE VIEW UserActivitySummary AS
SELECT 
    u.UserID,
    u.FullName,
    u.Email,
    u.UserRole,
    u.CreatedAt as registration_date,
    COUNT(DISTINCT b.BookingID) as total_bookings,
    COALESCE(SUM(b.TotalFare), 0) as total_spent,
    COUNT(DISTINCT uo.OfferID) as offers_used,
    MAX(b.BookingTime) as last_booking_date,
    COUNT(DISTINCT atr.RequestID) as ai_requests_count,
    CASE 
        WHEN MAX(b.BookingTime) >= DATE_SUB(NOW(), INTERVAL 30 DAY) THEN 'Active'
        WHEN MAX(b.BookingTime) >= DATE_SUB(NOW(), INTERVAL 90 DAY) THEN 'Inactive'
        ELSE 'Dormant'
    END as user_status
FROM User u
LEFT JOIN Booking b ON u.UserID = b.UserID
LEFT JOIN UserOffers uo ON u.UserID = uo.UserID
LEFT JOIN AITripRequests atr ON u.UserID = atr.UserID
WHERE u.UserRole IN ('user', 'provider')
GROUP BY u.UserID, u.FullName, u.Email, u.UserRole, u.CreatedAt;

CREATE VIEW ProviderPerformanceSummary AS
SELECT 
    sp.ProviderID,
    u.FullName as provider_name,
    u.Email,
    sp.CompanyName,
    sp.ServiceType,
    sp.IsVerified,
    COUNT(DISTINCT v.VehicleID) as total_vehicles,
    COUNT(DISTINCT CASE WHEN v.IsActive = 1 THEN v.VehicleID END) as active_vehicles,
    COUNT(DISTINCT bs.SegmentID) as total_bookings,
    COALESCE(SUM(bs.Fare), 0) as total_earnings,
    AVG(bs.Fare) as avg_booking_value,
    MAX(bs.BookingDate) as last_booking_date
FROM ServiceProvider sp
JOIN User u ON sp.UserID = u.UserID
LEFT JOIN Vehicle v ON sp.ProviderID = v.ProviderID
LEFT JOIN BookingSegment bs ON v.VehicleID = bs.VehicleID
GROUP BY sp.ProviderID, u.FullName, u.Email, sp.CompanyName, sp.ServiceType, sp.IsVerified;

-- Step 9: Create admin-specific indexes for performance
CREATE INDEX idx_user_role ON User(UserRole);
CREATE INDEX idx_admin_actions_admin_user ON AdminActions(AdminUserID, ActionTimestamp);
CREATE INDEX idx_booking_status_date ON Booking(BookingStatus, BookingTime);

-- Step 10: Update admin user passwords (use bcrypt hash for 'admin123')
-- Note: In production, use proper password hashing
UPDATE User 
SET PasswordHash = '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi' 
WHERE UserRole = 'admin';

-- Step 11: Verification queries
SELECT 'Admin Users Created' as status, COUNT(*) as count FROM User WHERE UserRole = 'admin';
SELECT 'Admin Tables Created' as status, COUNT(*) as count FROM information_schema.tables WHERE table_schema = 'TransportBookingSystem' AND table_name IN ('AdminActions', 'AdminSettings');
SELECT 'Admin Views Created' as status, COUNT(*) as count FROM information_schema.views WHERE table_schema = 'TransportBookingSystem' AND table_name LIKE '%Admin%' OR table_name LIKE '%Summary';

-- Display admin dashboard stats
SELECT * FROM AdminDashboardStats;

COMMIT;
