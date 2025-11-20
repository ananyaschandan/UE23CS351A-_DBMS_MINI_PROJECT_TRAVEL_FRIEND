import express from 'express';
import { pool } from '../config/database.js';

const router = express.Router();

// Get service comparisons (5km base)
router.get('/service-comparisons', async (req, res) => {
  try {
    const [comparisons] = await pool.query(`
      SELECT 
        ServiceType as serviceType,
        VehicleType as vehicleType,
        ROUND(BaseFare + (PerKmRate * 5), 2) AS fareFor5Km
      FROM Fare
      WHERE ServiceType IN ('Ola', 'Uber', 'Rapido', 'Namma Yatri', 'Individual')
        AND VehicleType IN ('Auto', 'Cab', 'Bike')
      ORDER BY fareFor5Km ASC
    `);

    res.json(comparisons);
  } catch (error) {
    console.error('Error fetching service comparisons:', error);
    res.status(500).json({ error: 'Failed to fetch service comparisons' });
  }
});

// Get three route options
router.post('/route-options', async (req, res) => {
  try {
    const { startLocation, endLocation } = req.body;

    if (!startLocation || !endLocation) {
      return res.status(400).json({ error: 'Start and end locations are required' });
    }

    // Get route details from database
    const [routes] = await pool.query(
      'SELECT Distance, EstimatedTime FROM Route WHERE StartLocation = ? AND EndLocation = ? LIMIT 1',
      [startLocation, endLocation]
    );

    let distance, estimatedTime;

    if (routes.length > 0) {
      distance = parseFloat(routes[0].Distance);
      estimatedTime = parseInt(routes[0].EstimatedTime);
    } else {
      // Default values if route not found
      distance = 5.0;
      estimatedTime = 20;
    }

    // Calculate three route options with different characteristics
    const routeOptions = [
      {
        routeType: 'Shortest',
        distance: distance,
        estimatedTime: estimatedTime,
        estimatedFare: parseFloat((25 + (8 * distance) + (0.8 * estimatedTime)).toFixed(2)),
        recommendedService: 'Individual Auto',
        serviceType: 'Individual',
        vehicleType: 'Auto'
      },
      {
        routeType: 'Fastest',
        distance: distance + 0.2,
        estimatedTime: Math.max(estimatedTime - 5, 10),
        estimatedFare: parseFloat((55 + (11.5 * (distance + 0.2)) + (1.5 * Math.max(estimatedTime - 5, 10))).toFixed(2)),
        recommendedService: 'Uber Cab',
        serviceType: 'Uber',
        vehicleType: 'Cab'
      },
      {
        routeType: 'Cheapest',
        distance: distance + 0.8,
        estimatedTime: estimatedTime + 10,
        estimatedFare: parseFloat((10 + (2 * (distance + 0.8))).toFixed(2)),
        recommendedService: 'Rapido Bike',
        serviceType: 'Rapido',
        vehicleType: 'Bike'
      }
    ];

    res.json(routeOptions);
  } catch (error) {
    console.error('Error calculating route options:', error);
    res.status(500).json({ error: 'Failed to calculate route options' });
  }
});

// Get all available routes
router.get('/available-routes', async (req, res) => {
  try {
    const [routes] = await pool.query(`
      SELECT 
        RouteID as id,
        RouteName as name,
        StartLocation as startLocation,
        EndLocation as endLocation,
        Distance as distance,
        EstimatedTime as estimatedTime,
        RouteType as routeType
      FROM Route
      ORDER BY StartLocation, EndLocation
    `);

    res.json(routes);
  } catch (error) {
    console.error('Error fetching routes:', error);
    res.status(500).json({ error: 'Failed to fetch routes' });
  }
});

export default router;
