import express from 'express';
import { pool } from '../config/database.js';
import { verifyAdmin, logAdminAction, requirePermission, adminRateLimit } from '../middleware/adminAuth.js';

const router = express.Router();

// Apply admin authentication to all routes
router.use(verifyAdmin);
router.use(adminRateLimit());

// Get comprehensive admin dashboard statistics
router.get('/stats', requirePermission('analytics_view'), async (req, res) => {
  try {
    // Use the new AdminDashboardStats view
    const [dashboardStats] = await pool.query('SELECT * FROM AdminDashboardStats');
    
    // Get additional time-based statistics
    const [dailyStats] = await pool.query(`
      SELECT 
        DATE(BookingTime) as date,
        COUNT(*) as bookings,
        SUM(TotalFare) as revenue,
        COUNT(DISTINCT UserID) as unique_users
      FROM Booking 
      WHERE BookingTime >= DATE_SUB(NOW(), INTERVAL 7 DAY)
      GROUP BY DATE(BookingTime)
      ORDER BY date DESC
    `);

    // Get AI trip statistics
    const [aiStats] = await pool.query(`
      SELECT 
        COUNT(*) as total_requests,
        COUNT(DISTINCT SessionID) as unique_sessions,
        AVG(CASE WHEN atresp.CacheHit = 0 THEN atresp.GenerationTime END) as avg_generation_time
      FROM AITripRequests atr
      LEFT JOIN AITripResponses atresp ON atr.RequestID = atresp.RequestID
      WHERE atr.RequestTimestamp >= DATE_SUB(NOW(), INTERVAL 24 HOUR)
    `);

    res.json({
      dashboard: dashboardStats[0],
      dailyTrends: dailyStats,
      aiStatistics: aiStats[0],
      lastUpdated: new Date().toISOString()
    });
  } catch (error) {
    console.error('Error fetching admin stats:', error);
    res.status(500).json({ error: 'Failed to fetch statistics' });
  }
});

// Get recent bookings
router.get('/bookings/recent', async (req, res) => {
  try {
    const limit = parseInt(req.query.limit) || 10;
    
    const [bookings] = await pool.query(
      `SELECT 
        b.BookingID,
        u.FullName AS UserName,
        b.StartLocation,
        b.EndLocation,
        b.TotalFare,
        b.BookingStatus,
        b.RouteType,
        b.BookingTime
       FROM Booking b
       JOIN User u ON b.UserID = u.UserID
       ORDER BY b.BookingTime DESC
       LIMIT ?`,
      [limit]
    );

    res.json(bookings);
  } catch (error) {
    console.error('Error fetching recent bookings:', error);
    res.status(500).json({ error: 'Failed to fetch bookings' });
  }
});

// Get all users
router.get('/users', async (req, res) => {
  try {
    const [users] = await pool.query(
      `SELECT 
        UserID,
        FullName,
        Email,
        Phone,
        Age,
        IsProvider,
        IsActive,
        CreatedAt
       FROM User
       ORDER BY CreatedAt DESC`
    );

    res.json(users);
  } catch (error) {
    console.error('Error fetching users:', error);
    res.status(500).json({ error: 'Failed to fetch users' });
  }
});

// Get all providers with details
router.get('/providers', async (req, res) => {
  try {
    const [providers] = await pool.query(
      `SELECT 
        sp.ProviderID,
        u.FullName,
        u.Email,
        u.Phone,
        sp.ProviderType,
        sp.Rating,
        sp.TotalRides,
        sp.TotalEarnings,
        sp.IsApproved,
        COUNT(DISTINCT v.VehicleID) AS VehicleCount
       FROM ServiceProvider sp
       JOIN User u ON sp.UserID = u.UserID
       LEFT JOIN Vehicle v ON sp.ProviderID = v.ProviderID
       GROUP BY sp.ProviderID, u.FullName, u.Email, u.Phone, sp.ProviderType, 
                sp.Rating, sp.TotalRides, sp.TotalEarnings, sp.IsApproved
       ORDER BY sp.TotalEarnings DESC`
    );

    res.json(providers);
  } catch (error) {
    console.error('Error fetching providers:', error);
    res.status(500).json({ error: 'Failed to fetch providers' });
  }
});

// User Management Routes
router.get('/users/summary', requirePermission('user_management'), async (req, res) => {
  try {
    const [users] = await pool.query('SELECT * FROM UserActivitySummary ORDER BY total_spent DESC LIMIT 50');
    res.json(users);
  } catch (error) {
    console.error('Error fetching user summary:', error);
    res.status(500).json({ error: 'Failed to fetch user summary' });
  }
});

router.put('/users/:userId/status', requirePermission('user_management'), logAdminAction('user_management', 'Updated user status'), async (req, res) => {
  try {
    const { userId } = req.params;
    const { isActive } = req.body;
    
    await pool.query('UPDATE User SET IsActive = ? WHERE UserID = ?', [isActive, userId]);
    
    res.json({ success: true, message: 'User status updated successfully' });
  } catch (error) {
    console.error('Error updating user status:', error);
    res.status(500).json({ error: 'Failed to update user status' });
  }
});

// Provider Management Routes
router.get('/providers/summary', requirePermission('provider_management'), async (req, res) => {
  try {
    const [providers] = await pool.query('SELECT * FROM ProviderPerformanceSummary ORDER BY total_earnings DESC');
    res.json(providers);
  } catch (error) {
    console.error('Error fetching provider summary:', error);
    res.status(500).json({ error: 'Failed to fetch provider summary' });
  }
});

router.put('/providers/:providerId/verify', requirePermission('provider_management'), logAdminAction('provider_management', 'Verified provider'), async (req, res) => {
  try {
    const { providerId } = req.params;
    const { isVerified } = req.body;
    
    await pool.query('UPDATE ServiceProvider SET IsVerified = ? WHERE ProviderID = ?', [isVerified, providerId]);
    
    res.json({ success: true, message: 'Provider verification status updated' });
  } catch (error) {
    console.error('Error updating provider verification:', error);
    res.status(500).json({ error: 'Failed to update provider verification' });
  }
});

// Booking Management Routes
router.get('/bookings/analytics', requirePermission('booking_management'), async (req, res) => {
  try {
    const [analytics] = await pool.query(`
      SELECT 
        BookingStatus,
        COUNT(*) as count,
        SUM(TotalFare) as total_revenue,
        AVG(TotalFare) as avg_fare
      FROM Booking 
      GROUP BY BookingStatus
    `);
    
    const [routeAnalytics] = await pool.query(`
      SELECT 
        RouteType,
        COUNT(*) as count,
        AVG(TotalDistance) as avg_distance,
        AVG(TotalTime) as avg_time
      FROM Booking 
      GROUP BY RouteType
    `);

    res.json({
      statusAnalytics: analytics,
      routeAnalytics: routeAnalytics
    });
  } catch (error) {
    console.error('Error fetching booking analytics:', error);
    res.status(500).json({ error: 'Failed to fetch booking analytics' });
  }
});

// Offer Management Routes
router.post('/offers', requirePermission('offer_management'), logAdminAction('offer_management', 'Created new offer'), async (req, res) => {
  try {
    const { offerCode, title, description, discountPercentage, maxDiscountAmount, validFrom, validTo } = req.body;
    
    const [result] = await pool.query(`
      INSERT INTO Offers (OfferCode, Title, Description, DiscountPercentage, MaxDiscountAmount, ValidFrom, ValidTo, IsActive)
      VALUES (?, ?, ?, ?, ?, ?, ?, 1)
    `, [offerCode, title, description, discountPercentage, maxDiscountAmount, validFrom, validTo]);
    
    res.json({ success: true, offerId: result.insertId, message: 'Offer created successfully' });
  } catch (error) {
    console.error('Error creating offer:', error);
    res.status(500).json({ error: 'Failed to create offer' });
  }
});

router.put('/offers/:offerId/status', requirePermission('offer_management'), logAdminAction('offer_management', 'Updated offer status'), async (req, res) => {
  try {
    const { offerId } = req.params;
    const { isActive } = req.body;
    
    await pool.query('UPDATE Offers SET IsActive = ? WHERE OfferID = ?', [isActive, offerId]);
    
    res.json({ success: true, message: 'Offer status updated successfully' });
  } catch (error) {
    console.error('Error updating offer status:', error);
    res.status(500).json({ error: 'Failed to update offer status' });
  }
});

// System Configuration Routes
router.get('/settings', requirePermission('system_config'), async (req, res) => {
  try {
    const [settings] = await pool.query('SELECT * FROM AdminSettings ORDER BY SettingKey');
    res.json(settings);
  } catch (error) {
    console.error('Error fetching settings:', error);
    res.status(500).json({ error: 'Failed to fetch settings' });
  }
});

router.put('/settings/:settingKey', requirePermission('system_config'), logAdminAction('system_config', 'Updated system setting'), async (req, res) => {
  try {
    const { settingKey } = req.params;
    const { settingValue } = req.body;
    
    await pool.query(
      'UPDATE AdminSettings SET SettingValue = ?, ModifiedBy = ?, ModifiedAt = NOW() WHERE SettingKey = ?',
      [settingValue, req.admin.userId, settingKey]
    );
    
    res.json({ success: true, message: 'Setting updated successfully' });
  } catch (error) {
    console.error('Error updating setting:', error);
    res.status(500).json({ error: 'Failed to update setting' });
  }
});

// Admin Actions Log
router.get('/actions', requirePermission('analytics_view'), async (req, res) => {
  try {
    const limit = parseInt(req.query.limit) || 50;
    const offset = parseInt(req.query.offset) || 0;
    
    const [actions] = await pool.query(`
      SELECT 
        aa.ActionID,
        u.FullName as AdminName,
        aa.ActionType,
        aa.ActionDescription,
        aa.TargetTable,
        aa.TargetRecordID,
        aa.ActionTimestamp
      FROM AdminActions aa
      JOIN User u ON aa.AdminUserID = u.UserID
      ORDER BY aa.ActionTimestamp DESC
      LIMIT ? OFFSET ?
    `, [limit, offset]);
    
    res.json(actions);
  } catch (error) {
    console.error('Error fetching admin actions:', error);
    res.status(500).json({ error: 'Failed to fetch admin actions' });
  }
});

// Data Export Routes
router.get('/export/users', requirePermission('data_export'), logAdminAction('data_export', 'Exported user data'), async (req, res) => {
  try {
    const [users] = await pool.query(`
      SELECT 
        UserID, FullName, Email, PhoneNumber, UserRole, CreatedAt,
        (SELECT COUNT(*) FROM Booking WHERE UserID = u.UserID) as TotalBookings,
        (SELECT SUM(TotalFare) FROM Booking WHERE UserID = u.UserID AND BookingStatus = 'Confirmed') as TotalSpent
      FROM User u
      ORDER BY CreatedAt DESC
    `);
    
    res.json(users);
  } catch (error) {
    console.error('Error exporting user data:', error);
    res.status(500).json({ error: 'Failed to export user data' });
  }
});

router.get('/export/bookings', requirePermission('data_export'), logAdminAction('data_export', 'Exported booking data'), async (req, res) => {
  try {
    const { startDate, endDate } = req.query;
    
    let query = `
      SELECT 
        b.BookingID, u.FullName as UserName, u.Email,
        b.StartLocation, b.EndLocation, b.TotalDistance, b.TotalTime,
        b.TotalFare, b.OriginalFare, b.DiscountAmount, b.OfferCode,
        b.RouteType, b.BookingStatus, b.IsMultiModal, b.BookingTime
      FROM Booking b
      JOIN User u ON b.UserID = u.UserID
    `;
    
    const params = [];
    if (startDate && endDate) {
      query += ' WHERE b.BookingTime BETWEEN ? AND ?';
      params.push(startDate, endDate);
    }
    
    query += ' ORDER BY b.BookingTime DESC';
    
    const [bookings] = await pool.query(query, params);
    res.json(bookings);
  } catch (error) {
    console.error('Error exporting booking data:', error);
    res.status(500).json({ error: 'Failed to export booking data' });
  }
});

export default router;
