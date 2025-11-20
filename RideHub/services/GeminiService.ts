
import { TripSuggestion } from "../types";

// Generate session ID for tracking
const generateSessionId = (): string => {
  return `session_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
};

// Get or create session ID
const getSessionId = (): string => {
  let sessionId = sessionStorage.getItem('ai_trip_session_id');
  if (!sessionId) {
    sessionId = generateSessionId();
    sessionStorage.setItem('ai_trip_session_id', sessionId);
  }
  return sessionId;
};

// Get user ID from localStorage (if logged in)
const getUserId = (): number | null => {
  const userData = localStorage.getItem('user');
  if (userData) {
    try {
      const user = JSON.parse(userData);
      return user.id || null;
    } catch {
      return null;
    }
  }
  return null;
};

export const generateTripSuggestion = async (
  destination: string, 
  interests: string
): Promise<{ suggestion: TripSuggestion; metadata: any } | null> => {
  try {
    console.log(`🤖 Generating AI trip suggestion for: ${destination} (${interests})`);
    
    const sessionId = getSessionId();
    const userId = getUserId();
    
    console.log(`📱 Session ID: ${sessionId}`);
    console.log(`👤 User ID: ${userId || 'Anonymous'}`);

    const response = await fetch('http://localhost:5000/api/ai-trip/generate', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        destination,
        interests,
        userId,
        sessionId
      })
    });

    if (!response.ok) {
      const errorData = await response.json();
      console.error('❌ AI Trip API error:', errorData);
      throw new Error(`HTTP ${response.status}: ${errorData.error || 'Unknown error'}`);
    }

    const result = await response.json();
    
    if (!result.success) {
      console.error('❌ AI Trip generation failed:', result.error);
      return null;
    }

    console.log('✅ AI Trip suggestion generated successfully');
    console.log(`📊 Cache hit: ${result.metadata.cacheHit}`);
    console.log(`⏱️ Generation time: ${result.metadata.generationTime}s`);
    console.log(`🔑 Cache key: ${result.metadata.cacheKey}`);

    // Store metadata in sessionStorage for analytics
    const metadata = {
      requestId: result.metadata.requestId,
      cacheHit: result.metadata.cacheHit,
      generationTime: result.metadata.generationTime,
      timestamp: result.metadata.timestamp
    };
    
    sessionStorage.setItem('last_ai_trip_metadata', JSON.stringify(metadata));

    return {
      suggestion: result.data as TripSuggestion,
      metadata: result.metadata
    };

  } catch (error) {
    console.error("❌ Error generating trip suggestion:", error);
    
    // Fallback: Try to get from local cache if available
    const cacheKey = `local_cache:${destination}:${interests}`;
    const cachedData = localStorage.getItem(cacheKey);
    
    if (cachedData) {
      try {
        const parsed = JSON.parse(cachedData);
        console.log('📦 Using local fallback cache');
        return {
          suggestion: parsed as TripSuggestion,
          metadata: { cacheHit: true, isMockData: false, generationTime: 0 }
        };
      } catch {
        // Ignore cache parsing errors
      }
    }
    
    return null;
  }
};

// Get user's AI trip history
export const getAITripHistory = async (limit: number = 10, offset: number = 0) => {
  try {
    const userId = getUserId();
    if (!userId) {
      console.log('👤 No user logged in, cannot fetch history');
      return { success: false, error: 'User not logged in' };
    }

    const response = await fetch(
      `http://localhost:5000/api/ai-trip/history/${userId}?limit=${limit}&offset=${offset}`
    );

    if (!response.ok) {
      throw new Error(`HTTP ${response.status}`);
    }

    const result = await response.json();
    console.log(`📚 Fetched ${result.data.length} AI trip history items`);
    
    return result;

  } catch (error) {
    console.error('❌ Error fetching AI trip history:', error);
    return { success: false, error: error instanceof Error ? error.message : 'Unknown error' };
  }
};

// Get popular destinations
export const getPopularDestinations = async () => {
  try {
    const response = await fetch('http://localhost:5000/api/ai-trip/popular-destinations');

    if (!response.ok) {
      throw new Error(`HTTP ${response.status}`);
    }

    const result = await response.json();
    console.log(`🌟 Fetched ${result.data.length} popular destinations`);
    
    return result;

  } catch (error) {
    console.error('❌ Error fetching popular destinations:', error);
    return { success: false, error: error instanceof Error ? error.message : 'Unknown error' };
  }
};

// Get cache performance analytics
export const getCacheAnalytics = async () => {
  try {
    const response = await fetch('http://localhost:5000/api/ai-trip/analytics/cache-performance');

    if (!response.ok) {
      throw new Error(`HTTP ${response.status}`);
    }

    const result = await response.json();
    console.log('📊 Fetched cache analytics:', result.data.summary);
    
    return result;

  } catch (error) {
    console.error('❌ Error fetching cache analytics:', error);
    return { success: false, error: error instanceof Error ? error.message : 'Unknown error' };
  }
};
