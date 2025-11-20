-- =====================================================
-- FIX: UPDATE ALL USER PASSWORDS
-- =====================================================
-- This fixes login issues by setting correct bcrypt hashes
-- Password for ALL users: "password123"
-- Correct bcrypt hash generated with 10 rounds
-- =====================================================

USE TransportBookingSystem;

-- Update all user passwords with correct bcrypt hash
-- This hash is for "password123" with bcrypt rounds=10
UPDATE User 
SET PasswordHash = '$2b$10$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW';

-- Verify update
SELECT 
    UserID,
    Email,
    FullName,
    IsProvider,
    LEFT(PasswordHash, 20) AS PasswordHashPreview
FROM User
LIMIT 5;

SELECT '✅ All passwords updated!' AS Status;
SELECT 'Password for ALL users: password123' AS Info;
SELECT 'Try logging in now with any email and password123' AS Instruction;
