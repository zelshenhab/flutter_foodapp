export interface CreateOrderItemRequest {
  id: string; // menu item id
  name: string;
  price: number;
  qty: number;
  image: string;
}

export interface CreateOrderRequest {
  items: CreateOrderItemRequest[];
  deliveryFee?: number;
  discount?: number;
}

