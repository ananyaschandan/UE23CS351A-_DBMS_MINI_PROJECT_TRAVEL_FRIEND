import express from 'express';
import { pool } from '../config/database.js';

const router = express.Router();

// Get provider's vehicles
router.get('/provider/:providerId', async (req, res) => {
  try {
    const { providerId } = req.params;

    const [vehicles] = await pool.query(
      `SELECT 
        VehicleID as id,
        VehicleNumber as vehicleNumber,
        Model as model,
        VehicleType as vehicleType,
        Capacity as capacity,
        IsAvailable as isAvailable,
        HourlyRate as hourlyRate
      FROM Vehicle
      WHERE ProviderID = ?
      ORDER BY VehicleID DESC`,
      [providerId]
    );

    res.json(vehicles);
  } catch (error) {
    console.error('Error fetching vehicles:', error);
    res.status(500).json({ error: 'Failed to fetch vehicles' });
  }
});

// Add a new vehicle
router.post('/provider/:providerId', async (req, res) => {
  try {
    const { providerId } = req.params;
    const { vehicleNumber, model, vehicleType, capacity, hourlyRate } = req.body;

    if (!vehicleNumber || !vehicleType || !capacity || !hourlyRate) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    const [result] = await pool.query(
      `INSERT INTO Vehicle 
       (ProviderID, VehicleNumber, Model, VehicleType, Capacity, HourlyRate, IsAvailable) 
       VALUES (?, ?, ?, ?, ?, ?, TRUE)`,
      [providerId, vehicleNumber, model || '', vehicleType, capacity, hourlyRate]
    );

    const newVehicle = {
      id: result.insertId,
      vehicleNumber,
      model: model || '',
      vehicleType,
      capacity: parseInt(capacity),
      hourlyRate: parseFloat(hourlyRate),
      isAvailable: true
    };

    res.status(201).json(newVehicle);
  } catch (error) {
    console.error('Error adding vehicle:', error);
    if (error.code === 'ER_DUP_ENTRY') {
      return res.status(409).json({ error: 'Vehicle number already exists' });
    }
    res.status(500).json({ error: 'Failed to add vehicle', details: error.message });
  }
});

// Update vehicle
router.put('/:vehicleId', async (req, res) => {
  try {
    const { vehicleId } = req.params;
    const { vehicleNumber, model, vehicleType, capacity, hourlyRate, isAvailable } = req.body;

    await pool.query(
      `UPDATE Vehicle 
       SET VehicleNumber = ?, Model = ?, VehicleType = ?, Capacity = ?, HourlyRate = ?, IsAvailable = ?
       WHERE VehicleID = ?`,
      [vehicleNumber, model, vehicleType, capacity, hourlyRate, isAvailable, vehicleId]
    );

    const updatedVehicle = {
      id: parseInt(vehicleId),
      vehicleNumber,
      model,
      vehicleType,
      capacity: parseInt(capacity),
      hourlyRate: parseFloat(hourlyRate),
      isAvailable
    };

    res.json(updatedVehicle);
  } catch (error) {
    console.error('Error updating vehicle:', error);
    res.status(500).json({ error: 'Failed to update vehicle' });
  }
});

// Toggle vehicle availability
router.patch('/:vehicleId/toggle-availability', async (req, res) => {
  try {
    const { vehicleId } = req.params;

    // Get current availability
    const [vehicles] = await pool.query(
      'SELECT IsAvailable FROM Vehicle WHERE VehicleID = ?',
      [vehicleId]
    );

    if (vehicles.length === 0) {
      return res.status(404).json({ error: 'Vehicle not found' });
    }

    const newAvailability = !vehicles[0].IsAvailable;

    // Update availability
    await pool.query(
      'UPDATE Vehicle SET IsAvailable = ? WHERE VehicleID = ?',
      [newAvailability, vehicleId]
    );

    res.json({ 
      id: parseInt(vehicleId),
      isAvailable: newAvailability,
      message: 'Vehicle availability updated successfully' 
    });
  } catch (error) {
    console.error('Error toggling vehicle availability:', error);
    res.status(500).json({ error: 'Failed to toggle vehicle availability' });
  }
});

// Delete vehicle
router.delete('/:vehicleId', async (req, res) => {
  try {
    const { vehicleId } = req.params;

    // Check if vehicle has any bookings
    const [bookings] = await pool.query(
      'SELECT COUNT(*) as count FROM Booking WHERE VehicleID = ?',
      [vehicleId]
    );

    if (bookings[0].count > 0) {
      return res.status(400).json({ 
        error: 'Cannot delete vehicle with existing bookings. Please set as unavailable instead.' 
      });
    }

    await pool.query('DELETE FROM Vehicle WHERE VehicleID = ?', [vehicleId]);

    res.json({ message: 'Vehicle deleted successfully' });
  } catch (error) {
    console.error('Error deleting vehicle:', error);
    res.status(500).json({ error: 'Failed to delete vehicle', details: error.message });
  }
});

export default router;
