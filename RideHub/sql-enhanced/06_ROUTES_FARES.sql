-- =====================================================
-- FILE 6: ROUTES AND FARE STRUCTURE
-- =====================================================
-- Routes from Majestic + Complete Fare Table
-- =====================================================

USE TransportBookingSystem;

-- =====================================================
-- ROUTES FROM MAJESTIC (11 routes with GPS)
-- =====================================================

INSERT INTO Route (RouteName, StartLocation, EndLocation, Distance, EstimatedTime, RouteType, TrafficCondition, StartPoint, EndPoint) VALUES
('Majestic to Lalbagh', 'Majestic', 'Lalbagh Botanical Garden', 5.2, 22, 'Shortest', 'Medium', 
 ST_GeomFromText('POINT(77.5733 12.9767)', 4326), ST_GeomFromText('POINT(77.5848 12.9507)', 4326)),
('Majestic to Basavanagudi', 'Majestic', 'Basavanagudi', 4.8, 20, 'Shortest', 'Low',
 ST_GeomFromText('POINT(77.5733 12.9767)', 4326), ST_GeomFromText('POINT(77.5639 12.9395)', 4326)),
('Majestic to Jayanagar', 'Majestic', 'Jayanagar', 6.5, 28, 'Shortest', 'Medium',
 ST_GeomFromText('POINT(77.5733 12.9767)', 4326), ST_GeomFromText('POINT(77.5888 12.9243)', 4326)),
('Majestic to J.P. Nagar', 'Majestic', 'J.P. Nagar', 8.3, 35, 'Shortest', 'High',
 ST_GeomFromText('POINT(77.5733 12.9767)', 4326), ST_GeomFromText('POINT(77.5842 12.9070)', 4326)),
('Majestic to Rajajinagar', 'Majestic', 'Rajajinagar', 7.1, 30, 'Shortest', 'Medium',
 ST_GeomFromText('POINT(77.5733 12.9767)', 4326), ST_GeomFromText('POINT(77.5553 13.0092)', 4326)),
('Majestic to Bengaluru Palace', 'Majestic', 'Bengaluru Palace', 4.5, 18, 'Shortest', 'Low',
 ST_GeomFromText('POINT(77.5733 12.9767)', 4326), ST_GeomFromText('POINT(77.5921 12.9983)', 4326)),
('Majestic to MG Road', 'Majestic', 'MG Road', 3.2, 15, 'Shortest', 'High',
 ST_GeomFromText('POINT(77.5733 12.9767)', 4326), ST_GeomFromText('POINT(77.5946 12.9716)', 4326)),
('Majestic to ISKCON Temple', 'Majestic', 'ISKCON Temple', 9.8, 38, 'Shortest', 'Medium',
 ST_GeomFromText('POINT(77.5733 12.9767)', 4326), ST_GeomFromText('POINT(77.5516 13.0162)', 4326)),
('Majestic to Malleshwaram', 'Majestic', 'Malleshwaram', 5.5, 23, 'Shortest', 'Medium',
 ST_GeomFromText('POINT(77.5733 12.9767)', 4326), ST_GeomFromText('POINT(77.5727 13.0076)', 4326)),
('Majestic to Yeshwanthpur', 'Majestic', 'Yeshwanthpur', 6.8, 28, 'Shortest', 'Medium',
 ST_GeomFromText('POINT(77.5733 12.9767)', 4326), ST_GeomFromText('POINT(77.5501 13.0224)', 4326)),
('Majestic to Koramangala', 'Majestic', 'Koramangala', 9.8, 42, 'Shortest', 'High',
 ST_GeomFromText('POINT(77.5733 12.9767)', 4326), ST_GeomFromText('POINT(77.6192 12.9352)', 4326));

-- =====================================================
-- COMPLETE FARE STRUCTURE
-- =====================================================

INSERT INTO Fare (ServiceType, VehicleType, BaseFare, PerKmRate, PerMinuteRate, SurgeMultiplier) VALUES
-- Ola Services
('Ola', 'Cab', 50.00, 12.00, 1.50, 1.00),
('Ola', 'Auto', 30.00, 10.00, 1.00, 1.00),

-- Uber Services  
('Uber', 'Cab', 55.00, 11.50, 1.50, 1.00),
('Uber', 'Auto', 35.00, 9.50, 1.00, 1.00),

-- Namma Yatri Services
('Namma Yatri', 'Cab', 45.00, 10.50, 1.40, 1.00),
('Namma Yatri', 'Auto', 28.00, 9.00, 0.95, 1.00),

-- Rapido Services
('Rapido', 'Bike', 20.00, 5.00, 0.50, 1.00),

-- Individual Services
('Individual', 'Cab', 40.00, 10.00, 1.20, 1.00),
('Individual', 'Auto', 25.00, 8.00, 0.80, 1.00),
('Individual', 'Bike', 18.00, 4.50, 0.45, 1.00),

-- Bounce Services (Electric Scooters)
('Bounce', 'Scooter', 10.00, 3.00, 0.30, 1.00),

-- BMTC Services (Buses)
('BMTC', 'Bus', 5.00, 1.50, 0.10, 1.00);

SELECT '✅ Routes and Fares created!' AS Status;
SELECT CONCAT('Total Routes: ', COUNT(*)) AS Info FROM Route;
SELECT CONCAT('Total Fare Entries: ', COUNT(*)) AS Info FROM Fare;
SELECT 'Cheapest Services:' AS Info;
SELECT ServiceType, VehicleType, CONCAT('₹', BaseFare, ' + ₹', PerKmRate, '/km') AS Pricing 
FROM Fare 
ORDER BY BaseFare ASC 
LIMIT 5;
