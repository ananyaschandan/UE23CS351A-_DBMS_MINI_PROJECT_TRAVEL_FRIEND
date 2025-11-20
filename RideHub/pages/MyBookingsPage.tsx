import React, { useState, useEffect } from 'react';
import { User, Booking } from '../types';
import { api } from '../services/api';
import Card from '../components/Card';
import Button from '../components/Button';

interface MyBookingsPageProps {
  user: User;
  navigate: (page: any) => void;
  PageEnum: any;
}

const MyBookingsPage: React.FC<MyBookingsPageProps> = ({ user, navigate, PageEnum }) => {
  const [bookings, setBookings] = useState<Booking[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const fetchBookings = async () => {
      setIsLoading(true);
      try {
        console.log('Fetching bookings for user:', user.id);
        const data = await api.getMyBookings(user.id);
        console.log('Received bookings:', data);
        setBookings(data);
      } catch (error) {
        console.error("Failed to fetch bookings", error);
      } finally {
        setIsLoading(false);
      }
    };
    fetchBookings();
  }, [user.id]);
  
  const getStatusColor = (status: string) => {
    switch (status) {
      case 'Completed': return 'bg-green-100 text-green-800';
      case 'InProgress': return 'bg-yellow-100 text-yellow-800';
      case 'Confirmed': return 'bg-blue-100 text-blue-800';
      default: return 'bg-slate-100 text-slate-800';
    }
  };

  const getRouteTypeColor = (routeType: string) => {
    switch (routeType) {
      case 'Fastest': return 'bg-purple-100 text-purple-800';
      case 'Cheapest': return 'bg-emerald-100 text-emerald-800';
      case 'Shortest': return 'bg-sky-100 text-sky-800';
      default: return 'bg-slate-100 text-slate-800';
    }
  };


  return (
    <>
      <div className="max-w-4xl mx-auto">
        <h2 className="text-3xl font-bold text-slate-900 mb-6">My Bookings</h2>
        {isLoading ? (
          <div className="text-center p-8 text-slate-600">Loading bookings...</div>
        ) : bookings.length === 0 ? (
          <Card className="text-center">
            <h3 className="text-xl font-semibold text-slate-900">No bookings yet!</h3>
            <p className="text-slate-500 mt-2 mb-4">Time to plan your next trip.</p>
            <Button onClick={() => navigate(PageEnum.Booking)}>Book a Ride</Button>
          </Card>
        ) : (
          <div className="space-y-4">
            {bookings.map(booking => (
              <Card key={booking.id}>
                <div className="space-y-4">
                  {/* Header */}
                  <div className="flex flex-col md:flex-row justify-between items-start md:items-center">
                    <div className="flex-1">
                      <div className="flex items-center space-x-3 mb-2">
                        <span className={`px-2.5 py-1 text-xs font-semibold rounded-full ${getStatusColor(booking.status)}`}>{booking.status}</span>
                        <span className={`px-2.5 py-1 text-xs font-semibold rounded-full ${getRouteTypeColor(booking.selectedRouteType)}`}>{booking.selectedRouteType} Route</span>
                      </div>
                      <p className="text-lg font-semibold text-slate-900">
                        {booking.startLocation} 
                        <span className="text-slate-400 mx-2">→</span> 
                        {booking.endLocation}
                      </p>
                      <div className="flex items-center space-x-4 mt-2 text-sm text-slate-600">
                        <span>📏 {booking.totalDistance} km</span>
                        <span>⏱️ {booking.totalTime} min</span>
                        {booking.offerCode ? (
                          <div className="flex items-center space-x-2">
                            <span className="text-slate-500 line-through">₹{booking.originalFare}</span>
                            <span className="font-semibold text-green-600">₹{booking.totalFare}</span>
                            <span className="bg-green-100 text-green-700 px-2 py-1 rounded-full text-xs font-semibold">
                              🎁 {booking.offerCode}
                            </span>
                          </div>
                        ) : (
                          <span className="font-semibold text-green-600">₹{booking.totalFare}</span>
                        )}
                      </div>
                      
                      {booking.offerCode && booking.discountAmount && (
                        <div className="mt-2 p-2 bg-green-50 border border-green-200 rounded-lg">
                          <div className="flex items-center justify-between text-sm">
                            <span className="text-green-700 font-medium">
                              🎁 Offer Applied: {booking.offerCode} ({booking.discountPercentage}% off)
                            </span>
                            <span className="text-green-600 font-semibold">
                              Saved ₹{booking.discountAmount}
                            </span>
                          </div>
                        </div>
                      )}
                    </div>
                  </div>

                  {/* Segments */}
                  {booking.segments && booking.segments.length > 0 && (
                    <div className="border-t pt-3">
                      <h4 className="text-sm font-semibold text-slate-700 mb-2">Trip Segments:</h4>
                      <div className="space-y-2">
                        {booking.segments.map((segment: any, index: number) => (
                          <div key={index} className="flex items-center justify-between bg-slate-50 p-3 rounded-lg">
                            <div className="flex items-center space-x-3">
                              <span className="bg-blue-100 text-blue-800 px-2 py-1 rounded text-xs font-semibold">
                                {index + 1}
                              </span>
                              <div>
                                <p className="font-semibold text-slate-900">
                                  {segment.serviceType} {segment.vehicleType}
                                </p>
                                <p className="text-xs text-slate-600">
                                  {segment.startLocation} → {segment.endLocation}
                                </p>
                              </div>
                            </div>
                            <div className="text-right">
                              <p className="text-sm text-slate-600">{segment.distance} km • {segment.estimatedTime} min</p>
                              <p className="text-sm font-semibold text-green-600">₹{segment.segmentFare}</p>
                            </div>
                          </div>
                        ))}
                      </div>
                    </div>
                  )}
                </div>
              </Card>
            ))}
          </div>
        )}
      </div>
    </>
  );
};

export default MyBookingsPage;
