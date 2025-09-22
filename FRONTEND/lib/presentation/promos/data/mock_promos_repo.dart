import '../models/promo.dart';

class MockPromosRepo {
  static List<Promo> fetchActive() {
    return [
      Promo(
        id: 'p1',
        title: 'Скидка новичкам',
        description: '10% на первый заказ от 1000 ₽',
        type: PromoType.percent,
        amount: 10,
        code: 'WELCOME',
        validTo: DateTime.now().add(const Duration(days: 7)),
      ),
      Promo(
        id: 'p2',
        title: 'Комбо выходного',
        description: 'Скидка 300 ₽ при заказе от 1500 ₽',
        type: PromoType.fixed,
        amount: 300,
        code: 'WEEKEND300',
        validTo: DateTime.now().add(const Duration(days: 3)),
      ),
      Promo(
        id: 'p3',
        title: 'Бесплатный соус',
        description: 'Добавьте соус бесплатно к шаурме',
        type: PromoType.fixed,
        amount: 50,
        code: 'FREESAUCE',
        validTo: null,
      ),
    ];
  }
}
