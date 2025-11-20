import React from 'react';

interface AuthInputProps extends React.InputHTMLAttributes<HTMLInputElement> {
  label: string;
  id: string;
  children?: React.ReactNode;
}

const AuthInput: React.FC<AuthInputProps> = ({ label, id, children, ...props }) => {
  return (
    <div>
      <label htmlFor={id} className="block text-sm font-medium text-slate-700 mb-1">
        {label}
      </label>
      <div className="relative">
        {children && (
            <div className="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" strokeWidth={1.5} stroke="currentColor" className="w-5 h-5 text-slate-400">
                    {children}
                </svg>
            </div>
        )}
        <input
          id={id}
          name={id}
          className={`w-full bg-slate-50 border border-slate-300 rounded-lg py-2 text-slate-900 focus:ring-blue-500 focus:border-blue-500 ${children ? 'pl-10' : 'px-3'}`}
          {...props}
        />
      </div>
    </div>
  );
};

export default AuthInput;
