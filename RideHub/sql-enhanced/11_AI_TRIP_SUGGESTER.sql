-- =====================================================
-- FILE 11: AI TRIP SUGGESTER TABLES
-- =====================================================
-- Tables for storing AI trip suggestions and user preferences
-- =====================================================

USE TransportBookingSystem;

-- =====================================================
-- TABLE 1: User Trip Preferences
-- =====================================================

CREATE TABLE UserTripPreferences (
    PreferenceID INT PRIMARY KEY AUTO_INCREMENT,
    UserID INT NOT NULL,
    Place VARCHAR(100) DEFAULT 'Bangalore',
    InterestedActivities SET('Food', 'Entertainment', 'History', 'Shopping', 'Nature', 'Adventure', 'Culture', 'Nightlife', 'Sports', 'Religious') NOT NULL,
    PreferredBudget ENUM('Low', 'Medium', 'High') DEFAULT 'Medium',
    PreferredDuration ENUM('Half-Day', 'Full-Day', 'Weekend') DEFAULT 'Full-Day',
    PreferredTransport SET('Metro', 'Bus', 'Auto', 'Bike', 'Car', 'Walk') DEFAULT 'Metro,Bus',
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (UserID) REFERENCES User(UserID) ON DELETE CASCADE,
    INDEX idx_user_preferences (UserID),
    INDEX idx_activities (InterestedActivities)
) ENGINE=InnoDB;

-- =====================================================
-- TABLE 2: AI Trip Suggestions
-- =====================================================

CREATE TABLE AITripSuggestions (
    SuggestionID INT PRIMARY KEY AUTO_INCREMENT,
    UserID INT NOT NULL,
    PreferenceID INT,
    TripTitle VARCHAR(200) NOT NULL,
    TripDescription TEXT,
    SuggestedPlaces JSON, -- Array of places: [{name, location, type, estimatedTime}]
    TotalEstimatedTime INT, -- in minutes
    TotalEstimatedCost DECIMAL(10,2),
    TransportModes JSON, -- Array of transport modes used
    RouteSequence JSON, -- Ordered sequence of locations
    AIModel VARCHAR(50) DEFAULT 'Gemini',
    AIPrompt TEXT,
    AIResponse TEXT,
    IsAccepted BOOLEAN DEFAULT FALSE,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (UserID) REFERENCES User(UserID) ON DELETE CASCADE,
    FOREIGN KEY (PreferenceID) REFERENCES UserTripPreferences(PreferenceID) ON DELETE SET NULL,
    INDEX idx_user_suggestions (UserID),
    INDEX idx_accepted (IsAccepted),
    INDEX idx_created (CreatedAt)
) ENGINE=InnoDB;

-- =====================================================
-- TABLE 3: Trip Suggestion Feedback
-- =====================================================

CREATE TABLE TripSuggestionFeedback (
    FeedbackID INT PRIMARY KEY AUTO_INCREMENT,
    SuggestionID INT NOT NULL,
    UserID INT NOT NULL,
    Rating INT CHECK (Rating BETWEEN 1 AND 5),
    WasUseful BOOLEAN,
    ActuallyVisited BOOLEAN DEFAULT FALSE,
    Comments TEXT,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (SuggestionID) REFERENCES AITripSuggestions(SuggestionID) ON DELETE CASCADE,
    FOREIGN KEY (UserID) REFERENCES User(UserID) ON DELETE CASCADE,
    INDEX idx_suggestion_feedback (SuggestionID),
    INDEX idx_rating (Rating)
) ENGINE=InnoDB;

-- =====================================================
-- SAMPLE DATA: User Trip Preferences (10 Records)
-- =====================================================

INSERT INTO UserTripPreferences (UserID, Place, InterestedActivities, PreferredBudget, PreferredDuration, PreferredTransport) VALUES
-- User 1: John Doe - Food lover
(1, 'Bangalore', 'Food,Culture', 'Medium', 'Full-Day', 'Metro,Auto'),

-- User 2: Jane Smith - History enthusiast
(2, 'Bangalore', 'History,Culture,Religious', 'Low', 'Half-Day', 'Bus,Walk'),

-- User 3: Mike Johnson - Entertainment seeker
(3, 'Bangalore', 'Entertainment,Nightlife,Food', 'High', 'Full-Day', 'Car,Metro'),

-- User 4: Emily Davis - Nature lover
(4, 'Bangalore', 'Nature,Adventure', 'Medium', 'Weekend', 'Bike,Walk'),

-- User 5: Chris Wilson - Shopaholic
(5, 'Bangalore', 'Shopping,Food,Entertainment', 'High', 'Full-Day', 'Metro,Auto'),

-- User 6: Sarah Brown - Adventure enthusiast
(6, 'Bangalore', 'Adventure,Sports,Nature', 'Medium', 'Weekend', 'Bike,Car'),

-- User 7: David Lee - Cultural explorer
(7, 'Bangalore', 'Culture,History,Religious', 'Low', 'Half-Day', 'Bus,Metro'),

-- User 8: Lisa Anderson - Foodie & Nightlife
(8, 'Bangalore', 'Food,Nightlife,Entertainment', 'High', 'Full-Day', 'Auto,Car'),

-- User 9: Tom Martinez - Sports fan
(9, 'Bangalore', 'Sports,Entertainment,Food', 'Medium', 'Half-Day', 'Metro,Bus'),

-- User 10: Anna Taylor - Religious & Culture
(10, 'Bangalore', 'Religious,Culture,History', 'Low', 'Full-Day', 'Bus,Walk');

-- =====================================================
-- SAMPLE DATA: AI Trip Suggestions (10 Records)
-- =====================================================

INSERT INTO AITripSuggestions (
    UserID, PreferenceID, TripTitle, TripDescription, 
    SuggestedPlaces, TotalEstimatedTime, TotalEstimatedCost, 
    TransportModes, RouteSequence, AIModel, IsAccepted
) VALUES
-- Suggestion 1: Food Tour
(1, 1, 'Bangalore Food Trail', 
 'Explore the best street food and restaurants in Bangalore',
 JSON_ARRAY(
     JSON_OBJECT('name', 'VV Puram Food Street', 'location', 'VV Puram', 'type', 'Food', 'estimatedTime', 90),
     JSON_OBJECT('name', 'MTR Restaurant', 'location', 'Lalbagh', 'type', 'Food', 'estimatedTime', 60),
     JSON_OBJECT('name', 'Shivaji Nagar Market', 'location', 'Shivaji Nagar', 'type', 'Food', 'estimatedTime', 60)
 ),
 210, 450.00,
 JSON_ARRAY('Metro', 'Auto', 'Walk'),
 JSON_ARRAY('Majestic', 'VV Puram', 'Lalbagh', 'Shivaji Nagar'),
 'Gemini', TRUE),

-- Suggestion 2: Historical Tour
(2, 2, 'Bangalore Heritage Walk',
 'Discover the rich history of Bangalore through its monuments',
 JSON_ARRAY(
     JSON_OBJECT('name', 'Bangalore Palace', 'location', 'Vasanth Nagar', 'type', 'History', 'estimatedTime', 90),
     JSON_OBJECT('name', 'Tipu Sultan Palace', 'location', 'KR Market', 'type', 'History', 'estimatedTime', 60),
     JSON_OBJECT('name', 'Bull Temple', 'location', 'Basavanagudi', 'type', 'Religious', 'estimatedTime', 45)
 ),
 195, 250.00,
 JSON_ARRAY('Bus', 'Walk'),
 JSON_ARRAY('Majestic', 'Vasanth Nagar', 'KR Market', 'Basavanagudi'),
 'Gemini', TRUE),

-- Suggestion 3: Entertainment & Nightlife
(3, 3, 'Bangalore Party Circuit',
 'Experience the best entertainment and nightlife spots',
 JSON_ARRAY(
     JSON_OBJECT('name', 'UB City Mall', 'location', 'Vittal Mallya Road', 'type', 'Entertainment', 'estimatedTime', 120),
     JSON_OBJECT('name', 'Indiranagar Pubs', 'location', 'Indiranagar', 'type', 'Nightlife', 'estimatedTime', 180),
     JSON_OBJECT('name', 'Koramangala Cafes', 'location', 'Koramangala', 'type', 'Food', 'estimatedTime', 90)
 ),
 390, 2500.00,
 JSON_ARRAY('Car', 'Metro'),
 JSON_ARRAY('MG Road', 'Indiranagar', 'Koramangala'),
 'Gemini', FALSE),

-- Suggestion 4: Nature & Adventure
(4, 4, 'Bangalore Green Escape',
 'Explore parks, lakes and adventure activities',
 JSON_ARRAY(
     JSON_OBJECT('name', 'Lalbagh Botanical Garden', 'location', 'Lalbagh', 'type', 'Nature', 'estimatedTime', 120),
     JSON_OBJECT('name', 'Ulsoor Lake', 'location', 'Ulsoor', 'type', 'Nature', 'estimatedTime', 90),
     JSON_OBJECT('name', 'Cubbon Park', 'location', 'Cubbon Park', 'type', 'Nature', 'estimatedTime', 90)
 ),
 300, 350.00,
 JSON_ARRAY('Bike', 'Walk'),
 JSON_ARRAY('Lalbagh', 'Ulsoor', 'Cubbon Park'),
 'Gemini', TRUE),

-- Suggestion 5: Shopping Spree
(5, 5, 'Bangalore Shopping Marathon',
 'Visit the best shopping destinations in Bangalore',
 JSON_ARRAY(
     JSON_OBJECT('name', 'Commercial Street', 'location', 'Commercial Street', 'type', 'Shopping', 'estimatedTime', 120),
     JSON_OBJECT('name', 'Brigade Road', 'location', 'Brigade Road', 'type', 'Shopping', 'estimatedTime', 90),
     JSON_OBJECT('name', 'Orion Mall', 'location', 'Rajajinagar', 'type', 'Shopping', 'estimatedTime', 120)
 ),
 330, 1800.00,
 JSON_ARRAY('Metro', 'Auto'),
 JSON_ARRAY('MG Road', 'Commercial Street', 'Brigade Road', 'Rajajinagar'),
 'Gemini', TRUE),

-- Suggestion 6: Adventure Sports
(6, 6, 'Bangalore Adventure Day',
 'Thrilling adventure activities around Bangalore',
 JSON_ARRAY(
     JSON_OBJECT('name', 'Wonderla Amusement Park', 'location', 'Bidadi', 'type', 'Adventure', 'estimatedTime', 300),
     JSON_OBJECT('name', 'Go Karting', 'location', 'Manyata Tech Park', 'type', 'Sports', 'estimatedTime', 90)
 ),
 390, 1500.00,
 JSON_ARRAY('Bike', 'Car'),
 JSON_ARRAY('Bangalore', 'Bidadi', 'Manyata'),
 'Gemini', FALSE),

-- Suggestion 7: Cultural Journey
(7, 7, 'Bangalore Cultural Experience',
 'Immerse in the culture and traditions of Bangalore',
 JSON_ARRAY(
     JSON_OBJECT('name', 'ISKCON Temple', 'location', 'Rajajinagar', 'type', 'Religious', 'estimatedTime', 90),
     JSON_OBJECT('name', 'Karnataka Chitrakala Parishath', 'location', 'Kumara Krupa', 'type', 'Culture', 'estimatedTime', 60),
     JSON_OBJECT('name', 'National Gallery of Modern Art', 'location', 'Manikyavelu Mansion', 'type', 'Culture', 'estimatedTime', 60)
 ),
 210, 200.00,
 JSON_ARRAY('Bus', 'Metro'),
 JSON_ARRAY('Majestic', 'Rajajinagar', 'Kumara Krupa'),
 'Gemini', TRUE),

-- Suggestion 8: Foodie Night Out
(8, 8, 'Bangalore Food & Nightlife',
 'Best restaurants and nightlife spots in one evening',
 JSON_ARRAY(
     JSON_OBJECT('name', 'Toit Brewpub', 'location', 'Indiranagar', 'type', 'Food', 'estimatedTime', 120),
     JSON_OBJECT('name', 'Skyye Lounge', 'location', 'UB City', 'type', 'Nightlife', 'estimatedTime', 150),
     JSON_OBJECT('name', 'Church Street Social', 'location', 'Church Street', 'type', 'Entertainment', 'estimatedTime', 90)
 ),
 360, 3000.00,
 JSON_ARRAY('Auto', 'Car'),
 JSON_ARRAY('Indiranagar', 'UB City', 'Church Street'),
 'Gemini', TRUE),

-- Suggestion 9: Sports & Entertainment
(9, 9, 'Bangalore Sports Day',
 'Watch sports and enjoy entertainment',
 JSON_ARRAY(
     JSON_OBJECT('name', 'Chinnaswamy Stadium', 'location', 'Cubbon Park', 'type', 'Sports', 'estimatedTime', 180),
     JSON_OBJECT('name', 'PVR Cinemas', 'location', 'Koramangala', 'type', 'Entertainment', 'estimatedTime', 150),
     JSON_OBJECT('name', 'Truffles Restaurant', 'location', 'Koramangala', 'type', 'Food', 'estimatedTime', 60)
 ),
 390, 800.00,
 JSON_ARRAY('Metro', 'Bus'),
 JSON_ARRAY('Cubbon Park', 'Koramangala'),
 'Gemini', FALSE),

-- Suggestion 10: Religious & Heritage
(10, 10, 'Bangalore Temple Trail',
 'Visit famous temples and religious sites',
 JSON_ARRAY(
     JSON_OBJECT('name', 'Bull Temple', 'location', 'Basavanagudi', 'type', 'Religious', 'estimatedTime', 45),
     JSON_OBJECT('name', 'ISKCON Temple', 'location', 'Rajajinagar', 'type', 'Religious', 'estimatedTime', 90),
     JSON_OBJECT('name', 'Gavi Gangadhareshwara Temple', 'location', 'Gavipuram', 'type', 'Religious', 'estimatedTime', 60),
     JSON_OBJECT('name', 'Dodda Basavana Gudi', 'location', 'Bull Temple Road', 'type', 'Religious', 'estimatedTime', 45)
 ),
 240, 150.00,
 JSON_ARRAY('Bus', 'Walk'),
 JSON_ARRAY('Basavanagudi', 'Rajajinagar', 'Gavipuram'),
 'Gemini', TRUE);

-- =====================================================
-- SAMPLE DATA: Trip Suggestion Feedback (5 Records)
-- =====================================================

INSERT INTO TripSuggestionFeedback (SuggestionID, UserID, Rating, WasUseful, ActuallyVisited, Comments) VALUES
(1, 1, 5, TRUE, TRUE, 'Amazing food tour! Loved VV Puram street food.'),
(2, 2, 4, TRUE, TRUE, 'Great historical insights. Bangalore Palace was stunning.'),
(4, 4, 5, TRUE, TRUE, 'Perfect nature escape. Lalbagh was so peaceful.'),
(5, 5, 4, TRUE, FALSE, 'Good shopping suggestions. Will visit soon!'),
(7, 7, 5, TRUE, TRUE, 'Wonderful cultural experience. ISKCON temple was divine.');

-- =====================================================
-- VIEW: User Trip Preferences Summary
-- =====================================================

CREATE VIEW UserTripPreferencesSummary AS
SELECT 
    u.UserID,
    u.FullName,
    u.Email,
    utp.Place,
    utp.InterestedActivities,
    utp.PreferredBudget,
    utp.PreferredDuration,
    utp.PreferredTransport,
    COUNT(DISTINCT ats.SuggestionID) AS TotalSuggestions,
    COUNT(DISTINCT CASE WHEN ats.IsAccepted = TRUE THEN ats.SuggestionID END) AS AcceptedSuggestions,
    AVG(tsf.Rating) AS AverageRating,
    utp.CreatedAt AS PreferenceCreatedAt
FROM User u
LEFT JOIN UserTripPreferences utp ON u.UserID = utp.UserID
LEFT JOIN AITripSuggestions ats ON utp.PreferenceID = ats.PreferenceID
LEFT JOIN TripSuggestionFeedback tsf ON ats.SuggestionID = tsf.SuggestionID
GROUP BY u.UserID, utp.PreferenceID;

-- =====================================================
-- VIEW: Popular Trip Activities
-- =====================================================

CREATE VIEW PopularTripActivities AS
SELECT 
    SUBSTRING_INDEX(SUBSTRING_INDEX(InterestedActivities, ',', numbers.n), ',', -1) AS Activity,
    COUNT(*) AS UserCount,
    AVG(CASE WHEN PreferredBudget = 'Low' THEN 1 WHEN PreferredBudget = 'Medium' THEN 2 ELSE 3 END) AS AvgBudgetLevel,
    COUNT(DISTINCT ats.SuggestionID) AS TotalSuggestions
FROM UserTripPreferences utp
CROSS JOIN (
    SELECT 1 n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 
    UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10
) numbers
LEFT JOIN AITripSuggestions ats ON utp.PreferenceID = ats.PreferenceID
WHERE CHAR_LENGTH(InterestedActivities) - CHAR_LENGTH(REPLACE(InterestedActivities, ',', '')) >= numbers.n - 1
GROUP BY Activity
ORDER BY UserCount DESC;

-- =====================================================
-- STORED PROCEDURE: Save AI Trip Suggestion
-- =====================================================

DELIMITER //

CREATE PROCEDURE SaveAITripSuggestion(
    IN p_UserID INT,
    IN p_PreferenceID INT,
    IN p_TripTitle VARCHAR(200),
    IN p_TripDescription TEXT,
    IN p_SuggestedPlaces JSON,
    IN p_TotalEstimatedTime INT,
    IN p_TotalEstimatedCost DECIMAL(10,2),
    IN p_TransportModes JSON,
    IN p_RouteSequence JSON,
    IN p_AIPrompt TEXT,
    IN p_AIResponse TEXT
)
BEGIN
    INSERT INTO AITripSuggestions (
        UserID, PreferenceID, TripTitle, TripDescription,
        SuggestedPlaces, TotalEstimatedTime, TotalEstimatedCost,
        TransportModes, RouteSequence, AIPrompt, AIResponse
    ) VALUES (
        p_UserID, p_PreferenceID, p_TripTitle, p_TripDescription,
        p_SuggestedPlaces, p_TotalEstimatedTime, p_TotalEstimatedCost,
        p_TransportModes, p_RouteSequence, p_AIPrompt, p_AIResponse
    );
    
    SELECT LAST_INSERT_ID() AS SuggestionID, 'AI Trip Suggestion saved successfully' AS Message;
END //

DELIMITER ;

-- =====================================================
-- INDEXES FOR PERFORMANCE
-- =====================================================

CREATE INDEX idx_trip_title ON AITripSuggestions(TripTitle);
CREATE INDEX idx_total_cost ON AITripSuggestions(TotalEstimatedCost);
CREATE INDEX idx_feedback_rating ON TripSuggestionFeedback(Rating, WasUseful);

-- =====================================================
-- VERIFICATION QUERIES
-- =====================================================

-- Check data counts
SELECT 'User Trip Preferences' AS TableName, COUNT(*) AS RecordCount FROM UserTripPreferences
UNION ALL
SELECT 'AI Trip Suggestions', COUNT(*) FROM AITripSuggestions
UNION ALL
SELECT 'Trip Suggestion Feedback', COUNT(*) FROM TripSuggestionFeedback;

-- Show sample preferences
SELECT 
    u.FullName,
    utp.InterestedActivities,
    utp.PreferredBudget,
    COUNT(ats.SuggestionID) AS TotalSuggestions
FROM User u
JOIN UserTripPreferences utp ON u.UserID = utp.UserID
LEFT JOIN AITripSuggestions ats ON utp.PreferenceID = ats.PreferenceID
GROUP BY u.UserID
ORDER BY TotalSuggestions DESC;

-- =====================================================
-- END OF FILE 11
-- =====================================================
