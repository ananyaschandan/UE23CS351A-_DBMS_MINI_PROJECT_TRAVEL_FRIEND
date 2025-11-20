import React, { useState, useEffect, useCallback } from 'react';
import { User, Vehicle } from '../types';
import { api } from '../services/api';
import Card from '../components/Card';
import Button from '../components/Button';
import Modal from '../components/Modal';

interface ProviderDashboardProps {
  user: User;
}

const VehicleForm: React.FC<{
  vehicle: Partial<Vehicle> | null,
  onSave: (vehicle: Omit<Vehicle, 'id'> | Vehicle) => void,
  onCancel: () => void,
}> = ({ vehicle, onSave, onCancel }) => {
  const [formData, setFormData] = useState({
    vehicleNumber: vehicle?.vehicleNumber || '',
    model: vehicle?.model || '',
    vehicleType: vehicle?.vehicleType || 'Cab',
    capacity: vehicle?.capacity || 4,
    hourlyRate: (vehicle as any)?.hourlyRate || 100,
    isAvailable: vehicle?.isAvailable ?? true,
  });

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
    const { name, value, type } = e.target;
    if (type === 'checkbox') {
        const { checked } = e.target as HTMLInputElement;
        setFormData(prev => ({ ...prev, [name]: checked }));
    } else {
        const numericFields = ['capacity', 'hourlyRate'];
        setFormData(prev => ({ ...prev, [name]: numericFields.includes(name) ? parseFloat(value) : value }));
    }
  };
  
  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (vehicle && 'id' in vehicle) {
      onSave({ ...formData, id: vehicle.id as number });
    } else {
      onSave(formData as Omit<Vehicle, 'id'>);
    }
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <div>
        <label className="block text-sm font-medium text-slate-700">Vehicle Number</label>
        <input type="text" name="vehicleNumber" value={formData.vehicleNumber} onChange={handleChange} required className="mt-1 w-full bg-slate-50 border border-slate-300 rounded-md p-2 text-slate-900 focus:ring-blue-500 focus:border-blue-500"/>
      </div>
      <div>
        <label className="block text-sm font-medium text-slate-700">Model</label>
        <input type="text" name="model" value={formData.model} onChange={handleChange} required className="mt-1 w-full bg-slate-50 border border-slate-300 rounded-md p-2 text-slate-900 focus:ring-blue-500 focus:border-blue-500"/>
      </div>
       <div>
        <label className="block text-sm font-medium text-slate-700">Vehicle Type</label>
        <select name="vehicleType" value={formData.vehicleType} onChange={handleChange} className="mt-1 w-full bg-slate-50 border border-slate-300 rounded-md p-2 text-slate-900 focus:ring-blue-500 focus:border-blue-500">
          <option>Cab</option>
          <option>Auto</option>
          <option>Bike</option>
        </select>
      </div>
       <div>
        <label className="block text-sm font-medium text-slate-700">Capacity</label>
        <input type="number" name="capacity" value={formData.capacity} onChange={handleChange} required min="1" className="mt-1 w-full bg-slate-50 border border-slate-300 rounded-md p-2 text-slate-900 focus:ring-blue-500 focus:border-blue-500"/>
      </div>
      <div>
        <label className="block text-sm font-medium text-slate-700">Hourly Rate (₹)</label>
        <input type="number" name="hourlyRate" value={formData.hourlyRate} onChange={handleChange} required min="1" step="0.01" className="mt-1 w-full bg-slate-50 border border-slate-300 rounded-md p-2 text-slate-900 focus:ring-blue-500 focus:border-blue-500"/>
      </div>
      <div className="flex justify-end space-x-3 pt-2">
        <Button type="button" variant="secondary" onClick={onCancel}>Cancel</Button>
        <Button type="submit">Save Vehicle</Button>
      </div>
    </form>
  )
}

const ProviderDashboard: React.FC<ProviderDashboardProps> = ({ user }) => {
  const [vehicles, setVehicles] = useState<Vehicle[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingVehicle, setEditingVehicle] = useState<Partial<Vehicle> | null>(null);

  const fetchVehicles = useCallback(async () => {
    setIsLoading(true);
    try {
      const providerId = user.providerId || user.id;
      const data = await api.getProviderVehicles(providerId);
      setVehicles(data);
    } catch (error) {
      console.error("Failed to fetch vehicles", error);
      alert('Failed to load vehicles. Please try again.');
    } finally {
      setIsLoading(false);
    }
  }, [user.id, user.providerId]);

  useEffect(() => {
    fetchVehicles();
  }, [fetchVehicles]);

  const handleSaveVehicle = async (vehicleData: Omit<Vehicle, 'id'> | Vehicle) => {
    try {
      const providerId = user.providerId || user.id;
      if ('id' in vehicleData) {
        await api.updateVehicle(providerId, vehicleData);
      } else {
        await api.addVehicle(providerId, vehicleData);
      }
      fetchVehicles();
      setIsModalOpen(false);
      setEditingVehicle(null);
    } catch (error) {
      console.error("Failed to save vehicle", error);
      alert('Failed to save vehicle. Please try again.');
    }
  };
  
  const handleToggleAvailability = async (vehicleId: number) => {
    try {
      const providerId = user.providerId || user.id;
      await api.toggleVehicleAvailability(providerId, vehicleId);
      fetchVehicles();
    } catch (error) {
      console.error("Failed to toggle availability", error);
      alert('Failed to update vehicle status. Please try again.');
    }
  };

  const handleDeleteVehicle = async (vehicleId: number, vehicleNumber: string) => {
    if (confirm(`Are you sure you want to delete vehicle ${vehicleNumber}? This action cannot be undone.`)) {
      try {
        await api.deleteVehicle(vehicleId);
        fetchVehicles();
        alert('Vehicle deleted successfully!');
      } catch (error: any) {
        console.error("Failed to delete vehicle", error);
        alert(error.message || 'Failed to delete vehicle. It may have existing bookings.');
      }
    }
  };

  return (
    <>
      <div className="max-w-6xl mx-auto">
        <div className="flex justify-between items-center mb-6">
          <h2 className="text-3xl font-bold text-slate-900">My Vehicles</h2>
          <Button onClick={() => { setEditingVehicle({}); setIsModalOpen(true); }}>Add New Vehicle</Button>
        </div>
        {isLoading ? (
          <div className="text-center p-8 text-slate-600">Loading vehicles...</div>
        ) : (
          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
            {vehicles.map(vehicle => (
              <Card key={vehicle.id} className="flex flex-col justify-between">
                <div>
                  <div className="flex justify-between items-start">
                    <h3 className="text-lg font-bold text-slate-900">{vehicle.model}</h3>
                    <span className={`px-2 py-1 text-xs font-semibold rounded-full ${vehicle.isAvailable ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'}`}>
                      {vehicle.isAvailable ? 'Available' : 'Unavailable'}
                    </span>
                  </div>
                  <p className="text-slate-500">{vehicle.vehicleNumber} - {vehicle.vehicleType}</p>
                  <p className="text-sm text-slate-600 mt-2">Capacity: {vehicle.capacity} passengers</p>
                </div>
                <div className="flex justify-end space-x-2 mt-4">
                  <Button variant="secondary" onClick={() => handleToggleAvailability(vehicle.id)}>Toggle Status</Button>
                  <Button variant="secondary" onClick={() => { setEditingVehicle(vehicle); setIsModalOpen(true); }}>Edit</Button>
                  <Button variant="secondary" onClick={() => handleDeleteVehicle(vehicle.id, vehicle.vehicleNumber)} className="bg-red-100 text-red-800 hover:bg-red-200">Delete</Button>
                </div>
              </Card>
            ))}
          </div>
        )}
      </div>

      <Modal isOpen={isModalOpen} onClose={() => setIsModalOpen(false)} title={editingVehicle && 'id' in editingVehicle ? 'Edit Vehicle' : 'Add Vehicle'}>
        <VehicleForm 
            vehicle={editingVehicle}
            onSave={handleSaveVehicle}
            onCancel={() => { setIsModalOpen(false); setEditingVehicle(null); }}
        />
      </Modal>
    </>
  );
};

export default ProviderDashboard;
