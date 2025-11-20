import React, { useState, useEffect } from 'react';
import { api } from '../services/api';
import Card from '../components/Card';
import Button from '../components/Button';

interface Offer {
  OfferID: number;
  OfferCode: string;
  DiscountPercentage: number;
  MaxDiscountAmount: number;
  ValidFrom: string;
  ValidTo: string;
  IsActive: boolean;
}

interface BookingData {
  userId: number;
  route: any;
  startLocation: string;
  endLocation: string;
  totalAmount: number;
  timestamp: string;
}

interface OffersPageProps {
  navigate?: (page: any) => void;
  PageEnum?: any;
}

const OffersPage: React.FC<OffersPageProps> = ({ navigate, PageEnum }) => {
  const [offers, setOffers] = useState<Offer[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [copiedCode, setCopiedCode] = useState<string | null>(null);
  const [bookingData, setBookingData] = useState<BookingData | null>(null);
  const [selectedOffer, setSelectedOffer] = useState<Offer | null>(null);
  const [finalAmount, setFinalAmount] = useState<number>(0);
  const [discountAmount, setDiscountAmount] = useState<number>(0);
  const [isProcessingBooking, setIsProcessingBooking] = useState(false);

  useEffect(() => {
    fetchOffers();
    loadBookingData();
  }, []);

  const loadBookingData = () => {
    console.log('🔍 Checking for pending booking data...');
    const storedBooking = sessionStorage.getItem('pendingBooking');
    console.log('📂 Raw sessionStorage data:', storedBooking);
    
    if (storedBooking) {
      try {
        const booking = JSON.parse(storedBooking);
        setBookingData(booking);
        setFinalAmount(booking.totalAmount);
        console.log('📦 ✅ Loaded booking data successfully:', booking);
        console.log('💰 Total amount:', booking.totalAmount);
      } catch (error) {
        console.error('❌ Failed to parse booking data:', error);
        sessionStorage.removeItem('pendingBooking');
      }
    } else {
      console.log('📭 No pending booking data found');
    }
  };

  const fetchOffers = async () => {
    try {
      console.log('🔄 Fetching offers from API...');
      const data = await api.getActiveOffers();
      console.log('📦 Offers data received:', data);
      console.log('📊 Number of offers:', data.length);
      
      setOffers(data);
      setError(null);
      console.log('✅ Offers state updated successfully');
    } catch (error: any) {
      console.error('❌ Failed to fetch offers:', error);
      setError(error.message || 'Failed to load offers');
    } finally {
      setLoading(false);
      console.log('🏁 Offers loading complete');
    }
  };

  const copyCode = (code: string) => {
    navigator.clipboard.writeText(code);
    setCopiedCode(code);
    setTimeout(() => setCopiedCode(null), 2000);
  };

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString('en-IN', {
      year: 'numeric',
      month: 'short',
      day: 'numeric'
    });
  };

  const selectOffer = (offer: Offer) => {
    console.log('🎁 Selecting offer:', offer.OfferCode);
    
    if (!bookingData) {
      console.error('❌ No booking data available for offer selection');
      return;
    }
    
    console.log('💰 Original amount:', bookingData.totalAmount);
    console.log('📊 Offer details:', {
      code: offer.OfferCode,
      percentage: offer.DiscountPercentage,
      maxDiscount: offer.MaxDiscountAmount
    });
    
    setSelectedOffer(offer);
    
    // Calculate discount
    const discountPercentage = (bookingData.totalAmount * offer.DiscountPercentage) / 100;
    const discount = Math.min(discountPercentage, offer.MaxDiscountAmount);
    const final = bookingData.totalAmount - discount;
    
    console.log('🧮 Discount calculation:');
    console.log('  - Percentage discount:', discountPercentage);
    console.log('  - Max discount allowed:', offer.MaxDiscountAmount);
    console.log('  - Final discount applied:', discount);
    console.log('  - Final amount:', final);
    
    setDiscountAmount(discount);
    setFinalAmount(final);
    
    console.log('✅ Offer applied successfully!');
  };

  const proceedWithoutOffer = async () => {
    console.log('⏭️ Proceeding without offer...');
    
    if (!bookingData || !navigate || !PageEnum) {
      console.error('❌ Missing required data for booking completion');
      return;
    }
    
    setIsProcessingBooking(true);
    try {
      console.log('📞 Calling confirmBooking API...');
      // Complete booking without offer
      const result = await api.confirmBooking(
        bookingData.userId, 
        bookingData.route, 
        bookingData.startLocation, 
        bookingData.endLocation
      );
      
      console.log('📋 Booking API result:', result);
      
      if (result.success) {
        console.log('✅ Booking successful! Cleaning up and navigating...');
        sessionStorage.removeItem('pendingBooking');
        navigate(PageEnum.MyBookings);
      } else {
        console.error('❌ Booking API returned failure');
        alert('Booking failed. Please try again.');
      }
    } catch (error) {
      console.error('❌ Booking failed:', error);
      alert('Booking failed. Please try again.');
    } finally {
      setIsProcessingBooking(false);
    }
  };

  const completeBookingWithOffer = async () => {
    console.log('🎁 Completing booking with offer...');
    
    if (!bookingData || !selectedOffer || !navigate || !PageEnum) {
      console.error('❌ Missing required data for offer booking completion');
      return;
    }
    
    console.log('📊 Booking with offer details:', {
      offer: selectedOffer.OfferCode,
      discount: discountAmount,
      final: finalAmount
    });
    
    setIsProcessingBooking(true);
    try {
      console.log('📞 Calling confirmBooking API with offer data...');
      
      // Prepare offer data for API
      const offerApiData = {
        offerCode: selectedOffer.OfferCode,
        discountPercentage: selectedOffer.DiscountPercentage,
        discountAmount: discountAmount,
        originalAmount: bookingData.totalAmount,
        finalAmount: finalAmount
      };
      
      console.log('💾 Sending offer data to API:', offerApiData);
      
      // Complete booking with offer data
      const result = await fetch('http://localhost:5000/api/multimodal/create-booking', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          userId: bookingData.userId,
          startLocation: bookingData.startLocation,
          endLocation: bookingData.endLocation,
          routeOption: bookingData.route,
          offerData: offerApiData
        })
      });
      
      if (!result.ok) {
        throw new Error(`HTTP ${result.status}: ${result.statusText}`);
      }
      
      const apiResponse = await result.json();
      
      console.log('📋 Booking API result:', apiResponse);
      
      if (apiResponse.success) {
        console.log('✅ Booking successful! Discount stored in database');
        console.log('💰 Final booking details:', {
          bookingId: apiResponse.bookingId,
          originalAmount: bookingData.totalAmount,
          discountAmount: discountAmount,
          finalAmount: finalAmount,
          offerCode: selectedOffer.OfferCode
        });
        
        sessionStorage.removeItem('pendingBooking');
        console.log('🧹 Cleaned up pending booking data');
        
        console.log('🔄 Navigating to MyBookings...');
        navigate(PageEnum.MyBookings);
      } else {
        console.error('❌ Booking API returned failure');
        alert('Booking failed. Please try again.');
      }
    } catch (error) {
      console.error('❌ Booking with offer failed:', error);
      alert('Booking failed. Please try again.');
    } finally {
      setIsProcessingBooking(false);
    }
  };

  console.log('🎨 Render - Loading:', loading, 'Error:', error, 'Offers:', offers.length);

  if (loading) {
    console.log('🔄 Showing loading spinner');
    return (
      <div className="flex justify-center items-center h-screen">
        <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-blue-600"></div>
      </div>
    );
  }

  if (error) {
    console.log('❌ Showing error card:', error);
    return (
      <div className="max-w-7xl mx-auto px-4 py-6">
        <div className="bg-red-50 border-2 border-red-200 rounded-xl p-8 text-center">
          <div className="text-6xl mb-4">⚠️</div>
          <h2 className="text-2xl font-bold text-red-800 mb-2">Failed to Load Offers</h2>
          <p className="text-red-600 mb-4">{error}</p>
          <div className="space-y-2 text-sm text-red-700 bg-red-100 p-4 rounded-lg mb-4">
            <p><strong>Possible causes:</strong></p>
            <ul className="list-disc list-inside text-left">
              <li>Backend server is not running (check http://localhost:5000)</li>
              <li>Database table 'Offers' doesn't exist</li>
              <li>No offers data in database</li>
              <li>Network connection issue</li>
            </ul>
          </div>
          <button
            onClick={fetchOffers}
            className="px-6 py-3 bg-blue-600 text-white font-semibold rounded-lg hover:bg-blue-700 transition"
          >
            🔄 Retry
          </button>
        </div>
      </div>
    );
  }

  if (offers.length === 0) {
    console.log('📭 Showing empty state');
    return (
      <div className="max-w-7xl mx-auto px-4 py-6">
        <div className="bg-yellow-50 border-2 border-yellow-200 rounded-xl p-8 text-center">
          <div className="text-6xl mb-4">🎁</div>
          <h2 className="text-2xl font-bold text-yellow-800 mb-2">No Active Offers</h2>
          <p className="text-yellow-600 mb-4">There are no active offers available right now.</p>
          <div className="space-y-2 text-sm text-yellow-700 bg-yellow-100 p-4 rounded-lg">
            <p><strong>To add offers:</strong></p>
            <ol className="list-decimal list-inside text-left">
              <li>Open MySQL: <code className="bg-white px-2 py-1 rounded">mysql -u root -p</code></li>
              <li>Run: <code className="bg-white px-2 py-1 rounded">USE TransportBookingSystem;</code></li>
              <li>Run: <code className="bg-white px-2 py-1 rounded">SOURCE sql-enhanced/09_ADDITIONAL_TABLES.sql;</code></li>
            </ol>
          </div>
        </div>
      </div>
    );
  }

  console.log('✅ Showing offers grid with', offers.length, 'offers');

  return (
    <div className="max-w-7xl mx-auto px-4 py-6">
      {bookingData ? (
        <>
          <h2 className="text-3xl font-bold text-slate-900 mb-4">🎁 Select an Offer for Your Ride</h2>
          
          {/* Booking Summary */}
          <Card className="mb-6 bg-gradient-to-r from-blue-50 to-purple-50 border-blue-200">
            <div className="flex justify-between items-center mb-4">
              <div>
                <h3 className="text-lg font-semibold text-slate-800">Your Booking</h3>
                <p className="text-sm text-slate-600">
                  {bookingData.startLocation} → {bookingData.endLocation}
                </p>
              </div>
              <div className="text-right">
                <p className="text-sm text-slate-600">Original Amount</p>
                <p className="text-2xl font-bold text-slate-900">₹{bookingData.totalAmount.toFixed(2)}</p>
              </div>
            </div>
            
            {selectedOffer && (
              <div className="border-t border-blue-200 pt-4">
                <div className="flex justify-between items-center">
                  <div>
                    <p className="text-sm font-semibold text-green-700">
                      🎁 {selectedOffer.OfferCode} Applied ({selectedOffer.DiscountPercentage}% off)
                    </p>
                    <p className="text-xs text-slate-600">Discount: -₹{discountAmount.toFixed(2)}</p>
                  </div>
                  <div className="text-right">
                    <p className="text-sm text-slate-600">Final Amount</p>
                    <p className="text-2xl font-bold text-green-600">₹{finalAmount.toFixed(2)}</p>
                  </div>
                </div>
              </div>
            )}
          </Card>
          
          {/* Action Buttons */}
          <div className="flex gap-4 mb-6">
            {selectedOffer ? (
              <Button
                onClick={completeBookingWithOffer}
                isLoading={isProcessingBooking}
                variant="gradient"
                className="flex-1"
              >
                Complete Booking - ₹{finalAmount.toFixed(2)}
              </Button>
            ) : (
              <Button
                onClick={proceedWithoutOffer}
                isLoading={isProcessingBooking}
                variant="secondary"
                className="flex-1"
              >
                Skip Offers - ₹{bookingData.totalAmount.toFixed(2)}
              </Button>
            )}
          </div>
        </>
      ) : (
        <h2 className="text-3xl font-bold text-slate-900 mb-6">🎁 Active Offers & Discounts</h2>
      )}
      
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {offers.map((offer) => (
          <Card key={offer.OfferID}>
            <div className="relative">
              {/* Discount Badge */}
              <div className="absolute -top-3 -right-3 bg-gradient-to-r from-orange-500 to-red-500 text-white rounded-full w-16 h-16 flex items-center justify-center font-bold shadow-lg">
                {offer.DiscountPercentage}%
              </div>

              {/* Offer Code */}
              <div className="mb-4">
                <div className="flex items-center justify-between mb-2">
                  <span className="text-xs text-slate-500 uppercase font-semibold">Promo Code</span>
                </div>
                <div className="bg-gradient-to-r from-blue-50 to-purple-50 border-2 border-dashed border-blue-300 rounded-lg p-3 flex items-center justify-between">
                  <span className="text-xl font-bold text-blue-600 tracking-wider">
                    {offer.OfferCode}
                  </span>
                  {bookingData ? (
                    <Button
                      onClick={() => selectOffer(offer)}
                      variant={selectedOffer?.OfferID === offer.OfferID ? "primary" : "secondary"}
                      className="text-xs"
                    >
                      {selectedOffer?.OfferID === offer.OfferID ? '✓ Selected' : 'Select'}
                    </Button>
                  ) : (
                    <Button
                      onClick={() => copyCode(offer.OfferCode)}
                      variant="secondary"
                      className="text-xs"
                    >
                      {copiedCode === offer.OfferCode ? '✓ Copied' : 'Copy'}
                    </Button>
                  )}
                </div>
              </div>

              {/* Offer Details */}
              <div className="space-y-3">
                <div className="flex items-center justify-between">
                  <span className="text-sm text-slate-600">Discount</span>
                  <span className="text-lg font-bold text-green-600">
                    {offer.DiscountPercentage}% OFF
                  </span>
                </div>

                <div className="flex items-center justify-between">
                  <span className="text-sm text-slate-600">Max Discount</span>
                  <span className="text-lg font-bold text-slate-900">
                    ₹{offer.MaxDiscountAmount}
                  </span>
                </div>

                <div className="border-t border-slate-200 pt-3 mt-3">
                  <div className="text-xs text-slate-500">
                    <div className="flex justify-between mb-1">
                      <span>Valid From:</span>
                      <span className="font-semibold">{formatDate(offer.ValidFrom)}</span>
                    </div>
                    <div className="flex justify-between">
                      <span>Valid Until:</span>
                      <span className="font-semibold">{formatDate(offer.ValidTo)}</span>
                    </div>
                  </div>
                </div>

                {/* Status Badge */}
                {offer.IsActive && (
                  <div className="bg-green-100 text-green-700 text-xs font-semibold px-3 py-1 rounded-full text-center">
                    ✓ Active Now
                  </div>
                )}
              </div>
            </div>
          </Card>
        ))}
      </div>

      {offers.length === 0 && (
        <div className="text-center py-12">
          <p className="text-slate-500 text-lg">No active offers available</p>
        </div>
      )}
    </div>
  );
};

export default OffersPage;
