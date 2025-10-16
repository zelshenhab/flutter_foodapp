export interface UpdateUserProfileRequest {
  name?: string;
  email?: string;
  address?: string;
  notifications?: boolean;
  languageCode?: string;
  avatarPath?: string;
}

