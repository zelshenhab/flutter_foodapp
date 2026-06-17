export interface AdminUser {
  id: number;
  name: string | null;
  email: string;
  avatarUrl?: string | null;
  role: string;     // "customer" | "admin" | "manager"
  blocked: boolean;
  createdAt: string | null;
  loyaltyPoints: number; // 👈 ADD THIS
}