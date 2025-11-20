# 🧪 RideHub Testing Checklist

Use this checklist to verify all functionality is working correctly.

## 📋 Pre-Testing Setup

- [ ] MySQL server is running
- [ ] Database `TransportBookingSystem` is created and initialized
- [ ] Backend server is running on port 5000
- [ ] Frontend is running on port 5173
- [ ] Both `.env` files are configured

## 🔐 Authentication Tests

### User Signup
- [ ] Navigate to landing page
- [ ] Click "Get Started"
- [ ] Fill in all user signup fields
- [ ] Submit form
- [ ] Verify success message
- [ ] Check database: `SELECT * FROM User WHERE Email = 'your_email';`

### User Login
- [ ] Click "Sign In" as User
- [ ] Enter email: `test@example.com`
- [ ] Click login
- [ ] Verify redirect to User Dashboard
- [ ] Check user name displays in header

### Provider Signup
- [ ] Navigate to landing page
- [ ] Click "Become a Provider"
- [ ] Fill in all provider signup fields
- [ ] Submit form
- [ ] Verify success message
- [ ] Check database: `SELECT * FROM ServiceProvider;`

### Provider Login
- [ ] Click "Sign In" as Provider
- [ ] Enter email: `ram@example.com`
- [ ] Click login
- [ ] Verify redirect to Provider Dashboard
- [ ] Check provider name displays in header

## 🚗 User Flow Tests

### View Service Comparisons
- [ ] Login as user
- [ ] Navigate to dashboard
- [ ] Verify service comparison table loads
- [ ] Check prices are displayed correctly
- [ ] Verify at least 8 services shown

### Book a Ride
- [ ] Click "Book a Ride"
- [ ] Enter Start Location: `Majestic`
- [ ] Enter End Location: `Lalbagh Botanical Garden`
- [ ] Click "Find Routes"
- [ ] Verify 3 route options appear:
  - [ ] Shortest route
  - [ ] Fastest route
  - [ ] Cheapest route
- [ ] Check distances and fares are displayed
- [ ] Select one route option
- [ ] Click "Confirm Booking"
- [ ] Verify success message
- [ ] Check redirect to My Bookings

### View My Bookings
- [ ] Navigate to "My Bookings"
- [ ] Verify booking list loads
- [ ] Check booking details are correct:
  - [ ] Start and end locations
  - [ ] Status (Confirmed)
  - [ ] Route type
  - [ ] Provider details
- [ ] Verify database: `SELECT * FROM Booking WHERE UserID = ?;`

### Try Different Routes
Test with these route combinations:
- [ ] Majestic → MG Road (3.2 km)
- [ ] Majestic → Bengaluru Palace (4.5 km)
- [ ] Majestic → J.P. Nagar (8.3 km)
- [ ] Majestic → ISKCON Temple (9.8 km)

## 🚙 Provider Flow Tests

### View Dashboard
- [ ] Login as provider
- [ ] Verify dashboard loads
- [ ] Check "My Vehicles" section
- [ ] Verify existing vehicles display (if any)

### Add New Vehicle
- [ ] Click "Add New Vehicle"
- [ ] Fill in vehicle details:
  - [ ] Vehicle Number: `KA01TEST1234`
  - [ ] Model: `Test Vehicle`
  - [ ] Type: Select from dropdown
  - [ ] Capacity: `4`
  - [ ] Hourly Rate: `150`
- [ ] Click "Save Vehicle"
- [ ] Verify vehicle appears in list
- [ ] Check database: `SELECT * FROM Vehicle WHERE VehicleNumber = 'KA01TEST1234';`

### Edit Vehicle
- [ ] Click "Edit" on a vehicle
- [ ] Modify vehicle details
- [ ] Click "Save Vehicle"
- [ ] Verify changes are reflected
- [ ] Check database for updated values

### Toggle Vehicle Availability
- [ ] Click "Toggle Status" on a vehicle
- [ ] Verify status badge changes (Available ↔ Unavailable)
- [ ] Click again to toggle back
- [ ] Check database: `SELECT IsAvailable FROM Vehicle WHERE VehicleID = ?;`

## 🔌 API Endpoint Tests

### Health Check
```bash
curl http://localhost:5000/api/health
```
- [ ] Returns status: "ok"

### Service Comparisons
```bash
curl http://localhost:5000/api/routes/service-comparisons
```
- [ ] Returns array of services
- [ ] Each has serviceType, vehicleType, fareFor5Km

### Route Options
```bash
curl -X POST http://localhost:5000/api/routes/route-options \
  -H "Content-Type: application/json" \
  -d '{"startLocation":"Majestic","endLocation":"Lalbagh Botanical Garden"}'
```
- [ ] Returns 3 route options
- [ ] Each has routeType, distance, estimatedTime, estimatedFare

## 🗄️ Database Tests

### Verify Data Integrity
```sql
-- Check users
SELECT COUNT(*) FROM User;  -- Should have at least 3

-- Check providers
SELECT COUNT(*) FROM ServiceProvider;  -- Should have at least 2

-- Check routes
SELECT COUNT(*) FROM Route;  -- Should have 11 Bangalore routes

-- Check fares
SELECT COUNT(*) FROM Fare;  -- Should have 10 fare entries

-- Check vehicles
SELECT COUNT(*) FROM Vehicle;  -- Should have at least 4

-- Check bookings
SELECT * FROM Booking ORDER BY BookingTime DESC LIMIT 5;
```

### Test Geospatial Data
```sql
-- Verify routes have coordinates
SELECT 
    RouteName,
    StartLocation,
    EndLocation,
    Distance,
    ST_AsText(StartPoint) as StartCoords,
    ST_AsText(EndPoint) as EndCoords
FROM Route
WHERE StartLocation = 'Majestic'
LIMIT 3;
```
- [ ] All routes have StartPoint and EndPoint
- [ ] Coordinates are in POINT format

## 🐛 Error Handling Tests

### Backend Errors
- [ ] Stop MySQL server
- [ ] Try to login
- [ ] Verify frontend shows error message
- [ ] Check browser console for error details
- [ ] Restart MySQL and verify recovery

### Invalid Data
- [ ] Try to add vehicle with duplicate number
- [ ] Verify error message
- [ ] Try to book with empty locations
- [ ] Verify validation works

### Network Errors
- [ ] Stop backend server
- [ ] Try to perform any action
- [ ] Verify user-friendly error message
- [ ] Check browser console

## 🎨 UI/UX Tests

### Responsive Design
- [ ] Resize browser window
- [ ] Test on mobile view (F12 → Device Toolbar)
- [ ] Verify layout adapts correctly
- [ ] Check all buttons are clickable

### Loading States
- [ ] Verify loading spinners appear during API calls
- [ ] Check buttons show loading state
- [ ] Ensure no double-submissions possible

### Navigation
- [ ] Test all header navigation links
- [ ] Verify logout works
- [ ] Check back navigation
- [ ] Test page refresh maintains state

## 🚀 Performance Tests

### Load Times
- [ ] Dashboard loads in < 2 seconds
- [ ] Route calculation completes in < 1 second
- [ ] Booking confirmation is instant

### Concurrent Users
- [ ] Open app in 2 different browsers
- [ ] Login as different users
- [ ] Perform actions simultaneously
- [ ] Verify no conflicts

## ✅ Final Verification

- [ ] All user flows work end-to-end
- [ ] All provider flows work end-to-end
- [ ] Database is properly populated
- [ ] No console errors in browser
- [ ] No errors in backend logs
- [ ] All API endpoints respond correctly

## 📝 Test Results

**Date Tested:** _______________

**Tested By:** _______________

**Overall Status:** 
- [ ] ✅ All tests passed
- [ ] ⚠️ Some issues found (list below)
- [ ] ❌ Major issues found

**Issues Found:**
1. 
2. 
3. 

**Notes:**


---

**Testing Complete! 🎉**
