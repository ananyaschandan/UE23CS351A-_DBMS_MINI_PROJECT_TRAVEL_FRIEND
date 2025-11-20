-- =====================================================
-- OFFERS QUICK FIX - Run this to fix offers immediately
-- =====================================================

USE TransportBookingSystem;

-- Create Offers table if it doesn't exist
CREATE TABLE IF NOT EXISTS Offers (
    OfferID INT PRIMARY KEY AUTO_INCREMENT,
    OfferCode VARCHAR(50) UNIQUE NOT NULL,
    DiscountPercentage DECIMAL(5, 2),
    MaxDiscountAmount DECIMAL(10, 2),
    ValidFrom DATE,
    ValidTo DATE,
    IsActive BOOLEAN DEFAULT TRUE,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Clear existing data
DELETE FROM Offers;

-- Insert fresh offers with current dates
INSERT INTO Offers (OfferCode, DiscountPercentage, MaxDiscountAmount, ValidFrom, ValidTo, IsActive) VALUES
('FIRST50', 50.00, 100.00, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 1 YEAR), TRUE),
('WEEKEND20', 20.00, 50.00, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 1 YEAR), TRUE),
('METRO15', 15.00, 30.00, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 1 YEAR), TRUE),
('STUDENT10', 10.00, 25.00, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 1 YEAR), TRUE),
('NEWUSER30', 30.00, 75.00, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 6 MONTH), TRUE);

-- Verify data was inserted
SELECT '✅ Offers table created and populated!' AS Status;
SELECT CONCAT('Total offers: ', COUNT(*)) AS Result FROM Offers;
SELECT CONCAT('Active offers: ', COUNT(*)) AS Result FROM Offers WHERE IsActive = TRUE;

-- Show all offers
SELECT 
    OfferCode,
    CONCAT(DiscountPercentage, '%') AS Discount,
    CONCAT('₹', MaxDiscountAmount) AS MaxDiscount,
    ValidFrom,
    ValidTo,
    CASE WHEN IsActive THEN '✅ Active' ELSE '❌ Inactive' END AS Status
FROM Offers
ORDER BY DiscountPercentage DESC;

-- Test the exact query that the API uses
SELECT '🧪 Testing API query:' AS Info;
SELECT 
    OfferID,
    OfferCode,
    DiscountPercentage,
    MaxDiscountAmount,
    ValidFrom,
    ValidTo,
    IsActive
FROM Offers
WHERE IsActive = TRUE 
  AND ValidFrom <= CURDATE() 
  AND ValidTo >= CURDATE()
ORDER BY DiscountPercentage DESC;

SELECT '🎉 Offers setup complete! Refresh your frontend now.' AS Message;