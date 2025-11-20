# UE23CS351A-_DBMS_MINI_PROJECT_TRAVEL_FRIEND

# 🚗 RideHub - Multi-Modal Transportation Booking System

[![Database](https://img.shields.io/badge/Database-MySQL-blue.svg)](https://www.mysql.com/)
[![Backend](https://img.shields.io/badge/Backend-Node.js-green.svg)](https://nodejs.org/)
[![Frontend](https://img.shields.io/badge/Frontend-React-61DAFB.svg)](https://reactjs.org/)
[![Cache](https://img.shields.io/badge/Cache-Redis-red.svg)](https://redis.io/)
[![AI](https://img.shields.io/badge/AI-Google%20Gemini-orange.svg)](https://ai.google.dev/)

> A comprehensive multi-modal transportation booking system that integrates various transportation services including Ola, Uber, Metro, BMTC buses, Bounce scooters, and individual providers into a single unified platform.

## 📋 Table of Contents

- [🎯 Project Overview](#-project-overview)
- [✨ Key Features](#-key-features)
- [🏗️ System Architecture](#️-system-architecture)
- [🗄️ Database Design](#️-database-design)
- [🚀 Technology Stack](#-technology-stack)
- [📱 User Interface](#-user-interface)
- [🔧 Installation & Setup](#-installation--setup)
- [📊 Database Schema](#-database-schema)
- [🔄 API Endpoints](#-api-endpoints)
- [🧪 Testing Guide](#-testing-guide)
- [📈 Performance Features](#-performance-features)
- [🎨 Screenshots](#-screenshots)
- [👥 Team](#-team)
- [📄 License](#-license)

## 🎯 Project Overview

RideHub addresses the fragmented urban transportation ecosystem by providing a unified platform where users can:

- **Plan Multi-Modal Journeys**: Combine different transport modes (Metro + Ola + Bounce) in a single booking
- **Compare Routes**: Choose between shortest, fastest, or cheapest route options
- **Real-Time Tracking**: Get live updates and notifications throughout the journey
- **Integrated Payments**: Seamless payment processing with multiple methods
- **AI-Powered Suggestions**: Get intelligent trip recommendations based on destinations and interests

### 🎯 Problem Statement

Urban transportation in cities like Bangalore involves multiple disconnected services. Users often struggle to:
- Plan efficient multi-modal journeys
- Compare costs across different transport modes
- Get real-time updates during complex trips
- Manage bookings across multiple platforms

### 💡 Solution

RideHub provides a centralized platform that integrates all transportation modes, enabling users to book complex journeys like:
1. **Bounce scooter** from home to metro station
2. **Bangalore Metro** from Electronic City to MG Road
3. **Ola cab** from MG Road to final destination

## ✨ Key Features

### 🚀 Core Functionality

- **Multi-Modal Booking System**: Book complex journeys with multiple transportation segments
- **Real-Time Vehicle Assignment**: Automatic assignment of available vehicles based on location and ratings
- **Dynamic Fare Calculation**: Smart pricing based on distance, time, surge factors, and offers
- **Comprehensive Notifications**: SMS, email, and push notifications for booking updates
- **Provider Management**: Complete system for transportation service providers
- **Payment Integration**: Secure payment processing with multiple payment methods

### 🧠 Advanced Features

- **AI Trip Suggester**: Powered by Google Gemini AI for intelligent trip recommendations
- **Redis Caching**: High-performance caching for frequently accessed data
- **Metro Integration**: Complete Bangalore Metro system with route planning
- **Bounce Centers**: Real-time scooter availability across Bangalore
- **Bus Routes**: BMTC bus integration with route information
- **Rating System**: User feedback and provider rating management

### 🔐 Security & Performance

- **JWT Authentication**: Secure token-based authentication system
- **Password Hashing**: bcrypt implementation for secure password storage
- **Role-Based Access**: Different access levels for users and providers
- **Database Optimization**: Proper indexing and query optimization
- **Error Handling**: Comprehensive error management and logging

## 🏗️ System Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   React Frontend │    │   Node.js API   │    │   MySQL Database│
│                 │◄──►│                 │◄──►│                 │
│  - User Interface│    │  - Authentication│    │  - User Data    │
│  - Booking Forms │    │  - Business Logic│    │  - Bookings     │
│  - Real-time UI  │    │  - Route Planning│    │  - Vehicles     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │              ┌─────────────────┐             │
         │              │   Redis Cache   │             │
         └──────────────►│                 │◄────────────┘
                        │  - Session Data │
                        │  - AI Responses │
                        │  - Route Cache  │
                        └─────────────────┘
                                 │
                        ┌─────────────────┐
                        │  Google Gemini  │
                        │      AI API     │
                        │                 │
                        │ - Trip Suggestions│
                        │ - Route Planning │
                        └─────────────────┘
```

## 🗄️ Database Design

### 📊 Entity Relationship Overview

Our database follows a normalized design with the following key relationships:

- **User (1:N) Booking**: One user can have multiple bookings
- **Booking (1:N) BookingSegment**: Multi-modal journeys have multiple segments
- **ServiceProvider (1:N) Vehicle**: Providers can own multiple vehicles
- **Booking (1:1) Payment**: Each booking has one payment record
- **User (1:N) Notification**: Users receive multiple notifications

### 🏛️ Core Tables

| Table | Purpose | Key Features |
|-------|---------|--------------|
| **User** | User management | Authentication, profiles, roles |
| **Booking** | Journey bookings | Multi-modal support, status tracking |
| **BookingSegment** | Journey segments | Individual transport legs |
| **ServiceProvider** | Provider management | Ratings, earnings, verification |
| **Vehicle** | Vehicle inventory | Availability, types, assignments |
| **Notification** | Communication | Real-time updates, multi-channel |

## 🚀 Technology Stack

### 🖥️ Backend Technologies
- **Node.js**: Server-side runtime environment
- **Express.js**: Web application framework
- **MySQL**: Primary relational database with InnoDB engine
- **Redis**: In-memory caching for performance optimization
- **JWT**: JSON Web Tokens for secure authentication
- **bcrypt**: Password hashing and security

### 🎨 Frontend Technologies
- **React 18**: Modern frontend framework with hooks
- **TypeScript**: Type-safe JavaScript development
- **Tailwind CSS**: Utility-first CSS framework
- **Vite**: Fast build tool and development server

### 🔌 External APIs & Services
- **Google Gemini AI**: AI-powered trip suggestions and route optimization
- **Multer**: File upload handling for provider documents

### 🛠️ Development Tools
- **Visual Studio Code**: Primary IDE
- **MySQL Workbench**: Database design and management
- **Redis CLI**: Cache management and monitoring
- **Git**: Version control system

## 📱 User Interface

### 🏠 Landing Page
- Clean, modern design with role-based login
- Feature overview and navigation
- Responsive design for all devices

### 👤 User Dashboard
- Quick booking interface with route options
- Recent bookings with status tracking
- Notification center for real-time updates

### 🚗 Provider Dashboard
- Earnings tracking and analytics
- Booking management and history
- Vehicle management interface

### 📊 Booking Interface
- Multi-modal route planning
- Real-time fare calculation
- Segment-wise journey breakdown
- Payment integration

## 🔧 Installation & Setup

### 📋 Prerequisites

- **Node.js** (v16 or higher)
- **MySQL** (v8.0 or higher)
- **Redis** (v6.0 or higher)
- **Git**

### 🚀 Quick Start

1. **Clone the Repository**
```bash
git clone https://github.com/yourusername/ridehub.git
cd ridehub
```

2. **Database Setup**
```bash
# Start MySQL service
mysql -u root -p

# Create database and run scripts
source sql-enhanced/01_SCHEMA_ENHANCED.sql;
source sql-enhanced/02_USERS_DATA.sql;
source sql-enhanced/03_VEHICLES_DATA.sql;
source sql-enhanced/04_BOUNCE_CENTERS.sql;
source sql-enhanced/05_BUS_ROUTES.sql;
source sql-enhanced/06_ROUTES_FARES.sql;
source sql-enhanced/07_PROCEDURES_TRIGGERS.sql;
source sql-enhanced/08_SAMPLE_BOOKINGS.sql;
```

3. **Backend Setup**
```bash
cd server
npm install
cp .env.example .env
# Edit .env with your database credentials
npm start
```

4. **Frontend Setup**
```bash
# In project root
npm install
npm run dev
```

5. **Redis Setup**
```bash
# Start Redis server
redis-server
```

### 🌐 Access the Application

- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:5000
- **Database**: localhost:3306

## 📊 Database Schema

### 🗂️ Core Tables Structure

```sql
-- User Management
CREATE TABLE User (
    UserID INT PRIMARY KEY AUTO_INCREMENT,
    Phone VARCHAR(15) UNIQUE NOT NULL,
    Username VARCHAR(50) UNIQUE NOT NULL,
    FullName VARCHAR(100) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    PasswordHash VARCHAR(255) NOT NULL,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    IsActive BOOLEAN DEFAULT TRUE,
    IsProvider BOOLEAN DEFAULT FALSE
);

-- Multi-Modal Booking System
CREATE TABLE Booking (
    BookingID INT PRIMARY KEY AUTO_INCREMENT,
    UserID INT NOT NULL,
    StartLocation VARCHAR(200) NOT NULL,
    EndLocation VARCHAR(200) NOT NULL,
    TotalDistance DECIMAL(10, 2) NOT NULL,
    TotalTime INT NOT NULL,
    TotalFare DECIMAL(10, 2) NOT NULL,
    BookingStatus ENUM('Pending', 'Confirmed', 'InProgress', 'Completed', 'Cancelled'),
    IsMultiModal BOOLEAN DEFAULT FALSE,
    SegmentCount INT DEFAULT 1,
    FOREIGN KEY (UserID) REFERENCES User(UserID)
);

-- Journey Segments
CREATE TABLE BookingSegment (
    SegmentID INT PRIMARY KEY AUTO_INCREMENT,
    BookingID INT NOT NULL,
    SegmentOrder INT NOT NULL,
    ServiceType ENUM('Ola', 'Uber', 'Metro', 'Namma Yatri', 'Rapido', 'Bounce', 'BMTC'),
    VehicleType ENUM('Auto', 'Cab', 'Bike', 'Metro', 'Scooter', 'Bus'),
    StartLocation VARCHAR(200) NOT NULL,
    EndLocation VARCHAR(200) NOT NULL,
    SegmentFare DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (BookingID) REFERENCES Booking(BookingID)
);
```

### 🔄 Stored Procedures

**Multi-Modal Booking Creation:**
```sql
CALL CreateMultiModalBooking(
    1,                    -- UserID
    'Electronic City',    -- StartLocation
    'Indiranagar',       -- EndLocation
    25.5,                -- TotalDistance
    65,                  -- TotalTime
    180.00,              -- TotalFare
    'Fastest',           -- RouteType
    TRUE,                -- IsMultiModal
    3                    -- SegmentCount
);
```

### ⚡ Triggers

**Automatic Notifications:**
```sql
CREATE TRIGGER trg_NotifyUserOnBooking
AFTER INSERT ON Booking
FOR EACH ROW
BEGIN
    INSERT INTO Notification (UserID, Message, NotificationType)
    VALUES (NEW.UserID, 
           CONCAT('Booking #', NEW.BookingID, ' confirmed! Fare: ₹', NEW.TotalFare),
           'Booking');
END;
```

## 🔄 API Endpoints

### 🔐 Authentication
- `POST /api/auth/login` - User login
- `POST /api/auth/signup/user` - User registration
- `POST /api/auth/signup/provider` - Provider registration

### 🚗 Booking Management
- `POST /api/multimodal/book` - Create multi-modal booking
- `GET /api/multimodal/user/:userId` - Get user bookings
- `PUT /api/bookings/:id/status` - Update booking status

### 🚇 Transportation Services
- `GET /api/metro/routes` - Get metro routes
- `GET /api/bounce/centers` - Get bounce centers
- `GET /api/routes/bus` - Get bus routes

### 🤖 AI Services
- `POST /api/ai-trip/generate` - Generate AI trip suggestions
- `GET /api/ai-trip/cache-stats` - Get cache performance

### 📱 Notifications
- `GET /api/notifications/:userId` - Get user notifications
- `PUT /api/notifications/:id/read` - Mark notification as read

## 🧪 Testing Guide

### 🔍 Database Testing

```sql
-- Test user creation
INSERT INTO User (Phone, Username, FullName, Email, PasswordHash) 
VALUES ('9876543210', 'testuser', 'Test User', 'test@example.com', 'hashedpassword');

-- Test booking creation
CALL CreateMultiModalBooking(1, 'Koramangala', 'Whitefield', 18.5, 45, 150.00, 'Shortest', FALSE, 1);

-- Verify notifications
SELECT * FROM Notification WHERE UserID = 1;
```

### 🌐 API Testing

```bash
# Test user login
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "test@example.com", "role": "USER"}'

# Test booking creation
curl -X POST http://localhost:5000/api/multimodal/book \
  -H "Content-Type: application/json" \
  -d '{"userId": 1, "startLocation": "Koramangala", "endLocation": "Whitefield"}'
```

### 🎯 Frontend Testing

1. **User Registration**: Test signup flow with validation
2. **Multi-Modal Booking**: Create complex journeys with multiple segments
3. **Real-Time Updates**: Verify notifications and status changes
4. **Payment Flow**: Test payment integration and confirmation
5. **Provider Features**: Test provider dashboard and vehicle management

## 📈 Performance Features

### ⚡ Redis Caching
- **AI Response Caching**: Cache trip suggestions for 1 hour
- **Route Caching**: Cache frequently requested routes
- **Session Management**: Fast session data retrieval

### 🗄️ Database Optimization
- **Proper Indexing**: Strategic indexes on frequently queried columns
- **Query Optimization**: Efficient joins and aggregations
- **Connection Pooling**: Optimized database connections

### 🔄 Real-Time Features
- **Live Notifications**: Instant updates via WebSocket connections
- **Dynamic Pricing**: Real-time fare calculations based on demand
- **Vehicle Tracking**: Live vehicle availability updates

## 🎨 Screenshots

### 🏠 Landing Page
![Landing Page](docs/screenshots/landing-page.png)
*Clean, modern interface with role-based access*

### 📱 User Dashboard
![User Dashboard](docs/screenshots/user-dashboard.png)
*Intuitive booking interface with quick access to features*

### 🚗 Multi-Modal Booking
![Booking Interface](docs/screenshots/booking-interface.png)
*Comprehensive booking system with route comparison*

### 📊 Provider Dashboard
![Provider Dashboard](docs/screenshots/provider-dashboard.png)
*Complete provider management with earnings tracking*

### 🚇 Metro Integration
![Metro System](docs/screenshots/metro-system.png)
*Interactive metro map with route planning*

### 🛴 Bounce Centers
![Bounce Centers](docs/screenshots/bounce-centers.png)
*Real-time scooter availability across Bangalore*

## 📁 Project Structure

```
RideHub/
├── 📁 server/                 # Backend Node.js application
│   ├── 📁 routes/            # API endpoints
│   │   ├── auth.js           # Authentication routes
│   │   ├── multimodal.js     # Booking management
│   │   ├── metro.js          # Metro system integration
│   │   └── aiTrip.js         # AI trip suggestions
│   ├── 📁 middleware/        # Authentication middleware
│   ├── 📁 config/           # Database configuration
│   └── server.js            # Main server file
├── 📁 pages/                 # React frontend pages
│   ├── LandingPage.tsx      # Home page
│   ├── BookingPage.tsx      # Booking interface
│   ├── UserDashboard.tsx    # User dashboard
│   └── ProviderDashboard.tsx # Provider dashboard
├── 📁 components/           # Reusable UI components
├── 📁 services/             # API service layers
├── 📁 sql-enhanced/         # Database scripts
│   ├── 01_SCHEMA_ENHANCED.sql
│   ├── 02_USERS_DATA.sql
│   └── 07_PROCEDURES_TRIGGERS.sql
└── 📁 docs/                 # Documentation
```

## 🚀 Deployment

### 🌐 Production Setup

1. **Environment Configuration**
```bash
# Production environment variables
NODE_ENV=production
DB_HOST=your-production-db-host
DB_USER=your-db-user
DB_PASSWORD=your-secure-password
REDIS_URL=your-redis-url
JWT_SECRET=your-jwt-secret
```

2. **Database Migration**
```bash
# Run all SQL scripts in sequence
mysql -u root -p < sql-enhanced/01_SCHEMA_ENHANCED.sql
# ... continue with all scripts
```

3. **Application Deployment**
```bash
# Build frontend
npm run build

# Start production server
npm run start:prod
```

## 🔮 Future Enhancements

### 🎯 Planned Features
- **Real-Time Tracking**: GPS integration for live vehicle tracking
- **Advanced Analytics**: Machine learning for demand prediction
- **Mobile App**: Native iOS and Android applications
- **Payment Gateway**: Integration with multiple payment providers
- **Social Features**: Ride sharing and social booking options

### 🚀 Scalability Improvements
- **Microservices Architecture**: Break down into smaller services
- **Load Balancing**: Distribute traffic across multiple servers
- **Database Sharding**: Horizontal scaling for large datasets
- **CDN Integration**: Fast content delivery worldwide

## 👥 Team

**Project Team:**
- **Developer 1**: [Your Name] - Full-stack development, database design
- **Developer 2**: [Team Member] - Frontend development, UI/UX design

**Roles & Responsibilities:**
- Database design and optimization
- Backend API development
- Frontend user interface
- System integration and testing

## 📊 Project Statistics

- **📁 Total Files**: 100+
- **🗄️ Database Tables**: 15+ with proper relationships
- **🔄 Stored Procedures**: 10+ with complex business logic
- **⚡ Triggers**: 5+ for automated operations
- **🌐 API Endpoints**: 30+ for complete functionality
- **📱 Frontend Pages**: 15+ with responsive design
- **🧪 Test Cases**: 50+ covering all major functionality


## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📞 Support

For support and questions:
- 📧 Email: [ananyanshenoy2005@gmail.com]
- 📧 Email: [ananyas.chandan@gmail.com]

---

<div align="center">

**🚗 RideHub - Connecting Your Journey, One Ride at a Time 🚗**

Made with ❤️ for urban transportation

</div>


