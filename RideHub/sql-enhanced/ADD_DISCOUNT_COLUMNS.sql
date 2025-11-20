-- =====================================================
-- ADD DISCOUNT COLUMNS TO BOOKING TABLE
-- =====================================================
-- Run this to add offer/discount support to existing bookings

USE TransportBookingSystem;

-- Add discount-related columns to Booking table
ALTER TABLE Booking 
ADD COLUMN OfferCode VARCHAR(50) NULL,
ADD COLUMN DiscountPercentage DECIMAL(5, 2) NULL,
ADD COLUMN DiscountAmount DECIMAL(10, 2) DEFAULT 0.00,
ADD COLUMN OriginalFare DECIMAL(10, 2) NULL;

-- Update existing bookings to have OriginalFare = TotalFare
UPDATE Booking 
SET OriginalFare = TotalFare 
WHERE OriginalFare IS NULL;

-- Add index for offer code lookups
CREATE INDEX idx_booking_offer ON Booking(OfferCode);

-- Verify the changes
SELECT 'Booking table updated with discount columns!' AS Status;

DESCRIBE Booking;

-- Show sample of updated structure
SELECT 
    BookingID,
    TotalFare,
    OriginalFare,
    DiscountAmount,
    OfferCode,
    DiscountPercentage
FROM Booking 
LIMIT 3;

SELECT '✅ Discount columns added successfully!' AS Message;