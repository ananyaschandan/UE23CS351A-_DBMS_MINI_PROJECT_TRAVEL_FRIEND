import React, { useState, useEffect } from 'react';
import { User } from '../types';
import Card from '../components/Card';

interface ProviderProfilePageProps {
  user: User;
}

interface Document {
  DocumentID: number;
  DocumentType: string;
  DocumentName: string;
  MimeType: string;
  FileSize: number;
  fileSizeKB: string;
  VerificationStatus: 'Pending' | 'Approved' | 'Rejected';
  RejectionReason?: string;
  UploadedAt: string;
  VerifiedAt?: string;
}

const ProviderProfilePage: React.FC<ProviderProfilePageProps> = ({ user }) => {
  const [documents, setDocuments] = useState<Document[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchDocuments();
  }, [user.providerId]);

  const fetchDocuments = async () => {
    try {
      const providerId = user.providerId || user.id;
      const response = await fetch(`http://localhost:5000/api/auth/provider/${providerId}/documents`);
      const data = await response.json();
      
      if (data.success) {
        setDocuments(data.documents);
      }
    } catch (error) {
      console.error('Failed to fetch documents:', error);
    } finally {
      setLoading(false);
    }
  };

  const getStatusBadge = (status: string) => {
    switch (status) {
      case 'Approved':
        return 'bg-green-100 text-green-800';
      case 'Rejected':
        return 'bg-red-100 text-red-800';
      default:
        return 'bg-yellow-100 text-yellow-800';
    }
  };

  const getDocumentIcon = (type: string) => {
    const icons: { [key: string]: string } = {
      'Driving_License': '🪪',
      'Aadhaar_Card': '🆔',
      'PAN_Card': '💳',
      'Photo': '📸',
      'Vehicle_Registration': '📋',
      'Vehicle_Insurance': '🛡️',
      'Pollution_Certificate': '✅',
      'Fitness_Certificate': '🔧',
      'Permit': '📜'
    };
    return icons[type] || '📄';
  };

  const formatDocumentType = (type: string) => {
    return type.replace(/_/g, ' ');
  };

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString('en-IN', {
      year: 'numeric',
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    });
  };

  if (loading) {
    return (
      <div className="flex justify-center items-center min-h-screen">
        <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-purple-600"></div>
      </div>
    );
  }

  return (
    <div className="max-w-7xl mx-auto">
      {/* Header */}
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-slate-900 mb-2">Provider Profile</h1>
        <p className="text-slate-600">View your uploaded documents and verification status</p>
      </div>

      {/* Provider Info Card */}
      <Card className="mb-6 bg-gradient-to-r from-purple-50 to-blue-50">
        <div className="flex items-center space-x-4">
          <div className="w-16 h-16 bg-purple-600 rounded-full flex items-center justify-center text-white text-2xl font-bold">
            {user.firstName?.[0]}{user.lastName?.[0]}
          </div>
          <div>
            <h2 className="text-2xl font-bold text-slate-900">{user.fullName}</h2>
            <p className="text-slate-600">{user.email}</p>
            <p className="text-slate-600">{user.phone}</p>
          </div>
        </div>
      </Card>

      {/* Documents Section */}
      <div className="mb-6">
        <h2 className="text-2xl font-bold text-slate-900 mb-4">📄 Uploaded Documents</h2>
        
        {documents.length === 0 ? (
          <Card>
            <div className="text-center py-12">
              <p className="text-slate-500 text-lg">No documents uploaded yet</p>
              <p className="text-slate-400 text-sm mt-2">Documents will appear here after signup</p>
            </div>
          </Card>
        ) : (
          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
            {documents.map((doc) => (
              <Card key={doc.DocumentID} className="hover:shadow-lg transition-shadow">
                <div className="space-y-4">
                  {/* Document Header */}
                  <div className="flex items-start justify-between">
                    <div className="flex items-center space-x-3">
                      <span className="text-4xl">{getDocumentIcon(doc.DocumentType)}</span>
                      <div>
                        <h3 className="font-semibold text-slate-900">
                          {formatDocumentType(doc.DocumentType)}
                        </h3>
                        <p className="text-xs text-slate-500">{doc.DocumentName}</p>
                      </div>
                    </div>
                  </div>

                  {/* Status Badge */}
                  <div className="flex items-center justify-between">
                    <span className={`px-3 py-1 rounded-full text-xs font-semibold ${getStatusBadge(doc.VerificationStatus)}`}>
                      {doc.VerificationStatus}
                    </span>
                    <span className="text-xs text-slate-500">{doc.fileSizeKB} KB</span>
                  </div>

                  {/* Document Info */}
                  <div className="text-xs text-slate-600 space-y-1">
                    <p>📅 Uploaded: {formatDate(doc.UploadedAt)}</p>
                    {doc.VerifiedAt && (
                      <p>✅ Verified: {formatDate(doc.VerifiedAt)}</p>
                    )}
                    {doc.RejectionReason && (
                      <p className="text-red-600">❌ Reason: {doc.RejectionReason}</p>
                    )}
                  </div>

                  {/* View Button */}
                  <button
                    onClick={() => {
                      window.open(`http://localhost:5000/api/auth/provider/document/${doc.DocumentID}`, '_blank');
                    }}
                    className="w-full px-4 py-2 bg-purple-600 text-white rounded-lg hover:bg-purple-700 transition font-semibold text-sm"
                  >
                    👁️ View Document
                  </button>
                </div>
              </Card>
            ))}
          </div>
        )}
      </div>

      {/* Statistics */}
      <div className="grid md:grid-cols-3 gap-6 mt-8">
        <Card className="bg-green-50">
          <div className="text-center">
            <p className="text-3xl font-bold text-green-600">
              {documents.filter(d => d.VerificationStatus === 'Approved').length}
            </p>
            <p className="text-slate-600 mt-2">Approved Documents</p>
          </div>
        </Card>
        <Card className="bg-yellow-50">
          <div className="text-center">
            <p className="text-3xl font-bold text-yellow-600">
              {documents.filter(d => d.VerificationStatus === 'Pending').length}
            </p>
            <p className="text-slate-600 mt-2">Pending Verification</p>
          </div>
        </Card>
        <Card className="bg-red-50">
          <div className="text-center">
            <p className="text-3xl font-bold text-red-600">
              {documents.filter(d => d.VerificationStatus === 'Rejected').length}
            </p>
            <p className="text-slate-600 mt-2">Rejected Documents</p>
          </div>
        </Card>
      </div>
    </div>
  );
};

export default ProviderProfilePage;
