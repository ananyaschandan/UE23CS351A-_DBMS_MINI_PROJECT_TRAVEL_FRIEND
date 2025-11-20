-- =====================================================
-- FILE 3: VEHICLES DATA - 45+ VEHICLES
-- =====================================================
-- Includes: Autos, Cabs, Bikes, Scooters, Buses
-- =====================================================

USE TransportBookingSystem;

INSERT INTO Vehicle (ProviderID, VehicleNumber, Model, VehicleType, Capacity, HourlyRate, IsAvailable) VALUES
-- Provider 1 (Individual) - 3 vehicles
(1, 'KA01AB1234', 'Bajaj RE Compact', 'Auto', 3, 80.00, TRUE),
(1, 'KA01CD5678', 'Maruti Swift Dzire', 'Cab', 4, 150.00, TRUE),
(1, 'KA01EF9012', 'Honda Activa 6G', 'Bike', 1, 50.00, TRUE),

-- Provider 2 (Ola) - 4 vehicles
(2, 'KA02GH3456', 'Toyota Etios', 'Cab', 4, 180.00, TRUE),
(2, 'KA02IJ7890', 'Bajaj RE 4S', 'Auto', 3, 90.00, TRUE),
(2, 'KA02KL1234', 'Honda City', 'Cab', 4, 200.00, TRUE),
(2, 'KA02MN5678', 'Maruti Ertiga', 'Cab', 6, 220.00, TRUE),

-- Provider 3 (Uber) - 5 vehicles
(3, 'KA03OP9012', 'Hyundai Xcent', 'Cab', 4, 190.00, TRUE),
(3, 'KA03QR3456', 'Maruti Baleno', 'Cab', 4, 195.00, TRUE),
(3, 'KA03ST7890', 'Piaggio Ape', 'Auto', 3, 85.00, TRUE),
(3, 'KA03UV1234', 'Toyota Innova', 'Cab', 6, 250.00, TRUE),
(3, 'KA03WX5678', 'Hyundai Creta', 'Cab', 5, 240.00, TRUE),

-- Provider 4 (Rapido) - 5 vehicles
(4, 'KA04YZ9012', 'Honda Activa 5G', 'Bike', 1, 45.00, TRUE),
(4, 'KA04AA3456', 'TVS Jupiter', 'Bike', 1, 48.00, TRUE),
(4, 'KA04BB7890', 'Bajaj Pulsar 150', 'Bike', 1, 55.00, TRUE),
(4, 'KA04CC1234', 'Royal Enfield Classic', 'Bike', 1, 60.00, TRUE),
(4, 'KA04DD5678', 'Yamaha FZ', 'Bike', 1, 52.00, TRUE),

-- Provider 5 (Namma Yatri) - 4 vehicles
(5, 'KA05EE9012', 'Tata Tigor EV', 'Cab', 4, 150.00, TRUE),
(5, 'KA05FF3456', 'Bajaj Maxima', 'Auto', 3, 75.00, TRUE),
(5, 'KA05GG7890', 'Mahindra e2o Plus', 'Cab', 4, 140.00, TRUE),
(5, 'KA05HH1234', 'Tata Nexon EV', 'Cab', 5, 180.00, TRUE),

-- Provider 6 (Individual) - 3 vehicles
(6, 'KA06II5678', 'Bajaj RE', 'Auto', 3, 70.00, TRUE),
(6, 'KA06JJ9012', 'Hero Splendor', 'Bike', 1, 40.00, TRUE),
(6, 'KA06KK3456', 'Maruti Celerio', 'Cab', 4, 130.00, TRUE),

-- Provider 7 (Ola) - 4 vehicles
(7, 'KA07LL7890', 'Hyundai Verna', 'Cab', 4, 205.00, TRUE),
(7, 'KA07MM1234', 'Maruti WagonR', 'Cab', 4, 140.00, TRUE),
(7, 'KA07NN5678', 'Bajaj Compact RE', 'Auto', 3, 82.00, TRUE),
(7, 'KA07OO9012', 'Honda Amaze', 'Cab', 4, 175.00, TRUE),

-- Provider 8 (Uber) - 4 vehicles
(8, 'KA08PP3456', 'Ford EcoSport', 'Cab', 4, 230.00, TRUE),
(8, 'KA08QQ7890', 'Hyundai i20', 'Cab', 4, 185.00, TRUE),
(8, 'KA08RR1234', 'Piaggio Ape Elite', 'Auto', 3, 88.00, TRUE),
(8, 'KA08SS5678', 'Kia Seltos', 'Cab', 5, 260.00, TRUE),

-- Provider 9 (Rapido) - 4 vehicles
(9, 'KA09TT9012', 'Honda Dio', 'Bike', 1, 42.00, TRUE),
(9, 'KA09UU3456', 'TVS Apache', 'Bike', 1, 58.00, TRUE),
(9, 'KA09VV7890', 'Suzuki Access', 'Bike', 1, 46.00, TRUE),
(9, 'KA09WW1234', 'Bajaj Avenger', 'Bike', 1, 62.00, TRUE),

-- Provider 10 (Bounce) - 10 scooters
(10, 'BOUNCE001', 'Bounce Infinity E1', 'Scooter', 1, 30.00, TRUE),
(10, 'BOUNCE002', 'Bounce Infinity E1', 'Scooter', 1, 30.00, TRUE),
(10, 'BOUNCE003', 'Bounce Infinity E1', 'Scooter', 1, 30.00, TRUE),
(10, 'BOUNCE004', 'Bounce Infinity E1', 'Scooter', 1, 30.00, TRUE),
(10, 'BOUNCE005', 'Bounce Infinity E1', 'Scooter', 1, 30.00, TRUE),
(10, 'BOUNCE006', 'Bounce Infinity E1', 'Scooter', 1, 30.00, TRUE),
(10, 'BOUNCE007', 'Bounce Infinity E1', 'Scooter', 1, 30.00, TRUE),
(10, 'BOUNCE008', 'Bounce Infinity E1', 'Scooter', 1, 30.00, TRUE),
(10, 'BOUNCE009', 'Bounce Infinity E1', 'Scooter', 1, 30.00, TRUE),
(10, 'BOUNCE010', 'Bounce Infinity E1', 'Scooter', 1, 30.00, TRUE),

-- Provider 11 (BMTC) - 8 buses
(11, 'KA01F1001', 'Volvo 8400', 'Bus', 40, 50.00, TRUE),
(11, 'KA01F1002', 'Ashok Leyland Viking', 'Bus', 45, 45.00, TRUE),
(11, 'KA01F1003', 'Tata Marcopolo', 'Bus', 42, 48.00, TRUE),
(11, 'KA01F1004', 'Volvo 7900 Hybrid', 'Bus', 40, 50.00, TRUE),
(11, 'KA01F1005', 'BYD K9 Electric', 'Bus', 35, 40.00, TRUE),
(11, 'KA01F1006', 'Eicher Skyline Pro', 'Bus', 50, 42.00, TRUE),
(11, 'KA01F1007', 'Ashok Leyland Lynx', 'Bus', 48, 44.00, TRUE),
(11, 'KA01F1008', 'Tata Starbus Ultra', 'Bus', 46, 46.00, TRUE),

-- Provider 12 (Individual) - 3 vehicles
(12, 'KA10XX5678', 'Maruti Alto', 'Cab', 4, 120.00, TRUE),
(12, 'KA10YY9012', 'Bajaj Platina', 'Bike', 1, 38.00, TRUE),
(12, 'KA10ZZ3456', 'Piaggio Ape Auto', 'Auto', 3, 68.00, TRUE);

SELECT '✅ Vehicles created!' AS Status;
SELECT CONCAT('Total Vehicles: ', COUNT(*)) AS Info FROM Vehicle;
SELECT CONCAT('Autos: ', COUNT(*)) AS Info FROM Vehicle WHERE VehicleType = 'Auto';
SELECT CONCAT('Cabs: ', COUNT(*)) AS Info FROM Vehicle WHERE VehicleType = 'Cab';
SELECT CONCAT('Bikes: ', COUNT(*)) AS Info FROM Vehicle WHERE VehicleType = 'Bike';
SELECT CONCAT('Scooters: ', COUNT(*)) AS Info FROM Vehicle WHERE VehicleType = 'Scooter';
SELECT CONCAT('Buses: ', COUNT(*)) AS Info FROM Vehicle WHERE VehicleType = 'Bus';
