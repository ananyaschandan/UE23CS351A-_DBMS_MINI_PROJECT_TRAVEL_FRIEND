export enum Role {
  User = 'USER',
  Provider = 'PROVIDER',
}

export enum RouteType {
  Shortest = 'Shortest',
  Fastest = 'Fastest',
  Cheapest = 'Cheapest',
}

export interface User {
  id: number;
  fullName: string;
  firstName: string;
  lastName: string;
  username: string;
  email: string;
  phone: string;
  age: number;
  role: Role;
  providerId?: number; // For provider users
  ratePerHour?: number; // For provider users
  rating?: number; // For provider users
}

export interface Provider extends User {
  servicePartnership: 'Individual';
  idProofUrl: string;
  vehicleRegUrl: string;
  licenseUrl: string;
}

export interface ServiceComparison {
  serviceType: string;
  vehicleType: string;
  fareFor5Km: number;
}

export interface BookingSegment {
  segmentOrder: number;
  serviceType: string;
  vehicleType: string;
  startLocation: string;
  endLocation: string;
  distance: number;
  estimatedTime: number;
  segmentFare: number;
  vehicleNumber?: string;
  vehicleModel?: string;
  providerName?: string;
}

export interface RouteOption {
  routeType: RouteType;
  totalDistance: number;
  totalTime: number;
  totalFare: number;
  segments: BookingSegment[];
  isMultiModal: boolean;
  // Legacy fields for compatibility
  distance?: number;
  estimatedTime?: number;
  estimatedFare?: number;
  recommendedService?: string;
}

export interface ProviderDetails {
  name: string;
  phone: string;
  vehicleNumber: string;
  model: string;
  rating: number;
}

export interface Booking {
  id: number;
  userId: number;
  startLocation: string;
  endLocation: string;
  totalDistance: number;
  totalTime: number;
  totalFare: number;
  originalFare?: number;
  discountAmount?: number;
  offerCode?: string;
  discountPercentage?: number;
  status: 'Confirmed' | 'InProgress' | 'Completed';
  selectedRouteType: RouteType;
  bookingTime: string;
  isMultiModal: boolean;
  segmentCount: number;
  segments?: BookingSegment[];
  providerDetails?: ProviderDetails; // Legacy field, may not be present
}

export interface Vehicle {
  id: number;
  vehicleNumber: string;
  model: string;
  vehicleType: 'Auto' | 'Cab' | 'Bike';
  capacity: number;
  isAvailable: boolean;
}

export interface TripSuggestion {
  title: string;
  summary: string;
  stops: {
    name: string;
    description: string;
    timeOfDay: string;
  }[];
}