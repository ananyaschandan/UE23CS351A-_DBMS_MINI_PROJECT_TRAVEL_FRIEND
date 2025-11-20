-- =====================================================
-- FILE 5: BMTC BUS ROUTES FROM MAJESTIC
-- =====================================================
-- 20 Bus Routes covering major Bangalore destinations
-- =====================================================

USE TransportBookingSystem;

INSERT INTO BusRoute (RouteNumber, RouteName, StartLocation, EndLocation, Distance, EstimatedTime, Fare, Frequency, BusType) VALUES
-- Routes to South Bangalore
('G-4', 'Majestic to Jayanagar', 'Majestic', 'Jayanagar', 6.5, 35, 15.00, 10, 'Ordinary'),
('335E', 'Majestic to JP Nagar', 'Majestic', 'J.P. Nagar', 8.3, 45, 20.00, 12, 'Ordinary'),
('G-9', 'Majestic to Bannerghatta', 'Majestic', 'Bannerghatta', 12.5, 60, 25.00, 15, 'Ordinary'),
('V-500C', 'Majestic to BTM Layout', 'Majestic', 'BTM Layout', 9.2, 50, 35.00, 10, 'Volvo'),
('V-500K', 'Majestic to Electronic City', 'Majestic', 'Electronic City', 18.5, 75, 45.00, 15, 'Volvo'),

-- Routes to East Bangalore
('500D', 'Majestic to Whitefield', 'Majestic', 'Whitefield', 22.0, 90, 50.00, 12, 'Volvo'),
('G-2', 'Majestic to Indiranagar', 'Majestic', 'Indiranagar', 8.5, 40, 18.00, 8, 'Ordinary'),
('171K', 'Majestic to Marathahalli', 'Majestic', 'Marathahalli', 15.2, 65, 22.00, 10, 'Ordinary'),
('V-365', 'Majestic to HSR Layout', 'Majestic', 'HSR Layout', 11.5, 55, 38.00, 12, 'Volvo'),
('201', 'Majestic to Koramangala', 'Majestic', 'Koramangala', 9.8, 48, 20.00, 8, 'Ordinary'),

-- Routes to North Bangalore
('G-3', 'Majestic to Hebbal', 'Majestic', 'Hebbal', 10.5, 50, 20.00, 10, 'Ordinary'),
('V-500A', 'Majestic to Yelahanka', 'Majestic', 'Yelahanka', 18.0, 70, 42.00, 15, 'Volvo'),
('226M', 'Majestic to Yeshwanthpur', 'Majestic', 'Yeshwanthpur', 6.8, 35, 15.00, 8, 'Ordinary'),

-- Routes to West Bangalore
('G-1', 'Majestic to Rajajinagar', 'Majestic', 'Rajajinagar', 7.1, 38, 15.00, 10, 'Ordinary'),
('201A', 'Majestic to Vijayanagar', 'Majestic', 'Vijayanagar', 5.2, 28, 12.00, 8, 'Ordinary'),
('G-6', 'Majestic to Malleshwaram', 'Majestic', 'Malleshwaram', 5.5, 30, 12.00, 8, 'Ordinary'),

-- Central Routes
('9', 'Majestic to MG Road', 'Majestic', 'MG Road', 3.2, 20, 10.00, 5, 'Ordinary'),
('V-500', 'Majestic to Koramangala (Volvo)', 'Majestic', 'Koramangala', 9.8, 42, 35.00, 10, 'Volvo'),
('AC-1', 'Majestic to Whitefield (AC)', 'Majestic', 'Whitefield', 22.0, 80, 60.00, 15, 'AC'),
('201B', 'Majestic to Basavanagudi', 'Majestic', 'Basavanagudi', 4.8, 25, 12.00, 8, 'Ordinary');

SELECT '✅ Bus Routes created!' AS Status;
SELECT CONCAT('Total Bus Routes: ', COUNT(*)) AS Info FROM BusRoute;
SELECT 'Cheapest Routes:' AS Info;
SELECT RouteNumber, RouteName, CONCAT('₹', Fare) AS Fare 
FROM BusRoute 
ORDER BY Fare ASC 
LIMIT 5;
SELECT 'Fastest Routes:' AS Info;
SELECT RouteNumber, RouteName, CONCAT(EstimatedTime, ' min') AS Time 
FROM BusRoute 
ORDER BY EstimatedTime ASC 
LIMIT 5;
