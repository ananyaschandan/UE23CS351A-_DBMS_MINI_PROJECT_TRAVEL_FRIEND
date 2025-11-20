-- =====================================================
-- UPDATE BOOKING PROCEDURE TO HANDLE DISCOUNTS
-- =====================================================

USE TransportBookingSystem;

-- Drop existing procedure
DROP PROCEDURE IF EXISTS CreateMultiModalBooking;

-- Create updated procedure with discount support
DELIMITER $$

CREATE PROCEDURE CreateMultiModalBooking(
    IN p_UserID INT,
    IN p_StartLocation VARCHAR(200),
    IN p_EndLocation VARCHAR(200),
    IN p_TotalDistance DECIMAL(10,2),
    IN p_TotalTime INT,
    IN p_TotalFare DECIMAL(10,2),
    IN p_RouteType ENUM('Shortest', 'Fastest', 'Cheapest'),
    IN p_IsMultiModal BOOLEAN,
    IN p_SegmentCount INT,
    IN p_OfferCode VARCHAR(50),
    IN p_DiscountPercentage DECIMAL(5,2),
    IN p_DiscountAmount DECIMAL(10,2),
    IN p_OriginalFare DECIMAL(10,2)
)
BEGIN
    DECLARE v_BookingID INT;
    
    -- Insert main booking with discount information
    INSERT INTO Booking (
        UserID, StartLocation, EndLocation,
        TotalDistance, TotalTime, RouteType,
        TotalFare, OriginalFare, OfferCode, 
        DiscountPercentage, DiscountAmount,
        BookingStatus, IsMultiModal, SegmentCount
    )
    VALUES (
        p_UserID, p_StartLocation, p_EndLocation,
        p_TotalDistance, p_TotalTime, p_RouteType,
        p_TotalFare, p_OriginalFare, p_OfferCode,
        p_DiscountPercentage, p_DiscountAmount,
        'Confirmed', p_IsMultiModal, p_SegmentCount
    );
    
    SET v_BookingID = LAST_INSERT_ID();
    
    -- Log discount application if offer was used
    IF p_OfferCode IS NOT NULL THEN
        SELECT CONCAT('✅ Booking ', v_BookingID, ' created with offer ', p_OfferCode, 
                     ' (₹', p_DiscountAmount, ' discount)') AS Message;
    ELSE
        SELECT CONCAT('✅ Booking ', v_BookingID, ' created without offer') AS Message;
    END IF;
    
    -- Return booking ID and details
    SELECT 
        v_BookingID AS BookingID, 
        p_TotalFare AS FinalAmount,
        p_OriginalFare AS OriginalAmount,
        p_DiscountAmount AS DiscountApplied,
        p_OfferCode AS OfferUsed,
        'Booking created successfully' AS Status;
END$$

DELIMITER ;

-- Test the updated procedure
SELECT '✅ Updated CreateMultiModalBooking procedure with discount support!' AS Status;

-- Show procedure definition
SHOW CREATE PROCEDURE CreateMultiModalBooking;