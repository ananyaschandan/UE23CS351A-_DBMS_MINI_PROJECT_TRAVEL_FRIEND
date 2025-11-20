import React, { useState, useEffect } from 'react';
import { User, ServiceComparison } from '../types';
import { api } from '../services/api';
import Card from '../components/Card';
import Button from '../components/Button';
import AITripSuggestor from './AITripSuggestor';

interface UserDashboardProps {
  user: User;
  navigate: (page: any) => void;
  PageEnum: any;
}

const UserDashboard: React.FC<UserDashboardProps> = ({ navigate, PageEnum }) => {
  const [comparisons, setComparisons] = useState<ServiceComparison[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const fetchComparisons = async () => {
      try {
        const data = await api.getServiceComparisons();
        setComparisons(data);
      } catch (error) {
        console.error("Failed to fetch service comparisons", error);
      } finally {
        setIsLoading(false);
      }
    };
    fetchComparisons();
  }, []);

  return (
    <div className="max-w-7xl mx-auto grid grid-cols-1 lg:grid-cols-3 gap-8">
      <div className="lg:col-span-2">
        <div className="flex justify-between items-center mb-6">
          <h2 className="text-3xl font-bold text-slate-900">Dashboard</h2>
          <Button onClick={() => navigate(PageEnum.Booking)} variant="primary">Book a New Ride</Button>
        </div>
        
        <Card>
          <h3 className="text-xl font-semibold mb-4 text-blue-600">Service Price Comparison (for 5 km)</h3>
          {isLoading ? (
             <div className="flex justify-center items-center p-8">
                <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
            </div>
          ) : (
            <div className="overflow-x-auto">
              <table className="min-w-full">
                <thead >
                  <tr>
                    <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider">Service</th>
                    <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider">Vehicle</th>
                    <th scope="col" className="px-6 py-3 text-right text-xs font-medium text-slate-500 uppercase tracking-wider">Estimated Fare</th>
                  </tr>
                </thead>
                <tbody className="bg-white divide-y divide-slate-200">
                  {comparisons.map((item, index) => (
                    <tr key={index} className="hover:bg-slate-50/50 transition-colors">
                      <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-slate-900">{item.serviceType}</td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-slate-600">{item.vehicleType}</td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-right font-semibold text-blue-600">₹{Number(item.fareFor5Km || 0).toFixed(2)}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </Card>
      </div>
      <div className="lg:col-span-1">
         <AITripSuggestor />
      </div>
    </div>
  );
};

export default UserDashboard;
