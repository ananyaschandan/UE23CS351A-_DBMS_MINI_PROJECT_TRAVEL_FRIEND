-- =====================================================
-- FILE 7: STORED PROCEDURES AND TRIGGERS
-- =====================================================
-- Multi-modal booking procedures + Notification triggers
-- =====================================================

USE TransportBookingSystem;

DELIMITER //

-- =====================================================
-- PROCEDURE 1: Create Multi-Modal Booking
-- =====================================================

CREATE PROCEDURE CreateMultiModalBooking(
    IN p_UserID INT,
    IN p_StartLocation VARCHAR(200),
    IN p_EndLocation VARCHAR(200),
    IN p_TotalDistance DECIMAL(10,2),
    IN p_TotalTime INT,
    IN p_TotalFare DECIMAL(10,2),
    IN p_RouteType ENUM('Shortest', 'Fastest', 'Cheapest'),
    IN p_IsMultiModal BOOLEAN,
    IN p_SegmentCount INT
)
BEGIN
    DECLARE v_BookingID INT;
    
    -- Insert main booking
    INSERT INTO Booking (
        UserID, StartLocation, EndLocation,
        TotalDistance, TotalTime, RouteType,
        TotalFare, BookingStatus, IsMultiModal, SegmentCount
    )
    VALUES (
        p_UserID, p_StartLocation, p_EndLocation,
        p_TotalDistance, p_TotalTime, p_RouteType,
        p_TotalFare, 'Confirmed', p_IsMultiModal, p_SegmentCount
    );
    
    SET v_BookingID = LAST_INSERT_ID();
    
    -- Return booking ID
    SELECT v_BookingID AS BookingID, 'Booking created successfully' AS Message;
END //

-- =====================================================
-- PROCEDURE 2: Add Booking Segment
-- =====================================================

CREATE PROCEDURE AddBookingSegment(
    IN p_BookingID INT,
    IN p_SegmentOrder INT,
    IN p_ServiceType VARCHAR(20),
    IN p_VehicleType VARCHAR(20),
    IN p_StartLocation VARCHAR(200),
    IN p_EndLocation VARCHAR(200),
    IN p_Distance DECIMAL(10,2),
    IN p_EstimatedTime INT,
    IN p_SegmentFare DECIMAL(10,2)
)
BEGIN
    DECLARE v_VehicleID INT DEFAULT NULL;
    DECLARE v_ProviderID INT DEFAULT NULL;
    DECLARE v_VehicleNumber VARCHAR(20) DEFAULT NULL;
    DECLARE v_VehicleModel VARCHAR(100) DEFAULT NULL;
    DECLARE v_ProviderName VARCHAR(100) DEFAULT NULL;
    DECLARE v_ProviderPhone VARCHAR(15) DEFAULT NULL;
    DECLARE v_ProviderUserID INT DEFAULT NULL;
    
    -- Find available vehicle (skip for Walk segments)
    IF p_ServiceType != 'Walk' THEN
        SELECT v.VehicleID, v.ProviderID, v.VehicleNumber, v.Model
        INTO v_VehicleID, v_ProviderID, v_VehicleNumber, v_VehicleModel
        FROM Vehicle v
        JOIN ServiceProvider sp ON v.ProviderID = sp.ProviderID
        WHERE v.VehicleType = p_VehicleType
          AND v.IsAvailable = TRUE
          AND sp.ProviderType = p_ServiceType
          AND sp.IsApproved = TRUE
        ORDER BY sp.Rating DESC, v.TotalRides ASC
        LIMIT 1;
        
        -- Get provider details
        IF v_ProviderID IS NOT NULL THEN
            SELECT u.FullName, u.Phone, sp.UserID
            INTO v_ProviderName, v_ProviderPhone, v_ProviderUserID
            FROM ServiceProvider sp
            JOIN User u ON sp.UserID = u.UserID
            WHERE sp.ProviderID = v_ProviderID;
        END IF;
    END IF;
    
    -- Insert segment
    INSERT INTO BookingSegment (
        BookingID, SegmentOrder, VehicleID, ProviderID,
        ServiceType, VehicleType, StartLocation, EndLocation,
        Distance, EstimatedTime, SegmentFare,
        VehicleNumber, VehicleModel, ProviderName, ProviderPhone
    )
    VALUES (
        p_BookingID, p_SegmentOrder, v_VehicleID, v_ProviderID,
        p_ServiceType, p_VehicleType, p_StartLocation, p_EndLocation,
        p_Distance, p_EstimatedTime, p_SegmentFare,
        v_VehicleNumber, v_VehicleModel, v_ProviderName, v_ProviderPhone
    );
    
    -- Update vehicle and provider counts
    IF v_VehicleID IS NOT NULL THEN
        UPDATE Vehicle SET TotalRides = TotalRides + 1 WHERE VehicleID = v_VehicleID;
    END IF;
    
    IF v_ProviderID IS NOT NULL THEN
        UPDATE ServiceProvider SET TotalRides = TotalRides + 1 WHERE ProviderID = v_ProviderID;
        
        -- Send notification to provider
        IF v_ProviderUserID IS NOT NULL THEN
            INSERT INTO Notification (UserID, Message, NotificationType, Status)
            VALUES (
                v_ProviderUserID,
                CONCAT('New booking segment assigned! From ', p_StartLocation, ' to ', p_EndLocation, '. Segment ', p_SegmentOrder),
                'Booking',
                'Pending'
            );
        END IF;
    END IF;
    
    SELECT LAST_INSERT_ID() AS SegmentID, 'Segment added successfully' AS Message;
END //

-- =====================================================
-- PROCEDURE 3: Complete Booking with Earnings
-- =====================================================

CREATE PROCEDURE CompleteBooking(
    IN p_BookingID INT
)
BEGIN
    DECLARE v_TotalFare DECIMAL(10,2);
    DECLARE v_ProviderEarnings DECIMAL(10,2);
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_ProviderID INT;
    DECLARE v_VehicleID INT;
    DECLARE v_SegmentFare DECIMAL(10,2);
    
    DECLARE segment_cursor CURSOR FOR 
        SELECT ProviderID, VehicleID, SegmentFare 
        FROM BookingSegment 
        WHERE BookingID = p_BookingID AND ProviderID IS NOT NULL;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    -- Get total fare
    SELECT TotalFare INTO v_TotalFare
    FROM Booking
    WHERE BookingID = p_BookingID;
    
    -- Update booking status
    UPDATE Booking 
    SET BookingStatus = 'Completed', CompletedAt = CURRENT_TIMESTAMP
    WHERE BookingID = p_BookingID;
    
    -- Update earnings for each segment's provider (80% of segment fare)
    OPEN segment_cursor;
    
    read_loop: LOOP
        FETCH segment_cursor INTO v_ProviderID, v_VehicleID, v_SegmentFare;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        SET v_ProviderEarnings = ROUND(v_SegmentFare * 0.80, 2);
        
        IF v_ProviderID IS NOT NULL THEN
            UPDATE ServiceProvider 
            SET TotalEarnings = TotalEarnings + v_ProviderEarnings
            WHERE ProviderID = v_ProviderID;
        END IF;
        
        IF v_VehicleID IS NOT NULL THEN
            UPDATE Vehicle 
            SET TotalEarnings = TotalEarnings + v_ProviderEarnings,
                IsAvailable = TRUE
            WHERE VehicleID = v_VehicleID;
        END IF;
    END LOOP;
    
    CLOSE segment_cursor;
    
    SELECT 'Booking completed and earnings updated' AS Message;
END //

-- =====================================================
-- TRIGGER 1: Notify User on Booking Creation
-- =====================================================

CREATE TRIGGER trg_NotifyUserOnBooking
AFTER INSERT ON Booking
FOR EACH ROW
BEGIN
    INSERT INTO Notification (UserID, Message, NotificationType, Status)
    VALUES (
        NEW.UserID,
        CONCAT('Your booking #', NEW.BookingID, ' has been confirmed! Total Fare: ₹', NEW.TotalFare, '. ', 
               CASE WHEN NEW.IsMultiModal THEN CONCAT('Multi-modal journey with ', NEW.SegmentCount, ' segments.') 
                    ELSE 'Single vehicle journey.' END),
        'Booking',
        'Pending'
    );
END //

-- =====================================================
-- TRIGGER 2: Notify on Vehicle Change (Segment)
-- =====================================================

CREATE TRIGGER trg_NotifyVehicleChange
AFTER INSERT ON BookingSegment
FOR EACH ROW
BEGIN
    DECLARE v_UserID INT;
    
    -- Get user ID from booking
    SELECT UserID INTO v_UserID
    FROM Booking
    WHERE BookingID = NEW.BookingID;
    
    -- Only notify if this is segment 2 or higher (vehicle change)
    IF NEW.SegmentOrder > 1 THEN
        INSERT INTO Notification (UserID, Message, NotificationType, Status)
        VALUES (
            v_UserID,
            CONCAT('🚗 Vehicle Change Alert! Segment ', NEW.SegmentOrder, ': Switch to ', 
                   NEW.ServiceType, ' ', NEW.VehicleType, 
                   CASE WHEN NEW.VehicleNumber IS NOT NULL 
                        THEN CONCAT(' (', NEW.VehicleNumber, ')') 
                        ELSE '' END,
                   ' at ', NEW.StartLocation),
            'VehicleChange',
            'Pending'
        );
    END IF;
END //

-- =====================================================
-- TRIGGER 3: Update Provider Rating
-- =====================================================

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

DELIMITER ;

SELECT '✅ Procedures and Triggers created!' AS Status;
SELECT 'Procedures: CreateMultiModalBooking, AddBookingSegment, CompleteBooking' AS Info;
SELECT 'Triggers: trg_NotifyUserOnBooking, trg_NotifyVehicleChange, trg_UpdateProviderRating' AS Info;
