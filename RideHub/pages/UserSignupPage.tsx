import React, { useState } from 'react';
import { Page } from '../App';
import { Role } from '../types';
import Button from '../components/Button';
import AuthPage from './AuthPage';
import AuthInput from '../components/AuthInput';

interface UserSignupPageProps {
  navigate: (page: Page) => void;
  PageEnum: typeof Page;
  setIsLoading: (isLoading: boolean) => void;
  onSignup: (userData: any, role: Role) => Promise<void>;
}

const UserSignupPage: React.FC<UserSignupPageProps> = ({ navigate, PageEnum, setIsLoading, onSignup }) => {
  const [formData, setFormData] = useState({
    firstName: '',
    lastName: '',
    username: '',
    phone: '',
    email: '',
    age: '',
    password: '',
  });

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      const { age, ...rest } = formData;
      const userData = { ...rest, age: parseInt(age, 10) };
      await onSignup(userData, Role.User);
      // onSignup handles loading state, login, and navigation
    } catch (error) {
      // Error already handled by onSignup
      console.error('Signup failed', error);
    }
  };

  return (
    <AuthPage title="Create Account" subtitle="Join us and start your journey">
      <form onSubmit={handleSubmit} className="space-y-5">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <AuthInput label="First Name" id="firstName" name="firstName" value={formData.firstName} onChange={handleChange} required>
                <path strokeLinecap="round" strokeLinejoin="round" d="M15.75 6a3.75 3.75 0 11-7.5 0 3.75 3.75 0 017.5 0zM4.501 20.118a7.5 7.5 0 0114.998 0A17.933 17.933 0 0112 21.75c-2.676 0-5.216-.584-7.499-1.632z" />
            </AuthInput>
            <AuthInput label="Last Name" id="lastName" name="lastName" value={formData.lastName} onChange={handleChange} required>
                 <path strokeLinecap="round" strokeLinejoin="round" d="M15.75 6a3.75 3.75 0 11-7.5 0 3.75 3.75 0 017.5 0zM4.501 20.118a7.5 7.5 0 0114.998 0A17.933 17.933 0 0112 21.75c-2.676 0-5.216-.584-7.499-1.632z" />
            </AuthInput>
            <AuthInput label="Username" id="username" name="username" value={formData.username} onChange={handleChange} required>
                <path strokeLinecap="round" strokeLinejoin="round" d="M15.75 6a3.75 3.75 0 11-7.5 0 3.75 3.75 0 017.5 0zM4.501 20.118a7.5 7.5 0 0114.998 0A17.933 17.933 0 0112 21.75c-2.676 0-5.216-.584-7.499-1.632z" />
            </AuthInput>
            <AuthInput label="Phone Number" id="phone" name="phone" type="tel" value={formData.phone} onChange={handleChange} required>
                <path strokeLinecap="round" strokeLinejoin="round" d="M2.25 6.75c0 8.284 6.716 15 15 15h2.25a2.25 2.25 0 002.25-2.25v-1.372c0-.516-.351-.966-.852-1.091l-4.423-1.106c-.44-.11-.902.055-1.173.417l-.97 1.293c-.282.376-.769.542-1.21.38a12.035 12.035 0 01-7.143-7.143c-.162-.441.004-.928.38-1.21l1.293-.97c.363-.271.527-.734.417-1.173L6.963 3.102a1.125 1.125 0 00-1.091-.852H4.5A2.25 2.25 0 002.25 6.75z" />
            </AuthInput>
        </div>
        <AuthInput label="Email Address" id="email" name="email" type="email" value={formData.email} onChange={handleChange} required>
             <path strokeLinecap="round" strokeLinejoin="round" d="M21.75 6.75v10.5a2.25 2.25 0 01-2.25 2.25h-15a2.25 2.25 0 01-2.25-2.25V6.75m19.5 0A2.25 2.25 0 0019.5 4.5h-15a2.25 2.25 0 00-2.25 2.25m19.5 0v.243a2.25 2.25 0 01-1.07 1.916l-7.5 4.615a2.25 2.25 0 01-2.36 0L3.32 8.91a2.25 2.25 0 01-1.07-1.916V6.75" />
        </AuthInput>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <AuthInput label="Age (18+)" id="age" name="age" type="number" min="18" value={formData.age} onChange={handleChange} required>
                <path strokeLinecap="round" strokeLinejoin="round" d="M6.75 3v2.25M17.25 3v2.25M3 18.75V7.5a2.25 2.25 0 012.25-2.25h13.5A2.25 2.25 0 0121 7.5v11.25m-18 0A2.25 2.25 0 005.25 21h13.5A2.25 2.25 0 0021 18.75m-18 0v-7.5A2.25 2.25 0 0115.25 9h13.5A2.25 2.25 0 0121 11.25v7.5" />
            </AuthInput>
            <AuthInput label="Password" id="password" name="password" type="password" value={formData.password} onChange={handleChange} required>
                 <path strokeLinecap="round" strokeLinejoin="round" d="M16.5 10.5V6.75a4.5 4.5 0 10-9 0v3.75m-.75 11.25h10.5a2.25 2.25 0 002.25-2.25v-6.75a2.25 2.25 0 00-2.25-2.25H6.75a2.25 2.25 0 00-2.25 2.25v6.75a2.25 2.25 0 002.25 2.25z" />
            </AuthInput>
        </div>
        <Button type="submit" className="w-full !py-3 !text-base !mt-8" variant="gradient">
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" strokeWidth={1.5} stroke="currentColor" className="w-6 h-6 mr-2">
            <path strokeLinecap="round" strokeLinejoin="round" d="M19 7.5v3m0 0v3m0-3h3m-3 0h-3m-2.25-4.125a3.375 3.375 0 11-6.75 0 3.375 3.375 0 016.75 0zM4 19.235v-.11a6.375 6.375 0 0112.75 0v.109A12.318 12.318 0 0110.374 21c-2.331 0-4.512-.645-6.374-1.766z" />
          </svg>
          Create Account
        </Button>
      </form>
      <p className="mt-6 text-center text-sm text-slate-600">
        Already have an account?{' '}
        <button 
          onClick={() => navigate(PageEnum.UserLogin)} 
          className="font-semibold text-blue-600 hover:text-blue-500"
        >
          Sign In
        </button>
      </p>
    </AuthPage>
  );
};

export default UserSignupPage;
