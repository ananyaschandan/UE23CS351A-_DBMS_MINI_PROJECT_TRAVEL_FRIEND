import React, { useState } from 'react';
import { Role } from '../types';
import { Page } from '../App';
import Button from '../components/Button';
import AuthPage from './AuthPage';
import AuthInput from '../components/AuthInput';

interface LoginPageProps {
  role: Role;
  onLogin: (email: string, password: string, role: Role) => void;
  navigate: (page: Page) => void;
  PageEnum: typeof Page;
}

const LoginPage: React.FC<LoginPageProps> = ({ role, onLogin, navigate, PageEnum }) => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [isLoading, setIsLoading] = useState(false);

  const isUser = role === Role.User;
  const title = isUser ? 'User Login' : 'Provider Login';
  const subtitle = 'Welcome back! Please enter your details.';
  
  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsLoading(true);
    await onLogin(email, password, role);
    setIsLoading(false);
  }

  return (
    <AuthPage title={title} subtitle={subtitle}>
      <form onSubmit={handleSubmit} className="space-y-6">
        <AuthInput
          id="email"
          type="email"
          label="Email Address"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          placeholder="you@example.com"
          required
        >
          <path strokeLinecap="round" strokeLinejoin="round" d="M21.75 6.75v10.5a2.25 2.25 0 01-2.25 2.25h-15a2.25 2.25 0 01-2.25-2.25V6.75m19.5 0A2.25 2.25 0 0019.5 4.5h-15a2.25 2.25 0 00-2.25 2.25m19.5 0v.243a2.25 2.25 0 01-1.07 1.916l-7.5 4.615a2.25 2.25 0 01-2.36 0L3.32 8.91a2.25 2.25 0 01-1.07-1.916V6.75" />
        </AuthInput>

        <AuthInput
          id="password"
          type="password"
          label="Password"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          placeholder="••••••••"
          required
        >
          <path strokeLinecap="round" strokeLinejoin="round" d="M16.5 10.5V6.75a4.5 4.5 0 10-9 0v3.75m-.75 11.25h10.5a2.25 2.25 0 002.25-2.25v-6.75a2.25 2.25 0 00-2.25-2.25H6.75a2.25 2.25 0 00-2.25 2.25v6.75a2.25 2.25 0 002.25 2.25z" />
        </AuthInput>
        
        <Button type="submit" isLoading={isLoading} className="w-full !py-3 !text-base" variant="gradient">
          Sign In
        </Button>
      </form>
      <p className="mt-6 text-center text-sm text-slate-600">
        {isUser ? "Don't have an account?" : "Not a provider yet?"}{' '}
        <button 
          onClick={() => navigate(isUser ? PageEnum.UserSignup : PageEnum.ProviderSignup)} 
          className="font-semibold text-blue-600 hover:text-blue-500"
        >
          {isUser ? "Sign Up" : "Become a Provider"}
        </button>
      </p>
    </AuthPage>
  );
};

export default LoginPage;
