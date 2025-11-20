# 🧪 RideHub Complete UI Testing Guide

## 📋 What This Guide Covers
- Step-by-step UI testing instructions
- Expected frontend outputs (what you'll see on screen)
- Expected backend outputs (database changes)
- Where to check each feature
- Screenshots of what to expect

---

## 🚀 Pre-Testing Setup

### 1. Start Everything
```bash
# Terminal 1: Database (run once)
mysql -u root -p < server/database/init_database.sql

# Terminal 2: Backend
cd server
npm start

# Terminal 3: Frontend
npm run dev
```

### 2. Open Browser
- Go to: **http://localhost:5173**
- Open DevTools: **F12** (to see console logs)
- Open Network tab to see API calls

---

## 🧪 TEST 1: User Login & Dashboard

### Steps:
1. Open **http://localhost:5173**
2. Click **"Get Started"** button
3. Enter email: **`john@example.com`**
4. Click **"Sign In"**

### Expected Frontend Output:
```
✅ URL changes to: http://localhost:5173 (stays on same page but shows dashboard)
✅ Header shows: "Welcome, John Doe"
✅ You see 3 sections:
   - Service Comparison Table
   - "Book a Ride" button
   - "My Bookings" button
```

### Expected Backend Output:
```
Terminal shows:
POST /api/auth/login 200 - Response time: ~50ms
```

### Expected Database:
```sql
-- Check login worked (no database change, just verification)
SELECT UserID, FullName, Email, Role FROM User WHERE Email = 'john@example.com';

Expected Result:
UserID | FullName  | Email              | Role
1      | John Doe  | john@example.com   | USER
```

### Where to Check:
- **Frontend**: Browser URL, Header text, Dashboard cards
- **Backend**: Terminal logs showing POST /api/auth/login
- **Database**: MySQL Workbench or command line

---

## 🧪 TEST 2: View Service Comparison

### Steps:
1. After login, scroll down to **Service Comparison Table**

### Expected Frontend Output:
```
✅ Table with 10 rows showing:

Service Type    | Vehicle Type | Fare for 5km
----------------|--------------|-------------
Rapido          | Bike         | ₹45.00
Individual      | Auto         | ₹65.00
Namma Yatri     | Auto         | ₹73.00
Rapido          | Auto         | ₹67.50
Ola             | Auto         | ₹80.00
Uber            | Auto         | ₹82.50
Individual      | Cab          | ₹90.00
Namma Yatri     | Cab          | ₹97.50
Ola             | Cab          | ₹110.00
Uber            | Cab          | ₹112.50
```

### Expected Backend Output:
```
Terminal shows:
GET /api/routes/service-comparisons 200 - Response time: ~30ms
```

### Expected Database Query:
```sql
SELECT ServiceType, VehicleType, 
       ROUND(BaseFare + (PerKmRate * 5), 2) AS FareFor5Km
FROM Fare
ORDER BY FareFor5Km ASC;

-- This is what the API fetches
```

### Where to Check:
- **Frontend**: Service Comparison table on dashboard
- **Backend**: Terminal logs showing GET request
- **Database**: Run the query above to verify data

---

## 🧪 TEST 3: Book a Ride (Most Important!)

### Steps:
1. Click **"Book a Ride"** button
2. Enter **Start Location**: `Majestic`
3. Enter **End Location**: `Lalbagh Botanical Garden`
4. Click **"Find Routes"** button
5. Wait 1-2 seconds for routes to load

### Expected Frontend Output - Route Options:
```
✅ 3 route cards appear:

Card 1: SHORTEST ROUTE
- Distance: 5.2 km
- Time: 22 minutes
- Fare: ₹92.40
- Service: Individual Auto
- Button: "Select Route"

Card 2: FASTEST ROUTE
- Distance: 5.4 km
- Time: 17 minutes
- Fare: ₹145.50
- Service: Uber Cab
- Button: "Select Route"

Card 3: CHEAPEST ROUTE
- Distance: 6.0 km
- Time: 32 minutes
- Fare: ₹35.60
- Service: Rapido Bike
- Button: "Select Route"
```

### Expected Backend Output:
```
Terminal shows:
POST /api/routes/route-options 200
Body: {"startLocation":"Majestic","endLocation":"Lalbagh Botanical Garden"}
Response: [
  {
    "routeType": "Shortest",
    "distance": 5.2,
    "estimatedTime": 22,
    "estimatedFare": 92.40,
    "recommendedService": "Individual Auto",
    "serviceType": "Individual",
    "vehicleType": "Auto"
  },
  ...
]
```

### Expected Database Query:
```sql
-- Backend runs this query
SELECT Distance, EstimatedTime 
FROM Route 
WHERE StartLocation = 'Majestic' 
  AND EndLocation = 'Lalbagh Botanical Garden'
LIMIT 1;

Expected Result:
Distance | EstimatedTime
5.2      | 22
```

### Where to Check:
- **Frontend**: 3 route cards with different options
- **Backend**: Terminal shows POST request with locations
- **Database**: Route table has the distance data
- **DevTools Network**: See the API call and response

---

## 🧪 TEST 4: Confirm Booking & See Vehicle Details

### Steps:
1. From the 3 route options, click **"Select Route"** on **FASTEST ROUTE** (Uber Cab)
2. Click **"Confirm Booking"** button
3. Wait for confirmation

### Expected Frontend Output:
```
✅ Success message appears:
"Booking confirmed successfully!"

✅ Modal/Alert shows vehicle details:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🚗 Your Ride Details
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Service: Uber Cab
Vehicle: KA03OP9012 - Hyundai Xcent
Driver: Vijay Reddy
Phone: 9876543216
Rating: ⭐ 4.7
Fare: ₹145.50
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ After 2 seconds, redirects to "My Bookings" page
```

### Expected Backend Output:
```
Terminal shows:
POST /api/bookings/confirm 201
Body: {
  "userId": 1,
  "startLocation": "Majestic",
  "endLocation": "Lalbagh Botanical Garden",
  "routeType": "Fastest",
  "estimatedFare": 145.50,
  "distance": 5.4,
  "estimatedTime": 17,
  "serviceType": "Uber",
  "vehicleType": "Cab"
}

Response: {
  "bookingId": 7,
  "status": "Confirmed",
  "message": "Booking confirmed successfully!",
  "vehicleDetails": {
    "vehicleNumber": "KA03OP9012",
    "model": "Hyundai Xcent",
    "vehicleType": "Cab",
    "providerName": "Vijay Reddy",
    "providerPhone": "9876543216",
    "providerType": "Uber",
    "rating": 4.7
  }
}
```

### Expected Database Changes:
```sql
-- New booking inserted
SELECT * FROM Booking ORDER BY BookingID DESC LIMIT 1;

Expected Result:
BookingID: 7
UserID: 1
VehicleID: 7 (Hyundai Xcent)
ProviderID: 3 (Vijay Reddy - Uber)
StartLocation: Majestic
EndLocation: Lalbagh Botanical Garden
Distance: 5.4
ServiceType: Uber
VehicleType: Cab
TotalFare: 145.50
BookingStatus: Confirmed

-- Vehicle ride count increased
SELECT VehicleNumber, TotalRides FROM Vehicle WHERE VehicleID = 7;

Expected Result:
VehicleNumber | TotalRides
KA03OP9012    | 1 (was 0, now 1)

-- Provider ride count increased
SELECT u.FullName, sp.TotalRides 
FROM ServiceProvider sp
JOIN User u ON sp.UserID = u.UserID
WHERE sp.ProviderID = 3;

Expected Result:
FullName    | TotalRides
Vijay Reddy | 1 (was 0, now 1)
```

### Where to Check:
- **Frontend**: Success message, vehicle details modal, redirect to My Bookings
- **Backend**: Terminal shows POST /api/bookings/confirm with full response
- **Database**: New row in Booking table, TotalRides incremented
- **DevTools Console**: See the booking response object

---

## 🧪 TEST 5: View My Bookings

### Steps:
1. Click **"My Bookings"** from header or wait for auto-redirect
2. View your booking history

### Expected Frontend Output:
```
✅ Page title: "My Bookings"

✅ List of booking cards (you'll see 4 bookings - 3 pre-loaded + 1 new):

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Booking #7 - Confirmed ✅
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
From: Majestic
To: Lalbagh Botanical Garden
Service: Uber Cab
Distance: 5.4 km
Fare: ₹145.50

Driver Details:
👤 Vijay Reddy
📞 9876543216
🚗 KA03OP9012 - Hyundai Xcent
⭐ Rating: 4.7

Booked: Just now
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Booking #3 - In Progress 🚕
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
From: Majestic
To: Jayanagar
Service: Rapido Bike
Distance: 6.5 km
Fare: ₹52.50

Driver Details:
👤 Vijay Reddy
📞 9876543216
🚗 KA04WX5678 - Honda Activa 5G
⭐ Rating: 4.6

Booked: 2 hours ago
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[... 2 more completed bookings ...]
```

### Expected Backend Output:
```
Terminal shows:
GET /api/bookings/user/1 200
Response: [
  {
    "id": 7,
    "startLocation": "Majestic",
    "endLocation": "Lalbagh Botanical Garden",
    "distance": 5.4,
    "selectedRouteType": "Fastest",
    "serviceType": "Uber",
    "vehicleType": "Cab",
    "totalFare": 145.50,
    "status": "Confirmed",
    "providerDetails": {
      "name": "Vijay Reddy",
      "phone": "9876543216",
      "vehicleNumber": "KA03OP9012",
      "model": "Hyundai Xcent",
      "providerType": "Uber",
      "rating": 4.7
    }
  },
  ...
]
```

### Expected Database Query:
```sql
-- Backend runs this query
SELECT 
  b.BookingID, b.StartLocation, b.EndLocation,
  b.Distance, b.ServiceType, b.VehicleType,
  b.TotalFare, b.BookingStatus,
  v.VehicleNumber, v.Model,
  sp.ProviderType, sp.Rating,
  u.FullName as ProviderName, u.Phone as ProviderPhone
FROM Booking b
LEFT JOIN Vehicle v ON b.VehicleID = v.VehicleID
LEFT JOIN ServiceProvider sp ON b.ProviderID = sp.ProviderID
LEFT JOIN User u ON sp.UserID = u.UserID
WHERE b.UserID = 1
ORDER BY b.BookingTime DESC;

Expected Result: 4 rows with all booking details
```

### Where to Check:
- **Frontend**: My Bookings page with list of cards
- **Backend**: Terminal shows GET /api/bookings/user/1
- **Database**: Run the query above to see all bookings
- **DevTools Network**: See the full booking array response

---

## 🧪 TEST 6: Provider Login & Dashboard

### Steps:
1. Click **"Logout"** (if logged in)
2. Click **"Sign In"**
3. Enter email: **`ram@example.com`**
4. Click **"Sign In"**

### Expected Frontend Output:
```
✅ URL: http://localhost:5173
✅ Header shows: "Welcome, Ram Kumar"
✅ Page title: "My Vehicles"

✅ Dashboard shows:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Provider Stats:
Total Rides: 4
Total Earnings: ₹296.00
Rating: ⭐ 4.5
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ Vehicle cards (3 vehicles):

┌─────────────────────────────────┐
│ Bajaj RE Compact - Auto         │
│ KA01AB1234                      │
│ Capacity: 3 passengers          │
│ Hourly Rate: ₹80.00             │
│ Status: ✅ Available            │
│ Rides: 1 | Earnings: ₹73.92    │
│                                 │
│ [Toggle Status] [Edit]          │
└─────────────────────────────────┘

┌─────────────────────────────────┐
│ Maruti Swift Dzire - Cab        │
│ KA01CD5678                      │
│ Capacity: 4 passengers          │
│ Hourly Rate: ₹150.00            │
│ Status: ✅ Available            │
│ Rides: 1 | Earnings: ₹116.40   │
│                                 │
│ [Toggle Status] [Edit]          │
└─────────────────────────────────┘

┌─────────────────────────────────┐
│ Honda Activa 6G - Bike          │
│ KA01EF9012                      │
│ Capacity: 1 passenger           │
│ Hourly Rate: ₹50.00             │
│ Status: ✅ Available            │
│ Rides: 0 | Earnings: ₹0.00     │
│                                 │
│ [Toggle Status] [Edit]          │
└─────────────────────────────────┘

[+ Add New Vehicle] button at top
```

### Expected Backend Output:
```
Terminal shows:
POST /api/auth/login 200
GET /api/vehicles/provider/1 200

Response: [
  {
    "VehicleID": 1,
    "VehicleNumber": "KA01AB1234",
    "Model": "Bajaj RE Compact",
    "VehicleType": "Auto",
    "Capacity": 3,
    "HourlyRate": 80.00,
    "IsAvailable": true,
    "TotalRides": 1,
    "TotalEarnings": 73.92
  },
  ...
]
```

### Expected Database Query:
```sql
-- Check provider details
SELECT 
  u.FullName,
  sp.ProviderType,
  sp.Rating,
  sp.TotalRides,
  sp.TotalEarnings
FROM ServiceProvider sp
JOIN User u ON sp.UserID = u.UserID
WHERE sp.ProviderID = 1;

Expected Result:
FullName   | ProviderType | Rating | TotalRides | TotalEarnings
Ram Kumar  | Individual   | 4.5    | 4          | 296.00

-- Check vehicles
SELECT 
  VehicleNumber, Model, VehicleType,
  TotalRides, TotalEarnings, IsAvailable
FROM Vehicle
WHERE ProviderID = 1;

Expected Result: 3 rows showing all vehicles
```

### Where to Check:
- **Frontend**: Provider dashboard with stats and vehicle cards
- **Backend**: Terminal shows login and vehicle fetch
- **Database**: ServiceProvider and Vehicle tables
- **DevTools**: See provider stats and vehicle array

---

## 🧪 TEST 7: Add New Vehicle (Provider)

### Steps:
1. As provider (ram@example.com), click **"Add New Vehicle"**
2. Fill in form:
   - Vehicle Number: `KA01ZZ9999`
   - Model: `Test Vehicle`
   - Vehicle Type: `Auto`
   - Capacity: `3`
   - Hourly Rate: `100`
3. Click **"Save Vehicle"**

### Expected Frontend Output:
```
✅ Modal closes
✅ New vehicle card appears in the list:

┌─────────────────────────────────┐
│ Test Vehicle - Auto             │
│ KA01ZZ9999                      │
│ Capacity: 3 passengers          │
│ Hourly Rate: ₹100.00            │
│ Status: ✅ Available            │
│ Rides: 0 | Earnings: ₹0.00     │
│                                 │
│ [Toggle Status] [Edit]          │
└─────────────────────────────────┘

✅ Total vehicles now: 4
```

### Expected Backend Output:
```
Terminal shows:
POST /api/vehicles/provider/1 201

Body: {
  "vehicleNumber": "KA01ZZ9999",
  "model": "Test Vehicle",
  "vehicleType": "Auto",
  "capacity": 3,
  "hourlyRate": 100,
  "isAvailable": true
}

Response: {
  "VehicleID": 26,
  "VehicleNumber": "KA01ZZ9999",
  "Model": "Test Vehicle",
  ...
}

Then:
GET /api/vehicles/provider/1 200 (refreshes list)
```

### Expected Database Changes:
```sql
-- New vehicle inserted
SELECT * FROM Vehicle WHERE VehicleNumber = 'KA01ZZ9999';

Expected Result:
VehicleID: 26 (new ID)
ProviderID: 1
VehicleNumber: KA01ZZ9999
Model: Test Vehicle
VehicleType: Auto
Capacity: 3
HourlyRate: 100.00
IsAvailable: 1 (TRUE)
TotalRides: 0
TotalEarnings: 0.00
```

### Where to Check:
- **Frontend**: New vehicle card in dashboard
- **Backend**: Terminal shows POST and GET requests
- **Database**: New row in Vehicle table
- **DevTools**: See the POST request and response

---

## 🧪 TEST 8: Toggle Vehicle Availability

### Steps:
1. On any vehicle card, click **"Toggle Status"** button
2. Wait for update

### Expected Frontend Output:
```
✅ Status badge changes:
   Before: ✅ Available (green)
   After:  ❌ Unavailable (red)

✅ Vehicle card updates immediately
```

### Expected Backend Output:
```
Terminal shows:
PATCH /api/vehicles/26/toggle-availability 200

Response: {
  "VehicleID": 26,
  "IsAvailable": false  (changed from true)
}

Then:
GET /api/vehicles/provider/1 200 (refreshes list)
```

### Expected Database Changes:
```sql
-- Check vehicle availability changed
SELECT VehicleNumber, IsAvailable FROM Vehicle WHERE VehicleID = 26;

Expected Result:
VehicleNumber | IsAvailable
KA01ZZ9999    | 0 (FALSE - was 1/TRUE before)
```

### Where to Check:
- **Frontend**: Status badge color changes
- **Backend**: Terminal shows PATCH request
- **Database**: IsAvailable column updated
- **DevTools**: See the toggle API call

---

## 🧪 TEST 9: Complete Booking & See Earnings Update

### Steps:
1. Open MySQL Workbench or command line
2. Run: `CALL CompleteBooking(7);` (your new booking ID)
3. Refresh provider dashboard in browser

### Expected Frontend Output:
```
✅ Provider dashboard updates:
   Total Rides: 5 (was 4)
   Total Earnings: ₹412.40 (was ₹296.00)
   
✅ Vehicle earnings update:
   Hyundai Xcent earnings: ₹116.40 (was ₹0.00)
```

### Expected Backend Output:
```
Terminal shows:
GET /api/vehicles/provider/3 200 (if viewing Uber provider)

Response shows updated earnings
```

### Expected Database Changes:
```sql
-- Check booking completed
SELECT BookingID, BookingStatus, CompletedAt 
FROM Booking WHERE BookingID = 7;

Expected Result:
BookingID | BookingStatus | CompletedAt
7         | Completed     | 2024-11-07 08:30:15

-- Check provider earnings (80% of ₹145.50 = ₹116.40)
SELECT TotalRides, TotalEarnings 
FROM ServiceProvider WHERE ProviderID = 3;

Expected Result:
TotalRides | TotalEarnings
1          | 116.40 (was 0.00)

-- Check vehicle earnings
SELECT VehicleNumber, TotalRides, TotalEarnings 
FROM Vehicle WHERE VehicleID = 7;

Expected Result:
VehicleNumber | TotalRides | TotalEarnings
KA03OP9012    | 1          | 116.40 (was 0.00)
```

### Where to Check:
- **Frontend**: Provider dashboard stats updated
- **Backend**: Terminal shows API calls
- **Database**: Booking status, provider earnings, vehicle earnings all updated
- **MySQL**: Run queries to verify

---

## 🧪 TEST 10: Check Different Service Types

### Steps:
1. Login as user
2. Book 3 different rides:
   - Route 1: Select "Shortest" (Individual Auto)
   - Route 2: Select "Fastest" (Uber Cab)
   - Route 3: Select "Cheapest" (Rapido Bike)
3. View "My Bookings"

### Expected Frontend Output:
```
✅ Each booking shows different service:

Booking #8 - Individual Auto
Driver: Ram Kumar (Individual provider)
Vehicle: KA01AB1234 - Bajaj RE Compact

Booking #9 - Uber Cab
Driver: Vijay Reddy (Uber provider)
Vehicle: KA03OP9012 - Hyundai Xcent

Booking #10 - Rapido Bike
Driver: Vijay Reddy (Rapido provider)
Vehicle: KA04WX5678 - Honda Activa 5G
```

### Expected Database:
```sql
SELECT 
  BookingID,
  ServiceType,
  VehicleType,
  v.VehicleNumber,
  sp.ProviderType
FROM Booking b
LEFT JOIN Vehicle v ON b.VehicleID = v.VehicleID
LEFT JOIN ServiceProvider sp ON b.ProviderID = sp.ProviderID
WHERE BookingID IN (8, 9, 10);

Expected Result:
BookingID | ServiceType | VehicleType | VehicleNumber | ProviderType
8         | Individual  | Auto        | KA01AB1234    | Individual
9         | Uber        | Cab         | KA03OP9012    | Uber
10        | Rapido      | Bike        | KA04WX5678    | Rapido
```

---

## 📊 Summary of All Checks

| Feature | Frontend Check | Backend Check | Database Check |
|---------|---------------|---------------|----------------|
| **Login** | Header shows name | POST /api/auth/login | User table |
| **Service Comparison** | Table with 10 rows | GET /api/routes/service-comparisons | Fare table |
| **Route Options** | 3 cards with prices | POST /api/routes/route-options | Route table |
| **Book Ride** | Success message + vehicle details | POST /api/bookings/confirm | Booking table, TotalRides++ |
| **My Bookings** | List of bookings with details | GET /api/bookings/user/:id | Booking with JOINs |
| **Provider Dashboard** | Stats + vehicle cards | GET /api/vehicles/provider/:id | ServiceProvider, Vehicle |
| **Add Vehicle** | New card appears | POST /api/vehicles/provider/:id | New Vehicle row |
| **Toggle Availability** | Status badge changes | PATCH /api/vehicles/:id/toggle | IsAvailable updated |
| **Complete Booking** | Earnings increase | - | TotalEarnings += 80% |
| **Service Types** | Different providers shown | - | ServiceType, ProviderType match |

---

## 🎯 Quick Verification Commands

### Check Everything is Working:
```sql
-- Total bookings
SELECT COUNT(*) as TotalBookings FROM Booking;
-- Should be: 6+ bookings

-- Provider earnings
SELECT 
  u.FullName,
  sp.ProviderType,
  sp.TotalRides,
  sp.TotalEarnings
FROM ServiceProvider sp
JOIN User u ON sp.UserID = u.UserID
WHERE sp.TotalEarnings > 0;
-- Should show providers with earnings

-- Vehicle assignments
SELECT 
  b.BookingID,
  b.ServiceType,
  v.VehicleNumber,
  v.Model,
  sp.ProviderType
FROM Booking b
LEFT JOIN Vehicle v ON b.VehicleID = v.VehicleID
LEFT JOIN ServiceProvider sp ON b.ProviderID = sp.ProviderID
WHERE b.VehicleID IS NOT NULL;
-- Should show bookings with assigned vehicles

-- Recent bookings with full details
SELECT * FROM BookingDetails LIMIT 5;
-- Should show complete booking information
```

---

## 🎉 Success Criteria

Your RideHub is working perfectly if:
- ✅ Users can login and see dashboard
- ✅ Service comparison table shows 10 services
- ✅ Route search returns 3 options with different services
- ✅ Booking confirmation shows vehicle details (number, model, driver)
- ✅ My Bookings shows all bookings with vehicle info
- ✅ Providers can login and see their vehicles
- ✅ Providers can add new vehicles
- ✅ Vehicle availability can be toggled
- ✅ Completing bookings updates provider earnings (80% of fare)
- ✅ Different service types (Ola/Uber/Rapido) are tracked correctly
- ✅ Database has 25+ vehicles, 8 providers, 6+ bookings

---

**🚀 Happy Testing! Everything should work exactly as described above!**
