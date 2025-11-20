import express from 'express';
import { pool } from '../config/database.js';

const router = express.Router();

// Get all metro stations
router.get('/metro-stations', async (req, res) => {
  try {
    const [stations] = await pool.query(
      `SELECT 
        StationID,
        StationName,
        Location,
        LineColor,
        CreatedAt
       FROM MetroStation
       ORDER BY StationName`
    );

    res.json(stations);
  } catch (error) {
    console.error('Error fetching metro stations:', error);
    res.status(500).json({ error: 'Failed to fetch metro stations' });
  }
});

// Get metro schedules for a station
router.get('/metro-schedules/:stationId', async (req, res) => {
  try {
    const { stationId } = req.params;
    
    const [schedules] = await pool.query(
      `SELECT 
        s.ScheduleID,
        s.DepartureTime,
        s.ArrivalTime,
        r.StartLocation,
        r.EndLocation,
        r.Distance
       FROM Schedule s
       JOIN Route r ON s.RouteID = r.RouteID
       WHERE s.VehicleType = 'Metro'
       ORDER BY s.DepartureTime`
    );

    res.json(schedules);
  } catch (error) {
    console.error('Error fetching schedules:', error);
    res.status(500).json({ error: 'Failed to fetch schedules' });
  }
});

// Get all bus routes
router.get('/bus-routes', async (req, res) => {
  try {
    const [routes] = await pool.query(
      `SELECT 
        BusRouteID,
        RouteNumber,
        RouteName,
        StartLocation,
        EndLocation,
        Distance,
        EstimatedTime,
        Fare,
        Frequency,
        BusType,
        IsActive
       FROM BusRoute
       WHERE IsActive = TRUE
       ORDER BY RouteNumber`
    );

    res.json(routes);
  } catch (error) {
    console.error('Error fetching bus routes:', error);
    res.status(500).json({ error: 'Failed to fetch bus routes' });
  }
});

// Get bus routes from a location
router.get('/bus-routes/from/:location', async (req, res) => {
  try {
    const { location } = req.params;
    
    const [routes] = await pool.query(
      `SELECT 
        BusRouteID,
        RouteNumber,
        RouteName,
        StartLocation,
        EndLocation,
        Distance,
        EstimatedTime,
        Fare,
        BusType
       FROM BusRoute
       WHERE StartLocation LIKE ? AND IsActive = TRUE
       ORDER BY Fare ASC`,
      [`%${location}%`]
    );

    res.json(routes);
  } catch (error) {
    console.error('Error fetching bus routes:', error);
    res.status(500).json({ error: 'Failed to fetch bus routes' });
  }
});

// Get traffic conditions
router.get('/traffic', async (req, res) => {
  try {
    const [traffic] = await pool.query(
      `SELECT 
        tc.TrafficID,
        r.StartLocation,
        r.EndLocation,
        tc.Condition,
        tc.UpdatedAt
       FROM TrafficCondition tc
       JOIN Route r ON tc.RouteID = r.RouteID
       ORDER BY tc.UpdatedAt DESC`
    );

    res.json(traffic);
  } catch (error) {
    console.error('Error fetching traffic:', error);
    res.status(500).json({ error: 'Failed to fetch traffic conditions' });
  }
});

export default router;
