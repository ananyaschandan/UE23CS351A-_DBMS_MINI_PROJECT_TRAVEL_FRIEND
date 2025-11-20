import React, { useState, useEffect } from 'react';
import { User } from '../types';
import Card from '../components/Card';

interface MetroPageProps {
  user: User;
}

interface MetroStation {
  StationID: number;
  StationName: string;
  StationCode: string;
  LineColor: 'Purple' | 'Green';
  Location: string;
  IsInterchange: boolean;
  StationOrder: number;
}

interface MetroRoute {
  fromStation: string;
  toStation: string;
  distance: number;
  time: number;
  fare: number;
  stops: number;
  interchangeAt: string | null;
  routeInstructions: string;
  firstTrain: string;
  lastTrain: string;
  stationSequence: Array<{
    StationName: string;
    StationCode: string;
    LineColor: string;
    StationOrder: number;
  }>;
}

const MetroPage: React.FC<MetroPageProps> = () => {
  const [stations, setStations] = useState<MetroStation[]>([]);
  const [fromStation, setFromStation] = useState('');
  const [toStation, setToStation] = useState('');
  const [route, setRoute] = useState<MetroRoute | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [showMap, setShowMap] = useState(false);
  const [mapImageUrl, setMapImageUrl] = useState('');
  const [hasMapInDB, setHasMapInDB] = useState(false);

  useEffect(() => {
    fetchStations();
    checkMapAvailability();
  }, []);

  const checkMapAvailability = async () => {
    try {
      const response = await fetch('http://localhost:5000/api/metro/map-info');
      const data = await response.json();
      if (data.success && data.hasMap) {
        setHasMapInDB(true);
        setMapImageUrl('http://localhost:5000/api/metro/map-image');
      }
    } catch (error) {
      console.error('Failed to check map availability:', error);
    }
  };

  const fetchStations = async () => {
    try {
      const response = await fetch('http://localhost:5000/api/metro/stations');
      const data = await response.json();
      if (data.success) {
        setStations(data.stations);
      }
    } catch (error) {
      console.error('Failed to fetch stations:', error);
    }
  };

  const findRoute = async () => {
    if (!fromStation || !toStation) {
      setError('Please select both source and destination stations');
      return;
    }

    if (fromStation === toStation) {
      setError('Source and destination cannot be the same');
      return;
    }

    setLoading(true);
    setError('');
    setRoute(null);

    try {
      const response = await fetch('http://localhost:5000/api/metro/find-route', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ fromStation, toStation }),
      });

      const data = await response.json();

      if (data.success) {
        setRoute(data.route);
      } else {
        setError(data.error || 'Failed to find route');
      }
    } catch (error) {
      console.error('Error finding route:', error);
      setError('Failed to find route. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  const getLineColor = (line: string) => {
    const colors = {
      Purple: '#8B5CF6',
      Green: '#10B981',
    };
    return colors[line as keyof typeof colors] || '#6B7280';
  };

  const getLineTextColor = (line: string) => {
    const colors = {
      Purple: 'text-purple-700',
      Green: 'text-green-700',
    };
    return colors[line as keyof typeof colors] || 'text-gray-700';
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-purple-50 via-white to-pink-50 p-6">
      <div className="max-w-6xl mx-auto">
        {/* Header */}
        <div className="text-center mb-8">
          <h1 className="text-5xl font-bold mb-3">
            <span className="bg-gradient-to-r from-purple-600 via-pink-600 to-green-600 bg-clip-text text-transparent">
              Namma Metro Route Finder
            </span>
          </h1>
          <p className="text-slate-600 text-lg">Find the best metro route for your journey in Bangalore</p>
        </div>

        {/* Route Finder Card */}
        <Card className="mb-6 bg-white/80 backdrop-blur-sm shadow-xl">
          <div className="grid md:grid-cols-2 gap-6 mb-6">
            {/* Source Station */}
            <div>
              <label className="block text-sm font-semibold text-slate-700 mb-2">
                Source Station:
              </label>
              <select
                value={fromStation}
                onChange={(e) => setFromStation(e.target.value)}
                className="w-full px-4 py-3 border-2 border-slate-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-purple-500 bg-white text-slate-900"
              >
                <option value="">Select Source Station</option>
                {stations.map((station) => (
                  <option key={station.StationID} value={station.StationName}>
                    {station.StationName} ({station.LineColor})
                  </option>
                ))}
              </select>
            </div>

            {/* Destination Station */}
            <div>
              <label className="block text-sm font-semibold text-slate-700 mb-2">
                Destination Station:
              </label>
              <select
                value={toStation}
                onChange={(e) => setToStation(e.target.value)}
                className="w-full px-4 py-3 border-2 border-slate-300 rounded-lg focus:ring-2 focus:ring-pink-500 focus:border-pink-500 bg-white text-slate-900"
              >
                <option value="">Select Destination Station</option>
                {stations.map((station) => (
                  <option key={station.StationID} value={station.StationName}>
                    {station.StationName} ({station.LineColor})
                  </option>
                ))}
              </select>
            </div>
          </div>

          {/* Find Route Button */}
          <div className="flex gap-4">
            <button
              onClick={findRoute}
              disabled={loading || !fromStation || !toStation}
              className="flex-1 bg-gradient-to-r from-purple-600 to-pink-600 text-white font-bold py-4 px-6 rounded-lg hover:from-purple-700 hover:to-pink-700 disabled:opacity-50 disabled:cursor-not-allowed transition-all shadow-lg hover:shadow-xl"
            >
              {loading ? 'Finding Route...' : 'Find Route'}
            </button>
            
            <button
              onClick={() => setShowMap(!showMap)}
              className="bg-gradient-to-r from-green-600 to-teal-600 text-white font-bold py-4 px-6 rounded-lg hover:from-green-700 hover:to-teal-700 transition-all shadow-lg hover:shadow-xl"
            >
              {showMap ? 'Hide Map' : 'View Map'}
            </button>
          </div>

          {error && (
            <div className="mt-4 p-4 bg-red-50 border-2 border-red-200 rounded-lg">
              <p className="text-red-700 font-semibold">{error}</p>
            </div>
          )}
        </Card>

        {/* Metro Map */}
        {showMap && (
          <Card className="mb-6 bg-white/80 backdrop-blur-sm shadow-xl">
            <h2 className="text-2xl font-bold text-slate-800 mb-4">Bangalore Metro Network Map</h2>
            <div className="bg-slate-100 rounded-lg p-4 flex items-center justify-center min-h-[400px]">
              {hasMapInDB ? (
                <img 
                  src={mapImageUrl} 
                  alt="Bangalore Metro Map" 
                  className="max-w-full h-auto rounded-lg shadow-lg"
                  onError={(e) => {
                    (e.target as HTMLImageElement).style.display = 'none';
                    (e.target as HTMLImageElement).parentElement!.innerHTML = '<p class="text-slate-600 text-center">Failed to load metro map from database.</p>';
                  }}
                />
              ) : (
                <div className="text-center">
                  <p className="text-slate-600 mb-4">No metro map uploaded yet.</p>
                  <p className="text-sm text-slate-500">Upload a metro map image using the API endpoint:</p>
                  <code className="bg-slate-200 px-3 py-1 rounded text-xs">POST /api/metro/upload-map</code>
                </div>
              )}
            </div>
          </Card>
        )}

        {/* Route Results */}
        {route && (
          <div className="space-y-6">
            {/* Journey Details Card - Clean Design */}
            <Card className="bg-white shadow-xl border-l-4 border-purple-600">
              <div className="mb-6">
                <h2 className="text-3xl font-bold text-slate-900 mb-3">Journey Details</h2>
                <div className="inline-block bg-green-500 text-white px-5 py-2 rounded-md font-bold text-sm">
                  ✓ Route Found!
                </div>
              </div>

              {/* From and To */}
              <div className="mb-6">
                <p className="text-lg mb-2">
                  <span className="font-bold text-purple-700">From:</span>{' '}
                  <span className="text-slate-900">{route.fromStation}</span>
                </p>
                <p className="text-lg">
                  <span className="font-bold text-purple-700">To:</span>{' '}
                  <span className="text-slate-900">{route.toStation}</span>
                </p>
              </div>

              {/* Distance and Time - Side by Side */}
              <div className="grid md:grid-cols-2 gap-4 mb-6">
                <div className="bg-slate-50 rounded-lg p-4 border border-slate-200">
                  <p className="text-sm text-slate-600 mb-1">Distance:</p>
                  <p className="text-xl font-bold text-slate-900">~{route.distance} km</p>
                </div>
                <div className="bg-slate-50 rounded-lg p-4 border border-slate-200">
                  <p className="text-sm text-slate-600 mb-1">Est. Time:</p>
                  <p className="text-xl font-bold text-slate-900">~{route.time} minutes</p>
                </div>
              </div>

              {/* Stations and Interchange */}
              <div className="grid md:grid-cols-2 gap-4 mb-6">
                <div className="bg-slate-50 rounded-lg p-4 border border-slate-200">
                  <p className="text-sm text-slate-600 mb-1">Stations:</p>
                  <p className="text-xl font-bold text-green-700">{route.stops} stops <span className="text-sm text-slate-600">(Approx.)</span></p>
                </div>

                {route.interchangeAt && (
                  <div className="bg-orange-50 rounded-lg p-4 border border-orange-300">
                    <p className="text-sm text-slate-600 mb-1">Interchange Required at:</p>
                    <p className="text-xl font-bold text-orange-700">{route.interchangeAt}</p>
                  </div>
                )}
              </div>

              {/* Fare */}
              <div className="bg-slate-50 rounded-lg p-4 border border-slate-200 mb-6">
                <p className="text-sm text-slate-600 mb-1">Est. Fare:</p>
                <p className="text-2xl font-bold text-blue-700">₹ {route.fare} <span className="text-sm text-slate-600">(Approx.)</span></p>
              </div>

              {/* First & Last Train Timings */}
              <div className="bg-purple-100 rounded-lg p-6 border-2 border-purple-300 mb-6">
                <h3 className="text-xl font-bold text-purple-900 mb-4">First & Last Train Timings:</h3>
                <div className="grid md:grid-cols-2 gap-4">
                  <div>
                    <p className="text-sm text-purple-700 font-semibold mb-1">First Train:</p>
                    <p className="text-lg text-slate-900">
                      Generally starts around <span className="font-bold text-purple-700">5:00 AM</span>{' '}
                      <span className="text-sm">(7:00 AM on Sundays)</span>
                    </p>
                  </div>
                  <div>
                    <p className="text-sm text-purple-700 font-semibold mb-1">Last Train:</p>
                    <p className="text-lg text-slate-900">
                      Last train departure is usually around <span className="font-bold text-purple-700">11:00 PM</span>
                    </p>
                  </div>
                </div>
                <p className="text-xs text-purple-600 italic mt-3">
                  (Note: These are general timings. Exact times can vary. Please check the official BMRCL app for precise information.)
                </p>
              </div>

              {/* Route Instructions */}
              <div className="bg-white rounded-lg p-6 border-2 border-purple-200">
                <h3 className="text-xl font-bold text-purple-900 mb-4">Route Instructions:</h3>
                <div className="space-y-3">
                  {route.routeInstructions.split('\n').map((instruction, index) => (
                    <div key={index} className="flex items-start gap-3">
                      {instruction.trim() && (
                        <>
                          <div className="flex-shrink-0 w-8 h-8 bg-purple-600 text-white rounded-full flex items-center justify-center font-bold">
                            {instruction.match(/^\d+\./) ? instruction.match(/^\d+/)![0] : '•'}
                          </div>
                          <p className="text-slate-800 flex-1 pt-1">{instruction.replace(/^\d+\.\s*/, '')}</p>
                        </>
                      )}
                    </div>
                  ))}
                </div>
                {route.interchangeAt && (
                  <p className="text-sm text-slate-600 italic mt-4">
                    (Platform numbers vary, please check signs at the station)
                  </p>
                )}
              </div>
            </Card>

            {/* Visual Route */}
            {route.stationSequence && route.stationSequence.length > 0 && (
              <Card className="bg-white/80 backdrop-blur-sm shadow-xl">
                <h3 className="text-2xl font-bold text-slate-800 mb-6">Visual Route:</h3>
                <div className="overflow-x-auto pb-4">
                  <div className="flex items-center gap-2 min-w-max">
                    {route.stationSequence.map((station, index) => (
                      <React.Fragment key={index}>
                        {/* Station */}
                        <div className="flex flex-col items-center">
                          <div
                            className={`w-12 h-12 rounded-full flex items-center justify-center font-bold text-white shadow-lg ${
                              station.StationName === route.interchangeAt
                                ? 'bg-orange-500 ring-4 ring-orange-300'
                                : station.LineColor === 'Purple'
                                ? 'bg-purple-600'
                                : station.LineColor === 'Green'
                                ? 'bg-green-600'
                                : 'bg-pink-600'
                            }`}
                            style={{
                              backgroundColor: station.StationName === route.interchangeAt 
                                ? '#f97316' 
                                : getLineColor(station.LineColor)
                            }}
                          >
                            {index === 0 ? '🚩' : index === route.stationSequence.length - 1 ? '🏁' : station.StationOrder}
                          </div>
                          <div className="mt-2 text-center max-w-[120px]">
                            <p className="text-xs font-semibold text-slate-900 break-words">
                              {station.StationName}
                            </p>
                            <p className={`text-xs font-bold ${getLineTextColor(station.LineColor)}`}>
                              {station.LineColor} Line
                            </p>
                            {station.StationName === route.interchangeAt && (
                              <p className="text-xs font-bold text-orange-600 mt-1">⚡ Interchange</p>
                            )}
                          </div>
                        </div>

                        {/* Connector Line */}
                        {index < route.stationSequence.length - 1 && (
                          <div
                            className="h-1 w-16 rounded"
                            style={{
                              backgroundColor: getLineColor(route.stationSequence[index + 1].LineColor),
                            }}
                          />
                        )}
                      </React.Fragment>
                    ))}
                  </div>
                </div>
              </Card>
            )}
          </div>
        )}

        {/* Metro Lines Info */}
        <Card className="mt-6 bg-white/80 backdrop-blur-sm shadow-xl">
          <h3 className="text-2xl font-bold text-slate-800 mb-4">Metro Lines</h3>
          <div className="grid md:grid-cols-2 gap-4">
            <div className="bg-purple-50 border-2 border-purple-300 rounded-lg p-4">
              <div className="flex items-center gap-2 mb-2">
                <div className="w-4 h-4 bg-purple-600 rounded-full"></div>
                <h4 className="font-bold text-purple-900">Purple Line</h4>
              </div>
              <p className="text-sm text-slate-700">Whitefield ↔ Challaghatta</p>
              <p className="text-xs text-slate-600 mt-1">
                {stations.filter((s) => s.LineColor === 'Purple').length} stations
              </p>
            </div>

            <div className="bg-green-50 border-2 border-green-300 rounded-lg p-4">
              <div className="flex items-center gap-2 mb-2">
                <div className="w-4 h-4 bg-green-600 rounded-full"></div>
                <h4 className="font-bold text-green-900">Green Line</h4>
              </div>
              <p className="text-sm text-slate-700">Nagasandra ↔ Puttenahalli</p>
              <p className="text-xs text-slate-600 mt-1">
                {stations.filter((s) => s.LineColor === 'Green').length} stations
              </p>
            </div>
          </div>
        </Card>
      </div>
    </div>
  );
};

export default MetroPage;
