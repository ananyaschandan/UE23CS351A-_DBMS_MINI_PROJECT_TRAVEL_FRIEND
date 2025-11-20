import React from 'react';
import { Page } from '../App';

interface LandingPageProps {
  navigate: (page: Page) => void;
  PageEnum: typeof Page;
}

const RoleCard: React.FC<{
  icon: React.ReactNode;
  title: string;
  description: string;
  linkText: string;
  linkColor: string;
  onSelect: () => void;
}> = ({ icon, title, description, linkText, linkColor, onSelect }) => (
  <div className="bg-white rounded-2xl shadow-xl p-8 text-center flex flex-col items-center transition-transform hover:scale-[1.03] duration-300 ease-in-out">
    <div className="mb-6">{icon}</div>
    <h2 className="text-2xl font-bold text-slate-900 mb-2">{title}</h2>
    <p className="text-slate-500 mb-6 flex-grow">{description}</p>
    <button onClick={onSelect} className={`font-semibold ${linkColor} group text-lg`}>
      {linkText} <span className="transition-transform group-hover:translate-x-1 inline-block">&rarr;</span>
    </button>
  </div>
);

const LandingPage: React.FC<LandingPageProps> = ({ navigate, PageEnum }) => {
  return (
    <div className="min-h-screen flex flex-col items-center justify-center bg-slate-50 p-6 font-sans">
      <div className="flex flex-col items-center text-center max-w-5xl w-full">
        <div className="mb-8 p-5 bg-gradient-to-br from-blue-500 to-purple-600 rounded-2xl shadow-lg">
           <svg xmlns="http://www.w3.org/2000/svg" className="h-12 w-12 text-white" viewBox="0 0 24 24" fill="currentColor">
              <path d="M19.93,10.63L14.3,3.13C13.5,2 12,1.33 10.33,1.33H5.33C4.23,1.33 3.33,2.23 3.33,3.33V15.33C3.33,16.43 4.23,17.33 5.33,17.33H10.5C11.55,17.33 12.5,17.83 13.07,18.67L15.25,22.07C15.72,22.84 16.73,22.88 17.26,22.18L21.23,16.12C22.2,14.65 21.47,12.43 19.93,10.63ZM11.33,15.33H5.33V3.33H10.33C11,3.33 11.5,3.67 11.83,4.17L17.17,11.33C17.5,11.67 17.33,12.33 16.83,12.33H13.33C12.23,12.33 11.33,13.23 11.33,14.33V15.33Z" />
           </svg>
        </div>

        <h1 className="text-5xl md:text-6xl font-extrabold text-slate-900 mb-3">
          Welcome to <span className="text-transparent bg-clip-text bg-gradient-to-r from-blue-600 to-purple-700">RideHub</span>
        </h1>
        <p className="text-lg text-slate-600 mb-12">
          Choose your role to continue
        </p>

        <div className="grid md:grid-cols-2 gap-8 w-full max-w-4xl">
          <RoleCard
            title="Login as User"
            description="Book rides, compare prices, track your journeys"
            linkText="Get Started"
            linkColor="text-blue-600"
            icon={
              <div className="bg-blue-500 rounded-xl p-4 shadow-md">
                <svg xmlns="http://www.w3.org/2000/svg" className="h-10 w-10 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
                  <path strokeLinecap="round" strokeLinejoin="round" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                </svg>
              </div>
            }
            onSelect={() => navigate(PageEnum.UserLogin)}
          />
          <RoleCard
            title="Login as Provider"
            description="Manage vehicles, view bookings, track earnings"
            linkText="Provider Portal"
            linkColor="text-purple-600"
            icon={
               <div className="bg-purple-500 rounded-xl p-4 shadow-md">
                <svg xmlns="http://www.w3.org/2000/svg" className="h-10 w-10 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
                  <path strokeLinecap="round" strokeLinejoin="round" d="M21 13.255A23.931 23.931 0 0112 15c-3.183 0-6.22-.62-9-1.745M16 6V4a2 2 0 00-2-2h-4a2 2 0 00-2 2v2m4 6h.01M5 20h14a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
                </svg>
              </div>
            }
            onSelect={() => navigate(PageEnum.ProviderLogin)}
          />
        </div>
        
        <p className="mt-12 text-slate-600">
          Don't have an account?{' '}
          <button onClick={() => navigate(PageEnum.UserSignup)} className="font-semibold text-blue-600 hover:underline">Sign up as User</button>
          {' or '}
          <button onClick={() => navigate(PageEnum.ProviderSignup)} className="font-semibold text-purple-600 hover:underline">Become a Provider</button>
        </p>

      </div>
    </div>
  );
};

export default LandingPage;
