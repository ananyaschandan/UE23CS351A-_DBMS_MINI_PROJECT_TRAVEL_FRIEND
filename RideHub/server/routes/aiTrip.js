// =====================================================
// AI TRIP SUGGESTER WITH REDIS CACHING
// =====================================================

import express from 'express';
import { pool } from '../config/database.js';
import { redisUtils } from '../config/redis.js';
import { GoogleGenAI, Type } from "@google/genai";

const router = express.Router();

// Initialize Google AI
const ai = new GoogleGenAI({ apiKey: process.env.GEMINI_API_KEY });

// Mock data generator for when API quota is exceeded
function generateMockTripSuggestion(destination, interests) {
  const mockData = {
    "Bangalore": {
      "food and culture": {
        title: "Bangalore Food & Culture Discovery",
        summary: "Experience the vibrant culinary scene and rich cultural heritage of India's Silicon Valley through local markets, historic temples, and authentic eateries.",
        stops: [
          {
            name: "Lalbagh Botanical Garden",
            description: "Start your day at this historic 240-acre garden with beautiful flora and the iconic Glass House. Perfect for morning walks and photography.",
            timeOfDay: "Morning"
          },
          {
            name: "Bangalore Palace",
            description: "Explore this Tudor-style palace built in 1887, showcasing royal artifacts and stunning architecture reminiscent of Windsor Castle.",
            timeOfDay: "Morning"
          },
          {
            name: "KR Market (City Market)",
            description: "Immerse yourself in the bustling wholesale market famous for flowers, spices, and fresh produce. Experience authentic local life.",
            timeOfDay: "Afternoon"
          },
          {
            name: "MTR (Mavalli Tiffin Rooms)",
            description: "Savor traditional South Indian breakfast at this legendary 95-year-old restaurant known for authentic dosas and filter coffee.",
            timeOfDay: "Afternoon"
          },
          {
            name: "ISKCON Temple",
            description: "Visit this magnificent temple complex with beautiful architecture, spiritual ambiance, and panoramic city views.",
            timeOfDay: "Evening"
          },
          {
            name: "Commercial Street",
            description: "End your day shopping for traditional silk sarees, handicrafts, and enjoying street food in this vibrant shopping district.",
            timeOfDay: "Evening"
          }
        ]
      },
      "music": {
        title: "Bangalore Music & Nightlife Trail",
        summary: "Discover Bangalore's vibrant music scene from classical Carnatic traditions to modern indie rock, exploring venues that showcase the city's diverse musical heritage.",
        stops: [
          {
            name: "Chowdiah Memorial Hall",
            description: "Start with India's first violin-shaped auditorium, hosting classical Carnatic music concerts and cultural performances since 1980.",
            timeOfDay: "Morning"
          },
          {
            name: "Bangalore Music Academy",
            description: "Visit this prestigious institution that has nurtured classical musicians for decades, often hosting morning practice sessions and workshops.",
            timeOfDay: "Morning"
          },
          {
            name: "VR Bengaluru - Music Stores",
            description: "Explore music instrument shops and vinyl record stores, discovering both traditional Indian instruments and modern music gear.",
            timeOfDay: "Afternoon"
          },
          {
            name: "Hard Rock Cafe Bangalore",
            description: "Experience live music performances while enjoying international cuisine in this iconic music-themed restaurant.",
            timeOfDay: "Afternoon"
          },
          {
            name: "The Humming Tree",
            description: "End your day at Bangalore's premier live music venue, known for hosting indie bands, jazz performances, and acoustic nights.",
            timeOfDay: "Evening"
          },
          {
            name: "Toit Brewpub",
            description: "Enjoy craft beer with live music sessions, a popular spot for local musicians and music lovers to gather and jam.",
            timeOfDay: "Evening"
          }
        ]
      },
      "history and monuments": {
        title: "Bangalore Historical Heritage Trail",
        summary: "Discover the rich history of Bangalore through ancient temples, colonial architecture, and monuments that tell the story of this dynamic city.",
        stops: [
          {
            name: "Tipu Sultan's Summer Palace",
            description: "Explore the beautiful wooden palace of the Tiger of Mysore, showcasing Indo-Islamic architecture and historical artifacts.",
            timeOfDay: "Morning"
          },
          {
            name: "Bull Temple (Dodda Basavana Gudi)",
            description: "Visit this 16th-century temple housing a massive monolithic bull statue, one of Bangalore's oldest temples.",
            timeOfDay: "Morning"
          },
          {
            name: "Bangalore Fort",
            description: "Walk through the remnants of Kempe Gowda's mud fort and Hyder Ali's stone fortification, witnessing centuries of history.",
            timeOfDay: "Afternoon"
          }
        ]
      }
    },
    "Mumbai": {
      "beaches and nightlife": {
        title: "Mumbai Coastal Nightlife Experience",
        summary: "Dive into Mumbai's vibrant coastal culture, from iconic beaches to buzzing nightlife, experiencing the city that never sleeps.",
        stops: [
          {
            name: "Marine Drive",
            description: "Start with a morning walk along the Queen's Necklace, enjoying sea breeze and Art Deco architecture.",
            timeOfDay: "Morning"
          },
          {
            name: "Juhu Beach",
            description: "Experience Mumbai's most famous beach with street food, horse rides, and Bollywood celebrity spotting.",
            timeOfDay: "Afternoon"
          },
          {
            name: "Bandra Bandstand",
            description: "Enjoy sunset views and celebrity home spotting at this popular waterfront promenade.",
            timeOfDay: "Evening"
          }
        ]
      }
    },
    "Delhi": {
      "monuments and culture": {
        title: "Delhi Cultural Heritage Journey",
        summary: "Explore India's capital through its magnificent monuments, bustling markets, and rich Mughal heritage.",
        stops: [
          {
            name: "Red Fort",
            description: "Begin at this UNESCO World Heritage site, the main residence of Mughal emperors for 200 years.",
            timeOfDay: "Morning"
          },
          {
            name: "India Gate",
            description: "Visit this iconic war memorial and enjoy the surrounding gardens and street food vendors.",
            timeOfDay: "Afternoon"
          },
          {
            name: "Chandni Chowk",
            description: "Experience the chaos and charm of Old Delhi's famous market with authentic street food and shopping.",
            timeOfDay: "Evening"
          }
        ]
      }
    }
  };

  // Normalize destination and interests for lookup
  const normalizedDestination = destination.toLowerCase().trim();
  const normalizedInterests = interests.toLowerCase().trim();

  // Try to find exact match
  for (const [city, cityData] of Object.entries(mockData)) {
    if (city.toLowerCase().includes(normalizedDestination) || normalizedDestination.includes(city.toLowerCase())) {
      // Try to match interests with more flexibility
      for (const [interest, data] of Object.entries(cityData)) {
        const interestWords = interest.toLowerCase().split(/[\s,&]+/);
        const inputWords = normalizedInterests.toLowerCase().split(/[\s,&]+/);
        
        // Check if any interest word matches any input word
        const hasMatch = interestWords.some(iWord => 
          inputWords.some(inputWord => 
            iWord.includes(inputWord) || inputWord.includes(iWord)
          )
        );
        
        if (hasMatch) {
          console.log(`✅ Found match: ${city} + ${interest} for input: ${destination} + ${interests}`);
          return data;
        }
      }
      // Return first available data for the city if interests don't match
      console.log(`⚠️ No interest match found for ${city}, using default`);
      return Object.values(cityData)[0];
    }
  }

  // Generic fallback
  return {
    title: `${destination} Discovery Tour`,
    summary: `Explore the best of ${destination} with a focus on ${interests}. This curated itinerary combines must-see attractions with local experiences.`,
    stops: [
      {
        name: `${destination} City Center`,
        description: `Start your exploration at the heart of ${destination}, discovering local architecture and urban culture.`,
        timeOfDay: "Morning"
      },
      {
        name: `Local Market District`,
        description: `Experience authentic local life through traditional markets and street food, focusing on ${interests}.`,
        timeOfDay: "Afternoon"
      },
      {
        name: `Cultural Heritage Site`,
        description: `End your day at a significant cultural location that showcases the essence of ${destination}.`,
        timeOfDay: "Evening"
      }
    ]
  };
}

// Response schema for structured AI output
const responseSchema = {
  type: Type.OBJECT,
  properties: {
    title: { type: Type.STRING, description: "A catchy title for the trip plan." },
    summary: { type: Type.STRING, description: "A short, engaging summary of the suggested itinerary." },
    stops: {
      type: Type.ARRAY,
      description: "An array of stops for the itinerary.",
      items: {
        type: Type.OBJECT,
        properties: {
          name: { type: Type.STRING, description: "Name of the location or stop." },
          description: { type: Type.STRING, description: "A brief description of what to do or see at this stop." },
          timeOfDay: { type: Type.STRING, description: "Recommended time of day, e.g., 'Morning', 'Afternoon', 'Evening'." },
        },
        required: ["name", "description", "timeOfDay"],
      },
    },
  },
  required: ["title", "summary", "stops"],
};

// Generate AI trip suggestion with Redis caching
router.post('/generate', async (req, res) => {
  const startTime = Date.now();
  
  try {
    const { destination, interests, userId, sessionId } = req.body;
    
    // Validation
    if (!destination || !interests) {
      return res.status(400).json({ 
        error: 'Destination and interests are required' 
      });
    }

    // Generate cache key
    const cacheKey = redisUtils.generateTripKey(destination, interests);
    console.log(`🔍 Checking cache for key: ${cacheKey}`);

    // Try to get from cache first
    let cachedResult = await redisUtils.getCache(cacheKey);
    let cacheHit = false;
    let requestId = null;

    // Log request to database
    try {
      const [requestResult] = await pool.query(
        'CALL LogAITripRequest(?, ?, ?, ?, ?, ?, ?)',
        [
          userId || null,
          sessionId || `session_${Date.now()}`,
          destination,
          interests,
          req.ip,
          req.get('User-Agent'),
          cacheKey
        ]
      );
      requestId = requestResult[0][0].RequestID;
      console.log(`📝 Logged request with ID: ${requestId}`);
    } catch (dbError) {
      console.error('❌ Database logging error:', dbError);
    }

    let tripSuggestion = null;
    let generationTime = 0;

    if (cachedResult) {
      // Cache hit - return cached result
      console.log('✅ Cache hit - returning cached result');
      tripSuggestion = cachedResult;
      cacheHit = true;
      generationTime = (Date.now() - startTime) / 1000;
    } else {
      // Cache miss - generate new suggestion
      console.log('❌ Cache miss - generating new suggestion');
      
      const prompt = `Create a creative and practical one-day trip itinerary for someone visiting "${destination}" who is interested in "${interests}". The plan should be exciting and well-structured with local insights.`;

      try {
        const response = await ai.models.generateContent({
          model: "gemini-2.0-flash-exp",
          contents: prompt,
          config: {
            responseMimeType: "application/json",
            responseSchema,
            temperature: 0.8,
          },
        });

        const jsonString = response.text?.trim() || '';
        if (!jsonString) {
          throw new Error('Empty response from AI service');
        }

        tripSuggestion = JSON.parse(jsonString);
        generationTime = (Date.now() - startTime) / 1000;

        // Cache the result (24 hours expiration)
        await redisUtils.setCache(cacheKey, tripSuggestion, 86400);
        console.log(`💾 Cached result for key: ${cacheKey}`);

      } catch (aiError) {
        console.error('❌ AI generation error:', aiError);
        
        // FALLBACK: Use mock data if API fails
        console.log('🔄 Using fallback mock data due to API quota exceeded');
        
        tripSuggestion = generateMockTripSuggestion(destination, interests);
        generationTime = (Date.now() - startTime) / 1000;
        
        // Cache the mock result too
        await redisUtils.setCache(cacheKey, tripSuggestion, 3600); // 1 hour for mock data
        console.log(`💾 Cached mock result for key: ${cacheKey}`);
      }
    }

    // Log response to database
    if (requestId && tripSuggestion) {
      try {
        const expiresAt = new Date(Date.now() + (86400 * 1000)); // 24 hours from now
        
        await pool.query(
          'CALL LogAITripResponse(?, ?, ?, ?, ?, ?, ?, ?)',
          [
            requestId,
            tripSuggestion.title,
            tripSuggestion.summary,
            JSON.stringify(tripSuggestion.stops),
            generationTime,
            cacheHit,
            cacheKey,
            expiresAt
          ]
        );
        console.log(`📝 Logged response for request ID: ${requestId}`);
      } catch (dbError) {
        console.error('❌ Response logging error:', dbError);
      }
    }

    // Update cache statistics
    try {
      await pool.query(
        'CALL UpdateCacheStats(?, ?, ?, ?, ?)',
        [
          new Date().toISOString().split('T')[0], // Today's date
          cacheHit,
          generationTime,
          destination,
          interests.split(' ')[0] // First interest word
        ]
      );
    } catch (statsError) {
      console.error('❌ Stats update error:', statsError);
    }

    // Store user session data
    if (sessionId) {
      await redisUtils.setSession(sessionId, {
        lastDestination: destination,
        lastInterests: interests,
        lastRequestTime: new Date().toISOString(),
        requestCount: await redisUtils.increment(`user_requests:${sessionId}`)
      });
    }

    // Return response with metadata
    res.json({
      success: true,
      data: tripSuggestion,
      metadata: {
        requestId,
        cacheHit,
        generationTime: parseFloat(generationTime.toFixed(3)),
        cacheKey,
        timestamp: new Date().toISOString(),
        isMockData: tripSuggestion.title?.includes('Discovery') || false // Indicator for mock data
      }
    });

  } catch (error) {
    console.error('❌ AI Trip generation error:', error);
    res.status(500).json({ 
      error: 'Internal server error',
      details: error.message 
    });
  }
});

// Get user's AI trip history
router.get('/history/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    const { limit = 10, offset = 0 } = req.query;

    const [history] = await pool.query(`
      SELECT 
        atr.RequestID,
        atr.Destination,
        atr.Interests,
        atr.RequestTimestamp,
        atresp.Title,
        atresp.Summary,
        atresp.StopsData,
        atresp.CacheHit,
        atresp.GenerationTime
      FROM AITripRequests atr
      JOIN AITripResponses atresp ON atr.RequestID = atresp.RequestID
      WHERE atr.UserID = ?
      ORDER BY atr.RequestTimestamp DESC
      LIMIT ? OFFSET ?
    `, [userId, parseInt(limit), parseInt(offset)]);

    res.json({
      success: true,
      data: history.map(item => ({
        ...item,
        StopsData: JSON.parse(item.StopsData)
      })),
      pagination: {
        limit: parseInt(limit),
        offset: parseInt(offset),
        total: history.length
      }
    });

  } catch (error) {
    console.error('❌ History fetch error:', error);
    res.status(500).json({ error: 'Failed to fetch history' });
  }
});

// Get popular destinations
router.get('/popular-destinations', async (req, res) => {
  try {
    const [destinations] = await pool.query(`
      SELECT * FROM PopularDestinationsView
      LIMIT 10
    `);

    res.json({
      success: true,
      data: destinations
    });

  } catch (error) {
    console.error('❌ Popular destinations error:', error);
    res.status(500).json({ error: 'Failed to fetch popular destinations' });
  }
});

// Get cache performance analytics
router.get('/analytics/cache-performance', async (req, res) => {
  try {
    const [performance] = await pool.query(`
      SELECT * FROM CachePerformanceView
      ORDER BY Date DESC
      LIMIT 7
    `);

    // Get Redis stats
    const redisStats = await redisUtils.getCacheStats();

    res.json({
      success: true,
      data: {
        daily: performance,
        redis: redisStats,
        summary: {
          totalRequests: performance.reduce((sum, day) => sum + day.TotalRequests, 0),
          averageHitRate: performance.length > 0 ? 
            (performance.reduce((sum, day) => sum + day.HitRate, 0) / performance.length).toFixed(2) : 0,
          averageResponseTime: performance.length > 0 ?
            (performance.reduce((sum, day) => sum + day.AvgResponseTime, 0) / performance.length).toFixed(3) : 0
        }
      }
    });

  } catch (error) {
    console.error('❌ Analytics error:', error);
    res.status(500).json({ error: 'Failed to fetch analytics' });
  }
});

// Clear cache for specific destination/interests
router.delete('/cache/clear', async (req, res) => {
  try {
    const { destination, interests, pattern } = req.body;

    let deletedCount = 0;

    if (pattern) {
      // Clear by pattern
      deletedCount = await redisUtils.flushPattern(pattern);
    } else if (destination && interests) {
      // Clear specific cache
      const cacheKey = redisUtils.generateTripKey(destination, interests);
      const deleted = await redisUtils.deleteCache(cacheKey);
      deletedCount = deleted ? 1 : 0;
    } else {
      return res.status(400).json({ 
        error: 'Either provide destination+interests or pattern' 
      });
    }

    res.json({
      success: true,
      message: `Cleared ${deletedCount} cache entries`,
      deletedCount
    });

  } catch (error) {
    console.error('❌ Cache clear error:', error);
    res.status(500).json({ error: 'Failed to clear cache' });
  }
});

// Health check endpoint
router.get('/health', async (req, res) => {
  try {
    // Check database connection
    const [dbCheck] = await pool.query('SELECT 1 as status');
    
    // Check Redis connection
    const redisHealth = await redisUtils.exists('health_check');
    await redisUtils.setCache('health_check', { status: 'ok' }, 60);

    res.json({
      success: true,
      status: 'healthy',
      services: {
        database: dbCheck.length > 0 ? 'connected' : 'disconnected',
        redis: 'connected',
        ai: process.env.GEMINI_API_KEY ? 'configured' : 'not_configured'
      },
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    console.error('❌ Health check error:', error);
    res.status(500).json({ 
      success: false,
      status: 'unhealthy',
      error: error.message 
    });
  }
});

export default router;
