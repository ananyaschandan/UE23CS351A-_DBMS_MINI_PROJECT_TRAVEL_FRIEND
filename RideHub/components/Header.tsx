import React from 'react';
import { User, Role } from '../types';

interface HeaderProps {
  user: User | null;
  onLogout: () => void;
  navigate: (page: any) => void;
  currentPage: any;
  PageEnum: any;
}

const NavLink: React.FC<{
  onClick: () => void;
  isActive: boolean;
  children: React.ReactNode;
}> = ({ onClick, isActive, children }) => (
  <button
    onClick={onClick}
    className={`px-3 py-2 rounded-md text-sm font-medium transition-colors ${
      isActive
        ? 'bg-blue-600 text-white'
        : 'text-slate-600 hover:bg-slate-100 hover:text-slate-900'
    }`}
  >
    {children}
  </button>
);


const Header: React.FC<HeaderProps> = ({ user, onLogout, navigate, currentPage, PageEnum }) => {
  return (
    <header className="bg-white shadow-sm border-b border-slate-200">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex items-center justify-between h-16">
          <div className="flex items-center">
             <h1 className="text-2xl font-bold text-transparent bg-clip-text bg-gradient-to-r from-blue-600 to-purple-700 cursor-pointer" onClick={() => navigate(user?.role === Role.User ? PageEnum.UserDashboard : PageEnum.ProviderDashboard)}>
              RideHub
            </h1>
          </div>
          {user && (
            <div className="flex items-center space-x-4">
              <div className="hidden md:flex items-center space-x-2">
                {user.role === Role.User && (
                  <>
                    <NavLink onClick={() => navigate(PageEnum.UserDashboard)} isActive={currentPage === PageEnum.UserDashboard}>Dashboard</NavLink>
                    <NavLink onClick={() => navigate(PageEnum.Booking)} isActive={currentPage === PageEnum.Booking}>Book Ride</NavLink>
                    <NavLink onClick={() => navigate(PageEnum.MyBookings)} isActive={currentPage === PageEnum.MyBookings}>My Bookings</NavLink>
                    <NavLink onClick={() => navigate(PageEnum.Notifications)} isActive={currentPage === PageEnum.Notifications}>🔔 Notifications</NavLink>
                    <NavLink onClick={() => navigate(PageEnum.MetroStations)} isActive={currentPage === PageEnum.MetroStations}>🚇 Metro</NavLink>
                    <NavLink onClick={() => navigate(PageEnum.BusRoutes)} isActive={currentPage === PageEnum.BusRoutes}>🚌 Buses</NavLink>
                    <NavLink onClick={() => navigate(PageEnum.BounceCenters)} isActive={currentPage === PageEnum.BounceCenters}>🛴 Bounce</NavLink>
                    <NavLink onClick={() => navigate(PageEnum.Offers)} isActive={currentPage === PageEnum.Offers}>🎁 Offers</NavLink>
                  </>
                )}
                 {user.role === Role.Provider && (
                  <>
                    <NavLink onClick={() => navigate(PageEnum.ProviderDashboard)} isActive={currentPage === PageEnum.ProviderDashboard}>Dashboard</NavLink>
                    <NavLink onClick={() => navigate(PageEnum.ProviderProfile)} isActive={currentPage === PageEnum.ProviderProfile}>📄 My Documents</NavLink>
                  </>
                )}
              </div>
              <div className="flex items-center">
                <span className="text-slate-600 mr-4">Welcome, {user.fullName}</span>
                <button
                  onClick={onLogout}
                  className="bg-red-500 hover:bg-red-600 text-white px-3 py-2 rounded-md text-sm font-medium transition-colors"
                >
                  Logout
                </button>
              </div>
            </div>
          )}
        </div>
      </div>
    </header>
  );
};

export default Header;
