-- =====================================================
-- AI TRIP SUGGESTER - REDIS & DATABASE INTEGRATION
-- =====================================================

USE TransportBookingSystem;

-- Create tables for AI trip data storage
-- =====================================================

-- AI Trip Requests - Store user inputs
CREATE TABLE AITripRequests (
    RequestID INT PRIMARY KEY AUTO_INCREMENT,
    UserID INT NULL, -- NULL for anonymous users
    SessionID VARCHAR(255) NOT NULL, -- For tracking anonymous sessions
    Destination VARCHAR(200) NOT NULL,
    Interests TEXT NOT NULL,
    RequestTimestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    IPAddress VARCHAR(45), -- For analytics
    UserAgent TEXT, -- Browser info
    RedisKey VARCHAR(255), -- Redis cache key
    INDEX idx_user_requests (UserID),
    INDEX idx_session_requests (SessionID),
    INDEX idx_destination (Destination),
    INDEX idx_timestamp (RequestTimestamp),
    FOREIGN KEY (UserID) REFERENCES User(UserID) ON DELETE SET NULL
) ENGINE=InnoDB;

-- AI Trip Responses - Store AI-generated suggestions
CREATE TABLE AITripResponses (
    ResponseID INT PRIMARY KEY AUTO_INCREMENT,
    RequestID INT NOT NULL,
    Title VARCHAR(500) NOT NULL,
    Summary TEXT NOT NULL,
    StopsData JSON NOT NULL, -- Store stops as JSON
    GenerationTime DECIMAL(8,3), -- Time taken to generate (seconds)
    ResponseTimestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CacheHit BOOLEAN DEFAULT FALSE, -- Was this served from cache?
    RedisKey VARCHAR(255), -- Redis cache key
    ExpiresAt TIMESTAMP NULL, -- Cache expiration
    INDEX idx_request_response (RequestID),
    INDEX idx_cache_hit (CacheHit),
    INDEX idx_expires (ExpiresAt),
    FOREIGN KEY (RequestID) REFERENCES AITripRequests(RequestID) ON DELETE CASCADE
) ENGINE=InnoDB;

-- AI Trip Analytics - Store usage patterns
CREATE TABLE AITripAnalytics (
    AnalyticsID INT PRIMARY KEY AUTO_INCREMENT,
    RequestID INT NOT NULL,
    UserID INT NULL,
    PopularDestination VARCHAR(200),
    PopularInterest VARCHAR(200),
    ResponseTime DECIMAL(8,3),
    CacheEfficiency DECIMAL(5,2), -- Cache hit rate
    UserSatisfaction ENUM('Positive', 'Negative', 'Neutral') NULL,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_destination_analytics (PopularDestination),
    INDEX idx_interest_analytics (PopularInterest),
    INDEX idx_user_analytics (UserID),
    FOREIGN KEY (RequestID) REFERENCES AITripRequests(RequestID) ON DELETE CASCADE,
    FOREIGN KEY (UserID) REFERENCES User(UserID) ON DELETE SET NULL
) ENGINE=InnoDB;

-- AI Cache Statistics - Monitor Redis performance
CREATE TABLE AICacheStats (
    StatID INT PRIMARY KEY AUTO_INCREMENT,
    Date DATE NOT NULL,
    TotalRequests INT DEFAULT 0,
    CacheHits INT DEFAULT 0,
    CacheMisses INT DEFAULT 0,
    CacheHitRate DECIMAL(5,2) DEFAULT 0.00,
    AverageResponseTime DECIMAL(8,3) DEFAULT 0.000,
    UniqueDestinations INT DEFAULT 0,
    UniqueInterests INT DEFAULT 0,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY unique_date (Date),
    INDEX idx_date (Date),
    INDEX idx_hit_rate (CacheHitRate)
) ENGINE=InnoDB;

-- =====================================================
-- STORED PROCEDURES FOR AI TRIP MANAGEMENT
-- =====================================================

-- Procedure to log AI trip request
DELIMITER $$
CREATE PROCEDURE LogAITripRequest(
    IN p_UserID INT,
    IN p_SessionID VARCHAR(255),
    IN p_Destination VARCHAR(200),
    IN p_Interests TEXT,
    IN p_IPAddress VARCHAR(45),
    IN p_UserAgent TEXT,
    IN p_RedisKey VARCHAR(255)
)
BEGIN
    INSERT INTO AITripRequests (
        UserID, SessionID, Destination, Interests, 
        IPAddress, UserAgent, RedisKey
    ) VALUES (
        p_UserID, p_SessionID, p_Destination, p_Interests,
        p_IPAddress, p_UserAgent, p_RedisKey
    );
    
    SELECT LAST_INSERT_ID() AS RequestID;
END$$

-- Procedure to log AI trip response
CREATE PROCEDURE LogAITripResponse(
    IN p_RequestID INT,
    IN p_Title VARCHAR(500),
    IN p_Summary TEXT,
    IN p_StopsData JSON,
    IN p_GenerationTime DECIMAL(8,3),
    IN p_CacheHit BOOLEAN,
    IN p_RedisKey VARCHAR(255),
    IN p_ExpiresAt TIMESTAMP
)
BEGIN
    INSERT INTO AITripResponses (
        RequestID, Title, Summary, StopsData,
        GenerationTime, CacheHit, RedisKey, ExpiresAt
    ) VALUES (
        p_RequestID, p_Title, p_Summary, p_StopsData,
        p_GenerationTime, p_CacheHit, p_RedisKey, p_ExpiresAt
    );
    
    SELECT LAST_INSERT_ID() AS ResponseID;
END$$

-- Procedure to update cache statistics
CREATE PROCEDURE UpdateCacheStats(
    IN p_Date DATE,
    IN p_IsHit BOOLEAN,
    IN p_ResponseTime DECIMAL(8,3),
    IN p_Destination VARCHAR(200),
    IN p_Interest VARCHAR(200)
)
BEGIN
    INSERT INTO AICacheStats (Date, TotalRequests, CacheHits, CacheMisses)
    VALUES (p_Date, 1, IF(p_IsHit, 1, 0), IF(p_IsHit, 0, 1))
    ON DUPLICATE KEY UPDATE
        TotalRequests = TotalRequests + 1,
        CacheHits = CacheHits + IF(p_IsHit, 1, 0),
        CacheMisses = CacheMisses + IF(p_IsHit, 0, 1),
        CacheHitRate = (CacheHits * 100.0) / TotalRequests,
        AverageResponseTime = ((AverageResponseTime * (TotalRequests - 1)) + p_ResponseTime) / TotalRequests;
END$$

DELIMITER ;

-- =====================================================
-- VIEWS FOR AI TRIP ANALYTICS
-- =====================================================

-- Popular destinations view
CREATE VIEW PopularDestinationsView AS
SELECT 
    Destination,
    COUNT(*) as RequestCount,
    AVG(atr.GenerationTime) as AvgResponseTime,
    COUNT(DISTINCT atr.UserID) as UniqueUsers,
    DATE(atr.RequestTimestamp) as RequestDate
FROM AITripRequests atr
JOIN AITripResponses atresp ON atr.RequestID = atresp.RequestID
WHERE atr.RequestTimestamp >= DATE_SUB(NOW(), INTERVAL 30 DAY)
GROUP BY Destination, DATE(atr.RequestTimestamp)
ORDER BY RequestCount DESC;

-- Cache performance view
CREATE VIEW CachePerformanceView AS
SELECT 
    DATE(RequestTimestamp) as Date,
    COUNT(*) as TotalRequests,
    SUM(CASE WHEN atresp.CacheHit = TRUE THEN 1 ELSE 0 END) as CacheHits,
    SUM(CASE WHEN atresp.CacheHit = FALSE THEN 1 ELSE 0 END) as CacheMisses,
    ROUND((SUM(CASE WHEN atresp.CacheHit = TRUE THEN 1 ELSE 0 END) * 100.0) / COUNT(*), 2) as HitRate,
    AVG(atresp.GenerationTime) as AvgResponseTime
FROM AITripRequests atr
JOIN AITripResponses atresp ON atr.RequestID = atresp.RequestID
WHERE atr.RequestTimestamp >= DATE_SUB(NOW(), INTERVAL 7 DAY)
GROUP BY DATE(RequestTimestamp)
ORDER BY Date DESC;

-- User AI usage patterns
CREATE VIEW UserAIUsageView AS
SELECT 
    u.UserID,
    u.FullName,
    u.Email,
    COUNT(atr.RequestID) as TotalRequests,
    COUNT(DISTINCT atr.Destination) as UniqueDestinations,
    AVG(atresp.GenerationTime) as AvgResponseTime,
    MAX(atr.RequestTimestamp) as LastUsed
FROM User u
JOIN AITripRequests atr ON u.UserID = atr.UserID
JOIN AITripResponses atresp ON atr.RequestID = atresp.RequestID
GROUP BY u.UserID, u.FullName, u.Email
ORDER BY TotalRequests DESC;

-- =====================================================
-- SAMPLE DATA FOR TESTING
-- =====================================================

-- Insert sample AI trip requests
INSERT INTO AITripRequests (UserID, SessionID, Destination, Interests, RedisKey) VALUES
(1, 'session_001', 'Bangalore', 'food and history', 'ai_trip:bangalore:food_history'),
(2, 'session_002', 'Mumbai', 'beaches and nightlife', 'ai_trip:mumbai:beaches_nightlife'),
(NULL, 'session_003', 'Delhi', 'monuments and culture', 'ai_trip:delhi:monuments_culture');

-- Insert sample responses
INSERT INTO AITripResponses (RequestID, Title, Summary, StopsData, GenerationTime, CacheHit, RedisKey) VALUES
(1, 'Bangalore Food & History Tour', 'Explore the rich culinary and historical heritage of Bangalore', 
 '{"stops": [{"name": "Lalbagh Botanical Garden", "description": "Historic garden with beautiful flora", "timeOfDay": "Morning"}]}', 
 2.450, FALSE, 'ai_trip:bangalore:food_history'),
(2, 'Mumbai Coastal Adventure', 'Experience the vibrant beaches and nightlife of Mumbai',
 '{"stops": [{"name": "Marine Drive", "description": "Iconic seafront promenade", "timeOfDay": "Evening"}]}',
 1.890, FALSE, 'ai_trip:mumbai:beaches_nightlife');

-- =====================================================
-- VERIFICATION QUERIES
-- =====================================================

SELECT '✅ AI Trip Redis Integration tables created!' AS Status;

-- Show table structures
SELECT 'AITripRequests table:' AS Info;
DESCRIBE AITripRequests;

SELECT 'AITripResponses table:' AS Info;
DESCRIBE AITripResponses;

SELECT 'Sample data verification:' AS Info;
SELECT COUNT(*) as TotalRequests FROM AITripRequests;
SELECT COUNT(*) as TotalResponses FROM AITripResponses;

-- Show views
SELECT 'Popular destinations:' AS Info;
SELECT * FROM PopularDestinationsView LIMIT 3;

SELECT 'Cache performance:' AS Info;
SELECT * FROM CachePerformanceView LIMIT 3;
