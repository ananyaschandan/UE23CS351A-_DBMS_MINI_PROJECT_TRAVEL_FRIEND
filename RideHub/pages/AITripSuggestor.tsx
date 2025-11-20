import React, { useState } from 'react';
import Card from '../components/Card';
import Button from '../components/Button';
import { generateTripSuggestion } from '../services/GeminiService';
import { TripSuggestion } from '../types';

const AITripSuggester: React.FC = () => {
  const [destination, setDestination] = useState('Bangalore');
  const [interests, setInterests] = useState('food and history');
  const [suggestion, setSuggestion] = useState<TripSuggestion | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [isMockData, setIsMockData] = useState(false);

  const handleGenerate = async () => {
    setIsLoading(true);
    setError(null);
    setSuggestion(null);
    setIsMockData(false);
    
    const result = await generateTripSuggestion(destination, interests);
    if (result) {
      setSuggestion(result.suggestion);
      setIsMockData(result.metadata?.isMockData || false);
    } else {
      setError('Could not generate a suggestion. The AI service may be unavailable.');
    }
    setIsLoading(false);
  };

  return (
    <Card className="sticky top-8">
      <h3 className="text-xl font-semibold mb-4 text-blue-600 flex items-center">
        <svg xmlns="http://www.w3.org/2000/svg" className="h-6 w-6 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9.663 17h4.673M12 3v1m6.364 1.636l-.707.707M21 12h-1M4 12H3m3.343-5.657l-.707-.707m2.828 9.9a5 5 0 117.072 0l-.548.547A3.374 3.374 0 0014 18.469V19a2 2 0 11-4 0v-.531c0-.895-.356-1.754-.988-2.386l-.548-.547z" />
        </svg>
        AI Trip Suggester
      </h3>
      
      {!suggestion && !isLoading && (
        <div className="space-y-4">
          <div>
            <label htmlFor="destination" className="block text-sm font-medium text-slate-700 mb-1">Destination</label>
            <input type="text" id="destination" value={destination} onChange={(e) => setDestination(e.target.value)} className="w-full bg-slate-50 border border-slate-300 rounded-md p-2 text-slate-900 focus:ring-blue-500 focus:border-blue-500"/>
          </div>
          <div>
            <label htmlFor="interests" className="block text-sm font-medium text-slate-700 mb-1">Interests</label>
            <input type="text" id="interests" value={interests} onChange={(e) => setInterests(e.target.value)} className="w-full bg-slate-50 border border-slate-300 rounded-md p-2 text-slate-900 focus:ring-blue-500 focus:border-blue-500"/>
          </div>
          <Button onClick={handleGenerate} isLoading={isLoading} disabled={!destination || !interests} className="w-full">
            Generate Itinerary
          </Button>
        </div>
      )}

      {isLoading && (
         <div className="text-center py-10">
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto"></div>
            <p className="mt-4 text-slate-600">Crafting your perfect day...</p>
        </div>
      )}

      {error && <p className="text-red-500 mt-4">{error}</p>}
      
      {suggestion && (
        <div className="mt-4 animate-fade-in">
          {isMockData && (
            <div className="mb-3 p-2 bg-yellow-50 border border-yellow-200 rounded-lg">
              <p className="text-yellow-800 text-xs flex items-center">
                <svg className="w-4 h-4 mr-1" fill="currentColor" viewBox="0 0 20 20">
                  <path fillRule="evenodd" d="M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z" clipRule="evenodd" />
                </svg>
                Demo mode: AI quota exceeded, showing sample itinerary
              </p>
            </div>
          )}
          <h4 className="text-lg font-bold text-slate-900">{suggestion.title}</h4>
          <p className="text-slate-600 mt-2 mb-4 text-sm">{suggestion.summary}</p>
          <div className="space-y-3 border-t border-slate-200 pt-3">
            {suggestion.stops.map((stop, index) => (
              <div key={index}>
                <p className="font-semibold text-blue-600">{stop.timeOfDay}: <span className="text-slate-800">{stop.name}</span></p>
                <p className="text-sm text-slate-500 pl-2 border-l-2 border-slate-300 ml-2 mt-1">{stop.description}</p>
              </div>
            ))}
          </div>
          <Button onClick={() => setSuggestion(null)} variant="secondary" className="w-full mt-6">
            Create Another
          </Button>
        </div>
      )}

      <style>{`
        @keyframes fade-in {
          0% { opacity: 0; }
          100% { opacity: 1; }
        }
        .animate-fade-in {
          animation: fade-in 0.5s ease-in-out forwards;
        }
      `}</style>
    </Card>
  );
};

export default AITripSuggester;
