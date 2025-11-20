import React, { useState, useEffect } from 'react';
import { api } from '../services/api';
import Card from '../components/Card';

interface BusRoute {
  BusRouteID: number;
  RouteNumber: string;
  RouteName: string;
  StartLocation: string;
  EndLocation: string;
  Distance: number;
  EstimatedTime: number;
  Fare: number;
  Frequency: string;
  BusType: string;
  IsActive: boolean;
}

const BusRoutesPage: React.FC = () => {
  const [routes, setRoutes] = useState<BusRoute[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');

  useEffect(() => {
    fetchRoutes();
  }, []);

  const fetchRoutes = async () => {
    try {
      const data = await api.getBusRoutes();
      setRoutes(data);
    } catch (error) {
      console.error('Failed to fetch bus routes:', error);
    } finally {
      setLoading(false);
    }
  };

  const filteredRoutes = routes.filter(route =>
    route.RouteNumber.toLowerCase().includes(searchTerm.toLowerCase()) ||
    route.RouteName.toLowerCase().includes(searchTerm.toLowerCase()) ||
    route.StartLocation.toLowerCase().includes(searchTerm.toLowerCase()) ||
    route.EndLocation.toLowerCase().includes(searchTerm.toLowerCase())
  );

  const getBusTypeColor = (type: string) => {
    const colorMap: { [key: string]: string } = {
      'Ordinary': 'bg-blue-100 text-blue-700',
      'Volvo AC': 'bg-purple-100 text-purple-700',
      'Vajra': 'bg-green-100 text-green-700',
      'Express': 'bg-orange-100 text-orange-700',
    };
    return colorMap[type] || 'bg-gray-100 text-gray-700';
  };

  if (loading) {
    return (
      <div className="flex justify-center items-center h-screen">
        <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-blue-600"></div>
      </div>
    );
  }

  return (
    <div className="max-w-7xl mx-auto">
      <div className="mb-6">
        <h2 className="text-3xl font-bold text-slate-900 mb-4">🚌 BMTC Bus Routes</h2>
        
        {/* Search Bar */}
        <div className="relative">
          <input
            type="text"
            placeholder="Search by route number, name, or location..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="w-full px-4 py-3 pl-12 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          />
          <span className="absolute left-4 top-3.5 text-slate-400 text-xl">🔍</span>
        </div>
      </div>

      {/* Stats Summary */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
        <Card>
          <div className="text-center">
            <div className="text-3xl font-bold text-blue-600">{routes.length}</div>
            <div className="text-sm text-slate-600">Total Routes</div>
          </div>
        </Card>
        <Card>
          <div className="text-center">
            <div className="text-3xl font-bold text-purple-600">
              {routes.filter(r => r.BusType === 'Volvo AC').length}
            </div>
            <div className="text-sm text-slate-600">Volvo AC</div>
          </div>
        </Card>
        <Card>
          <div className="text-center">
            <div className="text-3xl font-bold text-green-600">
              {routes.filter(r => r.BusType === 'Vajra').length}
            </div>
            <div className="text-sm text-slate-600">Vajra</div>
          </div>
        </Card>
        <Card>
          <div className="text-center">
            <div className="text-3xl font-bold text-orange-600">
              ₹{Math.min(...routes.map(r => r.Fare))}
            </div>
            <div className="text-sm text-slate-600">Min Fare</div>
          </div>
        </Card>
      </div>

      {/* Routes List */}
      <div className="space-y-4">
        {filteredRoutes.map((route) => (
          <Card key={route.BusRouteID}>
            <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
              {/* Route Info */}
              <div className="flex-1">
                <div className="flex items-center gap-3 mb-2">
                  <div className="bg-red-600 text-white font-bold px-3 py-1 rounded">
                    {route.RouteNumber}
                  </div>
                  <h3 className="text-lg font-bold text-slate-900">{route.RouteName}</h3>
                  <span className={`px-3 py-1 rounded-full text-xs font-semibold ${getBusTypeColor(route.BusType)}`}>
                    {route.BusType}
                  </span>
                </div>
                
                <div className="flex items-center gap-2 text-slate-600">
                  <span className="font-semibold">{route.StartLocation}</span>
                  <span className="text-blue-600">→</span>
                  <span className="font-semibold">{route.EndLocation}</span>
                </div>
              </div>

              {/* Route Stats */}
              <div className="flex gap-6 text-sm">
                <div className="text-center">
                  <div className="text-slate-500 text-xs">Distance</div>
                  <div className="font-bold text-slate-900">{route.Distance} km</div>
                </div>
                <div className="text-center">
                  <div className="text-slate-500 text-xs">Time</div>
                  <div className="font-bold text-slate-900">{route.EstimatedTime} min</div>
                </div>
                <div className="text-center">
                  <div className="text-slate-500 text-xs">Frequency</div>
                  <div className="font-bold text-slate-900">{route.Frequency}</div>
                </div>
                <div className="text-center">
                  <div className="text-slate-500 text-xs">Fare</div>
                  <div className="font-bold text-green-600 text-lg">₹{route.Fare}</div>
                </div>
              </div>
            </div>
          </Card>
        ))}
      </div>

      {filteredRoutes.length === 0 && (
        <div className="text-center py-12">
          <p className="text-slate-500 text-lg">
            {searchTerm ? 'No routes match your search' : 'No bus routes found'}
          </p>
        </div>
      )}
    </div>
  );
};

export default BusRoutesPage;
