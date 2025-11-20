import React, { useState, useEffect } from 'react';
import { User } from '../types';
import { api } from '../services/api';
import Card from '../components/Card';

interface Notification {
  NotificationID: number;
  UserID: number;
  Message: string;
  NotificationType: string;
  Status: 'Pending' | 'Sent' | 'Read';
  CreatedAt: string;
}

interface NotificationsPageProps {
  user: User;
}

const NotificationsPage: React.FC<NotificationsPageProps> = ({ user }) => {
  const [notifications, setNotifications] = useState<Notification[]>([]);
  const [loading, setLoading] = useState(true);
  const [filter, setFilter] = useState<'all' | 'unread'>('all');

  useEffect(() => {
    fetchNotifications();
  }, [user.id]);

  const fetchNotifications = async () => {
    try {
      console.log('Fetching notifications for user:', user.id);
      const data = await api.getUserNotifications(user.id);
      console.log('Received notifications:', data);
      console.log('Notification count:', data.length);
      setNotifications(data);
    } catch (error) {
      console.error('Failed to fetch notifications:', error);
      alert('Failed to load notifications. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  const markAsRead = async (notificationId: number) => {
    try {
      await api.markNotificationAsRead(notificationId);
      setNotifications(notifications.map(n => 
        n.NotificationID === notificationId ? { ...n, Status: 'Read' } : n
      ));
    } catch (error) {
      console.error('Failed to mark notification as read:', error);
    }
  };

  const markAllAsRead = async () => {
    try {
      await api.markAllNotificationsAsRead(user.id);
      setNotifications(notifications.map(n => ({ ...n, Status: 'Read' })));
    } catch (error) {
      console.error('Failed to mark all as read:', error);
    }
  };

  const getNotificationIcon = (type: string) => {
    const icons: { [key: string]: string } = {
      'Booking': '📋',
      'VehicleChange': '🚗',
      'Payment': '💰',
      'Cancellation': '❌',
      'Reminder': '⏰',
      'Promotion': '🎁',
      'Update': '🔔',
      'Provider': '🚕',
    };
    return icons[type] || '📬';
  };

  const getNotificationColor = (type: string) => {
    const colors: { [key: string]: string } = {
      'Booking': 'bg-blue-50 border-blue-200',
      'VehicleChange': 'bg-orange-50 border-orange-200',
      'Payment': 'bg-green-50 border-green-200',
      'Cancellation': 'bg-red-50 border-red-200',
      'Reminder': 'bg-yellow-50 border-yellow-200',
      'Promotion': 'bg-purple-50 border-purple-200',
      'Update': 'bg-slate-50 border-slate-200',
      'Provider': 'bg-teal-50 border-teal-200',
    };
    return colors[type] || 'bg-slate-50 border-slate-200';
  };

  const formatTime = (dateString: string) => {
    const date = new Date(dateString);
    const now = new Date();
    const diffMs = now.getTime() - date.getTime();
    const diffMins = Math.floor(diffMs / 60000);
    const diffHours = Math.floor(diffMins / 60);
    const diffDays = Math.floor(diffHours / 24);

    if (diffMins < 1) return 'Just now';
    if (diffMins < 60) return `${diffMins}m ago`;
    if (diffHours < 24) return `${diffHours}h ago`;
    if (diffDays < 7) return `${diffDays}d ago`;
    
    return date.toLocaleDateString('en-IN', { 
      month: 'short', 
      day: 'numeric',
      year: date.getFullYear() !== now.getFullYear() ? 'numeric' : undefined
    });
  };

  const filteredNotifications = filter === 'unread' 
    ? notifications.filter(n => n.Status !== 'Read')
    : notifications;

  const unreadCount = notifications.filter(n => n.Status !== 'Read').length;

  if (loading) {
    return (
      <div className="flex justify-center items-center h-screen">
        <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-blue-600"></div>
      </div>
    );
  }

  return (
    <div className="max-w-4xl mx-auto">
      {/* Header */}
      <div className="flex justify-between items-center mb-6">
        <div>
          <h2 className="text-3xl font-bold text-slate-900">Notifications</h2>
          {unreadCount > 0 && (
            <p className="text-sm text-slate-600 mt-1">
              You have {unreadCount} unread notification{unreadCount !== 1 ? 's' : ''}
            </p>
          )}
        </div>
        {unreadCount > 0 && (
          <button
            onClick={markAllAsRead}
            className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors text-sm font-medium"
          >
            Mark All as Read
          </button>
        )}
      </div>

      {/* Filter Tabs */}
      <div className="flex gap-2 mb-6">
        <button
          onClick={() => setFilter('all')}
          className={`px-4 py-2 rounded-lg font-medium transition-colors ${
            filter === 'all'
              ? 'bg-blue-600 text-white'
              : 'bg-white text-slate-600 hover:bg-slate-50 border border-slate-200'
          }`}
        >
          All ({notifications.length})
        </button>
        <button
          onClick={() => setFilter('unread')}
          className={`px-4 py-2 rounded-lg font-medium transition-colors ${
            filter === 'unread'
              ? 'bg-blue-600 text-white'
              : 'bg-white text-slate-600 hover:bg-slate-50 border border-slate-200'
          }`}
        >
          Unread ({unreadCount})
        </button>
      </div>

      {/* Notifications List */}
      <div className="space-y-3">
        {filteredNotifications.length === 0 ? (
          <Card>
            <div className="text-center py-12">
              <div className="text-6xl mb-4">📭</div>
              <p className="text-slate-500 text-lg">
                {filter === 'unread' ? 'No unread notifications' : 'No notifications yet'}
              </p>
            </div>
          </Card>
        ) : (
          filteredNotifications.map((notification) => (
            <div
              key={notification.NotificationID}
              className={`border-2 rounded-lg p-4 transition-all ${
                getNotificationColor(notification.NotificationType)
              } ${
                notification.Status !== 'Read' ? 'shadow-md' : 'opacity-75'
              }`}
            >
              <div className="flex items-start gap-4">
                {/* Icon */}
                <div className="text-3xl flex-shrink-0">
                  {getNotificationIcon(notification.NotificationType)}
                </div>

                {/* Content */}
                <div className="flex-1 min-w-0">
                  <div className="flex items-start justify-between gap-2 mb-1">
                    <span className="text-xs font-semibold text-slate-500 uppercase">
                      {notification.NotificationType}
                    </span>
                    <span className="text-xs text-slate-500 whitespace-nowrap">
                      {formatTime(notification.CreatedAt)}
                    </span>
                  </div>
                  <p className={`text-sm ${notification.Status !== 'Read' ? 'font-semibold text-slate-900' : 'text-slate-700'}`}>
                    {notification.Message}
                  </p>
                </div>

                {/* Mark as Read Button */}
                {notification.Status !== 'Read' && (
                  <button
                    onClick={() => markAsRead(notification.NotificationID)}
                    className="flex-shrink-0 text-blue-600 hover:text-blue-700 text-sm font-medium"
                  >
                    ✓
                  </button>
                )}
              </div>
            </div>
          ))
        )}
      </div>
    </div>
  );
};

export default NotificationsPage;
