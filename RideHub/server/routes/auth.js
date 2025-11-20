import express from 'express';
import bcrypt from 'bcrypt';
import multer from 'multer';
import { pool } from '../config/database.js';

const router = express.Router();

// Configure multer for memory storage (files stored in buffer)
const storage = multer.memoryStorage();
const upload = multer({
  storage: storage,
  limits: {
    fileSize: 5 * 1024 * 1024 // 5MB max file size
  },
  fileFilter: (req, file, cb) => {
    // Accept images and PDFs only
    if (file.mimetype.startsWith('image/') || file.mimetype === 'application/pdf') {
      cb(null, true);
    } else {
      cb(new Error('Only images and PDFs are allowed'));
    }
  }
});

// User Login
router.post('/login', async (req, res) => {
  try {
    const { email, role } = req.body;

    if (!email || !role) {
      return res.status(400).json({ error: 'Email and role are required' });
    }

    // Query user from database (NO PASSWORD CHECK)
    const [users] = await pool.query(
      'SELECT UserID as id, FullName as fullName, Phone as phone, Email as email, Age as age, Username as username, UserRole FROM User WHERE Email = ? AND IsActive = TRUE',
      [email]
    );

    if (users.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }

    const user = users[0];

    // Check if user is a provider
    if (role === 'PROVIDER') {
      const [providers] = await pool.query(
        'SELECT ProviderID, RatePerHour as ratePerHour, Rating FROM ServiceProvider WHERE UserID = ? AND IsApproved = TRUE',
        [user.id]
      );

      if (providers.length === 0) {
        return res.status(403).json({ error: 'Provider not found or not approved' });
      }

      user.providerId = providers[0].ProviderID;
      user.ratePerHour = providers[0].ratePerHour;
      user.rating = providers[0].Rating;
    }

    // Check if user is an admin
    if (role === 'ADMIN') {
      if (user.UserRole !== 'admin') {
        return res.status(403).json({ error: 'Access denied. Admin privileges required.' });
      }
      
      // Admin users get additional permissions
      user.permissions = [
        'user_management',
        'provider_management', 
        'booking_management',
        'offer_management',
        'system_config',
        'data_export',
        'analytics_view'
      ];
    }

    // Split fullName into firstName and lastName
    const nameParts = user.fullName.split(' ');
    user.firstName = nameParts[0] || '';
    user.lastName = nameParts.slice(1).join(' ') || '';
    user.role = role;
    user.userRole = user.UserRole; // Include the database role

    res.json(user);
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ error: 'Login failed', details: error.message });
  }
});

// User Signup
router.post('/signup/user', async (req, res) => {
  try {
    const { firstName, lastName, username, phone, email, age, password } = req.body;

    // Validate required fields
    if (!firstName || !lastName || !username || !phone || !email || !age) {
      return res.status(400).json({ error: 'All fields are required' });
    }

    // Use default password hash if no password provided
    const passwordHash = password 
      ? await bcrypt.hash(password, 10)
      : '$2b$10$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW'; // default: password123
    
    const fullName = `${firstName} ${lastName}`;

    // Insert user
    const [result] = await pool.query(
      'INSERT INTO User (Phone, Username, FullName, LastName, Email, Age, PasswordHash) VALUES (?, ?, ?, ?, ?, ?, ?)',
      [phone, username, fullName, lastName, email, age, passwordHash]
    );

    const newUser = {
      id: result.insertId,
      firstName,
      lastName,
      fullName,
      username,
      phone,
      email,
      age: parseInt(age),
      role: 'USER'
    };

    res.status(201).json({ status: 'success', user: newUser });
  } catch (error) {
    console.error('User signup error:', error);
    console.error('Error details:', error.message);
    console.error('Error code:', error.code);
    if (error.code === 'ER_DUP_ENTRY') {
      return res.status(409).json({ error: 'Username, email, or phone already exists' });
    }
    res.status(500).json({ error: 'Signup failed', details: error.message, code: error.code });
  }
});

// Provider Signup with Document Upload
router.post('/signup/provider', upload.fields([
  { name: 'drivingLicense', maxCount: 1 },
  { name: 'aadhaarCard', maxCount: 1 },
  { name: 'panCard', maxCount: 1 },
  { name: 'photo', maxCount: 1 },
  { name: 'vehicleRegistration', maxCount: 1 },
  { name: 'vehicleInsurance', maxCount: 1 },
  { name: 'pollutionCertificate', maxCount: 1 }
]), async (req, res) => {
  const connection = await pool.getConnection();
  try {
    await connection.beginTransaction();

    const {
      firstName,
      lastName,
      username,
      phone,
      email,
      age,
      password,
      servicePartnership,
      ratePerHour,
      idProofUrl,
      vehicleRegUrl,
      licenseUrl
    } = req.body;

    // Validate required fields
    if (!firstName || !lastName || !username || !phone || !email || !age || !ratePerHour) {
      await connection.rollback();
      return res.status(400).json({ error: 'All fields are required' });
    }

    // Use default password hash if no password provided
    const passwordHash = password 
      ? await bcrypt.hash(password, 10)
      : '$2b$10$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW'; // default: password123
    
    const fullName = `${firstName} ${lastName}`;

    // Insert user
    const [userResult] = await connection.query(
      'INSERT INTO User (Phone, Username, FullName, LastName, Email, Age, PasswordHash, IsProvider) VALUES (?, ?, ?, ?, ?, ?, ?, TRUE)',
      [phone, username, fullName, lastName, email, age, passwordHash]
    );

    const userId = userResult.insertId;

    // Insert service provider
    const [providerResult] = await connection.query(
      'INSERT INTO ServiceProvider (UserID, ProviderType, RatePerHour, IsApproved) VALUES (?, ?, ?, TRUE)',
      [userId, servicePartnership, ratePerHour]
    );

    const providerId = providerResult.insertId;

    // Insert provider documents (BLOB/CLOB storage)
    const files = req.files || {};
    let documentsUploaded = 0;

    // Helper function to store document
    const storeDocument = async (file, documentType) => {
      if (file && file[0]) {
        const fileData = file[0];
        const documentText = `Document: ${fileData.originalname}\nType: ${documentType}\nSize: ${fileData.size} bytes\nMime Type: ${fileData.mimetype}\nUploaded: ${new Date().toISOString()}`;
        
        await connection.query(
          `INSERT INTO ProviderDocuments 
           (ProviderID, DocumentType, DocumentName, DocumentData, DocumentText, MimeType, FileSize, VerificationStatus) 
           VALUES (?, ?, ?, ?, ?, ?, ?, 'Pending')`,
          [providerId, documentType, fileData.originalname, fileData.buffer, documentText, fileData.mimetype, fileData.size]
        );
        documentsUploaded++;
      }
    };

    // Store all uploaded documents
    await storeDocument(files.drivingLicense, 'Driving_License');
    await storeDocument(files.aadhaarCard, 'Aadhaar_Card');
    await storeDocument(files.panCard, 'PAN_Card');
    await storeDocument(files.photo, 'Photo');
    await storeDocument(files.vehicleRegistration, 'Vehicle_Registration');
    await storeDocument(files.vehicleInsurance, 'Vehicle_Insurance');
    await storeDocument(files.pollutionCertificate, 'Pollution_Certificate');

    await connection.commit();

    const newProvider = {
      id: userId,
      providerId,
      firstName,
      lastName,
      fullName,
      username,
      phone,
      email,
      age: parseInt(age),
      role: 'PROVIDER',
      servicePartnership,
      ratePerHour: parseFloat(ratePerHour),
      documentsUploaded
    };

    res.status(201).json({ 
      status: 'success', 
      message: `Provider registered successfully with ${documentsUploaded} documents`,
      provider: newProvider 
    });
  } catch (error) {
    await connection.rollback();
    console.error('Provider signup error:', error);
    if (error.code === 'ER_DUP_ENTRY') {
      return res.status(409).json({ error: 'Username, email, or phone already exists' });
    }
    res.status(500).json({ error: 'Signup failed', details: error.message });
  } finally {
    connection.release();
  }
});

// Get Provider Documents List
router.get('/provider/:providerId/documents', async (req, res) => {
  try {
    const { providerId } = req.params;

    const [documents] = await pool.query(
      `SELECT 
        DocumentID,
        DocumentType,
        DocumentName,
        MimeType,
        FileSize,
        ROUND(FileSize/1024, 2) as fileSizeKB,
        VerificationStatus,
        RejectionReason,
        UploadedAt,
        VerifiedAt
      FROM ProviderDocuments
      WHERE ProviderID = ?
      ORDER BY UploadedAt DESC`,
      [providerId]
    );

    res.json({ success: true, documents });
  } catch (error) {
    console.error('Error fetching documents:', error);
    res.status(500).json({ error: 'Failed to fetch documents' });
  }
});

// Get Document Image/PDF (BLOB)
router.get('/provider/document/:documentId', async (req, res) => {
  try {
    const { documentId } = req.params;

    const [documents] = await pool.query(
      'SELECT DocumentData, MimeType, DocumentName FROM ProviderDocuments WHERE DocumentID = ?',
      [documentId]
    );

    if (documents.length === 0) {
      return res.status(404).json({ error: 'Document not found' });
    }

    const doc = documents[0];
    
    // Set appropriate headers
    res.setHeader('Content-Type', doc.MimeType);
    res.setHeader('Content-Disposition', `inline; filename="${doc.DocumentName}"`);
    
    // Send binary data
    res.send(doc.DocumentData);
  } catch (error) {
    console.error('Error fetching document:', error);
    res.status(500).json({ error: 'Failed to fetch document' });
  }
});

// Get Document Text/Metadata (CLOB)
router.get('/provider/document/:documentId/text', async (req, res) => {
  try {
    const { documentId } = req.params;

    const [documents] = await pool.query(
      'SELECT DocumentText, DocumentName, DocumentType FROM ProviderDocuments WHERE DocumentID = ?',
      [documentId]
    );

    if (documents.length === 0) {
      return res.status(404).json({ error: 'Document not found' });
    }

    res.json({ success: true, document: documents[0] });
  } catch (error) {
    console.error('Error fetching document text:', error);
    res.status(500).json({ error: 'Failed to fetch document text' });
  }
});

export default router;
