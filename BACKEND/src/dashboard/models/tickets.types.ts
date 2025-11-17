export interface TicketMessage {
  sender: "user" | "admin";
  message: string;
  createdAt: string;
}

export interface Ticket {
  id: string;
  customer: string;
  subject: string;
  status: "open" | "closed";
  createdAt: string;
  messages: TicketMessage[];
}
