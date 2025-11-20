import React, { useState, useCallback } from 'react';
import { User, RouteOption, BookingSegment } from '../types';
import { api } from '../services/api';
import Card from '../components/Card';
import Button from '../components/Button';

interface BookingPageProps {
  user: User;
  navigate: (page: any) => void;
  PageEnum: any;
}

const SegmentDisplay: React.FC<{ segment: BookingSegment; isLast: boolean }> = ({ segment, isLast }) => {
  const getVehicleIcon = (type: string) => {
    switch (type) {
      case 'Walk': return '🚶';
      case 'Bike': return '🏍️';
      case 'Auto': return '🛺';
      case 'Cab': return '🚗';
      case 'Bus': return '🚌';
      case 'Scooter': return '🛴';
      default: return '🚗';
    }
  };

  return (
    <div className="relative">
      <div className="flex items-start space-x-3 pb-4">
        <div className="flex flex-col items-center">
          <div className="w-10 h-10 rounded-full bg-blue-100 flex items-center justify-center text-xl">
            {getVehicleIcon(segment.vehicleType)}
          </div>
          {!isLast && <div className="w-0.5 h-full bg-blue-200 mt-2"></div>}
        </div>
        <div className="flex-1 bg-slate-50 rounded-lg p-3">
          <div className="flex justify-between items-start mb-2">
            <div>
              <p className="font-semibold text-slate-900">
                {segment.serviceType} {segment.vehicleType}
              </p>
              {segment.vehicleNumber && (
                <p className="text-xs text-slate-500">{segment.vehicleNumber} - {segment.vehicleModel}</p>
              )}
            </div>
            <span className="text-lg font-bold text-blue-600">₹{segment.segmentFare.toFixed(2)}</span>
          </div>
          <div className="text-sm text-slate-600 space-y-1">
            <p>📍 {segment.startLocation} → {segment.endLocation}</p>
            <p>📏 {segment.distance} km • ⏱️ {segment.estimatedTime} min</p>
          </div>
        </div>
      </div>
    </div>
  );
};

const RouteOptionCard: React.FC<{
  option: RouteOption;
  isSelected: boolean;
  onSelect: () => void;
}> = ({ option, isSelected, onSelect }) => {
  const [showSegments, setShowSegments] = useState(false);

  const iconMap = {
    Shortest: 'M13 10V3L4 14h7v7l9-11h-7z',
    Fastest: 'M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z',
    Cheapest: 'M17 9V7a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2m2 4h10a2 2 0 002-2v-6a2 2 0 00-2-2H9a2 2 0 00-2 2v6a2 2 0 002 2zm7-5a2 2 0 11-4 0 2 2 0 014 0z',
  };

  return (
    <div
      className={`border-2 rounded-lg transition-all duration-200 ${
        isSelected ? 'border-blue-500 bg-blue-50' : 'border-slate-300 hover:border-slate-400 bg-white'
      }`}
    >
      <div className="p-4 cursor-pointer" onClick={onSelect}>
        <div className="flex items-center justify-between">
          <div className="flex items-center">
            <svg xmlns="http://www.w3.org/2000/svg" className="h-8 w-8 text-blue-500 mr-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d={iconMap[option.routeType]} />
            </svg>
            <div>
              <h3 className="text-lg font-bold text-slate-900">{option.routeType}</h3>
              <p className="text-sm text-slate-500">
                {option.isMultiModal ? `${option.segments.length} segments` : 'Direct route'}
              </p>
            </div>
          </div>
          <div className="text-right">
            <p className="text-xl font-bold text-blue-600">₹{option.totalFare.toFixed(2)}</p>
            <p className="text-sm text-slate-600">{option.totalDistance} km / {option.totalTime} min</p>
          </div>
        </div>
      </div>
      
      {option.isMultiModal && (
        <div className="border-t border-slate-200 px-4 py-2">
          <button
            onClick={(e) => {
              e.stopPropagation();
              setShowSegments(!showSegments);
            }}
            className="text-sm text-blue-600 hover:text-blue-700 font-medium"
          >
            {showSegments ? '▼ Hide segments' : '▶ Show segments'}
          </button>
          
          {showSegments && (
            <div className="mt-4 space-y-2">
              {option.segments.map((segment, index) => (
                <SegmentDisplay
                  key={index}
                  segment={segment}
                  isLast={index === option.segments.length - 1}
                />
              ))}
            </div>
          )}
        </div>
      )}
    </div>
  );
};

const BookingPage: React.FC<BookingPageProps> = ({ user, navigate, PageEnum }) => {
  const [startLocation, setStartLocation] = useState('Majestic');
  const [endLocation, setEndLocation] = useState('Lalbagh Botanical Garden');
  const [routeOptions, setRouteOptions] = useState<RouteOption[]>([]);
  const [selectedRoute, setSelectedRoute] = useState<RouteOption | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  const [isBooking, setIsBooking] = useState(false);
  const [bookingSuccess, setBookingSuccess] = useState(false);

  const locations = [
    'Majestic',
    'MG Road',
    'Koramangala',
    'Indiranagar',
    'Jayanagar',
    'J.P. Nagar',
    'Rajajinagar',
    'Bengaluru Palace',
    'ISKCON Temple',
    'Malleshwaram',
    'Yeshwanthpur',
    'Lalbagh Botanical Garden',
    'Basavanagudi'
  ];

  const findRoutes = useCallback(async () => {
    if (!startLocation || !endLocation) return;
    setIsLoading(true);
    setRouteOptions([]);
    setSelectedRoute(null);
    setBookingSuccess(false);
    try {
      const options = await api.getThreeRouteOptions(startLocation, endLocation);
      setRouteOptions(options);
    } catch (error) {
      console.error("Failed to fetch routes", error);
      alert('Failed to fetch routes. Please try again.');
    } finally {
      setIsLoading(false);
    }
  }, [startLocation, endLocation]);

  const confirmBooking = useCallback(async () => {
    if (!selectedRoute) return;
    setIsBooking(true);
    try {
      console.log('📝 Storing booking data for offers page...');
      // Store booking data in sessionStorage for offers page
      const bookingData = {
        userId: user.id,
        route: selectedRoute,
        startLocation,
        endLocation,
        totalAmount: selectedRoute.totalFare,
        timestamp: new Date().toISOString()
      };
      sessionStorage.setItem('pendingBooking', JSON.stringify(bookingData));
      console.log('✅ Booking data stored:', bookingData);
      
      setBookingSuccess(true);
      console.log('🔄 Redirecting to offers page in 2 seconds...');
      setTimeout(() => {
        console.log('🎁 Navigating to offers page...');
        navigate(PageEnum.Offers);
      }, 2000);
    } catch (error) {
      console.error("❌ Booking preparation failed", error);
      alert('Booking preparation failed. Please try again.');
    } finally {
      setIsBooking(false);
    }
  }, [selectedRoute, user.id, startLocation, endLocation, navigate, PageEnum]);

  return (
    <div className="max-w-4xl mx-auto">
      <h2 className="text-3xl font-bold text-slate-900 mb-6">Book a Ride</h2>
      <Card>
        {!bookingSuccess ? (
          <>
            <div className="grid md:grid-cols-2 gap-4 mb-4">
              <div>
                <label htmlFor="start" className="block text-sm font-medium text-slate-700 mb-1">From</label>
                <select
                  id="start"
                  value={startLocation}
                  onChange={(e) => setStartLocation(e.target.value)}
                  className="w-full bg-slate-50 border border-slate-300 rounded-md p-2 text-slate-900 focus:ring-blue-500 focus:border-blue-500"
                >
                  {locations.map(loc => (
                    <option key={loc} value={loc}>{loc}</option>
                  ))}
                </select>
              </div>
              <div>
                <label htmlFor="end" className="block text-sm font-medium text-slate-700 mb-1">To</label>
                <select
                  id="end"
                  value={endLocation}
                  onChange={(e) => setEndLocation(e.target.value)}
                  className="w-full bg-slate-50 border border-slate-300 rounded-md p-2 text-slate-900 focus:ring-blue-500 focus:border-blue-500"
                >
                  {locations.map(loc => (
                    <option key={loc} value={loc}>{loc}</option>
                  ))}
                </select>
              </div>
            </div>
            <Button onClick={findRoutes} isLoading={isLoading} className="w-full mb-6">
              Find Routes
            </Button>

            {routeOptions.length > 0 && (
              <div className="space-y-4 mb-6">
                <h3 className="text-xl font-semibold text-slate-900">Choose Your Route</h3>
                {routeOptions.map((option, index) => (
                  <RouteOptionCard
                    key={index}
                    option={option}
                    isSelected={selectedRoute === option}
                    onSelect={() => setSelectedRoute(option)}
                  />
                ))}
              </div>
            )}

            {selectedRoute && (
              <Button
                onClick={confirmBooking}
                isLoading={isBooking}
                variant="gradient"
                className="w-full"
              >
                Confirm Booking - ₹{selectedRoute.totalFare.toFixed(2)}
              </Button>
            )}
          </>
        ) : (
          <div className="text-center py-8">
            <div className="text-6xl mb-4">✅</div>
            <h3 className="text-2xl font-bold text-green-600 mb-2">Route Selected!</h3>
            <p className="text-slate-600">Redirecting to offers page to apply discounts...</p>
          </div>
        )}
      </Card>
    </div>
  );
};

export default BookingPage;
