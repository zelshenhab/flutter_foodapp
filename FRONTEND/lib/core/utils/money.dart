String money(num v) {
  final s = v.toStringAsFixed(0);
  final withSpaces = s.replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]} ',
  );
  return '$withSpaces ₽';
}
