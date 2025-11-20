import express from 'express';
import multer from 'multer';
import { pool } from '../config/database.js';

const router = express.Router();

// Configure multer for image upload (memory storage for BLOB)
const storage = multer.memoryStorage();
const upload = multer({ 
  storage: storage,
  limits: { fileSize: 10 * 1024 * 1024 }, // 10MB limit
  fileFilter: (req, file, cb) => {
    if (file.mimetype.startsWith('image/')) {
      cb(null, true);
    } else {
      cb(new Error('Only image files are allowed!'));
    }
  }
});

// =====================================================
// GET ALL METRO STATIONS
// =====================================================

router.get('/stations', async (req, res) => {
  try {
    console.log('\n=== Fetching all metro stations ===');
    
    const [stations] = await pool.query(`
      SELECT 
        StationID,
        StationName,
        StationCode,
        LineColor,
        Location,
        IsInterchange,
        StationOrder,
        FirstTrain,
        LastTrain
      FROM MetroStation
      ORDER BY LineColor, StationOrder
    `);

    console.log(`Found ${stations.length} metro stations`);
    
    // Group by line
    const stationsByLine = {
      Purple: stations.filter(s => s.LineColor === 'Purple'),
      Green: stations.filter(s => s.LineColor === 'Green')
    };

    res.json({
      success: true,
      total: stations.length,
      stations: stations,
      byLine: stationsByLine
    });

  } catch (error) {
    console.error('Error fetching metro stations:', error);
    res.status(500).json({ 
      success: false,
      error: 'Failed to fetch metro stations' 
    });
  }
});

// =====================================================
// GET STATIONS BY LINE
// =====================================================

router.get('/stations/line/:lineColor', async (req, res) => {
  try {
    const { lineColor } = req.params;
    console.log(`\n=== Fetching ${lineColor} line stations ===`);

    const [stations] = await pool.query(`
      SELECT 
        StationID,
        StationName,
        StationCode,
        LineColor,
        Location,
        IsInterchange,
        StationOrder
      FROM MetroStation
      WHERE LineColor = ?
      ORDER BY StationOrder
    `, [lineColor]);

    console.log(`Found ${stations.length} stations on ${lineColor} line`);

    res.json({
      success: true,
      line: lineColor,
      count: stations.length,
      stations: stations
    });

  } catch (error) {
    console.error('Error fetching line stations:', error);
    res.status(500).json({ 
      success: false,
      error: 'Failed to fetch line stations' 
    });
  }
});

// =====================================================
// FIND METRO ROUTE
// =====================================================

router.post('/find-route', async (req, res) => {
  try {
    const { fromStation, toStation } = req.body;
    
    console.log('\n=== Finding Metro Route ===');
    console.log(`From: ${fromStation}`);
    console.log(`To: ${toStation}`);

    if (!fromStation || !toStation) {
      return res.status(400).json({
        success: false,
        error: 'Please provide both fromStation and toStation'
      });
    }

    if (fromStation === toStation) {
      return res.json({
        success: true,
        message: 'Source and destination are the same',
        route: {
          fromStation,
          toStation,
          distance: 0,
          time: 0,
          fare: 0,
          stops: 0,
          interchangeAt: null,
          routeInstructions: 'You are already at your destination!',
          firstTrain: '05:00 AM',
          lastTrain: '11:00 PM',
          stationSequence: []
        }
      });
    }

    // STEP 1: Try to fetch from MetroRoutes table (pre-calculated data)
    console.log('Checking MetroRoutes table...');
    const [routes] = await pool.query(`
      SELECT 
        FromStation,
        ToStation,
        Distance,
        EstimatedTime,
        NumberOfStops,
        EstimatedFare,
        InterchangeAt,
        RouteInstructions,
        LineColor
      FROM MetroRoutes
      WHERE FromStation = ? AND ToStation = ?
      LIMIT 1
    `, [fromStation, toStation]);

    let routeData;
    let useStoredProcedure = false;

    if (routes.length > 0) {
      // Found in MetroRoutes table - use this data
      console.log('✅ Route found in MetroRoutes table');
      routeData = {
        FromStation: routes[0].FromStation,
        ToStation: routes[0].ToStation,
        Distance_KM: routes[0].Distance,
        EstimatedTime_Minutes: routes[0].EstimatedTime,
        NumberOfStops: routes[0].NumberOfStops,
        EstimatedFare_Rupees: routes[0].EstimatedFare,
        InterchangeAt: routes[0].InterchangeAt,
        RouteInstructions: routes[0].RouteInstructions,
        FirstTrain: '05:00 AM (07:00 AM on Sundays)',
        LastTrain: '11:00 PM'
      };
    } else {
      // STEP 2: Fallback to stored procedure for dynamic calculation
      console.log('⚠️ Route not found in MetroRoutes table, using stored procedure...');
      useStoredProcedure = true;
      
      try {
        const [results] = await pool.query('CALL FindMetroRoute(?, ?)', [fromStation, toStation]);
        routeData = results[0][0];
        
        if (!routeData || routeData.Message) {
          return res.status(404).json({
            success: false,
            error: routeData?.Message || 'Route not found. Please check station names.'
          });
        }
      } catch (procError) {
        console.error('Stored procedure error:', procError);
        return res.status(404).json({
          success: false,
          error: 'Route not found. Please check station names or add this route to the database.'
        });
      }
    }

    console.log('Route found:', {
      from: routeData.FromStation,
      to: routeData.ToStation,
      distance: routeData.Distance_KM,
      time: routeData.EstimatedTime_Minutes,
      fare: routeData.EstimatedFare_Rupees,
      stops: routeData.NumberOfStops
    });

    // Get detailed station sequence
    const [fromStationData] = await pool.query(
      'SELECT StationID, LineColor, StationOrder FROM MetroStation WHERE StationName = ?',
      [fromStation]
    );
    
    const [toStationData] = await pool.query(
      'SELECT StationID, LineColor, StationOrder FROM MetroStation WHERE StationName = ?',
      [toStation]
    );

    let stationSequence = [];
    
    if (fromStationData.length > 0 && toStationData.length > 0) {
      const fromLine = fromStationData[0].LineColor;
      const toLine = toStationData[0].LineColor;
      const fromOrder = fromStationData[0].StationOrder;
      const toOrder = toStationData[0].StationOrder;

      if (fromLine === toLine) {
        // Same line - get all stations between
        const [stations] = await pool.query(`
          SELECT StationName, StationCode, LineColor, StationOrder
          FROM MetroStation
          WHERE LineColor = ?
            AND StationOrder BETWEEN LEAST(?, ?) AND GREATEST(?, ?)
          ORDER BY CASE WHEN ? < ? THEN StationOrder ELSE -StationOrder END
        `, [fromLine, fromOrder, toOrder, fromOrder, toOrder, fromOrder, toOrder]);
        
        stationSequence = stations;
      } else {
        // Different lines - route via interchange (Majestic)
        const [leg1Stations] = await pool.query(`
          SELECT StationName, StationCode, LineColor, StationOrder
          FROM MetroStation
          WHERE LineColor = ?
            AND StationOrder BETWEEN LEAST(?, (SELECT StationOrder FROM MetroStation WHERE StationName = 'Majestic' AND LineColor = ?)) 
            AND GREATEST(?, (SELECT StationOrder FROM MetroStation WHERE StationName = 'Majestic' AND LineColor = ?))
          ORDER BY CASE WHEN ? < (SELECT StationOrder FROM MetroStation WHERE StationName = 'Majestic' AND LineColor = ?) 
                   THEN StationOrder ELSE -StationOrder END
        `, [fromLine, fromOrder, fromLine, fromOrder, fromLine, fromOrder, fromLine]);

        const [leg2Stations] = await pool.query(`
          SELECT StationName, StationCode, LineColor, StationOrder
          FROM MetroStation
          WHERE LineColor = ?
            AND StationOrder BETWEEN LEAST((SELECT StationOrder FROM MetroStation WHERE StationName = 'Majestic' AND LineColor = ?), ?) 
            AND GREATEST((SELECT StationOrder FROM MetroStation WHERE StationName = 'Majestic' AND LineColor = ?), ?)
          ORDER BY CASE WHEN (SELECT StationOrder FROM MetroStation WHERE StationName = 'Majestic' AND LineColor = ?) < ? 
                   THEN StationOrder ELSE -StationOrder END
        `, [toLine, toLine, toOrder, toLine, toOrder, toLine, toOrder]);

        stationSequence = [...leg1Stations, ...leg2Stations.slice(1)]; // Remove duplicate Majestic
      }
    }

    const response = {
      success: true,
      route: {
        fromStation: routeData.FromStation,
        toStation: routeData.ToStation,
        distance: parseFloat(routeData.Distance_KM) || 0,
        time: parseInt(routeData.EstimatedTime_Minutes) || 0,
        fare: parseFloat(routeData.EstimatedFare_Rupees) || 0,
        stops: parseInt(routeData.NumberOfStops) || 0,
        interchangeAt: routeData.InterchangeAt,
        routeInstructions: routeData.RouteInstructions,
        firstTrain: routeData.FirstTrain || '05:00 AM (07:00 AM on Sundays)',
        lastTrain: routeData.LastTrain || '11:00 PM',
        stationSequence: stationSequence
      }
    };

    console.log('=== Route calculation complete ===\n');

    res.json(response);

  } catch (error) {
    console.error('Error finding metro route:', error);
    console.error('Error stack:', error.stack);
    res.status(500).json({ 
      success: false,
      error: 'Failed to find metro route. Please try again.' 
    });
  }
});

// =====================================================
// GET INTERCHANGE STATIONS
// =====================================================

router.get('/interchange-stations', async (req, res) => {
  try {
    const [stations] = await pool.query(`
      SELECT 
        StationID,
        StationName,
        StationCode,
        LineColor,
        Location
      FROM MetroStation
      WHERE IsInterchange = TRUE
      ORDER BY StationName
    `);

    res.json({
      success: true,
      count: stations.length,
      stations: stations
    });

  } catch (error) {
    console.error('Error fetching interchange stations:', error);
    res.status(500).json({ 
      success: false,
      error: 'Failed to fetch interchange stations' 
    });
  }
});

// =====================================================
// GET METRO STATISTICS
// =====================================================

router.get('/statistics', async (req, res) => {
  try {
    const [totalStations] = await pool.query('SELECT COUNT(*) as count FROM MetroStation');
    const [purpleStations] = await pool.query('SELECT COUNT(*) as count FROM MetroStation WHERE LineColor = "Purple"');
    const [greenStations] = await pool.query('SELECT COUNT(*) as count FROM MetroStation WHERE LineColor = "Green"');
    const [interchangeStations] = await pool.query('SELECT COUNT(*) as count FROM MetroStation WHERE IsInterchange = TRUE');
    const [totalConnections] = await pool.query('SELECT COUNT(*) as count FROM MetroConnection');

    res.json({
      success: true,
      statistics: {
        totalStations: totalStations[0].count,
        purpleLineStations: purpleStations[0].count,
        greenLineStations: greenStations[0].count,
        interchangeStations: interchangeStations[0].count,
        totalConnections: totalConnections[0].count
      }
    });

  } catch (error) {
    console.error('Error fetching metro statistics:', error);
    res.status(500).json({ 
      success: false,
      error: 'Failed to fetch statistics' 
    });
  }
});

// =====================================================
// UPLOAD METRO MAP IMAGE (BLOB)
// =====================================================

router.post('/upload-map', upload.single('mapImage'), async (req, res) => {
  try {
    console.log('\n=== Uploading Metro Map Image ===');
    
    if (!req.file) {
      return res.status(400).json({
        success: false,
        error: 'No image file provided'
      });
    }

    const { mapName, mapDescription } = req.body;
    const imageData = req.file.buffer;
    const imageType = req.file.mimetype;
    const imageSize = req.file.size;

    console.log(`Image: ${mapName || 'Metro Map'}`);
    console.log(`Type: ${imageType}`);
    console.log(`Size: ${(imageSize / 1024).toFixed(2)} KB`);

    // Deactivate previous maps
    await pool.query('UPDATE MetroMapImage SET IsActive = FALSE WHERE IsActive = TRUE');

    // Insert new map
    const [result] = await pool.query(
      `INSERT INTO MetroMapImage (MapName, MapDescription, ImageData, ImageType, ImageSize, IsActive) 
       VALUES (?, ?, ?, ?, ?, TRUE)`,
      [mapName || 'Bangalore Metro Map', mapDescription || 'Official Bangalore Metro Network Map', imageData, imageType, imageSize]
    );

    console.log(`✅ Metro map uploaded successfully (ID: ${result.insertId})`);

    res.json({
      success: true,
      message: 'Metro map uploaded successfully',
      mapId: result.insertId,
      size: imageSize
    });

  } catch (error) {
    console.error('Error uploading metro map:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to upload metro map'
    });
  }
});

// =====================================================
// GET METRO MAP IMAGE (BLOB)
// =====================================================

router.get('/map-image', async (req, res) => {
  try {
    console.log('\n=== Fetching Metro Map Image ===');

    const [maps] = await pool.query(
      `SELECT MapID, MapName, ImageData, ImageType, ImageSize, UploadedAt 
       FROM MetroMapImage 
       WHERE IsActive = TRUE 
       ORDER BY UploadedAt DESC 
       LIMIT 1`
    );

    if (maps.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'No metro map found. Please upload a map first.'
      });
    }

    const map = maps[0];
    console.log(`Found map: ${map.MapName} (${(map.ImageSize / 1024).toFixed(2)} KB)`);

    // Set appropriate headers
    res.set({
      'Content-Type': map.ImageType,
      'Content-Length': map.ImageSize,
      'Cache-Control': 'public, max-age=86400' // Cache for 24 hours
    });

    // Send the BLOB data
    res.send(map.ImageData);

  } catch (error) {
    console.error('Error fetching metro map:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch metro map'
    });
  }
});

// =====================================================
// GET METRO MAP METADATA
// =====================================================

router.get('/map-info', async (req, res) => {
  try {
    const [maps] = await pool.query(
      `SELECT MapID, MapName, MapDescription, ImageType, ImageSize, UploadedAt 
       FROM MetroMapImage 
       WHERE IsActive = TRUE 
       ORDER BY UploadedAt DESC 
       LIMIT 1`
    );

    if (maps.length === 0) {
      return res.json({
        success: true,
        hasMap: false,
        message: 'No metro map uploaded yet'
      });
    }

    const map = maps[0];

    res.json({
      success: true,
      hasMap: true,
      map: {
        id: map.MapID,
        name: map.MapName,
        description: map.MapDescription,
        type: map.ImageType,
        size: map.ImageSize,
        sizeKB: (map.ImageSize / 1024).toFixed(2),
        uploadedAt: map.UploadedAt
      }
    });

  } catch (error) {
    console.error('Error fetching map info:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch map info'
    });
  }
});

export default router;
