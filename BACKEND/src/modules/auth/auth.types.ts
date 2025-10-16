export interface SendOtpRequest {
  phone: string;
}

export interface VerifyOtpRequest {
  phone: string;
  code: string;
}

export interface AuthResponse {
  token: string;
  user: {
    userId: string;
    name: string;
    phone: string;
    email?: string;
    address: string;
    notifications: boolean;
    languageCode: string;
    avatarPath?: string;
  };
}

