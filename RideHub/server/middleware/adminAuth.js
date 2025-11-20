// ============================================
// ADMIN AUTHENTICATION MIDDLEWARE
// ============================================

import jwt from 'jsonwebtoken';
import { pool } from '../config/database.js';

// Middleware to verify admin authentication
export const verifyAdmin = async (req, res, next) => {
  try {
    // Get token from header
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ 
        error: 'Access denied. No token provided.' 
      });
    }

    const token = authHeader.substring(7); // Remove 'Bearer ' prefix

    // Verify JWT token
    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'your-secret-key');
    
    // Get user details from database
    const [userRows] = await pool.query(
      'SELECT UserID, FullName, Email, UserRole FROM User WHERE UserID = ?',
      [decoded.userId]
    );

    if (userRows.length === 0) {
      return res.status(401).json({ 
        error: 'Invalid token. User not found.' 
      });
    }

    const user = userRows[0];

    // Check if user has admin role
    if (user.UserRole !== 'admin') {
      return res.status(403).json({ 
        error: 'Access denied. Admin privileges required.' 
      });
    }

    // Add user info to request object
    req.admin = {
      userId: user.UserID,
      fullName: user.FullName,
      email: user.Email,
      role: user.UserRole
    };

    next();
  } catch (error) {
    console.error('Admin auth error:', error);
    
    if (error.name === 'JsonWebTokenError') {
      return res.status(401).json({ 
        error: 'Invalid token.' 
      });
    }
    
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({ 
        error: 'Token expired.' 
      });
    }

    res.status(500).json({ 
      error: 'Internal server error during authentication.' 
    });
  }
};

// Middleware to log admin actions
export const logAdminAction = (actionType, actionDescription) => {
  return async (req, res, next) => {
    // Store original res.json to intercept response
    const originalJson = res.json;
    
    res.json = function(data) {
      // Log the admin action after successful response
      if (res.statusCode >= 200 && res.statusCode < 300) {
        logAction(req, actionType, actionDescription, data);
      }
      
      // Call original res.json
      return originalJson.call(this, data);
    };

    next();
  };
};

// Helper function to log admin actions to database
async function logAction(req, actionType, actionDescription, responseData) {
  try {
    const ipAddress = req.ip || req.connection.remoteAddress || 'unknown';
    const userAgent = req.get('User-Agent') || 'unknown';
    
    // Extract target information from request
    let targetTable = null;
    let targetRecordId = null;
    let newValues = null;

    // Determine target based on request path
    if (req.path.includes('/users')) {
      targetTable = 'User';
      targetRecordId = req.params.userId || req.body.userId;
    } else if (req.path.includes('/providers')) {
      targetTable = 'ServiceProvider';
      targetRecordId = req.params.providerId || req.body.providerId;
    } else if (req.path.includes('/bookings')) {
      targetTable = 'Booking';
      targetRecordId = req.params.bookingId || req.body.bookingId;
    } else if (req.path.includes('/offers')) {
      targetTable = 'Offers';
      targetRecordId = req.params.offerId || req.body.offerId;
    }

    // Prepare new values (sanitized)
    if (req.body && Object.keys(req.body).length > 0) {
      const sanitizedBody = { ...req.body };
      delete sanitizedBody.password;
      delete sanitizedBody.passwordHash;
      newValues = JSON.stringify(sanitizedBody);
    }

    // Log to database
    await pool.query(
      'CALL LogAdminAction(?, ?, ?, ?, ?, NULL, ?, ?, ?)',
      [
        req.admin.userId,
        actionType,
        actionDescription,
        targetTable,
        targetRecordId,
        newValues,
        ipAddress,
        userAgent
      ]
    );

    console.log(`📋 Admin action logged: ${actionType} by ${req.admin.email}`);
  } catch (error) {
    console.error('Error logging admin action:', error);
    // Don't throw error to avoid breaking the main request
  }
}

// Middleware to check specific admin permissions
export const requirePermission = (permission) => {
  return async (req, res, next) => {
    try {
      // For now, all admins have all permissions
      // In future, you can implement role-based permissions
      const adminPermissions = {
        'user_management': true,
        'provider_management': true,
        'booking_management': true,
        'offer_management': true,
        'system_config': true,
        'data_export': true,
        'analytics_view': true
      };

      if (!adminPermissions[permission]) {
        return res.status(403).json({
          error: `Access denied. Permission '${permission}' required.`
        });
      }

      next();
    } catch (error) {
      console.error('Permission check error:', error);
      res.status(500).json({ 
        error: 'Internal server error during permission check.' 
      });
    }
  };
};

// Rate limiting for admin actions
export const adminRateLimit = (maxRequests = 100, windowMs = 15 * 60 * 1000) => {
  const requests = new Map();

  return (req, res, next) => {
    const adminId = req.admin?.userId;
    if (!adminId) {
      return next();
    }

    const now = Date.now();
    const windowStart = now - windowMs;

    // Clean old entries
    for (const [key, timestamps] of requests.entries()) {
      requests.set(key, timestamps.filter(time => time > windowStart));
      if (requests.get(key).length === 0) {
        requests.delete(key);
      }
    }

    // Check current admin's requests
    const adminRequests = requests.get(adminId) || [];
    
    if (adminRequests.length >= maxRequests) {
      return res.status(429).json({
        error: 'Too many admin requests. Please try again later.',
        retryAfter: Math.ceil(windowMs / 1000)
      });
    }

    // Add current request
    adminRequests.push(now);
    requests.set(adminId, adminRequests);

    next();
  };
};

export default {
  verifyAdmin,
  logAdminAction,
  requirePermission,
  adminRateLimit
};
