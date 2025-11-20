import React, { useState, useCallback } from 'react';
import { User, Role } from './types';
import LandingPage from './pages/LandingPage';
import UserDashboard from './pages/UserDashboard';
import ProviderDashboard from './pages/ProviderDashboard';
import BookingPage from './pages/BookingPage';
import MyBookingsPage from './pages/MyBookingsPage';
import LoginPage from './pages/LoginPage';
import UserSignupPage from './pages/UserSignupPage';
import ProviderSignupPage from './pages/ProviderSignupPage';
import MetroPage from './pages/MetroPage';
import OffersPage from './pages/OffersPage';
import BounceCentersPage from './pages/BounceCentersPage';
import BusRoutesPage from './pages/BusRoutesPage';
import AdminDashboard from './pages/AdminDashboard';
import NotificationsPage from './pages/NotificationsPage';
import ProviderProfilePage from './pages/ProviderProfilePage';
import Header from './components/Header';
import { api } from './services/api';

export enum Page {
  Landing,
  UserLogin,
  ProviderLogin,
  UserSignup,
  ProviderSignup,
  UserDashboard,
  ProviderDashboard,
  ProviderProfile,
  Booking,
  MyBookings,
  MetroStations,
  Offers,
  BounceCenters,
  BusRoutes,
  AdminDashboard,
  Notifications,
}

const App: React.FC = () => {
  const [currentUser, setCurrentUser] = useState<User | null>(null);
  const [currentPage, setCurrentPage] = useState<Page>(Page.Landing);
  const [isLoading, setIsLoading] = useState(false);

  const handleLogin = useCallback(async (email: string, password: string, role: Role) => {
    setIsLoading(true);
    try {
      const user = await api.login(email, password, role);
      setCurrentUser(user as User);
      if (role === Role.User) {
        setCurrentPage(Page.UserDashboard);
      } else {
        setCurrentPage(Page.ProviderDashboard);
      }
    } catch (error) {
      console.error("Login failed", error);
      alert('Login failed: ' + (error as Error).message);
    } finally {
      setIsLoading(false);
    }
  }, []);

  const handleSignup = useCallback(async (userData: any, role: Role) => {
    // If userData already has id, it means user is already logged in (from ProviderSignupPage)
    if (userData.id) {
      setCurrentUser(userData as User);
      if (role === Role.User) {
        setCurrentPage(Page.UserDashboard);
      } else {
        setCurrentPage(Page.ProviderDashboard);
      }
      return;
    }

    // Otherwise, handle normal signup flow (for UserSignupPage)
    setIsLoading(true);
    try {
      // Sign up the user
      if (role === Role.User) {
        await api.signupUser(userData);
      } else {
        await api.signupProvider(userData);
      }
      
      // Automatically log in after successful signup
      const user = await api.login(userData.email, userData.password, role);
      setCurrentUser(user as User);
      
      // Navigate to appropriate dashboard
      if (role === Role.User) {
        setCurrentPage(Page.UserDashboard);
      } else {
        setCurrentPage(Page.ProviderDashboard);
      }
      
      alert('Account created successfully! Welcome!');
    } catch (error) {
      console.error('Signup failed', error);
      alert('Signup failed: ' + (error as Error).message);
      throw error; // Re-throw so the signup page can handle it
    } finally {
      setIsLoading(false);
    }
  }, []);

  const handleLogout = useCallback(() => {
    setCurrentUser(null);
    setCurrentPage(Page.Landing);
  }, []);

  const navigate = useCallback((page: Page) => {
    setCurrentPage(page);
  }, []);

  const renderContent = () => {
    if (isLoading && !currentUser) { // Full screen loader only on initial login/signup
      return <div className="flex justify-center items-center h-screen"><div className="animate-spin rounded-full h-32 w-32 border-b-2 border-blue-600"></div></div>;
    }

    // Unauthenticated Routes
    if (!currentUser) {
      switch (currentPage) {
        case Page.UserLogin:
          return <LoginPage role={Role.User} onLogin={handleLogin} navigate={navigate} PageEnum={Page} />;
        case Page.ProviderLogin:
          return <LoginPage role={Role.Provider} onLogin={handleLogin} navigate={navigate} PageEnum={Page} />;
        case Page.UserSignup:
          return <UserSignupPage navigate={navigate} PageEnum={Page} setIsLoading={setIsLoading} onSignup={handleSignup} />;
        case Page.ProviderSignup:
          return <ProviderSignupPage navigate={navigate} PageEnum={Page} setIsLoading={setIsLoading} onSignup={handleSignup} />;
        case Page.BounceCenters:
          return <BounceCentersPage />;
        case Page.Offers:
          return <OffersPage navigate={navigate} PageEnum={Page} />;
        case Page.Landing:
        default:
          return <LandingPage navigate={navigate} PageEnum={Page} />;
      }
    }

    // Authenticated Routes
    switch (currentPage) {
      case Page.UserDashboard:
        return <UserDashboard user={currentUser} navigate={navigate} PageEnum={Page} />;
      case Page.ProviderDashboard:
        return <ProviderDashboard user={currentUser} />;
      case Page.ProviderProfile:
        return <ProviderProfilePage user={currentUser} />;
      case Page.Booking:
        return <BookingPage user={currentUser} navigate={navigate} PageEnum={Page} />;
      case Page.MyBookings:
        return <MyBookingsPage user={currentUser} navigate={navigate} PageEnum={Page} />;
      case Page.MetroStations:
        return <MetroPage user={currentUser} />;
      case Page.Offers:
        return <OffersPage navigate={navigate} PageEnum={Page} />;
      case Page.BounceCenters:
        return <BounceCentersPage />;
      case Page.BusRoutes:
        return <BusRoutesPage />;
      case Page.AdminDashboard:
        return <AdminDashboard user={currentUser} />;
      case Page.Notifications:
        return <NotificationsPage user={currentUser} />;
      default:
        // If logged in but on a non-authed page, redirect to their dashboard
        return currentUser.role === Role.User
          ? <UserDashboard user={currentUser} navigate={navigate} PageEnum={Page} />
          : <ProviderDashboard user={currentUser} />;
    }
  };

  return (
    <div className="min-h-screen bg-slate-50 font-sans">
       {currentUser && <Header 
        user={currentUser} 
        onLogout={handleLogout} 
        navigate={navigate} 
        currentPage={currentPage} 
        PageEnum={Page}
      />}
      <main className={!currentUser ? '' : "p-4 md:p-8"}>
        {renderContent()}
      </main>
    </div>
  );
};

export default App;