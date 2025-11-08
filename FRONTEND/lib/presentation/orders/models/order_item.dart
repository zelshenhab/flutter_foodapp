class OrderItem {
  final int id;
  final int orderId;
  final int menuItemId;
  final String title;
  final String? options;
  final double unitPrice;
  final int quantity;
  final double lineTotal;
  final String? image; // optional, for UI

  const OrderItem({
    required this.id,
    required this.orderId,
    required this.menuItemId,
    required this.title,
    this.options,
    required this.unitPrice,
    required this.quantity,
    required this.lineTotal,
    this.image,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      orderId: json['orderId'] is int
          ? json['orderId']
          : int.tryParse(json['orderId'].toString()) ?? 0,
      menuItemId: json['menuItemId'] is int
          ? json['menuItemId']
          : int.tryParse(json['menuItemId'].toString()) ?? 0,
      title: json['title'] ??
          json['titleSnap'] ??
          'Без названия', // fallback if backend uses titleSnap
      options: json['optionsSnap']?.toString() ?? json['options']?.toString(),
      unitPrice: double.tryParse(json['unitPrice'].toString()) ?? 0,
      quantity: int.tryParse(json['quantity'].toString()) ?? 0,
      lineTotal: double.tryParse(json['lineTotal'].toString()) ?? 0,
      image: json['image']?.toString(), // optional for later UI use
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'orderId': orderId,
        'menuItemId': menuItemId,
        'title': title,
        'options': options,
        'unitPrice': unitPrice,
        'quantity': quantity,
        'lineTotal': lineTotal,
        'image': image,
      };
}
