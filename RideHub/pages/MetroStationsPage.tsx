import React, { useState, useEffect } from 'react';
import { api } from '../services/api';
import Card from '../components/Card';

interface MetroStation {
  StationID: number;
  StationName: string;
  Location: string;
  LineColor: string;
  CreatedAt: string;
}

const MetroStationsPage: React.FC = () => {
  const [stations, setStations] = useState<MetroStation[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchStations();
  }, []);

  const fetchStations = async () => {
    try {
      const data = await api.getMetroStations();
      setStations(data);
    } catch (error) {
      console.error('Failed to fetch metro stations:', error);
    } finally {
      setLoading(false);
    }
  };

  const getLineColorClass = (color: string) => {
    const colorMap: { [key: string]: string } = {
      'Purple': 'bg-purple-500',
      'Green': 'bg-green-500',
      'Blue': 'bg-blue-500',
      'Red': 'bg-red-500',
      'Yellow': 'bg-yellow-500',
    };
    return colorMap[color] || 'bg-gray-500';
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
      <h2 className="text-3xl font-bold text-slate-900 mb-6">🚇 Metro Stations</h2>
      
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {stations.map((station) => (
          <Card key={station.StationID}>
            <div className="flex items-start justify-between mb-3">
              <h3 className="text-lg font-bold text-slate-900">{station.StationName}</h3>
              <div className={`w-4 h-4 rounded-full ${getLineColorClass(station.LineColor)}`}></div>
            </div>
            
            <div className="space-y-2">
              <div className="flex items-center text-sm text-slate-600">
                <span className="mr-2">📍</span>
                <span>{station.Location}</span>
              </div>
              
              <div className="flex items-center text-sm">
                <span className="mr-2">🚊</span>
                <span className="font-semibold" style={{ color: station.LineColor.toLowerCase() }}>
                  {station.LineColor} Line
                </span>
              </div>
            </div>
          </Card>
        ))}
      </div>

      {stations.length === 0 && (
        <div className="text-center py-12">
          <p className="text-slate-500 text-lg">No metro stations found</p>
        </div>
      )}
    </div>
  );
};

export default MetroStationsPage;
