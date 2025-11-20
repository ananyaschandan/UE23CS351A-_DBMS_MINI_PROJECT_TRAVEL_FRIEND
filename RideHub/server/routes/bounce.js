import express from 'express';
import { pool } from '../config/database.js';

const router = express.Router();

// Get all Bounce centers
router.get('/centers', async (req, res) => {
  try {
    const [centers] = await pool.query(
      `SELECT 
        CenterID,
        CenterName,
        Location,
        Area,
        Latitude,
        Longitude,
        AvailableScooters,
        IsActive,
        CreatedAt
       FROM BounceCenter
       WHERE IsActive = TRUE
       ORDER BY CenterName`
    );

    res.json(centers);
  } catch (error) {
    console.error('Error fetching Bounce centers:', error);
    res.status(500).json({ error: 'Failed to fetch Bounce centers' });
  }
});

// Get nearby Bounce centers
router.get('/nearby', async (req, res) => {
  try {
    const { lat, lng, radius } = req.query;

    if (!lat || !lng) {
      return res.status(400).json({ error: 'Latitude and longitude required' });
    }

    const radiusKm = parseFloat(radius) || 5; // Default 5km radius

    const [centers] = await pool.query(
      `SELECT 
        CenterID,
        CenterName,
        Location,
        Area,
        Latitude,
        Longitude,
        AvailableScooters,
        (6371 * acos(
          cos(radians(?)) * cos(radians(Latitude)) *
          cos(radians(Longitude) - radians(?)) +
          sin(radians(?)) * sin(radians(Latitude))
        )) AS distance
       FROM BounceCenter
       WHERE IsActive = TRUE
       HAVING distance <= ?
       ORDER BY distance ASC`,
      [lat, lng, lat, radiusKm]
    );

    res.json(centers);
  } catch (error) {
    console.error('Error fetching nearby centers:', error);
    res.status(500).json({ error: 'Failed to fetch nearby centers' });
  }
});

// Get Bounce center by ID
router.get('/centers/:id', async (req, res) => {
  try {
    const { id } = req.params;

    const [centers] = await pool.query(
      `SELECT 
        CenterID,
        CenterName,
        Location,
        Area,
        Latitude,
        Longitude,
        AvailableScooters,
        IsActive
       FROM BounceCenter
       WHERE CenterID = ?`,
      [id]
    );

    if (centers.length === 0) {
      return res.status(404).json({ error: 'Center not found' });
    }

    res.json(centers[0]);
  } catch (error) {
    console.error('Error fetching center:', error);
    res.status(500).json({ error: 'Failed to fetch center' });
  }
});

// Update scooter availability
router.patch('/centers/:id/availability', async (req, res) => {
  try {
    const { id } = req.params;
    const { availableScooters } = req.body;

    if (availableScooters === undefined) {
      return res.status(400).json({ error: 'Available scooters count required' });
    }

    await pool.query(
      'UPDATE BounceCenter SET AvailableScooters = ? WHERE CenterID = ?',
      [availableScooters, id]
    );

    res.json({ 
      success: true, 
      message: 'Availability updated',
      availableScooters 
    });
  } catch (error) {
    console.error('Error updating availability:', error);
    res.status(500).json({ error: 'Failed to update availability' });
  }
});

export default router;
