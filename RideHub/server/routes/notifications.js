import express from 'express';
import { pool } from '../config/database.js';

const router = express.Router();

// Get user notifications
router.get('/user/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    console.log(`\n=== Fetching notifications for user ${userId} ===`);

    const [notifications] = await pool.query(
      `SELECT 
        NotificationID,
        UserID,
        Message,
        NotificationType,
        Status,
        CreatedAt
       FROM Notification
       WHERE UserID = ?
       ORDER BY CreatedAt DESC`,
      [userId]
    );

    console.log(`Found ${notifications.length} notifications for user ${userId}`);
    if (notifications.length > 0) {
      console.log('First notification:', {
        id: notifications[0].NotificationID,
        type: notifications[0].NotificationType,
        message: notifications[0].Message.substring(0, 50) + '...'
      });
    }
    console.log('=== End fetch notifications ===\n');

    res.json(notifications);
  } catch (error) {
    console.error('Error fetching notifications:', error);
    console.error('Error stack:', error.stack);
    res.status(500).json({ error: 'Failed to fetch notifications' });
  }
});

// Mark notification as read
router.patch('/:notificationId/read', async (req, res) => {
  try {
    const { notificationId } = req.params;

    await pool.query(
      "UPDATE Notification SET Status = 'Read' WHERE NotificationID = ?",
      [notificationId]
    );

    res.json({ success: true, message: 'Notification marked as read' });
  } catch (error) {
    console.error('Error marking notification as read:', error);
    res.status(500).json({ error: 'Failed to update notification' });
  }
});

// Mark all notifications as read for a user
router.patch('/user/:userId/read-all', async (req, res) => {
  try {
    const { userId } = req.params;

    await pool.query(
      "UPDATE Notification SET Status = 'Read' WHERE UserID = ? AND Status != 'Read'",
      [userId]
    );

    res.json({ success: true, message: 'All notifications marked as read' });
  } catch (error) {
    console.error('Error marking all notifications as read:', error);
    res.status(500).json({ error: 'Failed to update notifications' });
  }
});

// Get unread count
router.get('/user/:userId/unread-count', async (req, res) => {
  try {
    const { userId } = req.params;

    const [result] = await pool.query(
      "SELECT COUNT(*) as count FROM Notification WHERE UserID = ? AND Status != 'Read'",
      [userId]
    );

    res.json({ count: result[0].count });
  } catch (error) {
    console.error('Error fetching unread count:', error);
    res.status(500).json({ error: 'Failed to fetch unread count' });
  }
});

// Create notification (for testing)
router.post('/create', async (req, res) => {
  try {
    const { userId, message, notificationType } = req.body;

    const [result] = await pool.query(
      'INSERT INTO Notification (UserID, Message, NotificationType) VALUES (?, ?, ?)',
      [userId, message, notificationType || 'Update']
    );

    res.json({ 
      success: true, 
      notificationId: result.insertId,
      message: 'Notification created' 
    });
  } catch (error) {
    console.error('Error creating notification:', error);
    res.status(500).json({ error: 'Failed to create notification' });
  }
});

export default router;
