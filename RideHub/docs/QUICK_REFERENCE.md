# 🚀 RideHub Quick Reference Card

## ⚡ Quick Start Commands

```bash
# 1. Initialize Database
mysql -u root -p < server/database/init_database.sql

# 2. Start Backend (Terminal 1)
cd server
npm install
npm start

# 3. Start Frontend (Terminal 2)
npm install
npm run dev
```

## 🌐 URLs

- **Frontend:** http://localhost:5173
- **Backend:** http://localhost:5000
- **Health Check:** http://localhost:5000/api/health

## 🔑 Test Accounts

| Type | Email | Password |
|------|-------|----------|
| User | test@example.com | any |
| Provider | ram@example.com | any |

## 📁 Important Files

| File | Purpose |
|------|---------|
| `server/server.js` | Main backend server |
| `server/.env` | Backend configuration |
| `services/api.ts` | Frontend API calls |
| `.env` | Frontend configuration |
| `server/database/init_database.sql` | Database setup |

## 🔌 Key API Endpoints

```bash
# Login
POST /api/auth/login
Body: { "email": "test@example.com", "role": "USER" }

# Get Routes
POST /api/routes/route-options
Body: { "startLocation": "Majestic", "endLocation": "Lalbagh Botanical Garden" }

# Confirm Booking
POST /api/bookings/confirm
Body: { "userId": 1, "startLocation": "...", "endLocation": "...", "routeType": "Shortest", "estimatedFare": 92.4 }

# Get Vehicles
GET /api/vehicles/provider/:providerId
```

## 🗄️ Database Quick Queries

```sql
-- View all users
SELECT * FROM User;

-- View all bookings
SELECT * FROM Booking ORDER BY BookingTime DESC;

-- View all routes
SELECT RouteName, StartLocation, EndLocation, Distance FROM Route;

-- View service fares
SELECT ServiceType, VehicleType, BaseFare, PerKmRate FROM Fare;

-- View provider vehicles
SELECT v.*, sp.ProviderType FROM Vehicle v 
JOIN ServiceProvider sp ON v.ProviderID = sp.ProviderID;
```

## 🐛 Troubleshooting

| Problem | Solution |
|---------|----------|
| Database connection failed | Check MySQL is running, verify credentials in `server/.env` |
| Port 5000 in use | Change `PORT` in `server/.env` |
| Frontend can't connect | Verify backend is running, check `VITE_API_URL` in `.env` |
| npm install fails | Run `npm cache clean --force` and retry |

## 📊 Project Stats

- **Backend Files:** 7 routes + 1 server + 1 config
- **API Endpoints:** 15+ endpoints
- **Database Tables:** 8 main tables
- **Routes:** 11 pre-configured Bangalore routes
- **Services:** 5 transport services (Ola, Uber, Rapido, Namma Yatri, Individual)

## 🎯 Common Tasks

### Add a New Route
```sql
INSERT INTO Route (RouteName, StartLocation, EndLocation, Distance, EstimatedTime, RouteType) 
VALUES ('New Route', 'Start', 'End', 5.0, 20, 'Shortest');
```

### Add a New User
```sql
INSERT INTO User (Phone, Username, FullName, LastName, Email, Age, PasswordHash) 
VALUES ('1234567890', 'newuser', 'New User', 'User', 'new@example.com', 25, '$2b$10$hash');
```

### Check Booking Status
```sql
SELECT b.BookingID, u.FullName, b.StartLocation, b.EndLocation, b.BookingStatus, b.TotalFare
FROM Booking b
JOIN User u ON b.UserID = u.UserID
ORDER BY b.BookingTime DESC;
```

## 🔧 Environment Variables

### Frontend (.env)
```env
VITE_API_KEY=your_gemini_api_key
VITE_API_URL=http://localhost:5000/api
```

### Backend (server/.env)
```env
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=your_password
DB_NAME=TransportBookingSystem
PORT=5000
```

## 📚 Documentation Files

1. **README.md** - Full documentation
2. **SETUP_GUIDE.md** - 5-minute setup
3. **TESTING_CHECKLIST.md** - Testing guide
4. **IMPLEMENTATION_SUMMARY.md** - Technical details
5. **QUICK_REFERENCE.md** - This file

## 🎨 Tech Stack

- **Frontend:** React + TypeScript + Vite
- **Backend:** Node.js + Express
- **Database:** MySQL 8.0+
- **Auth:** bcrypt password hashing

## 📞 Support

Check these in order:
1. Browser console (F12)
2. Backend terminal logs
3. MySQL error logs
4. README.md troubleshooting section

---

**Keep this handy while developing! 📌**
