-- =====================================================
-- FILE 4: 30 BOUNCE CENTERS ACROSS BANGALORE
-- =====================================================
-- Real locations with GPS coordinates and VARIED scooter counts
-- RUN THIS FILE TO POPULATE BOUNCE CENTERS
-- =====================================================

USE TransportBookingSystem;

-- Verify we're in the correct database
SELECT DATABASE() AS CurrentDatabase;

-- Check if BounceCenter table exists
SELECT 'Checking if BounceCenter table exists...' AS Status;
SHOW TABLES LIKE 'BounceCenter';

-- Clear existing data to avoid duplicates
SELECT 'Clearing old bounce center data...' AS Status;
DELETE FROM BounceCenter;
SELECT 'Old data cleared!' AS Status;

INSERT INTO BounceCenter (CenterName, Location, Area, Latitude, Longitude, AvailableScooters, Coordinates) VALUES
('Majestic Bounce Hub', 'Majestic Bus Stand, Platform 12', 'Majestic', 12.9767, 77.5733, 18, ST_GeomFromText('POINT(77.5733 12.9767)', 4326)),
('MG Road Bounce', 'MG Road Metro Station, Exit 3', 'MG Road', 12.9716, 77.5946, 7, ST_GeomFromText('POINT(77.5946 12.9716)', 4326)),
('Koramangala Bounce', 'Koramangala 5th Block, Sony Signal', 'Koramangala', 12.9352, 77.6192, 22, ST_GeomFromText('POINT(77.6192 12.9352)', 4326)),
('Indiranagar Bounce', 'Indiranagar 100ft Road, Near CMH', 'Indiranagar', 12.9716, 77.6412, 5, ST_GeomFromText('POINT(77.6412 12.9716)', 4326)),
('Whitefield Bounce', 'Whitefield Main Road, Forum Mall', 'Whitefield', 12.9698, 77.7499, 31, ST_GeomFromText('POINT(77.7499 12.9698)', 4326)),
('Jayanagar Bounce', 'Jayanagar 4th Block, RV Road', 'Jayanagar', 12.9243, 77.5888, 14, ST_GeomFromText('POINT(77.5888 12.9243)', 4326)),
('BTM Layout Bounce', 'BTM 2nd Stage, Udupi Garden', 'BTM Layout', 12.9165, 77.6101, 9, ST_GeomFromText('POINT(77.6101 12.9165)', 4326)),
('HSR Layout Bounce', 'HSR Sector 1, 27th Main', 'HSR Layout', 12.9121, 77.6446, 26, ST_GeomFromText('POINT(77.6446 12.9121)', 4326)),
('Electronic City Bounce', 'Electronic City Phase 1, Infosys Gate', 'Electronic City', 12.8456, 77.6603, 3, ST_GeomFromText('POINT(77.6603 12.8456)', 4326)),
('Marathahalli Bounce', 'Marathahalli Bridge, Outer Ring Road', 'Marathahalli', 12.9591, 77.7011, 19, ST_GeomFromText('POINT(77.7011 12.9591)', 4326)),
('Bellandur Bounce', 'Bellandur Gate, Sarjapur Road', 'Bellandur', 12.9259, 77.6766, 11, ST_GeomFromText('POINT(77.6766 12.9259)', 4326)),
('Sarjapur Bounce', 'Sarjapur Road Junction, Wipro Campus', 'Sarjapur', 12.9010, 77.6870, 28, ST_GeomFromText('POINT(77.6870 12.9010)', 4326)),
('Bannerghatta Bounce', 'Bannerghatta Road, Meenakshi Mall', 'Bannerghatta', 12.8892, 77.5961, 6, ST_GeomFromText('POINT(77.5961 12.8892)', 4326)),
('JP Nagar Bounce', 'JP Nagar 6th Phase, Metro Station', 'JP Nagar', 12.9070, 77.5842, 16, ST_GeomFromText('POINT(77.5842 12.9070)', 4326)),
('Basavanagudi Bounce', 'Basavanagudi Circle, Bull Temple Road', 'Basavanagudi', 12.9395, 77.5639, 20, ST_GeomFromText('POINT(77.5639 12.9395)', 4326)),
('Malleshwaram Bounce', 'Malleshwaram 18th Cross, Sampige Road', 'Malleshwaram', 13.0076, 77.5727, 8, ST_GeomFromText('POINT(77.5727 13.0076)', 4326)),
('Rajajinagar Bounce', 'Rajajinagar Metro, Chord Road', 'Rajajinagar', 13.0092, 77.5553, 24, ST_GeomFromText('POINT(77.5553 13.0092)', 4326)),
('Yeshwanthpur Bounce', 'Yeshwanthpur Junction, Tumkur Road', 'Yeshwanthpur', 13.0224, 77.5501, 12, ST_GeomFromText('POINT(77.5501 13.0224)', 4326)),
('Hebbal Bounce', 'Hebbal Flyover, Bellary Road', 'Hebbal', 13.0358, 77.5970, 15, ST_GeomFromText('POINT(77.5970 13.0358)', 4326)),
('Yelahanka Bounce', 'Yelahanka New Town, Doddaballapur Road', 'Yelahanka', 13.1007, 77.5963, 4, ST_GeomFromText('POINT(77.5963 13.1007)', 4326)),
('Banashankari Bounce', 'Banashankari 2nd Stage, BMTC Depot', 'Banashankari', 12.9250, 77.5487, 29, ST_GeomFromText('POINT(77.5487 12.9250)', 4326)),
('Vijayanagar Bounce', 'Vijayanagar Metro, Chord Road Junction', 'Vijayanagar', 12.9698, 77.5350, 10, ST_GeomFromText('POINT(77.5350 12.9698)', 4326)),
('RT Nagar Bounce', 'RT Nagar Main Road, BEL Circle', 'RT Nagar', 13.0201, 77.5969, 17, ST_GeomFromText('POINT(77.5969 13.0201)', 4326)),
('Kammanahalli Bounce', 'Kammanahalli Main Road, Kalyan Nagar', 'Kammanahalli', 13.0117, 77.6390, 21, ST_GeomFromText('POINT(77.6390 13.0117)', 4326)),
('Frazer Town Bounce', 'Frazer Town, Coles Road', 'Frazer Town', 12.9897, 77.6186, 13, ST_GeomFromText('POINT(77.6186 12.9897)', 4326)),
('Richmond Town Bounce', 'Richmond Circle, Residency Road', 'Richmond Town', 12.9716, 77.6034, 25, ST_GeomFromText('POINT(77.6034 12.9716)', 4326)),
('Shivajinagar Bounce', 'Shivajinagar Bus Stand, Dickenson Road', 'Shivajinagar', 12.9813, 77.6013, 2, ST_GeomFromText('POINT(77.6013 12.9813)', 4326)),
('Sadashivanagar Bounce', 'Sadashivanagar, Sankey Road', 'Sadashivanagar', 13.0049, 77.5772, 27, ST_GeomFromText('POINT(77.5772 13.0049)', 4326)),
('Cunningham Road Bounce', 'Cunningham Road, Lavelle Road Junction', 'Cunningham Road', 12.9897, 77.5919, 23, ST_GeomFromText('POINT(77.5919 12.9897)', 4326)),
('Brigade Road Bounce', 'Brigade Road, Church Street', 'Brigade Road', 12.9716, 77.6088, 30, ST_GeomFromText('POINT(77.6088 12.9716)', 4326));

-- =====================================================
-- VERIFICATION - Check if data was inserted correctly
-- =====================================================

SELECT '✅ Bounce Centers created!' AS Status;

SELECT CONCAT('✅ Total Bounce Centers: ', COUNT(*)) AS Result FROM BounceCenter;

SELECT CONCAT('✅ Total Available Scooters: ', SUM(AvailableScooters)) AS Result FROM BounceCenter;

SELECT CONCAT('✅ All centers active: ', IF(COUNT(*) = SUM(IsActive), 'YES', 'NO')) AS Result FROM BounceCenter;

SELECT '📊 Top 5 Centers by Scooter Availability:' AS Info;
SELECT 
    CenterName AS 'Center Name', 
    Location, 
    Area,
    AvailableScooters AS 'Scooters',
    CONCAT(Latitude, ', ', Longitude) AS 'GPS Coordinates'
FROM BounceCenter 
ORDER BY AvailableScooters DESC 
LIMIT 5;

SELECT '📊 Bottom 5 Centers (Low Stock):' AS Info;
SELECT 
    CenterName AS 'Center Name', 
    Location, 
    AvailableScooters AS 'Scooters'
FROM BounceCenter 
ORDER BY AvailableScooters ASC 
LIMIT 5;

-- Final verification
SELECT 
    CASE 
        WHEN COUNT(*) = 30 THEN '✅ SUCCESS: All 30 Bounce Centers inserted correctly!'
        ELSE CONCAT('⚠️ WARNING: Only ', COUNT(*), ' centers inserted. Expected 30.')
    END AS FinalStatus
FROM BounceCenter;

SELECT '🎉 Bounce Centers setup complete! You can now use the Bounce page in frontend.' AS Message;
