import { ServiceComparison, RouteOption, Booking, Vehicle, Role, RouteType, User, Provider } from '../types';

// API Configuration
const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:5000/api';

// Helper function for API calls
const fetchAPI = async <T>(endpoint: string, options?: RequestInit): Promise<T> => {
  try {
    const response = await fetch(`${API_BASE_URL}${endpoint}`, {
      headers: {
        'Content-Type': 'application/json',
        ...options?.headers,
      },
      ...options,
    });

    if (!response.ok) {
      const error = await response.json().catch(() => ({ error: 'Request failed' }));
      throw new Error(error.error || error.message || `HTTP ${response.status}`);
    }

    return await response.json();
  } catch (error) {
    console.error(`API Error (${endpoint}):`, error);
    throw error;
  }
};

// API Functions
export const api = {
  // Authentication
  login: async (email: string, password: string, role: Role): Promise<User> => {
    // Password is ignored on backend, but kept in signature for compatibility
    return fetchAPI<User>('/auth/login', {
      method: 'POST',
      body: JSON.stringify({ email, role }),
    });
  },

  signupUser: async (userData: Omit<User, 'id' | 'role' | 'fullName'>): Promise<{ status: string; user: User }> => {
    return fetchAPI<{ status: string; user: User }>('/auth/signup/user', {
      method: 'POST',
      body: JSON.stringify(userData),
    });
  },

  signupProvider: async (providerData: Omit<Provider, 'id' | 'role' | 'fullName'>): Promise<{ status: string; provider: Provider }> => {
    return fetchAPI<{ status: string; provider: Provider }>('/auth/signup/provider', {
      method: 'POST',
      body: JSON.stringify(providerData),
    });
  },

  // Routes and Services
  getServiceComparisons: async (): Promise<ServiceComparison[]> => {
    return fetchAPI<ServiceComparison[]>('/routes/service-comparisons');
  },

  getThreeRouteOptions: async (startLocation: string, endLocation: string): Promise<RouteOption[]> => {
    return fetchAPI<RouteOption[]>('/multimodal/calculate-routes', {
      method: 'POST',
      body: JSON.stringify({ startLocation, endLocation }),
    });
  },

  // Bookings
  confirmBooking: async (
    userId: number, 
    route: RouteOption, 
    startLocation: string, 
    endLocation: string
  ): Promise<{ success: boolean; bookingId: number; booking: any }> => {
    return fetchAPI<{ success: boolean; bookingId: number; booking: any }>('/multimodal/create-booking', {
      method: 'POST',
      body: JSON.stringify({
        userId,
        startLocation,
        endLocation,
        routeOption: route
      }),
    });
  },

  getMyBookings: async (userId: number): Promise<Booking[]> => {
    return fetchAPI<Booking[]>(`/multimodal/user/${userId}`);
  },

  // Vehicles
  getProviderVehicles: async (providerId: number): Promise<Vehicle[]> => {
    return fetchAPI<Vehicle[]>(`/vehicles/provider/${providerId}`);
  },

  addVehicle: async (providerId: number, vehicle: Omit<Vehicle, 'id'>): Promise<Vehicle> => {
    return fetchAPI<Vehicle>(`/vehicles/provider/${providerId}`, {
      method: 'POST',
      body: JSON.stringify(vehicle),
    });
  },

  updateVehicle: async (providerId: number, vehicle: Vehicle): Promise<Vehicle> => {
    return fetchAPI<Vehicle>(`/vehicles/${vehicle.id}`, {
      method: 'PUT',
      body: JSON.stringify(vehicle),
    });
  },

  toggleVehicleAvailability: async (providerId: number, vehicleId: number): Promise<Vehicle> => {
    return fetchAPI<Vehicle>(`/vehicles/${vehicleId}/toggle-availability`, {
      method: 'PATCH',
    });
  },

  deleteVehicle: async (vehicleId: number): Promise<{ message: string }> => {
    return fetchAPI<{ message: string }>(`/vehicles/${vehicleId}`, {
      method: 'DELETE',
    });
  },

  cancelBooking: async (bookingId: number): Promise<{ message: string; status: string }> => {
    return fetchAPI<{ message: string; status: string }>(`/bookings/${bookingId}`, {
      method: 'DELETE',
    });
  },

  // Admin APIs
  getAdminStats: async (): Promise<any> => {
    return fetchAPI<any>('/admin/stats');
  },

  getRecentBookings: async (limit: number): Promise<any[]> => {
    return fetchAPI<any[]>(`/admin/bookings/recent?limit=${limit}`);
  },

  // Metro & Transit APIs
  getMetroStations: async (): Promise<any[]> => {
    return fetchAPI<any[]>('/transit/metro-stations');
  },

  getMetroSchedules: async (stationId: number): Promise<any[]> => {
    return fetchAPI<any[]>(`/transit/metro-schedules/${stationId}`);
  },

  getBusRoutes: async (): Promise<any[]> => {
    return fetchAPI<any[]>('/transit/bus-routes');
  },

  // Offers APIs
  getActiveOffers: async (): Promise<any[]> => {
    return fetchAPI<any[]>('/offers/active');
  },

  validateOffer: async (offerCode: string, bookingAmount: number): Promise<any> => {
    return fetchAPI<any>('/offers/validate', {
      method: 'POST',
      body: JSON.stringify({ offerCode, bookingAmount }),
    });
  },

  // Bounce Centers APIs
  getBounceCenters: async (): Promise<any[]> => {
    return fetchAPI<any[]>('/bounce/centers');
  },

  getNearbyBounceCenters: async (latitude: number, longitude: number, radius: number): Promise<any[]> => {
    return fetchAPI<any[]>(`/bounce/nearby?lat=${latitude}&lng=${longitude}&radius=${radius}`);
  },

  // Notifications APIs
  getUserNotifications: async (userId: number): Promise<any[]> => {
    return fetchAPI<any[]>(`/notifications/user/${userId}`);
  },

  markNotificationAsRead: async (notificationId: number): Promise<any> => {
    return fetchAPI<any>(`/notifications/${notificationId}/read`, {
      method: 'PATCH',
    });
  },

  markAllNotificationsAsRead: async (userId: number): Promise<any> => {
    return fetchAPI<any>(`/notifications/user/${userId}/read-all`, {
      method: 'PATCH',
    });
  },
};