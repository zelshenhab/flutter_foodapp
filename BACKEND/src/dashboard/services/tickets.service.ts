import { Ticket } from "../models/tickets.types";

export class TicketsService {
  private tickets: Ticket[] = [
    {
      id: "1001",
      customer: "Алексей",
      subject: "Проблема с оплатой",
      status: "open",
      createdAt: new Date().toISOString(),
      messages: [
        {
          sender: "user",
          message: "Платёж не проходит",
          createdAt: new Date().toISOString(),
        },
      ],
    },
    {
      id: "1002",
      customer: "Марина",
      subject: "Не работает промокод",
      status: "closed",
      createdAt: new Date().toISOString(),
      messages: [
        {
          sender: "user",
          message: "Промокод недействителен",
          createdAt: new Date().toISOString(),
        },
        {
          sender: "admin",
          message: "Мы исправили проблему",
          createdAt: new Date().toISOString(),
        },
      ],
    },
  ];

  getAll() {
    return this.tickets;
  }

  respond(id: string, message: string) {
    const t = this.tickets.find((x) => x.id === id);
    if (!t) return null;

    t.messages.push({
      sender: "admin",
      message,
      createdAt: new Date().toISOString(),
    });

    return t;
  }

  close(id: string) {
    const t = this.tickets.find((x) => x.id === id);
    if (!t) return null;
    t.status = "closed";
    return t;
  }

  reopen(id: string) {
    const t = this.tickets.find((x) => x.id === id);
    if (!t) return null;
    t.status = "open";
    return t;
  }
}
