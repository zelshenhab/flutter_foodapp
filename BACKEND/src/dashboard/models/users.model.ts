export interface AdminUser {
  id: number;
  name: string | null;
  phone: string;
  avatarUrl?: string | null;
  role: string;     // "customer" | "admin" | "manager"
  blocked: boolean;
  createdAt: string | null;
}
