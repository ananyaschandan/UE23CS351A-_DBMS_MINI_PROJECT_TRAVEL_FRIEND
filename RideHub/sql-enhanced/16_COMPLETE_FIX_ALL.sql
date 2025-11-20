-- =====================================================
-- COMPLETE FIX - RUN THIS FILE ONLY
-- This fixes Purple Line duplicates AND adds all routes
-- =====================================================

USE TransportBookingSystem;

-- =====================================================
-- STEP 1: FIX PURPLE LINE DUPLICATES
-- =====================================================

-- Delete ALL Purple Line stations first (clean slate)
DELETE FROM MetroStation WHERE LineColor = 'Purple';

-- Insert CORRECT Purple Line stations (27 stations total)
INSERT INTO MetroStation (StationName, StationCode, LineColor, Location, IsInterchange, StationOrder, FirstTrain, LastTrain) VALUES
-- Purple Line: Whitefield to Challaghatta (27 stations)
('Whitefield', 'WF01', 'Purple', 'Whitefield', FALSE, 1, '05:00:00', '23:00:00'),
('Kadugodi Tree Park', 'KD02', 'Purple', 'Kadugodi', FALSE, 2, '05:00:00', '23:00:00'),
('Pattandur Agrahara', 'PA03', 'Purple', 'Pattandur Agrahara', FALSE, 3, '05:00:00', '23:00:00'),
('Channasandra', 'CH04', 'Purple', 'Channasandra', FALSE, 4, '05:00:00', '23:00:00'),
('Hoodi', 'HO05', 'Purple', 'Hoodi', FALSE, 5, '05:00:00', '23:00:00'),
('Garudacharpalya', 'GA06', 'Purple', 'Garudacharpalya', FALSE, 6, '05:00:00', '23:00:00'),
('Doddanekundi', 'DD07', 'Purple', 'Doddanekundi', FALSE, 7, '05:00:00', '23:00:00'),
('Marathahalli', 'MA08', 'Purple', 'Marathahalli', FALSE, 8, '05:00:00', '23:00:00'),
('Halasuru', 'HA09', 'Purple', 'Halasuru', FALSE, 9, '05:00:00', '23:00:00'),
('Indiranagar', 'IN10', 'Purple', 'Indiranagar', FALSE, 10, '05:00:00', '23:00:00'),
('Swami Vivekananda Road', 'SV11', 'Purple', 'Swami Vivekananda Road', FALSE, 11, '05:00:00', '23:00:00'),
('Baiyappanahalli', 'BA12', 'Purple', 'Baiyappanahalli', FALSE, 12, '05:00:00', '23:00:00'),
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
('Challaghatta', 'CG27', 'Purple', 'Challaghatta', FALSE, 27, '05:00:00', '23:00:00');

-- =====================================================
-- STEP 2: ADD ALL PURPLE-GREEN INTERCHANGE ROUTES
-- =====================================================

INSERT INTO MetroRoutes (FromStation, ToStation, Distance, EstimatedTime, NumberOfStops, EstimatedFare, InterchangeAt, RouteInstructions, LineColor) VALUES

-- Whitefield (Purple) to Green Line
('Whitefield', 'Kuvempu Road', 25.0, 35, 20, 40, 'Majestic', '1. Take the Purple Line from Whitefield towards Majestic.\n2. Alight at Majestic (Interchange Station).\n3. Change to the Green Line towards Kuvempu Road.', 'Both'),
('Whitefield', 'JP Nagar', 34.0, 45, 25, 50, 'Majestic', '1. Take the Purple Line from Whitefield towards Majestic.\n2. Alight at Majestic (Interchange Station).\n3. Change to the Green Line towards JP Nagar.', 'Both'),
('Whitefield', 'Jayanagar', 28.0, 37, 22, 50, 'Majestic', '1. Take the Purple Line from Whitefield towards Majestic.\n2. Alight at Majestic (Interchange Station).\n3. Change to the Green Line towards Jayanagar.', 'Both'),
('Whitefield', 'South End Circle', 26.0, 35, 21, 40, 'Majestic', '1. Take the Purple Line from Whitefield towards Majestic.\n2. Alight at Majestic (Interchange Station).\n3. Change to the Green Line towards South End Circle.', 'Both'),
('Whitefield', 'National College', 22.0, 30, 19, 40, 'Majestic', '1. Take the Purple Line from Whitefield towards Majestic.\n2. Alight at Majestic (Interchange Station).\n3. Change to the Green Line towards National College.', 'Both'),
('Whitefield', 'RV Road', 30.0, 40, 23, 50, 'Majestic', '1. Take the Purple Line from Whitefield towards Majestic.\n2. Alight at Majestic (Interchange Station).\n3. Change to the Green Line towards RV Road.', 'Both'),
('Whitefield', 'Silk Institute', 46.0, 60, 31, 60, 'Majestic', '1. Take the Purple Line from Whitefield towards Majestic.\n2. Alight at Majestic (Interchange Station).\n3. Change to the Green Line towards Silk Institute.', 'Both'),

-- Indiranagar (Purple) to Green Line
('Indiranagar', 'Kuvempu Road', 18.0, 28, 14, 40, 'Majestic', '1. Take the Purple Line from Indiranagar towards Majestic.\n2. Alight at Majestic (Interchange Station).\n3. Change to the Green Line towards Kuvempu Road.', 'Both'),
('Indiranagar', 'JP Nagar', 18.0, 28, 14, 40, 'Majestic', '1. Take the Purple Line from Indiranagar towards Majestic.\n2. Alight at Majestic (Interchange Station).\n3. Change to the Green Line towards JP Nagar.', 'Both'),
('Indiranagar', 'Jayanagar', 15.0, 25, 12, 30, 'Majestic', '1. Take the Purple Line from Indiranagar towards Majestic.\n2. Alight at Majestic (Interchange Station).\n3. Change to the Green Line towards Jayanagar.', 'Both'),
('Indiranagar', 'South End Circle', 12.0, 22, 10, 30, 'Majestic', '1. Take the Purple Line from Indiranagar towards Majestic.\n2. Alight at Majestic (Interchange Station).\n3. Change to the Green Line towards South End Circle.', 'Both'),
('Indiranagar', 'National College', 10.0, 18, 8, 20, 'Majestic', '1. Take the Purple Line from Indiranagar towards Majestic.\n2. Alight at Majestic (Interchange Station).\n3. Change to the Green Line towards National College.', 'Both'),
('Indiranagar', 'RV Road', 20.0, 30, 16, 40, 'Majestic', '1. Take the Purple Line from Indiranagar towards Majestic.\n2. Alight at Majestic (Interchange Station).\n3. Change to the Green Line towards RV Road.', 'Both'),

-- Cubbon Park (Purple) to Green Line
('Cubbon Park', 'Kuvempu Road', 8.0, 15, 6, 20, 'Majestic', '1. Take the Purple Line from Cubbon Park towards Majestic.\n2. Alight at Majestic (Interchange Station).\n3. Change to the Green Line towards Kuvempu Road.', 'Both'),
('Cubbon Park', 'JP Nagar', 12.5, 22, 10, 30, 'Majestic', '1. Take the Purple Line from Cubbon Park towards Majestic.\n2. Alight at Majestic (Interchange Station).\n3. Change to the Green Line towards JP Nagar.', 'Both'),
('Cubbon Park', 'Jayanagar', 10.0, 18, 8, 20, 'Majestic', '1. Take the Purple Line from Cubbon Park towards Majestic.\n2. Alight at Majestic (Interchange Station).\n3. Change to the Green Line towards Jayanagar.', 'Both'),
('Cubbon Park', 'South End Circle', 8.0, 15, 6, 20, 'Majestic', '1. Take the Purple Line from Cubbon Park towards Majestic.\n2. Alight at Majestic (Interchange Station).\n3. Change to the Green Line towards South End Circle.', 'Both'),
('Cubbon Park', 'National College', 6.0, 12, 4, 20, 'Majestic', '1. Take the Purple Line from Cubbon Park towards Majestic.\n2. Alight at Majestic (Interchange Station).\n3. Change to the Green Line towards National College.', 'Both'),
('Cubbon Park', 'RV Road', 14.0, 24, 12, 30, 'Majestic', '1. Take the Purple Line from Cubbon Park towards Majestic.\n2. Alight at Majestic (Interchange Station).\n3. Change to the Green Line towards RV Road.', 'Both'),

-- MG Road (Purple) to Green Line
('MG Road', 'Kuvempu Road', 7.0, 14, 5, 20, 'Majestic', '1. Take the Purple Line from MG Road towards Majestic.\n2. Alight at Majestic (Interchange Station).\n3. Change to the Green Line towards Kuvempu Road.', 'Both'),
('MG Road', 'JP Nagar', 13.0, 23, 11, 30, 'Majestic', '1. Take the Purple Line from MG Road towards Majestic.\n2. Alight at Majestic (Interchange Station).\n3. Change to the Green Line towards JP Nagar.', 'Both'),
('MG Road', 'RV Road', 15.0, 25, 13, 30, 'Majestic', '1. Take the Purple Line from MG Road towards Majestic.\n2. Alight at Majestic (Interchange Station).\n3. Change to the Green Line towards RV Road.', 'Both'),
('MG Road', 'National College', 7.0, 13, 5, 20, 'Majestic', '1. Take the Purple Line from MG Road towards Majestic.\n2. Alight at Majestic (Interchange Station).\n3. Change to the Green Line towards National College.', 'Both'),

-- Trinity (Purple) to Green Line
('Trinity', 'Silk Institute', 32.0, 45, 24, 50, 'Majestic', '1. Take the Purple Line from Trinity towards Majestic.\n2. Alight at Majestic (Interchange Station).\n3. Change to the Green Line towards Silk Institute.', 'Both'),
('Trinity', 'JP Nagar', 14.0, 24, 12, 30, 'Majestic', '1. Take the Purple Line from Trinity towards Majestic.\n2. Alight at Majestic (Interchange Station).\n3. Change to the Green Line towards JP Nagar.', 'Both'),
('Trinity', 'National College', 8.0, 15, 6, 20, 'Majestic', '1. Take the Purple Line from Trinity towards Majestic.\n2. Alight at Majestic (Interchange Station).\n3. Change to the Green Line towards National College.', 'Both'),

-- Vidhana Soudha (Purple) to Green Line
('Vidhana Soudha', 'Silk Institute', 30.0, 42, 22, 50, 'Majestic', '1. Take the Purple Line from Vidhana Soudha towards Majestic.\n2. Alight at Majestic (Interchange Station).\n3. Change to the Green Line towards Silk Institute.', 'Both'),
('Vidhana Soudha', 'JP Nagar', 15.0, 25, 13, 30, 'Majestic', '1. Take the Purple Line from Vidhana Soudha towards Majestic.\n2. Alight at Majestic (Interchange Station).\n3. Change to the Green Line towards JP Nagar.', 'Both'),
('Vidhana Soudha', 'National College', 9.0, 16, 7, 20, 'Majestic', '1. Take the Purple Line from Vidhana Soudha towards Majestic.\n2. Alight at Majestic (Interchange Station).\n3. Change to the Green Line towards National College.', 'Both'),

-- Attiguppe (Purple) to Green Line
('Attiguppe', 'National College', 16.0, 26, 14, 40, 'Majestic', '1. Take the Purple Line from Attiguppe towards Majestic.\n2. Alight at Majestic (Interchange Station).\n3. Change to the Green Line towards National College.', 'Both'),
('Attiguppe', 'JP Nagar', 20.0, 32, 18, 40, 'Majestic', '1. Take the Purple Line from Attiguppe towards Majestic.\n2. Alight at Majestic (Interchange Station).\n3. Change to the Green Line towards JP Nagar.', 'Both'),
('Attiguppe', 'Kuvempu Road', 14.0, 24, 12, 30, 'Majestic', '1. Take the Purple Line from Attiguppe towards Majestic.\n2. Alight at Majestic (Interchange Station).\n3. Change to the Green Line towards Kuvempu Road.', 'Both'),

-- =====================================================
-- GREEN TO PURPLE ROUTES (Reverse)
-- =====================================================

-- Green Line to Whitefield
('Kuvempu Road', 'Whitefield', 25.0, 35, 20, 40, 'Majestic', '1. Take the Green Line from Kuvempu Road towards Majestic.\n2. Alight at Majestic (Interchange Station).\n3. Change to the Purple Line towards Whitefield.', 'Both'),
('JP Nagar', 'Whitefield', 34.0, 45, 25, 50, 'Majestic', '1. Take the Green Line from JP Nagar towards Majestic.\n2. Alight at Majestic (Interchange Station).\n3. Change to the Purple Line towards Whitefield.', 'Both'),
('Jayanagar', 'Whitefield', 28.0, 37, 22, 50, 'Majestic', '1. Take the Green Line from Jayanagar towards Majestic.\n2. Alight at Majestic (Interchange Station).\n3. Change to the Purple Line towards Whitefield.', 'Both'),
('South End Circle', 'Whitefield', 26.0, 35, 21, 40, 'Majestic', '1. Take the Green Line from South End Circle towards Majestic.\n2. Alight at Majestic (Interchange Station).\n3. Change to the Purple Line towards Whitefield.', 'Both'),
('National College', 'Whitefield', 22.0, 30, 19, 40, 'Majestic', '1. Take the Green Line from National College towards Majestic.\n2. Alight at Majestic (Interchange Station).\n3. Change to the Purple Line towards Whitefield.', 'Both'),
('RV Road', 'Whitefield', 30.0, 40, 23, 50, 'Majestic', '1. Take the Green Line from RV Road towards Majestic.\n2. Alight at Majestic (Interchange Station).\n3. Change to the Purple Line towards Whitefield.', 'Both'),
('Silk Institute', 'Whitefield', 46.0, 60, 31, 60, 'Majestic', '1. Take the Green Line from Silk Institute towards Majestic.\n2. Alight at Majestic (Interchange Station).\n3. Change to the Purple Line towards Whitefield.', 'Both'),

-- Green Line to Indiranagar
('Kuvempu Road', 'Indiranagar', 18.0, 28, 14, 40, 'Majestic', '1. Take the Green Line from Kuvempu Road towards Majestic.\n2. Alight at Majestic (Interchange Station).\n3. Change to the Purple Line towards Indiranagar.', 'Both'),
('JP Nagar', 'Indiranagar', 18.0, 28, 14, 40, 'Majestic', '1. Take the Green Line from JP Nagar towards Majestic.\n2. Alight at Majestic (Interchange Station).\n3. Change to the Purple Line towards Indiranagar.', 'Both'),
('Jayanagar', 'Indiranagar', 15.0, 25, 12, 30, 'Majestic', '1. Take the Green Line from Jayanagar towards Majestic.\n2. Alight at Majestic (Interchange Station).\n3. Change to the Purple Line towards Indiranagar.', 'Both'),
('South End Circle', 'Indiranagar', 12.0, 22, 10, 30, 'Majestic', '1. Take the Green Line from South End Circle towards Majestic.\n2. Alight at Majestic (Interchange Station).\n3. Change to the Purple Line towards Indiranagar.', 'Both'),
('National College', 'Indiranagar', 10.0, 18, 8, 20, 'Majestic', '1. Take the Green Line from National College towards Majestic.\n2. Alight at Majestic (Interchange Station).\n3. Change to the Purple Line towards Indiranagar.', 'Both'),
('RV Road', 'Indiranagar', 20.0, 30, 16, 40, 'Majestic', '1. Take the Green Line from RV Road towards Majestic.\n2. Alight at Majestic (Interchange Station).\n3. Change to the Purple Line towards Indiranagar.', 'Both'),

-- Green Line to Cubbon Park
('Kuvempu Road', 'Cubbon Park', 8.0, 15, 6, 20, 'Majestic', '1. Take the Green Line from Kuvempu Road towards Majestic.\n2. Alight at Majestic (Interchange Station).\n3. Change to the Purple Line towards Cubbon Park.', 'Both'),
('JP Nagar', 'Cubbon Park', 12.5, 22, 10, 30, 'Majestic', '1. Take the Green Line from JP Nagar towards Majestic.\n2. Alight at Majestic (Interchange Station).\n3. Change to the Purple Line towards Cubbon Park.', 'Both'),
('Jayanagar', 'Cubbon Park', 10.0, 18, 8, 20, 'Majestic', '1. Take the Green Line from Jayanagar towards Majestic.\n2. Alight at Majestic (Interchange Station).\n3. Change to the Purple Line towards Cubbon Park.', 'Both'),
('South End Circle', 'Cubbon Park', 8.0, 15, 6, 20, 'Majestic', '1. Take the Green Line from South End Circle towards Majestic.\n2. Alight at Majestic (Interchange Station).\n3. Change to the Purple Line towards Cubbon Park.', 'Both'),
('National College', 'Cubbon Park', 6.0, 12, 4, 20, 'Majestic', '1. Take the Green Line from National College towards Majestic.\n2. Alight at Majestic (Interchange Station).\n3. Change to the Purple Line towards Cubbon Park.', 'Both'),
('RV Road', 'Cubbon Park', 14.0, 24, 12, 30, 'Majestic', '1. Take the Green Line from RV Road towards Majestic.\n2. Alight at Majestic (Interchange Station).\n3. Change to the Purple Line towards Cubbon Park.', 'Both'),

-- Green Line to MG Road
('Kuvempu Road', 'MG Road', 7.0, 14, 5, 20, 'Majestic', '1. Take the Green Line from Kuvempu Road towards Majestic.\n2. Alight at Majestic (Interchange Station).\n3. Change to the Purple Line towards MG Road.', 'Both'),
('JP Nagar', 'MG Road', 13.0, 23, 11, 30, 'Majestic', '1. Take the Green Line from JP Nagar towards Majestic.\n2. Alight at Majestic (Interchange Station).\n3. Change to the Purple Line towards MG Road.', 'Both'),
('RV Road', 'MG Road', 15.0, 25, 13, 30, 'Majestic', '1. Take the Green Line from RV Road towards Majestic.\n2. Alight at Majestic (Interchange Station).\n3. Change to the Purple Line towards MG Road.', 'Both'),
('National College', 'MG Road', 7.0, 13, 5, 20, 'Majestic', '1. Take the Green Line from National College towards Majestic.\n2. Alight at Majestic (Interchange Station).\n3. Change to the Purple Line towards MG Road.', 'Both'),

-- Green Line to Trinity
('Silk Institute', 'Trinity', 32.0, 45, 24, 50, 'Majestic', '1. Take the Green Line from Silk Institute towards Majestic.\n2. Alight at Majestic (Interchange Station).\n3. Change to the Purple Line towards Trinity.', 'Both'),
('JP Nagar', 'Trinity', 14.0, 24, 12, 30, 'Majestic', '1. Take the Green Line from JP Nagar towards Majestic.\n2. Alight at Majestic (Interchange Station).\n3. Change to the Purple Line towards Trinity.', 'Both'),
('National College', 'Trinity', 8.0, 15, 6, 20, 'Majestic', '1. Take the Green Line from National College towards Majestic.\n2. Alight at Majestic (Interchange Station).\n3. Change to the Purple Line towards Trinity.', 'Both'),

-- Green Line to Vidhana Soudha
('Silk Institute', 'Vidhana Soudha', 30.0, 42, 22, 50, 'Majestic', '1. Take the Green Line from Silk Institute towards Majestic.\n2. Alight at Majestic (Interchange Station).\n3. Change to the Purple Line towards Vidhana Soudha.', 'Both'),
('JP Nagar', 'Vidhana Soudha', 15.0, 25, 13, 30, 'Majestic', '1. Take the Green Line from JP Nagar towards Majestic.\n2. Alight at Majestic (Interchange Station).\n3. Change to the Purple Line towards Vidhana Soudha.', 'Both'),
('National College', 'Vidhana Soudha', 9.0, 16, 7, 20, 'Majestic', '1. Take the Green Line from National College towards Majestic.\n2. Alight at Majestic (Interchange Station).\n3. Change to the Purple Line towards Vidhana Soudha.', 'Both'),

-- Green Line to Attiguppe
('National College', 'Attiguppe', 16.0, 26, 14, 40, 'Majestic', '1. Take the Green Line from National College towards Majestic.\n2. Alight at Majestic (Interchange Station).\n3. Change to the Purple Line towards Attiguppe.', 'Both'),
('JP Nagar', 'Attiguppe', 20.0, 32, 18, 40, 'Majestic', '1. Take the Green Line from JP Nagar towards Majestic.\n2. Alight at Majestic (Interchange Station).\n3. Change to the Purple Line towards Attiguppe.', 'Both'),
('Kuvempu Road', 'Attiguppe', 14.0, 24, 12, 30, 'Majestic', '1. Take the Green Line from Kuvempu Road towards Majestic.\n2. Alight at Majestic (Interchange Station).\n3. Change to the Purple Line towards Attiguppe.', 'Both'),

-- Green Line to Banashankari (this is a Green Line station, but adding for completeness)
('Banashankari', 'Trinity', 18.0, 28, 14, 40, 'Majestic', '1. Take the Green Line from Banashankari towards Majestic.\n2. Alight at Majestic (Interchange Station).\n3. Change to the Purple Line towards Trinity.', 'Both'),
('Trinity', 'Banashankari', 18.0, 28, 14, 40, 'Majestic', '1. Take the Purple Line from Trinity towards Majestic.\n2. Alight at Majestic (Interchange Station).\n3. Change to the Green Line towards Banashankari.', 'Both');

-- =====================================================
-- VERIFICATION
-- =====================================================

SELECT '✅ Purple Line Fixed!' as Status;
SELECT COUNT(*) as PurpleStations FROM MetroStation WHERE LineColor = 'Purple';
SELECT COUNT(*) as GreenStations FROM MetroStation WHERE LineColor = 'Green';
SELECT COUNT(*) as TotalRoutes FROM MetroRoutes;
SELECT COUNT(*) as InterchangeRoutes FROM MetroRoutes WHERE InterchangeAt = 'Majestic';

-- Show Purple Line stations
SELECT StationName, StationCode, StationOrder 
FROM MetroStation 
WHERE LineColor = 'Purple' 
ORDER BY StationOrder;
