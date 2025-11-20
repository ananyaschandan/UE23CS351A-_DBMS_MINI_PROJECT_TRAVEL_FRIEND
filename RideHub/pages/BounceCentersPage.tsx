import React, { useState, useEffect } from 'react';
import Card from '../components/Card';

interface BounceCenter {
  CenterID: number;
  CenterName: string;
  Location: string;
  Area: string;
  Latitude: number | string;
  Longitude: number | string;
  AvailableScooters: number;
  IsActive: boolean;
  distance?: number;
}

interface BounceCentersPageProps {
  navigate?: (page: any) => void;
  PageEnum?: any;
}

const BounceCentersPage: React.FC<BounceCentersPageProps> = ({ navigate, PageEnum }) => {
  const [centers, setCenters] = useState<BounceCenter[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [searchTerm, setSearchTerm] = useState('');
  const [userLocation, setUserLocation] = useState('');
  const [searchingLocation, setSearchingLocation] = useState(false);
  const [showNearby, setShowNearby] = useState(false);

  useEffect(() => {
    fetchCenters();
  }, []);

  const fetchCenters = async () => {
    try {
      console.log('🔄 Fetching bounce centers...');
      const response = await fetch('http://localhost:5000/api/bounce/centers');
      
      if (!response.ok) {
        throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      }
      
      const data = await response.json();
      console.log('✅ Bounce centers fetched:', data.length, 'centers');
      
      if (!Array.isArray(data)) {
        throw new Error('Invalid data format received');
      }
      
      setCenters(data);
      setError(null);
    } catch (error: any) {
      console.error('❌ Failed to fetch bounce centers:', error);
      setError(error.message || 'Failed to load bounce centers');
    } finally {
      setLoading(false);
    }
  };

  const findNearestCenters = async () => {
    if (!userLocation.trim()) {
      alert('Please enter your location');
      return;
    }

    setSearchingLocation(true);
    try {
      // Geocode the location using Nominatim (OpenStreetMap)
      const geocodeResponse = await fetch(
        `https://nominatim.openstreetmap.org/search?q=${encodeURIComponent(userLocation + ', Bangalore')}&format=json&limit=1`
      );
      const geocodeData = await geocodeResponse.json();

      if (geocodeData.length === 0) {
        alert('Location not found. Please try a different search term.');
        setSearchingLocation(false);
        return;
      }

      const { lat, lon } = geocodeData[0];

      // Fetch nearby centers
      const response = await fetch(
        `http://localhost:5000/api/bounce/nearby?lat=${lat}&lng=${lon}&radius=10`
      );
      const nearbyCenters = await response.json();

      setCenters(nearbyCenters);
      setShowNearby(true);
    } catch (error) {
      console.error('Failed to find nearby centers:', error);
      alert('Failed to find nearby centers. Please try again.');
    } finally {
      setSearchingLocation(false);
    }
  };

  const resetToAllCenters = () => {
    setShowNearby(false);
    setUserLocation('');
    fetchCenters();
  };

  const filteredCenters = centers.filter(center =>
    center.CenterName.toLowerCase().includes(searchTerm.toLowerCase()) ||
    center.Location.toLowerCase().includes(searchTerm.toLowerCase()) ||
    center.Area.toLowerCase().includes(searchTerm.toLowerCase())
  );

  const getAvailabilityColor = (count: number) => {
    if (count >= 10) return 'text-green-600 bg-green-50';
    if (count >= 5) return 'text-yellow-600 bg-yellow-50';
    return 'text-red-600 bg-red-50';
  };

  const getAvailabilityStatus = (count: number) => {
    if (count >= 10) return '✓ Good Stock';
    if (count >= 5) return '⚠ Low Stock';
    return '⚠ Very Low';
  };

  if (loading) {
    return (
      <div className="flex justify-center items-center h-screen">
        <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-blue-600"></div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="max-w-7xl mx-auto p-8">
        <div className="bg-red-50 border-2 border-red-200 rounded-xl p-8 text-center">
          <div className="text-6xl mb-4">⚠️</div>
          <h2 className="text-2xl font-bold text-red-800 mb-2">Failed to Load Bounce Centers</h2>
          <p className="text-red-600 mb-4">{error}</p>
          <div className="space-y-2 text-sm text-red-700 bg-red-100 p-4 rounded-lg mb-4">
            <p><strong>Possible causes:</strong></p>
            <ul className="list-disc list-inside text-left">
              <li>Backend server is not running (check http://localhost:5000)</li>
              <li>Database table 'BounceCenter' doesn't exist</li>
              <li>No bounce centers data in database</li>
              <li>Network connection issue</li>
            </ul>
          </div>
          <div className="flex gap-3 justify-center">
            <button
              onClick={fetchCenters}
              className="px-6 py-3 bg-blue-600 text-white font-semibold rounded-lg hover:bg-blue-700 transition"
            >
              🔄 Retry
            </button>
            {navigate && PageEnum && (
              <button
                onClick={() => navigate(PageEnum.Landing)}
                className="px-6 py-3 bg-slate-600 text-white font-semibold rounded-lg hover:bg-slate-700 transition"
              >
                ← Back to Home
              </button>
            )}
          </div>
        </div>
      </div>
    );
  }

  if (centers.length === 0) {
    return (
      <div className="max-w-7xl mx-auto p-8">
        <div className="bg-yellow-50 border-2 border-yellow-200 rounded-xl p-8 text-center">
          <div className="text-6xl mb-4">📭</div>
          <h2 className="text-2xl font-bold text-yellow-800 mb-2">No Bounce Centers Found</h2>
          <p className="text-yellow-600 mb-4">The database has no bounce centers yet.</p>
          <div className="space-y-2 text-sm text-yellow-700 bg-yellow-100 p-4 rounded-lg mb-4">
            <p><strong>To fix this:</strong></p>
            <ol className="list-decimal list-inside text-left">
              <li>Open MySQL: <code className="bg-white px-2 py-1 rounded">mysql -u root -p</code></li>
              <li>Run: <code className="bg-white px-2 py-1 rounded">USE TransportBookingSystem;</code></li>
              <li>Run: <code className="bg-white px-2 py-1 rounded">SOURCE sql-enhanced/04_BOUNCE_CENTERS.sql;</code></li>
            </ol>
          </div>
          {navigate && PageEnum && (
            <button
              onClick={() => navigate(PageEnum.Landing)}
              className="px-6 py-3 bg-slate-600 text-white font-semibold rounded-lg hover:bg-slate-700 transition"
            >
              ← Back to Home
            </button>
          )}
        </div>
      </div>
    );
  }

  return (
    <div className="max-w-7xl mx-auto px-4 py-6">
      {/* Navigation Header */}
      {navigate && PageEnum && (
        <div className="bg-white shadow-sm border border-slate-200 rounded-xl p-4 mb-6">
          <div className="flex items-center justify-between">
            <button
              onClick={() => navigate(PageEnum.Landing)}
              className="text-slate-600 hover:text-slate-900 font-medium flex items-center gap-2 transition"
            >
              ← Back to Home
            </button>
            <button
              onClick={() => navigate(PageEnum.UserLogin)}
              className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition font-semibold"
            >
              Login to Book Rides
            </button>
          </div>
        </div>
      )}

      {/* Page Title */}
      <div className="mb-6">
        <h2 className="text-3xl font-bold text-slate-900 mb-2">🛴 Bounce Scooter Centers</h2>
        <p className="text-slate-600">Find and rent electric scooters across Bangalore</p>
      </div>
        
      {/* Location Search */}
      <div className="bg-gradient-to-r from-blue-50 to-purple-50 p-6 rounded-xl mb-4 border border-blue-200">
        <h3 className="text-lg font-semibold text-slate-800 mb-3">📍 Find Nearest Centers</h3>
        <div className="flex gap-3">
          <input
            type="text"
            placeholder="Enter your location (e.g., Koramangala, MG Road)..."
            value={userLocation}
            onChange={(e) => setUserLocation(e.target.value)}
            onKeyPress={(e) => e.key === 'Enter' && findNearestCenters()}
            className="flex-1 px-4 py-3 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            disabled={searchingLocation}
          />
          <button
            onClick={findNearestCenters}
            disabled={searchingLocation}
            className="px-6 py-3 bg-blue-600 text-white font-semibold rounded-lg hover:bg-blue-700 transition disabled:bg-blue-300 disabled:cursor-not-allowed min-w-[120px]"
          >
            {searchingLocation ? '🔄 Searching...' : '🔍 Find Nearby'}
          </button>
          {showNearby && (
            <button
              onClick={resetToAllCenters}
              className="px-6 py-3 bg-slate-600 text-white font-semibold rounded-lg hover:bg-slate-700 transition"
            >
              Show All
            </button>
          )}
        </div>
        {showNearby && (
          <p className="text-sm text-green-700 mt-2 font-medium">✓ Showing centers near "{userLocation}" (sorted by distance)</p>
        )}
      </div>

      {/* Text Search Bar */}
      <div className="relative mb-6">
        <input
          type="text"
          placeholder="Search by name, location, or area..."
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
          className="w-full px-4 py-3 pl-12 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
        />
        <span className="absolute left-4 top-3.5 text-slate-400 text-xl">🔍</span>
      </div>

      {/* Stats Summary */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
        <Card>
          <div className="text-center">
            <div className="text-3xl font-bold text-blue-600">{filteredCenters.length}</div>
            <div className="text-sm text-slate-600">Total Centers</div>
          </div>
        </Card>
        <Card>
          <div className="text-center">
            <div className="text-3xl font-bold text-green-600">
              {filteredCenters.reduce((sum, c) => sum + c.AvailableScooters, 0)}
            </div>
            <div className="text-sm text-slate-600">Total Scooters</div>
          </div>
        </Card>
        <Card>
          <div className="text-center">
            <div className="text-3xl font-bold text-purple-600">
              {filteredCenters.filter(c => c.AvailableScooters >= 10).length}
            </div>
            <div className="text-sm text-slate-600">Well Stocked</div>
          </div>
        </Card>
      </div>

      {/* Centers Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {filteredCenters.map((center) => (
          <Card key={center.CenterID}>
            <div className="space-y-3">
              {/* Center Name */}
              <h3 className="text-lg font-bold text-slate-900">{center.CenterName}</h3>
              
              {/* Location */}
              <div className="space-y-1">
                <div className="flex items-start text-sm text-slate-600">
                  <span className="mr-2">📍</span>
                  <span>{center.Location}</span>
                </div>
                <div className="flex items-center text-sm text-slate-500">
                  <span className="mr-2">🏘️</span>
                  <span>{center.Area}</span>
                </div>
              </div>

              {/* Distance (if nearby search) */}
              {center.distance !== undefined && (
                <div className="bg-blue-50 border border-blue-200 p-2 rounded-lg">
                  <div className="flex items-center justify-center text-blue-700">
                    <span className="text-lg mr-2">📏</span>
                    <span className="font-bold text-lg">{center.distance.toFixed(2)} km away</span>
                  </div>
                </div>
              )}

              {/* Availability */}
              <div className={`flex items-center justify-between p-3 rounded-lg ${getAvailabilityColor(center.AvailableScooters)}`}>
                <div className="flex items-center">
                  <span className="text-2xl mr-2">🛴</span>
                  <div>
                    <div className="text-xs font-semibold uppercase">Available</div>
                    <div className="text-2xl font-bold">{center.AvailableScooters}</div>
                  </div>
                </div>
                <div className="text-xs font-semibold">
                  {getAvailabilityStatus(center.AvailableScooters)}
                </div>
              </div>

              {/* GPS Coordinates */}
              <div className="text-xs text-slate-400 border-t border-slate-200 pt-2">
                <div className="flex justify-between">
                  <span>Lat: {Number(center.Latitude).toFixed(4)}</span>
                  <span>Lng: {Number(center.Longitude).toFixed(4)}</span>
                </div>
              </div>

              {/* Action Button */}
              {navigate && PageEnum && (
                <button
                  onClick={() => navigate(PageEnum.UserLogin)}
                  className="w-full py-2 bg-blue-600 text-white font-semibold rounded-lg hover:bg-blue-700 transition"
                >
                  Rent Scooter
                </button>
              )}

              {/* Status */}
              {center.IsActive && (
                <div className="bg-green-100 text-green-700 text-xs font-semibold px-3 py-1 rounded-full text-center">
                  ✓ Active
                </div>
              )}
            </div>
          </Card>
        ))}
      </div>

      {filteredCenters.length === 0 && (
        <div className="text-center py-12">
          <div className="text-6xl mb-4">🔍</div>
          <p className="text-slate-500 text-lg">
            {searchTerm ? 'No centers match your search' : 'No bounce centers found'}
          </p>
        </div>
      )}
    </div>
  );
};

export default BounceCentersPage;