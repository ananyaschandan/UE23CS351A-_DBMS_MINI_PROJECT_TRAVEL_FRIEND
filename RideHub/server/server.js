import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import { testConnection } from './config/database.js';
import { checkRedisHealth, closeRedis } from './config/redis.js';
import authRoutes from './routes/auth.js';
import routeRoutes from './routes/routes.js';
import bookingRoutes from './routes/bookings.js';
import vehicleRoutes from './routes/vehicles.js';
import multimodalRoutes from './routes/multimodal.js';
import adminRoutes from './routes/admin.js';
import transitRoutes from './routes/transit.js';
import offersRoutes from './routes/offers.js';
import bounceRoutes from './routes/bounce.js';
import notificationsRoutes from './routes/notifications.js';
import metroRoutes from './routes/metro.js';
import aiTripRoutes from './routes/aiTrip.js';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 5000;

// Middleware
app.use(cors({
  origin: process.env.FRONTEND_URL || 'http://localhost:3000',
  credentials: true
}));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Request logging middleware
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.path}`);
  next();
});

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.json({ 
    status: 'ok', 
    message: 'RideHub API is running',
    timestamp: new Date().toISOString()
  });
});

// API Routes
app.use('/api/auth', authRoutes);
app.use('/api/routes', routeRoutes);
app.use('/api/bookings', bookingRoutes);
app.use('/api/vehicles', vehicleRoutes);
app.use('/api/multimodal', multimodalRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api/transit', transitRoutes);
app.use('/api/offers', offersRoutes);
app.use('/api/bounce', bounceRoutes);
app.use('/api/notifications', notificationsRoutes);
app.use('/api/metro', metroRoutes);
app.use('/api/ai-trip', aiTripRoutes);

// 404 handler
app.use((req, res) => {
  res.status(404).json({ error: 'Endpoint not found' });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error('Server error:', err);
  res.status(500).json({ 
    error: 'Internal server error',
    message: process.env.NODE_ENV === 'development' ? err.message : undefined
  });
});

// Start server
async function startServer() {
  try {
    // Test database connection
    const dbConnected = await testConnection();
    
    if (!dbConnected) {
      console.error('⚠️  Warning: Database connection failed. Server will start but API calls may fail.');
      console.error('Please check your database configuration in .env file');
    }

    // Test Redis connection
    const redisHealth = await checkRedisHealth();
    const redisConnected = redisHealth.status === 'healthy';

    if (!redisConnected) {
      console.error('⚠️  Warning: Redis connection failed. AI Trip caching will be disabled.');
      console.error('Please check your Redis configuration in .env file');
    }

    app.listen(PORT, () => {
      console.log('');
      console.log('╔════════════════════════════════════════╗');
      console.log('║     🚗 RideHub API Server Running     ║');
      console.log('╚════════════════════════════════════════╝');
      console.log('');
      console.log(`📍 Server URL: http://localhost:${PORT}`);
      console.log(`🔧 Environment: ${process.env.NODE_ENV || 'development'}`);
      console.log(`🗄️  Database: ${dbConnected ? '✅ Connected' : '❌ Not Connected'}`);
      console.log(`🔴 Redis: ${redisConnected ? '✅ Connected' : '❌ Not Connected'}`);
      console.log('');
      console.log('Available endpoints:');
      console.log('  GET  /api/health');
      console.log('  POST /api/auth/login');
      console.log('  POST /api/auth/signup/user');
      console.log('  POST /api/auth/signup/provider');
      console.log('  GET  /api/routes/service-comparisons');
      console.log('  POST /api/routes/route-options');
      console.log('  POST /api/bookings/confirm');
      console.log('  GET  /api/bookings/user/:userId');
      console.log('  GET  /api/vehicles/provider/:providerId');
      console.log('  POST /api/vehicles/provider/:providerId');
      console.log('');
      console.log('Press Ctrl+C to stop the server');
      console.log('');
    });
  } catch (error) {
    console.error('Failed to start server:', error);
    process.exit(1);
  }
}

startServer();
