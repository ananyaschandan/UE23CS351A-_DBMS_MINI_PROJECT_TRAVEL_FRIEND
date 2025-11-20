-- =====================================================
-- FIX PURPLE LINE DUPLICATE STATIONS
-- Remove duplicates and add correct stations
-- =====================================================

USE TransportBookingSystem;

-- First, let's check what we have
SELECT StationName, LineColor, COUNT(*) as count 
FROM MetroStation 
WHERE LineColor = 'Purple' 
GROUP BY StationName, LineColor 
HAVING COUNT(*) > 1;

-- Delete the duplicate/incorrect Purple Line stations
DELETE FROM MetroStation 
WHERE LineColor = 'Purple' 
AND StationName IN ('Hosahalli', 'Vijayanagar', 'Magadi Road');

-- Now insert the CORRECT Purple Line stations (replacing the duplicates)
-- The Purple Line should go: Whitefield -> ... -> Baiyappanahalli -> [Central stations] -> Challaghatta

INSERT INTO MetroStation (StationName, StationCode, LineColor, Location, IsInterchange, StationOrder, FirstTrain, LastTrain) VALUES
-- Central Purple Line stations (after Baiyappanahalli)
('Trinity', 'TR13', 'Purple', 'Trinity', FALSE, 13, '05:00:00', '23:00:00'),
('MG Road', 'MG14', 'Purple', 'MG Road', FALSE, 14, '05:00:00', '23:00:00'),
('Cubbon Park', 'CP15', 'Purple', 'Cubbon Park', FALSE, 15, '05:00:00', '23:00:00'),
('Vidhana Soudha', 'VS16', 'Purple', 'Vidhana Soudha', FALSE, 16, '05:00:00', '23:00:00'),
('Central College', 'CC17', 'Purple', 'Central College', FALSE, 17, '05:00:00', '23:00:00'),
('Nadaprabhu Kempegowda Station Majestic', 'MJ18', 'Purple', 'Majestic', TRUE, 18, '05:00:00', '23:00:00'),
('Magadi Road', 'MR19', 'Purple', 'Magadi Road', FALSE, 19, '05:00:00', '23:00:00'),
('Hosahalli', 'HS20', 'Purple', 'Hosahalli', FALSE, 20, '05:00:00', '23:00:00'),
('Vijayanagar', 'VJ21', 'Purple', 'Vijayanagar', FALSE, 21, '05:00:00', '23:00:00'),
('Attiguppe', 'AT22', 'Purple', 'Attiguppe', FALSE, 22, '05:00:00', '23:00:00'),
('Deepanjali Nagar', 'DN23', 'Purple', 'Deepanjali Nagar', FALSE, 23, '05:00:00', '23:00:00'),
('Mysuru Road', 'MY24', 'Purple', 'Mysuru Road', FALSE, 24, '05:00:00', '23:00:00'),
('Kengeri Bus Terminal', 'KB25', 'Purple', 'Kengeri', FALSE, 25, '05:00:00', '23:00:00'),
('Kengeri', 'KE26', 'Purple', 'Kengeri', FALSE, 26, '05:00:00', '23:00:00'),
('Challaghatta', 'CG27', 'Purple', 'Challaghatta', FALSE, 27, '05:00:00', '23:00:00')
ON DUPLICATE KEY UPDATE StationOrder = VALUES(StationOrder);

-- Update Majestic on Purple Line to be an interchange
UPDATE MetroStation 
SET IsInterchange = TRUE 
WHERE StationName LIKE '%Majestic%' AND LineColor = 'Purple';

-- Verify the fix
SELECT 
    'Purple Line Stations:' as Info,
    COUNT(*) as TotalStations
FROM MetroStation 
WHERE LineColor = 'Purple';

SELECT 
    'Green Line Stations:' as Info,
    COUNT(*) as TotalStations
FROM MetroStation 
WHERE LineColor = 'Green';

-- Show all Purple Line stations in order
SELECT StationName, StationCode, StationOrder, IsInterchange
FROM MetroStation
WHERE LineColor = 'Purple'
ORDER BY StationOrder;

SELECT '✅ Purple Line Fixed!' as Status;
