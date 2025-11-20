import express from 'express';
import { pool } from '../config/database.js';

const router = express.Router();

// Get all active offers
router.get('/active', async (req, res) => {
  try {
    console.log('📡 API: Fetching active offers from database...');
    const [offers] = await pool.query(
      `SELECT 
        OfferID,
        OfferCode,
        DiscountPercentage,
        MaxDiscountAmount,
        ValidFrom,
        ValidTo,
        IsActive
       FROM Offers
       WHERE IsActive = TRUE 
         AND ValidFrom <= CURDATE() 
         AND ValidTo >= CURDATE()
       ORDER BY DiscountPercentage DESC`
    );

    console.log(`✅ API: Found ${offers.length} active offers`);
    if (offers.length === 0) {
      console.warn('⚠️ API: Database has NO active offers! Run sql-enhanced/09_ADDITIONAL_TABLES.sql');
    }

    res.json(offers);
  } catch (error) {
    console.error('❌ API Error fetching offers:', error);
    res.status(500).json({ error: 'Failed to fetch offers' });
  }
});

// Validate and apply offer
router.post('/validate', async (req, res) => {
  try {
    const { offerCode, bookingAmount } = req.body;

    if (!offerCode || !bookingAmount) {
      return res.status(400).json({ error: 'Offer code and booking amount required' });
    }

    const [offers] = await pool.query(
      `SELECT 
        OfferID,
        OfferCode,
        DiscountPercentage,
        MaxDiscountAmount
       FROM Offers
       WHERE OfferCode = ? 
         AND IsActive = TRUE 
         AND ValidFrom <= CURDATE() 
         AND ValidTo >= CURDATE()`,
      [offerCode]
    );

    if (offers.length === 0) {
      return res.status(404).json({ 
        valid: false,
        error: 'Invalid or expired offer code' 
      });
    }

    const offer = offers[0];
    const discountAmount = Math.min(
      (bookingAmount * offer.DiscountPercentage) / 100,
      offer.MaxDiscountAmount
    );
    const finalAmount = bookingAmount - discountAmount;

    res.json({
      valid: true,
      offerCode: offer.OfferCode,
      discountPercentage: offer.DiscountPercentage,
      discountAmount: parseFloat(discountAmount.toFixed(2)),
      originalAmount: parseFloat(bookingAmount.toFixed(2)),
      finalAmount: parseFloat(finalAmount.toFixed(2))
    });
  } catch (error) {
    console.error('Error validating offer:', error);
    res.status(500).json({ error: 'Failed to validate offer' });
  }
});

// Get offer by code
router.get('/:offerCode', async (req, res) => {
  try {
    const { offerCode } = req.params;

    const [offers] = await pool.query(
      `SELECT 
        OfferID,
        OfferCode,
        DiscountPercentage,
        MaxDiscountAmount,
        ValidFrom,
        ValidTo,
        IsActive
       FROM Offers
       WHERE OfferCode = ?`,
      [offerCode]
    );

    if (offers.length === 0) {
      return res.status(404).json({ error: 'Offer not found' });
    }

    res.json(offers[0]);
  } catch (error) {
    console.error('Error fetching offer:', error);
    res.status(500).json({ error: 'Failed to fetch offer' });
  }
});

export default router;
