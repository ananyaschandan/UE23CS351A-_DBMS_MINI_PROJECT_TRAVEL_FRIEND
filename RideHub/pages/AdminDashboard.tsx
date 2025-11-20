import React, { useState, useEffect } from 'react';
import { User } from '../types';
import Card from '../components/Card';
import Button from '../components/Button';
import { api } from '../services/api';

interface AdminDashboardProps {
  user: User;
}

interface Stats {
  totalUsers: number;
  totalProviders: number;
  totalVehicles: number;
  totalBookings: number;
  totalRevenue: number;
  activeBookings: number;
  totalAdmins?: number;
  confirmedBookings?: number;
  cancelledBookings?: number;
  activeOffers?: number;
  totalDiscountsGiven?: number;
  aiRequestsToday?: number;
  notificationsToday?: number;
}

interface AdminUser {
  UserID: number;
  FullName: string;
  Email: string;
  UserRole: string;
  user_status: string;
  total_bookings: number;
  total_spent: number;
}

interface AdminAction {
  ActionID: number;
  AdminName: string;
  ActionType: string;
  ActionDescription: string;
  ActionTimestamp: string;
}

interface RecentBooking {
  BookingID: number;
  UserName: string;
  StartLocation: string;
  EndLocation: string;
  TotalFare: number;
  BookingStatus: string;
  RouteType: string;
}

const AdminDashboard: React.FC<AdminDashboardProps> = ({ user }) => {
  const [stats, setStats] = useState<Stats>({
    totalUsers: 0,
    totalProviders: 0,
    totalVehicles: 0,
    totalBookings: 0,
    totalRevenue: 0,
    activeBookings: 0
  });
  const [recentBookings, setRecentBookings] = useState<RecentBooking[]>([]);
  const [adminUsers, setAdminUsers] = useState<AdminUser[]>([]);
  const [adminActions, setAdminActions] = useState<AdminAction[]>([]);
  const [loading, setLoading] = useState(true);
  const [activeTab, setActiveTab] = useState<'dashboard' | 'users' | 'actions'>('dashboard');

  // Use the user prop to show admin info
  console.log('Admin user:', user.fullName, user.email);

  useEffect(() => {
    fetchAdminData();
  }, []);

  const fetchAdminData = async () => {
    try {
      const [statsData, bookingsData] = await Promise.all([
        api.getAdminStats(),
        api.getRecentBookings(10)
      ]);
      setStats(statsData);
      setRecentBookings(bookingsData);
    } catch (error) {
      console.error('Failed to fetch admin data:', error);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <div className="flex justify-center items-center h-screen">
        <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-blue-600"></div>
      </div>
    );
  }

  const fetchAdminUsers = async () => {
    try {
      // This would call the new admin API endpoints
      const usersData = await fetch('/api/admin/users/summary', {
        headers: { Authorization: `Bearer ${localStorage.getItem('token')}` }
      }).then(res => res.json());
      setAdminUsers(usersData);
    } catch (error) {
      console.error('Failed to fetch admin users:', error);
    }
  };

  const fetchAdminActions = async () => {
    try {
      const actionsData = await fetch('/api/admin/actions', {
        headers: { Authorization: `Bearer ${localStorage.getItem('token')}` }
      }).then(res => res.json());
      setAdminActions(actionsData);
    } catch (error) {
      console.error('Failed to fetch admin actions:', error);
    }
  };

  return (
    <div className="max-w-7xl mx-auto">
      <div className="flex justify-between items-center mb-6">
        <h2 className="text-3xl font-bold text-slate-900">Admin Dashboard</h2>
        <div className="text-sm text-slate-600">
          Welcome, <span className="font-semibold">{user.fullName}</span> ({user.email})
        </div>
      </div>

      {/* Navigation Tabs */}
      <div className="flex space-x-1 mb-6">
        <Button
          onClick={() => setActiveTab('dashboard')}
          variant={activeTab === 'dashboard' ? 'primary' : 'secondary'}
          className="px-4 py-2"
        >
          📊 Dashboard
        </Button>
        <Button
          onClick={() => {
            setActiveTab('users');
            fetchAdminUsers();
          }}
          variant={activeTab === 'users' ? 'primary' : 'secondary'}
          className="px-4 py-2"
        >
          👥 Users
        </Button>
        <Button
          onClick={() => {
            setActiveTab('actions');
            fetchAdminActions();
          }}
          variant={activeTab === 'actions' ? 'primary' : 'secondary'}
          className="px-4 py-2"
        >
          📋 Actions Log
        </Button>
      </div>

      {/* Conditional Content Based on Active Tab */}
      {activeTab === 'dashboard' && (
        <>
          {/* Stats Grid */}
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 mb-8">
        <Card>
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-slate-600">Total Users</p>
              <p className="text-3xl font-bold text-blue-600">{stats.totalUsers}</p>
            </div>
            <div className="text-4xl">👥</div>
          </div>
        </Card>

        <Card>
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-slate-600">Total Providers</p>
              <p className="text-3xl font-bold text-green-600">{stats.totalProviders}</p>
            </div>
            <div className="text-4xl">🚗</div>
          </div>
        </Card>

        <Card>
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-slate-600">Total Vehicles</p>
              <p className="text-3xl font-bold text-purple-600">{stats.totalVehicles}</p>
            </div>
            <div className="text-4xl">🚙</div>
          </div>
        </Card>

        <Card>
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-slate-600">Total Bookings</p>
              <p className="text-3xl font-bold text-orange-600">{stats.totalBookings}</p>
            </div>
            <div className="text-4xl">📋</div>
          </div>
        </Card>

        <Card>
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-slate-600">Total Revenue</p>
              <p className="text-3xl font-bold text-emerald-600">₹{stats.totalRevenue.toFixed(2)}</p>
            </div>
            <div className="text-4xl">💰</div>
          </div>
        </Card>

        <Card>
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-slate-600">Active Bookings</p>
              <p className="text-3xl font-bold text-red-600">{stats.activeBookings}</p>
            </div>
            <div className="text-4xl">🔄</div>
          </div>
        </Card>
      </div>

      {/* Recent Bookings */}
      <Card>
        <h3 className="text-xl font-bold text-slate-900 mb-4">Recent Bookings</h3>
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              <tr className="border-b border-slate-200">
                <th className="text-left py-3 px-4 text-sm font-semibold text-slate-700">ID</th>
                <th className="text-left py-3 px-4 text-sm font-semibold text-slate-700">User</th>
                <th className="text-left py-3 px-4 text-sm font-semibold text-slate-700">Route</th>
                <th className="text-left py-3 px-4 text-sm font-semibold text-slate-700">Type</th>
                <th className="text-left py-3 px-4 text-sm font-semibold text-slate-700">Fare</th>
                <th className="text-left py-3 px-4 text-sm font-semibold text-slate-700">Status</th>
              </tr>
            </thead>
            <tbody>
              {recentBookings.map((booking) => (
                <tr key={booking.BookingID} className="border-b border-slate-100 hover:bg-slate-50">
                  <td className="py-3 px-4 text-sm">#{booking.BookingID}</td>
                  <td className="py-3 px-4 text-sm">{booking.UserName}</td>
                  <td className="py-3 px-4 text-sm">
                    {booking.StartLocation} → {booking.EndLocation}
                  </td>
                  <td className="py-3 px-4 text-sm">
                    <span className="px-2 py-1 bg-blue-100 text-blue-700 rounded text-xs">
                      {booking.RouteType}
                    </span>
                  </td>
                  <td className="py-3 px-4 text-sm font-semibold">₹{booking.TotalFare.toFixed(2)}</td>
                  <td className="py-3 px-4 text-sm">
                    <span className={`px-2 py-1 rounded text-xs ${
                      booking.BookingStatus === 'Completed' ? 'bg-green-100 text-green-700' :
                      booking.BookingStatus === 'InProgress' ? 'bg-yellow-100 text-yellow-700' :
                      'bg-slate-100 text-slate-700'
                    }`}>
                      {booking.BookingStatus}
                    </span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </Card>
        </>
      )}

      {/* Users Management Tab */}
      {activeTab === 'users' && (
        <Card>
          <h3 className="text-xl font-bold text-slate-900 mb-4">User Management</h3>
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead>
                <tr className="border-b border-slate-200">
                  <th className="text-left py-3 px-4 text-sm font-semibold text-slate-700">Name</th>
                  <th className="text-left py-3 px-4 text-sm font-semibold text-slate-700">Email</th>
                  <th className="text-left py-3 px-4 text-sm font-semibold text-slate-700">Role</th>
                  <th className="text-left py-3 px-4 text-sm font-semibold text-slate-700">Status</th>
                  <th className="text-left py-3 px-4 text-sm font-semibold text-slate-700">Bookings</th>
                  <th className="text-left py-3 px-4 text-sm font-semibold text-slate-700">Total Spent</th>
                </tr>
              </thead>
              <tbody>
                {adminUsers.map((user) => (
                  <tr key={user.UserID} className="border-b border-slate-100 hover:bg-slate-50">
                    <td className="py-3 px-4 text-sm font-medium">{user.FullName}</td>
                    <td className="py-3 px-4 text-sm">{user.Email}</td>
                    <td className="py-3 px-4 text-sm">
                      <span className={`px-2 py-1 rounded text-xs ${
                        user.UserRole === 'admin' ? 'bg-red-100 text-red-700' :
                        user.UserRole === 'provider' ? 'bg-blue-100 text-blue-700' :
                        'bg-gray-100 text-gray-700'
                      }`}>
                        {user.UserRole}
                      </span>
                    </td>
                    <td className="py-3 px-4 text-sm">
                      <span className={`px-2 py-1 rounded text-xs ${
                        user.user_status === 'Active' ? 'bg-green-100 text-green-700' :
                        user.user_status === 'Inactive' ? 'bg-yellow-100 text-yellow-700' :
                        'bg-gray-100 text-gray-700'
                      }`}>
                        {user.user_status}
                      </span>
                    </td>
                    <td className="py-3 px-4 text-sm">{user.total_bookings}</td>
                    <td className="py-3 px-4 text-sm font-semibold">₹{user.total_spent.toFixed(2)}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </Card>
      )}

      {/* Admin Actions Log Tab */}
      {activeTab === 'actions' && (
        <Card>
          <h3 className="text-xl font-bold text-slate-900 mb-4">Admin Actions Log</h3>
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead>
                <tr className="border-b border-slate-200">
                  <th className="text-left py-3 px-4 text-sm font-semibold text-slate-700">Admin</th>
                  <th className="text-left py-3 px-4 text-sm font-semibold text-slate-700">Action Type</th>
                  <th className="text-left py-3 px-4 text-sm font-semibold text-slate-700">Description</th>
                  <th className="text-left py-3 px-4 text-sm font-semibold text-slate-700">Timestamp</th>
                </tr>
              </thead>
              <tbody>
                {adminActions.map((action) => (
                  <tr key={action.ActionID} className="border-b border-slate-100 hover:bg-slate-50">
                    <td className="py-3 px-4 text-sm font-medium">{action.AdminName}</td>
                    <td className="py-3 px-4 text-sm">
                      <span className="px-2 py-1 bg-purple-100 text-purple-700 rounded text-xs">
                        {action.ActionType.replace('_', ' ')}
                      </span>
                    </td>
                    <td className="py-3 px-4 text-sm">{action.ActionDescription}</td>
                    <td className="py-3 px-4 text-sm text-slate-500">
                      {new Date(action.ActionTimestamp).toLocaleString()}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </Card>
      )}
    </div>
  );
};

export default AdminDashboard;
