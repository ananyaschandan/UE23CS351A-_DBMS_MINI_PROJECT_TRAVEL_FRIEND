import React, { useState } from 'react';
import { Page } from '../App';
import { Role } from '../types';
import Button from '../components/Button';
import AuthPage from './AuthPage';
import AuthInput from '../components/AuthInput';

interface FileWithPreview {
  file: File;
  preview: string;
}

interface ProviderSignupPageProps {
  navigate: (page: Page) => void;
  PageEnum: typeof Page;
  setIsLoading: (isLoading: boolean) => void;
  onSignup: (userData: any, role: Role) => Promise<void>;
}

const SectionTitle: React.FC<{ icon: React.ReactNode, title: string }> = ({ icon, title }) => (
    <div className="flex items-center text-lg font-semibold text-slate-800 border-b border-slate-200 pb-2 mb-4">
        {icon}
        <h2 className="ml-2">{title}</h2>
    </div>
);

const FileUploadField: React.FC<{
  label: string;
  fieldName: string;
  file?: FileWithPreview;
  onChange: (e: React.ChangeEvent<HTMLInputElement>, fieldName: string) => void;
  required?: boolean;
}> = ({ label, fieldName, file, onChange, required }) => (
  <div>
    <label className="block text-sm font-medium text-slate-700 mb-2">
      {label}
    </label>
    <div className="relative">
      <input
        type="file"
        accept="image/*,application/pdf"
        onChange={(e) => onChange(e, fieldName)}
        required={required}
        className="block w-full text-sm text-slate-500
          file:mr-4 file:py-2 file:px-4
          file:rounded-lg file:border-0
          file:text-sm file:font-semibold
          file:bg-purple-50 file:text-purple-700
          hover:file:bg-purple-100
          cursor-pointer"
      />
    </div>
    {file && (
      <div className="mt-3 p-3 bg-slate-50 rounded-lg border border-slate-200">
        {file.preview ? (
          <div className="flex items-start space-x-3">
            <img 
              src={file.preview} 
              alt="Preview" 
              className="w-20 h-20 object-cover rounded-lg border border-slate-300"
            />
            <div className="flex-1">
              <p className="text-sm font-medium text-slate-900">{file.file.name}</p>
              <p className="text-xs text-slate-500">{(file.file.size / 1024).toFixed(2)} KB</p>
              <p className="text-xs text-green-600 mt-1">✓ File uploaded</p>
            </div>
          </div>
        ) : (
          <div>
            <p className="text-sm font-medium text-slate-900">{file.file.name}</p>
            <p className="text-xs text-slate-500">{(file.file.size / 1024).toFixed(2)} KB</p>
            <p className="text-xs text-green-600 mt-1">✓ File uploaded</p>
          </div>
        )}
      </div>
    )}
  </div>
);


const ProviderSignupPage: React.FC<ProviderSignupPageProps> = ({ navigate, PageEnum, setIsLoading, onSignup }) => {
  const [formData, setFormData] = useState({
    firstName: '',
    lastName: '',
    username: '',
    phone: '',
    email: '',
    age: '',
    password: '',
    servicePartnership: 'Individual' as const,
    ratePerHour: '200',
  });

  const [files, setFiles] = useState<{
    drivingLicense?: FileWithPreview;
    aadhaarCard?: FileWithPreview;
    panCard?: FileWithPreview;
    photo?: FileWithPreview;
    vehicleRegistration?: FileWithPreview;
    vehicleInsurance?: FileWithPreview;
    pollutionCertificate?: FileWithPreview;
  }>({});

  const [uploadError, setUploadError] = useState('');

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>, fieldName: string) => {
    const file = e.target.files?.[0];
    if (!file) return;

    // Validate file size (5MB max)
    if (file.size > 5 * 1024 * 1024) {
      setUploadError(`${fieldName}: File size must be less than 5MB`);
      return;
    }

    // Validate file type
    if (!file.type.startsWith('image/') && file.type !== 'application/pdf') {
      setUploadError(`${fieldName}: Only images and PDFs are allowed`);
      return;
    }

    setUploadError('');

    // Create preview for images
    const preview = file.type.startsWith('image/') ? URL.createObjectURL(file) : '';

    setFiles(prev => ({
      ...prev,
      [fieldName]: { file, preview }
    }));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsLoading(true);
    
    try {
      // Validate required documents
      if (!files.drivingLicense || !files.aadhaarCard || !files.photo || !files.vehicleRegistration) {
        alert('Please upload all required documents (marked with *)');
        setIsLoading(false);
        return;
      }

      // Create FormData for multipart upload
      const formDataToSend = new FormData();
      
      // Add text fields
      Object.keys(formData).forEach(key => {
        formDataToSend.append(key, (formData as any)[key]);
      });

      // Add files
      if (files.drivingLicense) formDataToSend.append('drivingLicense', files.drivingLicense.file);
      if (files.aadhaarCard) formDataToSend.append('aadhaarCard', files.aadhaarCard.file);
      if (files.panCard) formDataToSend.append('panCard', files.panCard.file);
      if (files.photo) formDataToSend.append('photo', files.photo.file);
      if (files.vehicleRegistration) formDataToSend.append('vehicleRegistration', files.vehicleRegistration.file);
      if (files.vehicleInsurance) formDataToSend.append('vehicleInsurance', files.vehicleInsurance.file);
      if (files.pollutionCertificate) formDataToSend.append('pollutionCertificate', files.pollutionCertificate.file);

      // Send to backend
      const response = await fetch('http://localhost:5000/api/auth/signup/provider', {
        method: 'POST',
        body: formDataToSend,
      });

      const data = await response.json();

      if (!response.ok) {
        throw new Error(data.error || 'Signup failed');
      }

      // Auto-login after successful signup
      const loginResponse = await fetch('http://localhost:5000/api/auth/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          email: formData.email,
          role: 'PROVIDER'
        })
      });

      const userData = await loginResponse.json();
      
      if (loginResponse.ok) {
        alert(`Account created successfully! ${data.message}`);
        // Call onSignup to set user and navigate
        await onSignup(userData, Role.Provider);
      } else {
        alert('Account created! Please log in manually.');
        navigate(PageEnum.ProviderLogin);
      }
    } catch (error: any) {
      console.error('Signup failed', error);
      alert('Signup failed: ' + error.message);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <AuthPage title="Become a Provider" subtitle="Register your vehicle and start earning">
      <form onSubmit={handleSubmit} className="space-y-6">
        {/* Personal Info */}
        <section>
             <SectionTitle title="Personal Information" icon={<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" strokeWidth={1.5} stroke="currentColor" className="w-6 h-6"><path strokeLinecap="round" strokeLinejoin="round" d="M15.75 6a3.75 3.75 0 11-7.5 0 3.75 3.75 0 017.5 0zM4.501 20.118a7.5 7.5 0 0114.998 0A17.933 17.933 0 0112 21.75c-2.676 0-5.216-.584-7.499-1.632z" /></svg>} />
             <div className="space-y-4">
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <AuthInput label="First Name" id="firstName" name="firstName" value={formData.firstName} onChange={handleChange} required />
                    <AuthInput label="Last Name" id="lastName" name="lastName" value={formData.lastName} onChange={handleChange} required />
                    <AuthInput label="Username" id="username" name="username" value={formData.username} onChange={handleChange} required />
                    <AuthInput label="Phone Number" id="phone" name="phone" type="tel" value={formData.phone} onChange={handleChange} required />
                </div>
                <AuthInput label="Email Address" id="email" name="email" type="email" value={formData.email} onChange={handleChange} required />
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <AuthInput label="Age (18+)" id="age" name="age" type="number" min="18" value={formData.age} onChange={handleChange} required />
                    <AuthInput label="Password" id="password" name="password" type="password" value={formData.password} onChange={handleChange} required />
                </div>
            </div>
        </section>

        {/* Provider Details */}
        <section>
            <SectionTitle title="Provider Details" icon={<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" strokeWidth={1.5} stroke="currentColor" className="w-6 h-6"><path strokeLinecap="round" strokeLinejoin="round" d="M8.25 21v-4.875c0-.621.504-1.125 1.125-1.125h2.25c.621 0 1.125.504 1.125 1.125V21m0 0h4.5V3.545M12.75 21h7.5V10.75M2.25 21h1.5m18 0h-18M2.25 9l4.5-1.636M18.75 3l-1.5.545m0 6.205l3 1m-3-1l-3-1m-3 1l-3 1m-3-1l3 1m0 0l3 1.636m-3-1.636l-3-1.636" /></svg>} />
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                     <label htmlFor="servicePartnership" className="block text-sm font-medium text-slate-700 mb-1">Service Partnership</label>
                    <select id="servicePartnership" name="servicePartnership" value={formData.servicePartnership} onChange={handleChange} className="w-full bg-slate-50 border border-slate-300 rounded-lg py-2 px-3 text-slate-900 focus:ring-blue-500 focus:border-blue-500">
                        <option>Individual</option>
                    </select>
                </div>
                <AuthInput label="Rate Per Hour (₹)" id="ratePerHour" name="ratePerHour" type="number" value={formData.ratePerHour} onChange={handleChange} required />
            </div>
        </section>
        
        {/* Documents */}
        <section>
             <SectionTitle title="Documents Upload" icon={<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" strokeWidth={1.5} stroke="currentColor" className="w-6 h-6"><path strokeLinecap="round" strokeLinejoin="round" d="M19.5 14.25v-2.625a3.375 3.375 0 00-3.375-3.375h-1.5A1.125 1.125 0 0113.5 7.125v-1.5a3.375 3.375 0 00-3.375-3.375H8.25m2.25 0H5.625c-.621 0-1.125.504-1.125 1.125v17.25c0 .621.504 1.125 1.125 1.125h12.75c.621 0 1.125-.504 1.125-1.125V11.25a9 9 0 00-9-9z" /></svg>} />
             {uploadError && (
               <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg mb-4">
                 {uploadError}
               </div>
             )}
             <div className="space-y-4">
                <FileUploadField 
                  label="Driving License *" 
                  fieldName="drivingLicense" 
                  file={files.drivingLicense} 
                  onChange={handleFileChange} 
                  required 
                />
                <FileUploadField 
                  label="Aadhaar Card *" 
                  fieldName="aadhaarCard" 
                  file={files.aadhaarCard} 
                  onChange={handleFileChange} 
                  required 
                />
                <FileUploadField 
                  label="PAN Card" 
                  fieldName="panCard" 
                  file={files.panCard} 
                  onChange={handleFileChange} 
                />
                <FileUploadField 
                  label="Profile Photo *" 
                  fieldName="photo" 
                  file={files.photo} 
                  onChange={handleFileChange} 
                  required 
                />
                <FileUploadField 
                  label="Vehicle Registration (RC) *" 
                  fieldName="vehicleRegistration" 
                  file={files.vehicleRegistration} 
                  onChange={handleFileChange} 
                  required 
                />
                <FileUploadField 
                  label="Vehicle Insurance" 
                  fieldName="vehicleInsurance" 
                  file={files.vehicleInsurance} 
                  onChange={handleFileChange} 
                />
                <FileUploadField 
                  label="Pollution Certificate (PUC)" 
                  fieldName="pollutionCertificate" 
                  file={files.pollutionCertificate} 
                  onChange={handleFileChange} 
                />
             </div>
             <p className="text-xs text-slate-500 mt-2">* Required documents. Max file size: 5MB. Formats: JPG, PNG, WebP, PDF</p>
        </section>

        <Button type="submit" className="w-full !py-3 !text-base !mt-8 bg-purple-600 hover:bg-purple-700 focus:ring-purple-500">
           <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" strokeWidth={1.5} stroke="currentColor" className="w-6 h-6 mr-2">
            <path strokeLinecap="round" strokeLinejoin="round" d="M9 12.75L11.25 15 15 9.75M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
          Submit Registration
        </Button>
      </form>
       <p className="mt-6 text-center text-sm text-slate-600">
        Already have an account?{' '}
        <button 
          onClick={() => navigate(PageEnum.ProviderLogin)} 
          className="font-semibold text-purple-600 hover:text-purple-500"
        >
          Sign In
        </button>
      </p>
    </AuthPage>
  );
};

export default ProviderSignupPage;
