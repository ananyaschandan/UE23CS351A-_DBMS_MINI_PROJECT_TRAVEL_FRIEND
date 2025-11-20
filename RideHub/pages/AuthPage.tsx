import React from 'react';

interface AuthPageProps {
  title: string;
  subtitle: string;
  children: React.ReactNode;
}

const AuthPage: React.FC<AuthPageProps> = ({ title, subtitle, children }) => {
  return (
    <div className="min-h-screen flex flex-col items-center justify-center bg-slate-50 p-4">
      <div className="w-full max-w-md">
        <div className="text-center mb-8">
          <h1 className="text-4xl md:text-5xl font-extrabold text-slate-900 mb-2">
            <span className="text-transparent bg-clip-text bg-gradient-to-r from-blue-600 to-purple-700">{title}</span>
          </h1>
          <p className="text-slate-600">{subtitle}</p>
        </div>
        <div className="bg-white p-8 rounded-lg shadow-lg border border-slate-200">
          {children}
        </div>
      </div>
    </div>
  );
};

export default AuthPage;
