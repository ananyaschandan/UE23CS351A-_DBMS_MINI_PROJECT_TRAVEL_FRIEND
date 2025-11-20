// =====================================================
// REDIS CONFIGURATION FOR AI TRIP SUGGESTER
// =====================================================

import Redis from 'ioredis';

// Redis configuration
const redisConfig = {
  host: process.env.REDIS_HOST || 'localhost',
  port: process.env.REDIS_PORT || 6379,
  password: process.env.REDIS_PASSWORD || null,
  db: process.env.REDIS_DB || 0,
  retryDelayOnFailover: 100,
  maxRetriesPerRequest: 3,
  lazyConnect: true,
  keepAlive: 30000,
  connectTimeout: 10000,
  commandTimeout: 5000,
};

// Create Redis client
const redis = new Redis(redisConfig);

// Redis event handlers
redis.on('connect', () => {
  console.log('🔴 Redis connected successfully');
});

redis.on('ready', () => {
  console.log('🔴 Redis is ready to accept commands');
});

redis.on('error', (error) => {
  console.error('❌ Redis connection error:', error);
});

redis.on('close', () => {
  console.log('🔴 Redis connection closed');
});

redis.on('reconnecting', () => {
  console.log('🔄 Redis reconnecting...');
});

// Redis utility functions
export const redisUtils = {
  // Generate cache key for AI trip suggestions
  generateTripKey: (destination, interests) => {
    const normalizedDestination = destination.toLowerCase().trim().replace(/\s+/g, '_');
    const normalizedInterests = interests.toLowerCase().trim().replace(/\s+/g, '_');
    return `ai_trip:${normalizedDestination}:${normalizedInterests}`;
  },

  // Generate session key
  generateSessionKey: (sessionId) => {
    return `session:${sessionId}`;
  },

  // Generate user analytics key
  generateUserAnalyticsKey: (userId) => {
    return `user_analytics:${userId}`;
  },

  // Set cache with expiration (default 24 hours)
  setCache: async (key, value, expireInSeconds = 86400) => {
    try {
      const serializedValue = JSON.stringify({
        data: value,
        timestamp: Date.now(),
        ttl: expireInSeconds
      });
      await redis.setex(key, expireInSeconds, serializedValue);
      console.log(`✅ Cache set for key: ${key}`);
      return true;
    } catch (error) {
      console.error('❌ Redis set error:', error);
      return false;
    }
  },

  // Get cache
  getCache: async (key) => {
    try {
      const cachedValue = await redis.get(key);
      if (!cachedValue) {
        console.log(`❌ Cache miss for key: ${key}`);
        return null;
      }
      
      const parsed = JSON.parse(cachedValue);
      console.log(`✅ Cache hit for key: ${key}`);
      return parsed.data;
    } catch (error) {
      console.error('❌ Redis get error:', error);
      return null;
    }
  },

  // Check if key exists
  exists: async (key) => {
    try {
      const exists = await redis.exists(key);
      return exists === 1;
    } catch (error) {
      console.error('❌ Redis exists error:', error);
      return false;
    }
  },

  // Delete cache
  deleteCache: async (key) => {
    try {
      await redis.del(key);
      console.log(`🗑️ Cache deleted for key: ${key}`);
      return true;
    } catch (error) {
      console.error('❌ Redis delete error:', error);
      return false;
    }
  },

  // Get cache TTL
  getTTL: async (key) => {
    try {
      const ttl = await redis.ttl(key);
      return ttl;
    } catch (error) {
      console.error('❌ Redis TTL error:', error);
      return -1;
    }
  },

  // Increment counter (for analytics)
  increment: async (key, expireInSeconds = 86400) => {
    try {
      const count = await redis.incr(key);
      if (count === 1) {
        await redis.expire(key, expireInSeconds);
      }
      return count;
    } catch (error) {
      console.error('❌ Redis increment error:', error);
      return 0;
    }
  },

  // Store user session data
  setSession: async (sessionId, userData, expireInSeconds = 3600) => {
    try {
      const key = redisUtils.generateSessionKey(sessionId);
      await redisUtils.setCache(key, userData, expireInSeconds);
      return true;
    } catch (error) {
      console.error('❌ Session set error:', error);
      return false;
    }
  },

  // Get user session data
  getSession: async (sessionId) => {
    try {
      const key = redisUtils.generateSessionKey(sessionId);
      return await redisUtils.getCache(key);
    } catch (error) {
      console.error('❌ Session get error:', error);
      return null;
    }
  },

  // Store analytics data
  storeAnalytics: async (type, data, expireInSeconds = 604800) => { // 7 days
    try {
      const key = `analytics:${type}:${Date.now()}`;
      await redisUtils.setCache(key, data, expireInSeconds);
      return key;
    } catch (error) {
      console.error('❌ Analytics store error:', error);
      return null;
    }
  },

  // Get cache statistics
  getCacheStats: async () => {
    try {
      const info = await redis.info('stats');
      const lines = info.split('\r\n');
      const stats = {};
      
      lines.forEach(line => {
        if (line.includes(':')) {
          const [key, value] = line.split(':');
          stats[key] = value;
        }
      });
      
      return {
        hits: parseInt(stats.keyspace_hits || 0),
        misses: parseInt(stats.keyspace_misses || 0),
        hitRate: stats.keyspace_hits && stats.keyspace_misses ? 
          ((parseInt(stats.keyspace_hits) / (parseInt(stats.keyspace_hits) + parseInt(stats.keyspace_misses))) * 100).toFixed(2) : 0
      };
    } catch (error) {
      console.error('❌ Cache stats error:', error);
      return { hits: 0, misses: 0, hitRate: 0 };
    }
  },

  // Flush specific pattern
  flushPattern: async (pattern) => {
    try {
      const keys = await redis.keys(pattern);
      if (keys.length > 0) {
        await redis.del(...keys);
        console.log(`🗑️ Deleted ${keys.length} keys matching pattern: ${pattern}`);
      }
      return keys.length;
    } catch (error) {
      console.error('❌ Flush pattern error:', error);
      return 0;
    }
  }
};

// Health check function
export const checkRedisHealth = async () => {
  try {
    await redis.ping();
    return { status: 'healthy', message: 'Redis is responding' };
  } catch (error) {
    return { status: 'unhealthy', message: error.message };
  }
};

// Graceful shutdown
export const closeRedis = async () => {
  try {
    await redis.quit();
    console.log('🔴 Redis connection closed gracefully');
  } catch (error) {
    console.error('❌ Error closing Redis connection:', error);
  }
};

export default redis;
