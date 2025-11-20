# 🚗 RideHub - Multi-Modal Transport Booking System

A comprehensive transport booking platform that allows users to compare and book rides across multiple service providers (Ola, Uber, Rapido, Namma Yatri, Individual providers) with intelligent route optimization.

## ✨ Features

### For Users
- 🔐 User authentication and registration
- 🗺️ Multi-route comparison (Shortest, Fastest, Cheapest)
- 💰 Real-time fare comparison across services
- 📍 Bangalore city routes with accurate distances
- 📱 Booking management and history
- 🤖 AI-powered trip suggestions (using Google Gemini)

### For Providers
- 🚙 Vehicle management (Add, Edit, Delete)
- 📊 Dashboard with booking overview
- ✅ Availability toggle for vehicles
- 📄 Document management

## 🛠️ Tech Stack

### Frontend
- **React 18** with TypeScript
- **Vite** for fast development
- **Tailwind CSS** for styling
- **Google Gemini AI** for trip suggestions

### Backend
- **Node.js** with Express.js
- **MySQL** database with geospatial support
- **bcrypt** for password hashing
- **CORS** enabled for cross-origin requests

## 📋 Prerequisites

Before you begin, ensure you have the following installed:
- **Node.js** (v18 or higher)
- **MySQL** (v8.0 or higher)
- **npm** or **yarn**

## 🚀 Installation & Setup

### 1. Clone the Repository
```bash
cd "c:\Users\anany\Downloads\RideHub (1)\RideHub"
```

### 2. Database Setup

#### Start MySQL Server
Make sure your MySQL server is running.

#### Create Database
```bash
# Login to MySQL
mysql -u root -p

# Run the initialization script
source server/database/init_database.sql
```

Or import via command line:
```bash
mysql -u root -p < server/database/init_database.sql
```

### 3. Backend Setup

#### Install Dependencies
```bash
cd server
npm install
```

#### Configure Environment
```bash
# Copy the example environment file
cp .env.example .env

# Edit .env with your database credentials
# Update these values:
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=your_mysql_password
DB_NAME=TransportBookingSystem
DB_PORT=3306
PORT=5000
```

#### Start Backend Server
```bash
npm start
# Or for development with auto-reload:
npm run dev
```

The backend server will start on `http://localhost:5000`

### 4. Frontend Setup

#### Install Dependencies
```bash
# From the root directory
npm install
```

#### Configure Environment
```bash
# Copy the example environment file
cp .env.example .env

# Edit .env and add your Google Gemini API key
VITE_API_KEY=your_gemini_api_key_here
VITE_API_URL=http://localhost:5000/api
```

Get your Gemini API key from: https://makersuite.google.com/app/apikey

#### Start Frontend Development Server
```bash
npm run dev
```

The frontend will start on `http://localhost:5173`

## 🎯 Usage

### Test Accounts

The database comes with pre-configured test accounts:

**User Account:**
- Email: `test@example.com`
- Password: (any password - authentication is simplified for testing)

**Provider Account:**
- Email: `ram@example.com`
- Password: (any password)

### Creating New Accounts

1. **User Signup:**
   - Click "Get Started" on landing page
   - Fill in personal details
   - Submit registration

2. **Provider Signup:**
   - Click "Become a Provider"
   - Fill in personal and business details
   - Upload document URLs
   - Submit registration

### Booking a Ride

1. Login as a user
2. Navigate to "Book a Ride"
3. Enter start location (e.g., "Majestic")
4. Enter destination (e.g., "Lalbagh Botanical Garden")
5. Click "Find Routes"
6. Compare the three route options
7. Select your preferred route
8. Confirm booking

### Managing Vehicles (Providers)

1. Login as a provider
2. View your dashboard
3. Add new vehicles with details
4. Toggle vehicle availability
5. Edit or delete existing vehicles

## 📁 Project Structure

```
RideHub/
├── server/                      # Backend server
│   ├── config/
│   │   └── database.js         # Database configuration
│   ├── routes/
│   │   ├── auth.js             # Authentication routes
│   │   ├── bookings.js         # Booking management
│   │   ├── routes.js           # Route calculations
│   │   └── vehicles.js         # Vehicle management
│   ├── database/
│   │   └── init_database.sql   # Database initialization
│   ├── server.js               # Main server file
│   └── package.json
├── services/
│   ├── api.ts                  # Frontend API service
│   └── GeminiService.ts        # AI integration
├── pages/                      # React pages
│   ├── LandingPage.tsx
│   ├── LoginPage.tsx
│   ├── UserSignupPage.tsx
│   ├── ProviderSignupPage.tsx
│   ├── UserDashboard.tsx
│   ├── ProviderDashboard.tsx
│   ├── BookingPage.tsx
│   └── MyBookingsPage.tsx
├── components/                 # Reusable components
│   ├── Header.tsx
│   ├── Button.tsx
│   ├── Card.tsx
│   ├── Modal.tsx
│   └── AuthInput.tsx
├── App.tsx                     # Main app component
├── types.ts                    # TypeScript types
└── package.json
```

## 🔌 API Endpoints

### Authentication
- `POST /api/auth/login` - User/Provider login
- `POST /api/auth/signup/user` - User registration
- `POST /api/auth/signup/provider` - Provider registration

### Routes
- `GET /api/routes/service-comparisons` - Get fare comparisons
- `POST /api/routes/route-options` - Calculate route options

### Bookings
- `POST /api/bookings/confirm` - Create new booking
- `GET /api/bookings/user/:userId` - Get user's bookings
- `PATCH /api/bookings/:bookingId/status` - Update booking status

### Vehicles
- `GET /api/vehicles/provider/:providerId` - Get provider's vehicles
- `POST /api/vehicles/provider/:providerId` - Add new vehicle
- `PUT /api/vehicles/:vehicleId` - Update vehicle
- `PATCH /api/vehicles/:vehicleId/toggle-availability` - Toggle availability
- `DELETE /api/vehicles/:vehicleId` - Delete vehicle

## 🗄️ Database Schema

### Key Tables
- **User** - User accounts (both riders and providers)
- **ServiceProvider** - Provider-specific information
- **Vehicle** - Provider vehicles
- **Route** - Pre-defined routes with geospatial data
- **Booking** - User bookings
- **Fare** - Service pricing structure
- **ProviderDocuments** - Provider verification documents

## 🐛 Troubleshooting

### Database Connection Issues
```bash
# Check if MySQL is running
mysql -u root -p

# Verify database exists
SHOW DATABASES;
USE TransportBookingSystem;
SHOW TABLES;
```

### Backend Not Starting
- Verify `.env` file exists in `server/` directory
- Check database credentials
- Ensure MySQL server is running
- Check port 5000 is not in use

### Frontend API Errors
- Verify backend server is running on port 5000
- Check browser console for CORS errors
- Verify `VITE_API_URL` in `.env` file

### Build Errors
```bash
# Clear node_modules and reinstall
rm -rf node_modules package-lock.json
npm install

# For backend
cd server
rm -rf node_modules package-lock.json
npm install
```

## 🔧 Development

### Running in Development Mode

**Backend:**
```bash
cd server
npm run dev  # Uses --watch flag for auto-reload
```

**Frontend:**
```bash
npm run dev  # Vite dev server with HMR
```

### Building for Production

```bash
# Frontend build
npm run build

# The built files will be in the dist/ directory
```

## 📝 Environment Variables

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
DB_PORT=3306
PORT=5000
NODE_ENV=development
FRONTEND_URL=http://localhost:5173
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License.

## 🙏 Acknowledgments

- Google Gemini AI for trip suggestions
- OpenStreetMap for geospatial data
- Bangalore transport services for inspiration

## 📞 Support

For issues and questions:
- Check the troubleshooting section
- Review the API documentation
- Check database logs in MySQL
- Review browser console for frontend errors

---

**Built with ❤️ for seamless multi-modal transport booking**
