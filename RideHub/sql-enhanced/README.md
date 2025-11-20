# 🗄️ RideHub Enhanced Database - SQL Files

## 📁 Files Overview

| File | Purpose | What It Creates |
|------|---------|-----------------|
| `01_SCHEMA_ENHANCED.sql` | Database structure | 15 core tables with indexes |
| `02_USERS_DATA.sql` | User accounts | 22 users (10 customers + 12 providers) |
| `03_VEHICLES_DATA.sql` | Vehicle fleet | 45+ vehicles (autos, cabs, bikes, buses, scooters) |
| `04_BOUNCE_CENTERS.sql` | Bounce locations | 30 Bounce centers across Bangalore |
| `05_BUS_ROUTES.sql` | BMTC bus routes | 20 bus routes from Majestic |
| `06_ROUTES_FARES.sql` | Routes & pricing | 11 routes + 12 fare structures |
| `07_PROCEDURES_TRIGGERS.sql` | Business logic | 3 procedures + 3 triggers |
| `08_SAMPLE_BOOKINGS.sql` | Test data | 6 sample multi-modal bookings |
| `09_ADDITIONAL_TABLES.sql` | Extra features | 11 additional tables (Metro, Offers, Admin, etc.) |
| `10_VIEWS.sql` | Database views | 8 views for easy querying |

---

## 🚀 Quick Start

### Run All Files in Order:

```sql
mysql -u root -p

source C:/Users/anany/Downloads/RideHub (1)/RideHub/sql-enhanced/01_SCHEMA_ENHANCED.sql
source C:/Users/anany/Downloads/RideHub (1)/RideHub/sql-enhanced/02_USERS_DATA.sql
source C:/Users/anany/Downloads/RideHub (1)/RideHub/sql-enhanced/03_VEHICLES_DATA.sql
source C:/Users/anany/Downloads/RideHub (1)/RideHub/sql-enhanced/04_BOUNCE_CENTERS.sql
source C:/Users/anany/Downloads/RideHub (1)/RideHub/sql-enhanced/05_BUS_ROUTES.sql
source C:/Users/anany/Downloads/RideHub (1)/RideHub/sql-enhanced/06_ROUTES_FARES.sql
source C:/Users/anany/Downloads/RideHub (1)/RideHub/sql-enhanced/07_PROCEDURES_TRIGGERS.sql
source C:/Users/anany/Downloads/RideHub (1)/RideHub/sql-enhanced/08_SAMPLE_BOOKINGS.sql
source C:/Users/anany/Downloads/RideHub (1)/RideHub/sql-enhanced/09_ADDITIONAL_TABLES.sql
source C:/Users/anany/Downloads/RideHub (1)/RideHub/sql-enhanced/10_VIEWS.sql
```

---

## 🔑 Login Credentials

**Password for ALL users**: `password123`

### Regular Users (Customers):
- john@example.com
- jane@example.com
- test@example.com
- amit@example.com
- priya.user@example.com
- rahul@example.com
- sneha@example.com
- vikram@example.com
- anjali@example.com
- rohan@example.com

### Provider Users (Drivers):
- ram@example.com (Individual)
- ahmed@example.com (Ola)
- priya@example.com (Uber)
- vijay@example.com (Rapido)
- lakshmi@example.com (Namma Yatri)
- kumar@example.com (Individual)
- anita@example.com (Ola)
- ravi@example.com (Uber)
- suresh@example.com (Rapido)
- deepak@example.com (Bounce)
- manish@example.com (BMTC)
- rajesh@example.com (Individual)

---

## ✅ What You Get

### Database Components:
- ✅ 15 Tables
- ✅ 3 Stored Procedures
- ✅ 3 Triggers
- ✅ 2 Spatial Indexes
- ✅ Multiple Regular Indexes

### Sample Data:
- ✅ 22 Users (real password hashing)
- ✅ 12 Service Providers
- ✅ 45+ Vehicles
- ✅ 30 Bounce Centers
- ✅ 20 Bus Routes
- ✅ 11 Routes with GPS
- ✅ 12 Fare Structures
- ✅ 6 Sample Bookings (13 segments)

### Features:
- ✅ Multi-modal journeys (Walk + Bounce + Rapido)
- ✅ Route types (Shortest/Fastest/Cheapest)
- ✅ Segment-based pricing
- ✅ Provider notifications
- ✅ Vehicle change alerts
- ✅ Real password authentication
- ✅ Earnings tracking (80/20 split)

---

## 📊 Quick Verification

```sql
USE TransportBookingSystem;

-- Check everything is loaded
SELECT 'Users' AS Item, COUNT(*) AS Count FROM User
UNION ALL SELECT 'Vehicles', COUNT(*) FROM Vehicle
UNION ALL SELECT 'Bounce Centers', COUNT(*) FROM BounceCenter
UNION ALL SELECT 'Bus Routes', COUNT(*) FROM BusRoute
UNION ALL SELECT 'Bookings', COUNT(*) FROM Booking
UNION ALL SELECT 'Segments', COUNT(*) FROM BookingSegment;
```

**Expected:**
```
+----------------+-------+
| Item           | Count |
+----------------+-------+
| Users          |    22 |
| Vehicles       |    45 |
| Bounce Centers |    30 |
| Bus Routes     |    20 |
| Bookings       |     6 |
| Segments       |    13 |
+----------------+-------+
```

---

## 📖 Full Documentation

See `DBMS_GUIDE.md` in the project root for:
- Complete testing guide
- Expected outputs
- Verification queries
- Troubleshooting tips

---

## 🎯 Key Examples

### Example 1: Shortest Route (Multi-modal)
**Majestic → Koramangala**: 9.2 km, 40 min, ₹95
- Segment 1: Walk to Bounce (0.3 km, 4 min, ₹0)
- Segment 2: Bounce Scooter (5.0 km, 18 min, ₹25)
- Segment 3: Rapido Bike (3.9 km, 18 min, ₹70)

### Example 2: Fastest Route
**Majestic → MG Road**: 3.2 km, 12 min, ₹145
- Single segment: Rapido Bike

### Example 3: Cheapest Route
**Majestic → Jayanagar**: 6.5 km, 35 min, ₹15
- Single segment: BMTC Bus

---

## 🔧 Troubleshooting

### Error: "Access denied"
- Check MySQL password
- Ensure user has CREATE/INSERT privileges

### Error: "Table already exists"
- Drop database first: `DROP DATABASE IF EXISTS TransportBookingSystem;`
- Or run File 1 which includes DROP command

### Error: "File not found"
- Check file paths in source commands
- Use forward slashes (/) not backslashes (\)
- Ensure files are in sql-enhanced folder

---

**✅ Ready to build a multi-modal transport system!**
