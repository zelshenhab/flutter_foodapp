class OrderHistory {
  final String id;
  final DateTime date;
  final String restaurant;
  final List<String> items; // أسماء الأطباق
  final double total;

  const OrderHistory({
    required this.id,
    required this.date,
    required this.restaurant,
    required this.items,
    required this.total,
  });
}
