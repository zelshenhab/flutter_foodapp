import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = [
    Locale('ru'),
    Locale('en'),
    Locale('ar'),
    Locale('tt'),
  ];

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  String get _code => locale.languageCode;

  String _t(Map<String, String> values) =>
      values[_code] ?? values['ru'] ?? values.values.first;

  // —— Common / brand ——
  String get appName => _t({
        'ru': 'Адам и Ева',
        'en': 'Adam & Eve',
        'ar': 'آدم وحواء',
        'tt': 'Адам һәм Һава',
      });

  String get retry => _t({
        'ru': 'Повторить',
        'en': 'Retry',
        'ar': 'إعادة المحاولة',
        'tt': 'Кабатлау',
      });

  String get save => _t({
        'ru': 'Сохранить',
        'en': 'Save',
        'ar': 'حفظ',
        'tt': 'Саклау',
      });

  String get cancel => _t({
        'ru': 'Отмена',
        'en': 'Cancel',
        'ar': 'إلغاء',
        'tt': 'Баш тарту',
      });

  String get undo => _t({
        'ru': 'Отменить',
        'en': 'Undo',
        'ar': 'تراجع',
        'tt': 'Кире кайтару',
      });

  String get language => _t({
        'ru': 'Язык',
        'en': 'Language',
        'ar': 'اللغة',
        'tt': 'Тел',
      });

  String get russian => 'Русский';
  String get english => 'English';
  String get arabic => 'العربية';
  String get tatar => 'Татарча';

  String languageName(String code) {
    switch (code) {
      case 'en':
        return english;
      case 'ar':
        return arabic;
      case 'tt':
        return tatar;
      default:
        return russian;
    }
  }

  // —— Nav ——
  String get navMenu => _t({
        'ru': 'Меню',
        'en': 'Menu',
        'ar': 'القائمة',
        'tt': 'Меню',
      });

  String get navCart => _t({
        'ru': 'Корзина',
        'en': 'Cart',
        'ar': 'السلة',
        'tt': 'Кәрзин',
      });

  String get navProfile => _t({
        'ru': 'Профиль',
        'en': 'Profile',
        'ar': 'الملف',
        'tt': 'Профиль',
      });

  // —— Auth / Login ——
  String get welcome => _t({
        'ru': 'Добро пожаловать!',
        'en': 'Welcome!',
        'ar': 'مرحباً!',
        'tt': 'Рәхим итегез!',
      });

  String get welcomeBack => _t({
        'ru': 'С возвращением!',
        'en': 'Welcome back!',
        'ar': 'أهلاً بعودتك!',
        'tt': 'Кабат рәхим итегез!',
      });

  String get alreadyHaveAccount => _t({
        'ru': 'Уже есть аккаунт? Войти по email',
        'en': 'Already have an account? Sign in with email',
        'ar': 'عندك حساب؟ سجّل دخول بالإيميل',
        'tt': 'Аккаунтыгыз бармы? Email белән керегез',
      });

  String get createNewAccount => _t({
        'ru': 'Новый пользователь? Создать аккаунт',
        'en': 'New here? Create an account',
        'ar': 'مستخدم جديد؟ أنشئ حساباً',
        'tt': 'Яңа кулланучы? Аккаунт булдыру',
      });

  String get signInWithEmailHint => _t({
        'ru': 'Введите email — мы отправим код для входа',
        'en': 'Enter your email — we will send a sign-in code',
        'ar': 'أدخل إيميلك — سنرسل رمز الدخول',
        'tt': 'Email кертегез — керү кодын җибәрәбез',
      });

  String get name => _t({
        'ru': 'Имя',
        'en': 'Name',
        'ar': 'الاسم',
        'tt': 'Исем',
      });

  String get email => _t({
        'ru': 'Email',
        'en': 'Email',
        'ar': 'البريد الإلكتروني',
        'tt': 'Email',
      });

  String get getCode => _t({
        'ru': 'Получить код',
        'en': 'Get code',
        'ar': 'الحصول على الرمز',
        'tt': 'Код алу',
      });

  String get agreeHint => _t({
        'ru': 'Чтобы продолжить, подтвердите согласие с документами.',
        'en': 'To continue, please accept the documents.',
        'ar': 'للمتابعة، يرجى الموافقة على المستندات.',
        'tt': 'Дәвам итү өчен документларга ризалыгызны раслагыз.',
      });

  String get iAccept => _t({
        'ru': 'Я принимаю ',
        'en': 'I accept the ',
        'ar': 'أوافق على ',
        'tt': 'Мин кабул итәм ',
      });

  String get andWord => _t({
        'ru': ' и ',
        'en': ' and ',
        'ar': ' و',
        'tt': ' һәм ',
      });

  String get termsOfUse => _t({
        'ru': 'Условия использования',
        'en': 'Terms of Use',
        'ar': 'شروط الاستخدام',
        'tt': 'Куллану шартлары',
      });

  String get privacyPolicy => _t({
        'ru': 'Политику конфиденциальности',
        'en': 'Privacy Policy',
        'ar': 'سياسة الخصوصية',
        'tt': 'Конфиденциальлек сәясәтен',
      });

  String get privacyPolicyTitle => _t({
        'ru': 'Политика конфиденциальности',
        'en': 'Privacy Policy',
        'ar': 'سياسة الخصوصية',
        'tt': 'Конфиденциальлек сәясәте',
      });

  String get enterOtp => _t({
        'ru': 'Введите код подтверждения',
        'en': 'Enter verification code',
        'ar': 'أدخل رمز التحقق',
        'tt': 'Раслау кодын кертегез',
      });

  String codeSentTo(String email) => _t({
        'ru': 'Код отправлен на $email',
        'en': 'Code sent to $email',
        'ar': 'تم إرسال الرمز إلى $email',
        'tt': 'Код $email адресына җибәрелде',
      });

  String get verify => _t({
        'ru': 'Подтвердить',
        'en': 'Verify',
        'ar': 'تأكيد',
        'tt': 'Раслау',
      });

  String get didNotGetCode => _t({
        'ru': 'Не получили код?',
        'en': "Didn't get the code?",
        'ar': 'لم يصلك الرمز؟',
        'tt': 'Код килмәдеме?',
      });

  String get resendCode => _t({
        'ru': 'Отправить повторно',
        'en': 'Resend',
        'ar': 'إعادة الإرسال',
        'tt': 'Кабат җибәрү',
      });

  String resendIn(int sec) => _t({
        'ru': 'Отправить повторно через $sec сек.',
        'en': 'Resend in $sec sec.',
        'ar': 'إعادة الإرسال خلال $sec ث.',
        'tt': '$sec сек. соң кабат җибәрү',
      });

  // —— Menu ——
  String get categories => _t({
        'ru': 'Категории',
        'en': 'Categories',
        'ar': 'التصنيفات',
        'tt': 'Категорияләр',
      });

  String get searchHint => _t({
        'ru': 'Поиск блюд или категорий',
        'en': 'Search dishes or categories',
        'ar': 'ابحث عن أطباق أو تصنيفات',
        'tt': 'Ашамлыклар яки категорияләр эзләү',
      });

  String get menuLoadError => _t({
        'ru': 'Ошибка при загрузке меню',
        'en': 'Failed to load menu',
        'ar': 'فشل تحميل القائمة',
        'tt': 'Менюны йөкләгәндә хата',
      });

  String itemUnavailable(String id) => _t({
        'ru': 'Товар недоступен для заказа (id: $id)',
        'en': 'Item unavailable for order (id: $id)',
        'ar': 'المنتج غير متاح للطلب (id: $id)',
        'tt': 'Товар заказ өчен мөмкин түгел (id: $id)',
      });

  String get promoDiscount30 => _t({
        'ru': 'Скидка 30%',
        'en': '30% off',
        'ar': 'خصم 30٪',
        'tt': '30% ташлама',
      });

  String get promoFirstOrder => _t({
        'ru': 'На первый заказ от 3000₽',
        'en': 'On first order from 3000₽',
        'ar': 'على أول طلب من 3000₽',
        'tt': 'Беренче заказга 3000₽ дан',
      });

  String get orderNow => _t({
        'ru': 'Заказать',
        'en': 'Order',
        'ar': 'اطلب',
        'tt': 'Заказ бирергә',
      });

  String get locationKazan => _t({
        'ru': 'Казань, Россия',
        'en': 'Kazan, Russia',
        'ar': 'قازان، روسيا',
        'tt': 'Казан, Россия',
      });

  String get selectRestaurantAddress => _t({
        'ru': 'Адрес ресторана',
        'en': 'Restaurant address',
        'ar': 'عنوان المطعم',
        'tt': 'Ресторан адресы',
      });

  String get openInMaps => _t({
        'ru': 'Открыть на карте',
        'en': 'Open in maps',
        'ar': 'فتح على الخريطة',
        'tt': 'Харитада ачу',
      });

  String get restaurantAddress => _t({
        'ru': 'Адрес ресторана',
        'en': 'Restaurant address',
        'ar': 'عنوان المطعم',
        'tt': 'Ресторан адресы',
      });

  // —— Cart ——
  String get cart => _t({
        'ru': 'Корзина',
        'en': 'Cart',
        'ar': 'السلة',
        'tt': 'Кәрзин',
      });

  String get cartEmpty => _t({
        'ru': 'Корзина пуста',
        'en': 'Cart is empty',
        'ar': 'السلة فارغة',
        'tt': 'Кәрзин буш',
      });

  String get pickup => _t({
        'ru': 'Самовывоз',
        'en': 'Pickup',
        'ar': 'استلام',
        'tt': 'Үзең алып китү',
      });

  String removedItem(String name) => _t({
        'ru': 'Удалено: $name',
        'en': 'Removed: $name',
        'ar': 'تم الحذف: $name',
        'tt': 'Бетерелде: $name',
      });

  String get enterPromo => _t({
        'ru': 'Введите промокод',
        'en': 'Enter promo code',
        'ar': 'أدخل رمز الخصم',
        'tt': 'Промокодны кертегез',
      });

  String get apply => _t({
        'ru': 'Применить',
        'en': 'Apply',
        'ar': 'تطبيق',
        'tt': 'Кулланырга',
      });

  String get payOnlineCard => _t({
        'ru': 'Оплата онлайн (банковская карта)',
        'en': 'Online payment (bank card)',
        'ar': 'دفع إلكتروني (بطاقة بنكية)',
        'tt': 'Онлайн түләү (банк картасы)',
      });

  String pickupAt(String address) => _t({
        'ru': 'Самовывоз — $address',
        'en': 'Pickup — $address',
        'ar': 'استلام — $address',
        'tt': 'Үзең алып китү — $address',
      });

  String get orderSum => _t({
        'ru': 'Сумма заказа',
        'en': 'Order subtotal',
        'ar': 'مجموع الطلب',
        'tt': 'Заказ суммасы',
      });

  String get discount => _t({
        'ru': 'Скидка',
        'en': 'Discount',
        'ar': 'الخصم',
        'tt': 'Ташлама',
      });

  String get serviceFee => _t({
        'ru': 'Сервис',
        'en': 'Service',
        'ar': 'رسوم الخدمة',
        'tt': 'Сервис',
      });

  String get total => _t({
        'ru': 'Итого',
        'en': 'Total',
        'ar': 'الإجمالي',
        'tt': 'Барлыгы',
      });

  String get checkoutPickup => _t({
        'ru': 'Оформить самовывоз',
        'en': 'Checkout pickup',
        'ar': 'إتمام الاستلام',
        'tt': 'Үзең алып китүне рәсмиләштерү',
      });

  String get checkoutOrder => _t({
        'ru': 'Оформить заказ',
        'en': 'Place order',
        'ar': 'تأكيد الطلب',
        'tt': 'Заказны рәсмиләштерү',
      });

  String get cartCheckoutDescription => _t({
        'ru': 'Самовывоз: заказ из корзины',
        'en': 'Pickup: cart order',
        'ar': 'استلام: طلب من السلة',
        'tt': 'Үзең алып китү: кәрзиннән заказ',
      });

  // —— Profile ——
  String get profile => _t({
        'ru': 'Профиль',
        'en': 'Profile',
        'ar': 'الملف الشخصي',
        'tt': 'Профиль',
      });

  String get myData => _t({
        'ru': 'Мои данные',
        'en': 'My details',
        'ar': 'بياناتي',
        'tt': 'Минем мәгълүматлар',
      });

  String nameLabel(String name) => _t({
        'ru': 'Имя: $name',
        'en': 'Name: $name',
        'ar': 'الاسم: $name',
        'tt': 'Исем: $name',
      });

  String emailLabel(String email) => _t({
        'ru': 'Элек.почта: $email',
        'en': 'Email: $email',
        'ar': 'البريد: $email',
        'tt': 'Эл.почта: $email',
      });

  String get edit => _t({
        'ru': 'Редактировать',
        'en': 'Edit',
        'ar': 'تعديل',
        'tt': 'Үзгәртү',
      });

  String get myOrders => _t({
        'ru': 'Мои заказы',
        'en': 'My orders',
        'ar': 'طلباتي',
        'tt': 'Минем заказлар',
      });

  String get viewOrders => _t({
        'ru': 'Посмотреть заказы',
        'en': 'View orders',
        'ar': 'عرض الطلبات',
        'tt': 'Заказларны карау',
      });

  /// Kept for compatibility; same as restaurant address title.
  String get deliveryAddress => restaurantAddress;

  String get settings => _t({
        'ru': 'Настройки',
        'en': 'Settings',
        'ar': 'الإعدادات',
        'tt': 'Көйләүләр',
      });

  String get notifications => _t({
        'ru': 'Уведомления',
        'en': 'Notifications',
        'ar': 'الإشعارات',
        'tt': 'Хәбәрнамәләр',
      });

  String get support => _t({
        'ru': 'Поддержка',
        'en': 'Support',
        'ar': 'الدعم',
        'tt': 'Ярдәм',
      });

  String get contactSupport => _t({
        'ru': 'Связаться с поддержкой',
        'en': 'Contact support',
        'ar': 'التواصل مع الدعم',
        'tt': 'Ярдәм белән элемтә',
      });

  String get editData => _t({
        'ru': 'Редактировать данные',
        'en': 'Edit details',
        'ar': 'تعديل البيانات',
        'tt': 'Мәгълүматларны үзгәртү',
      });

  String get enterName => _t({
        'ru': 'Введите имя',
        'en': 'Enter name',
        'ar': 'أدخل الاسم',
        'tt': 'Исемне кертегез',
      });

  String get fillNameEmail => _t({
        'ru': 'Заполните имя и email',
        'en': 'Fill in name and email',
        'ar': 'أدخل الاسم والبريد',
        'tt': 'Исем һәм email тутырыгыз',
      });

  String get camera => _t({
        'ru': 'Камера',
        'en': 'Camera',
        'ar': 'الكاميرا',
        'tt': 'Камера',
      });

  String get gallery => _t({
        'ru': 'Галерея',
        'en': 'Gallery',
        'ar': 'المعرض',
        'tt': 'Галерея',
      });

  String get imagePickFailed => _t({
        'ru': 'Не удалось выбрать изображение',
        'en': 'Could not select image',
        'ar': 'تعذر اختيار الصورة',
        'tt': 'Рәсемне сайлап булмады',
      });

  String get yourBonuses => _t({
        'ru': 'Ваши бонусы',
        'en': 'Your bonuses',
        'ar': 'بونصاتك',
        'tt': 'Сезнең бонуслар',
      });

  String get viewPromos => _t({
        'ru': 'Посмотреть акции',
        'en': 'View promos',
        'ar': 'عرض العروض',
        'tt': 'Акцияләрне карау',
      });

  // —— Orders ——
  String get noOrdersYet => _t({
        'ru': 'У вас пока нет заказов',
        'en': 'You have no orders yet',
        'ar': 'لا توجد طلبات بعد',
        'tt': 'Әлегә заказларыгыз юк',
      });

  String orderNumber(Object id) => _t({
        'ru': 'Заказ №$id',
        'en': 'Order #$id',
        'ar': 'طلب رقم $id',
        'tt': 'Заказ №$id',
      });

  String get brandPickup => _t({
        'ru': 'Адам и Ева — Самовывоз',
        'en': 'Adam & Eve — Pickup',
        'ar': 'آدم وحواء — استلام',
        'tt': 'Адам һәм Һава — Үзең алып китү',
      });

  String get orderComposition => _t({
        'ru': 'Состав заказа',
        'en': 'Order items',
        'ar': 'محتويات الطلب',
        'tt': 'Заказ составы',
      });

  String get noItemsInOrder => _t({
        'ru': 'Нет товаров в заказе',
        'en': 'No items in order',
        'ar': 'لا توجد منتجات في الطلب',
        'tt': 'Заказда товарлар юк',
      });

  String get confirmPickup => _t({
        'ru': 'Подтвердить получение',
        'en': 'Confirm pickup',
        'ar': 'تأكيد الاستلام',
        'tt': 'Алуны раслау',
      });

  String get enjoyMeal => _t({
        'ru': 'Спасибо! Приятного аппетита.',
        'en': 'Thanks! Enjoy your meal.',
        'ar': 'شكراً! بالهناء والشفاء.',
        'tt': 'Рәхмәт! Тәмле булсын.',
      });

  String get orderReadyTitle => _t({
        'ru': 'Заказ готов',
        'en': 'Order ready',
        'ar': 'الطلب جاهز',
        'tt': 'Заказ әзер',
      });

  String orderReadyBody(Object id) => _t({
        'ru': 'Заказ №$id готов к самовывозу',
        'en': 'Order #$id is ready for pickup',
        'ar': 'الطلب رقم $id جاهز للاستلام',
        'tt': 'Заказ №$id алуга әзер',
      });

  String get pickupLocation => _t({
        'ru': 'Адрес самовывоза',
        'en': 'Pickup location',
        'ar': 'مكان الاستلام',
        'tt': 'Алып китү адресы',
      });

  String promoCodeLabel(String code) => _t({
        'ru': 'Промокод: $code',
        'en': 'Promo: $code',
        'ar': 'رمز الخصم: $code',
        'tt': 'Промокод: $code',
      });

  String sumLabel(String value) => _t({
        'ru': 'Сумма: $value',
        'en': 'Subtotal: $value',
        'ar': 'المجموع: $value',
        'tt': 'Сумма: $value',
      });

  String discountLabel(String value) => _t({
        'ru': 'Скидка: -$value',
        'en': 'Discount: -$value',
        'ar': 'الخصم: -$value',
        'tt': 'Ташлама: -$value',
      });

  String serviceLabel(String value) => _t({
        'ru': 'Сервис: $value',
        'en': 'Service: $value',
        'ar': 'الخدمة: $value',
        'tt': 'Сервис: $value',
      });

  String statusText(String status) {
    switch (status) {
      case 'pending':
        return _t({
        'ru': 'Ожидает',
        'en': 'Pending',
        'ar': 'قيد الانتظار',
        'tt': 'Көтә',
      });
      case 'preparing':
        return _t({
        'ru': 'Готовится',
        'en': 'Preparing',
        'ar': 'قيد التحضير',
        'tt': 'Әзерләнә',
      });
      case 'ready':
        return _t({
        'ru': 'Готов к выдаче',
        'en': 'Ready for pickup',
        'ar': 'جاهز للاستلام',
        'tt': 'Тапшыруга әзер',
      });
      case 'completed':
        return _t({
        'ru': 'Завершён',
        'en': 'Completed',
        'ar': 'مكتمل',
        'tt': 'Тәмамланган',
      });
      case 'cancelled':
        return _t({
        'ru': 'Отменён',
        'en': 'Cancelled',
        'ar': 'ملغى',
        'tt': 'Бетерелгән',
      });
      default:
        return status;
    }
  }

  // —— Payments ——
  String get onlinePayment => _t({
        'ru': 'Онлайн-оплата',
        'en': 'Online payment',
        'ar': 'الدفع الإلكتروني',
        'tt': 'Онлайн түләү',
      });

  String get payment => _t({
        'ru': 'Оплата',
        'en': 'Payment',
        'ar': 'الدفع',
        'tt': 'Түләү',
      });

  String get amountDue => _t({
        'ru': 'К оплате',
        'en': 'Amount due',
        'ar': 'المبلغ المستحق',
        'tt': 'Түләүгә',
      });

  String get onlineCardHint => _t({
        'ru': 'Онлайн-оплата банковской картой',
        'en': 'Online bank card payment',
        'ar': 'الدفع ببطاقة بنكية عبر الإنترنت',
        'tt': 'Банк картасы белән онлайн түләү',
      });

  String get payOrder => _t({
        'ru': 'Оплатить заказ',
        'en': 'Pay order',
        'ar': 'ادفع الطلب',
        'tt': 'Заказны түләү',
      });

  String get paymentSuccess => _t({
        'ru': 'Оплата прошла успешно',
        'en': 'Payment successful',
        'ar': 'تم الدفع بنجاح',
        'tt': 'Түләү уңышлы үтте',
      });

  String paymentSuccessDetails(Object orderId, String amount) => _t({
        'ru': 'Заказ №$orderId оформлен.\nСумма: $amount',
        'en': 'Order #$orderId placed.\nAmount: $amount',
        'ar': 'تم إنشاء الطلب رقم $orderId.\nالمبلغ: $amount',
        'tt': 'Заказ №$orderId рәсмиләштерелде.\nСумма: $amount',
      });

  String get done => _t({
        'ru': 'Готово',
        'en': 'Done',
        'ar': 'تم',
        'tt': 'Әзер',
      });

  String get paymentError => _t({
        'ru': 'Ошибка оплаты',
        'en': 'Payment error',
        'ar': 'خطأ في الدفع',
        'tt': 'Түләү хатасы',
      });

  String get paymentDeclined => _t({
        'ru': 'Оплата отклонена',
        'en': 'Payment declined',
        'ar': 'تم رفض الدفع',
        'tt': 'Түләү кире кагылды',
      });

  String get tryAgain => _t({
        'ru': 'Попробуйте ещё раз',
        'en': 'Please try again',
        'ar': 'حاول مرة أخرى',
        'tt': 'Тагын бер кат сынап карагыз',
      });

  String get goBack => _t({
        'ru': 'Вернуться',
        'en': 'Go back',
        'ar': 'رجوع',
        'tt': 'Кире кайту',
      });

  String get paymentRejected => _t({
        'ru': 'Платёж был отклонён.',
        'en': 'Payment was declined.',
        'ar': 'تم رفض عملية الدفع.',
        'tt': 'Түләү кире кагылды.',
      });

  String get paymentInDevTitle => _t({
        'ru': 'Функция оплаты ещё в разработке',
        'en': 'Payment feature is still in development',
        'ar': 'ميزة الدفع قيد التطوير',
        'tt': 'Түләү функциясе әле эшләнә',
      });

  String get paymentInDevBody => _t({
        'ru': 'Скоро мы добавим онлайн-оплату. Спасибо за понимание.',
        'en': 'Online payment will be available soon. Thank you.',
        'ar': 'سنضيف الدفع الإلكتروني قريباً. شكراً لتفهمك.',
        'tt': 'Тиздән онлайн түләү өстәләчәк. Аңлауыгыз өчен рәхмәт.',
      });

  String get paymentHistory => _t({
        'ru': 'История оплат',
        'en': 'Payment history',
        'ar': 'سجل المدفوعات',
        'tt': 'Түләү тарихы',
      });

  // —— Promos ——
  String get promosTitle => _t({
        'ru': 'Акции и промокоды',
        'en': 'Promos & codes',
        'ar': 'العروض والأكواد',
        'tt': 'Акцияләр һәм промокодлар',
      });

  String get noPromos => _t({
        'ru': 'Акций пока нет',
        'en': 'No promos yet',
        'ar': 'لا توجد عروض بعد',
        'tt': 'Әлегә акцияләр юк',
      });

  String get copy => _t({
        'ru': 'Копировать',
        'en': 'Copy',
        'ar': 'نسخ',
        'tt': 'Күчереп алу',
      });

  String codeCopied(String code) => _t({
        'ru': 'Код $code скопирован',
        'en': 'Code $code copied',
        'ar': 'تم نسخ الرمز $code',
        'tt': '$code коды күчереп алынды',
      });

  String validUntil(String date) => _t({
        'ru': ' · до $date',
        'en': ' · until $date',
        'ar': ' · حتى $date',
        'tt': ' · $date га кадәр',
      });

  // —— Support ——
  String get contactUs => _t({
        'ru': 'Связаться с нами',
        'en': 'Contact us',
        'ar': 'تواصل معنا',
        'tt': 'Безнең белән элемтә',
      });

  String get callUs => _t({
        'ru': 'Позвонить',
        'en': 'Call',
        'ar': 'اتصال',
        'tt': 'Шалтырату',
      });

  String get whatsappHello => _t({
        'ru': 'Здравствуйте!',
        'en': 'Hello!',
        'ar': 'مرحباً!',
        'tt': 'Исәнмесез!',
      });

  String get faq => _t({
        'ru': 'Частые вопросы',
        'en': 'FAQ',
        'ar': 'الأسئلة الشائعة',
        'tt': 'Еш бирелә торган сораулар',
      });

  String get writeToSupport => _t({
        'ru': 'Написать в поддержку',
        'en': 'Write to support',
        'ar': 'راسل الدعم',
        'tt': 'Ярдәмгә язу',
      });

  String get topic => _t({
        'ru': 'Тема',
        'en': 'Topic',
        'ar': 'الموضوع',
        'tt': 'Тема',
      });

  String get orderNumberOptional => _t({
        'ru': 'Номер заказа (необязательно)',
        'en': 'Order number (optional)',
        'ar': 'رقم الطلب (اختياري)',
        'tt': 'Заказ номеры (мәҗбүри түгел)',
      });

  String get orderNumberHint => _t({
        'ru': 'Например: 1027',
        'en': 'e.g. 1027',
        'ar': 'مثال: 1027',
        'tt': 'Мәсәлән: 1027',
      });

  String get message => _t({
        'ru': 'Сообщение',
        'en': 'Message',
        'ar': 'الرسالة',
        'tt': 'Хәбәр',
      });

  String get describeProblem => _t({
        'ru': 'Опишите проблему...',
        'en': 'Describe the issue...',
        'ar': 'صف المشكلة...',
        'tt': 'Проблеманы тасвирлагыз...',
      });

  String get send => _t({
        'ru': 'Отправить',
        'en': 'Send',
        'ar': 'إرسال',
        'tt': 'Җибәрү',
      });

  String get topicOrderIssue => _t({
        'ru': 'Проблема с заказом',
        'en': 'Order issue',
        'ar': 'مشكلة في الطلب',
        'tt': 'Заказ белән проблема',
      });

  String get topicRefund => _t({
        'ru': 'Возврат/компенсация',
        'en': 'Refund / compensation',
        'ar': 'استرجاع / تعويض',
        'tt': 'Кире кайтару/компенсация',
      });

  String get topicPayment => _t({
        'ru': 'Проблема с оплатой',
        'en': 'Payment issue',
        'ar': 'مشكلة في الدفع',
        'tt': 'Түләү белән проблема',
      });

  String get topicOther => _t({
        'ru': 'Другое',
        'en': 'Other',
        'ar': 'أخرى',
        'tt': 'Башка',
      });

  List<String> get supportTopics => [
        topicOrderIssue,
        topicRefund,
        topicPayment,
        topicOther,
      ];

  String ticketSent(String id) => _t({
        'ru': 'Заявка отправлена • №$id',
        'en': 'Request sent • #$id',
        'ar': 'تم إرسال الطلب • رقم $id',
        'tt': 'Гариза җибәрелде • №$id',
      });

  String get ticketSendFailed => _t({
        'ru': 'Не удалось отправить заявку',
        'en': 'Failed to send request',
        'ar': 'تعذر إرسال الطلب',
        'tt': 'Гаризаны җибәреп булмады',
      });

  String get faqChangeOrderQ => _t({
        'ru': 'Как изменить или отменить заказ?',
        'en': 'How do I change or cancel an order?',
        'ar': 'كيف أعدّل أو ألغي طلباً؟',
        'tt': 'Заказны ничек үзгәртергә яки бетерергә?',
      });

  String get faqChangeOrderA => _t({
        'ru':
            'Напишите в поддержку с номером заказа, пока статус «ожидает» или «готовится». После статуса «готов» изменить заказ уже нельзя.',
        'en':
            'Message support with your order number while status is Pending or Preparing. Once it is Ready, the order cannot be changed.',
        'ar':
            'راسل الدعم برقم الطلب طالما الحالة «قيد الانتظار» أو «قيد التحضير». بعد «جاهز» لا يمكن تعديل الطلب.',
        'tt':
            'Статус «көтә» яки «әзерләнә» вакытта заказ номеры белән ярдәмгә языгыз. «Әзер» булгач үзгәртеп булмый.',
      });

  String get faqPaymentQ => _t({
        'ru': 'Какие способы оплаты доступны?',
        'en': 'What payment methods are available?',
        'ar': 'ما طرق الدفع المتاحة؟',
        'tt': 'Нининди түләү ысуллары бар?',
      });

  String get faqPaymentA => _t({
        'ru':
            'Оплата онлайн банковской картой в приложении. После успешной оплаты заказ уходит на кухню.',
        'en':
            'Pay online with a bank card in the app. After successful payment, your order goes to the kitchen.',
        'ar':
            'الدفع أونلاين ببطاقة بنكية داخل التطبيق. بعد نجاح الدفع يذهب الطلب للمطبخ.',
        'tt':
            'Кушымтада банк картасы белән онлайн түләү. Түләү уңышлы булса, заказ кухняга китә.',
      });

  String get faqDeliveryQ => _t({
        'ru': 'Как работает самовывоз?',
        'en': 'How does pickup work?',
        'ar': 'كيف يعمل الاستلام؟',
        'tt': 'Үзең алып китү ничек эшли?',
      });

  String get faqDeliveryA => _t({
        'ru':
            'Мы готовим заказ в выбранном филиале. Когда статус станет «готов», заберите его сами по адресу ресторана в приложении.',
        'en':
            'We prepare your order at the selected branch. When status becomes Ready, pick it up yourself at the restaurant address shown in the app.',
        'ar':
            'نحضّر طلبك في الفرع الذي اخترته. عندما تصبح الحالة «جاهز»، استلمه بنفسك من عنوان المطعم الظاهر في التطبيق.',
        'tt':
            'Без сез сайлаган филиалда әзерлибез. Статус «әзер» булгач, кушымтадагы ресторан адресыннан үзегез алып китегез.',
      });

  String get faqPromoQ => _t({
        'ru': 'У меня проблема с промокодом',
        'en': 'I have a promo code issue',
        'ar': 'لدي مشكلة مع رمز الخصم',
        'tt': 'Промокод белән проблема бар',
      });

  String get faqPromoA => _t({
        'ru':
            'Проверьте срок действия и минимальную сумму. Если не сработало — напишите нам.',
        'en':
            'Check expiry and minimum amount. If it fails — message us.',
        'ar':
            'تحقق من الصلاحية والحد الأدنى. إن لم يعمل — راسلنا.',
        'tt': 'Гамәлдә булу срогын һәм минималь сумманы тикшерегез. Эшләмәсә — безгә языгыз.',
      });

  // —— Notifications ——
  String get loginNotificationBody => _t({
        'ru': 'Поздравляю, вы в системе 🎉',
        'en': "You're signed in 🎉",
        'ar': 'تم تسجيل دخولك 🎉',
        'tt': 'Котлыйбыз, сез системада 🎉',
      });

  // —— VPN / splash ——
  String get vpnRequired => _t({
        'ru': 'Требуется VPN',
        'en': 'VPN required',
        'ar': 'مطلوب VPN',
        'tt': 'VPN кирәк',
      });

  String get vpnRequiredBody => _t({
        'ru': 'Для доступа к приложению необходимо включить VPN.',
        'en': 'You need to enable a VPN to access the app.',
        'ar': 'للوصول إلى التطبيق يجب تفعيل VPN.',
        'tt': 'Кушымтага керү өчен VPN кабызырга кирәк.',
      });

  String get vpnCheckHint => _t({
        'ru':
            '📍 Убедитесь, что VPN работает, затем нажмите "Проверить снова".',
        'en':
            '📍 Make sure the VPN is working, then tap "Check again".',
        'ar':
            '📍 تأكد من عمل VPN ثم اضغط "تحقق مرة أخرى".',
        'tt':
            '📍 VPN эшләвен тикшерегез, аннары "Кабат тикшерү"не басыгыз.',
      });

  String get vpnCheckInternet => _t({
        'ru': 'Проверьте подключение к интернету',
        'en': 'Check your internet connection',
        'ar': 'تحقق من اتصال الإنترنت',
        'tt': 'Интернет тоташуын тикшерегез',
      });

  String get vpnEnableRestart => _t({
        'ru': 'Включите VPN и перезапустите приложение',
        'en': 'Enable VPN and restart the app',
        'ar': 'فعّل VPN وأعد تشغيل التطبيق',
        'tt': 'VPN кабызыгыз һәм кушымтаны яңадан эшләтегез',
      });

  String get vpnTryLater => _t({
        'ru': 'Или попробуйте позже',
        'en': 'Or try again later',
        'ar': 'أو حاول لاحقاً',
        'tt': 'Яки соңрак сынап карагыз',
      });

  String get checkAgain => _t({
        'ru': 'Проверить снова',
        'en': 'Check again',
        'ar': 'تحقق مرة أخرى',
        'tt': 'Кабат тикшерү',
      });

  String get closeApp => _t({
        'ru': 'Закрыть приложение',
        'en': 'Close app',
        'ar': 'إغلاق التطبيق',
        'tt': 'Кушымтаны ябу',
      });

  String get pleaseEnableVpnRestart => _t({
        'ru': 'Пожалуйста, включите VPN и перезапустите приложение',
        'en': 'Please enable VPN and restart the app',
        'ar': 'يرجى تفعيل VPN وإعادة تشغيل التطبيق',
        'tt': 'Зинһар, VPN кабызыгыз һәм кушымтаны яңадан эшләтегез',
      });

  String get foodDelivery => _t({
        'ru': 'Доставка еды',
        'en': 'Food delivery',
        'ar': 'توصيل الطعام',
        'tt': 'Ашамлык китерү',
      });

  String get checkingConnection => _t({
        'ru': 'Проверка подключения...',
        'en': 'Checking connection...',
        'ar': 'جاري فحص الاتصال...',
        'tt': 'Тоташуны тикшерү...',
      });

  // —— Auth extras ——
  String get errorTitle => _t({
        'ru': 'Ошибка',
        'en': 'Error',
        'ar': 'خطأ',
        'tt': 'Хата',
      });

  String get ok => _t({
        'ru': 'Ок',
        'en': 'OK',
        'ar': 'حسناً',
        'tt': 'Ок',
      });

  String get continueAsGuest => _t({
        'ru': 'Продолжить как гость',
        'en': 'Continue as guest',
        'ar': 'المتابعة كضيف',
        'tt': 'Кунак буларак дәвам итү',
      });

  String get sendCodeFailed => _t({
        'ru': 'Не удалось отправить код',
        'en': 'Failed to send code',
        'ar': 'تعذر إرسال الرمز',
        'tt': 'Кодны җибәреп булмады',
      });

  String get noRequestId => _t({
        'ru': 'Нет requestId. Получите код заново.',
        'en': 'Missing requestId. Request a new code.',
        'ar': 'لا يوجد requestId. اطلب رمزاً جديداً.',
        'tt': 'requestId юк. Кодны яңадан алыгыз.',
      });

  String get invalidCode => _t({
        'ru': 'Неверный код',
        'en': 'Invalid code',
        'ar': 'رمز غير صالح',
        'tt': 'Ялгыш код',
      });

  // —— Cart / loyalty / promo ——
  String get productFallback => _t({
        'ru': 'Товар',
        'en': 'Product',
        'ar': 'منتج',
        'tt': 'Товар',
      });

  String get cartLoadFailed => _t({
        'ru': 'Не удалось загрузить корзину',
        'en': 'Failed to load cart',
        'ar': 'تعذر تحميل السلة',
        'tt': 'Кәрзинне йөкләп булмады',
      });

  String get addItemFailed => _t({
        'ru': 'Не удалось добавить товар',
        'en': 'Failed to add item',
        'ar': 'تعذر إضافة المنتج',
        'tt': 'Товарны өстәп булмады',
      });

  String get removeItemFailed => _t({
        'ru': 'Не удалось удалить товар',
        'en': 'Failed to remove item',
        'ar': 'تعذر حذف المنتج',
        'tt': 'Товарны бетереп булмады',
      });

  String get qtyIncreaseFailed => _t({
        'ru': 'Не удалось увеличить количество',
        'en': 'Failed to increase quantity',
        'ar': 'تعذر زيادة الكمية',
        'tt': 'Санны арттырып булмады',
      });

  String get qtyDecreaseFailed => _t({
        'ru': 'Не удалось уменьшить количество',
        'en': 'Failed to decrease quantity',
        'ar': 'تعذر تقليل الكمية',
        'tt': 'Санны киметеп булмады',
      });

  String get invalidPromo => _t({
        'ru': 'Неверный промокод',
        'en': 'Invalid promo code',
        'ar': 'رمز خصم غير صالح',
        'tt': 'Ялгыш промокод',
      });

  String get applyBonusesFailed => _t({
        'ru': 'Не удалось применить бонусы',
        'en': 'Failed to apply bonuses',
        'ar': 'تعذر تطبيق المكافآت',
        'tt': 'Бонусларны кулланып булмады',
      });

  String get cancelBonusesFailed => _t({
        'ru': 'Не удалось отменить бонусы',
        'en': 'Failed to cancel bonuses',
        'ar': 'تعذر إلغاء المكافآت',
        'tt': 'Бонусларны бетереп булмады',
      });

  String get delete => _t({
        'ru': 'Удалить',
        'en': 'Delete',
        'ar': 'حذف',
        'tt': 'Бетерү',
      });

  String get loginRequired => _t({
        'ru': 'Требуется вход',
        'en': 'Sign-in required',
        'ar': 'تسجيل الدخول مطلوب',
        'tt': 'Керү кирәк',
      });

  String get loginRequiredCheckout => _t({
        'ru': 'Чтобы оформить заказ, пожалуйста войдите в аккаунт.',
        'en': 'Please sign in to place an order.',
        'ar': 'يرجى تسجيل الدخول لإتمام الطلب.',
        'tt': 'Заказ бирү өчен аккаунтка керегез.',
      });

  String get loginRequiredAddToCart => _t({
        'ru':
            'Вы можете смотреть меню. Чтобы добавить в корзину и заказать — войдите.',
        'en':
            'You can browse the menu. Sign in to add items and place an order.',
        'ar':
            'يمكنك تصفح القائمة. سجّل الدخول لإضافة منتجات وإتمام الطلب.',
        'tt':
            'Сез менюны карый аласыз. Кәрзинә өстәү һәм заказ бирү өчен керегез.',
      });

  String get guestBrowseHint => _t({
        'ru': 'Вы смотрите меню как гость. Войдите, чтобы заказать.',
        'en': 'Browsing as guest. Sign in to place an order.',
        'ar': 'تتصفح كضيف. سجّل الدخول لإتمام الطلب.',
        'tt': 'Сез кунак буларак карыйсыз. Заказ бирү өчен керегез.',
      });

  String get guestCartHint => _t({
        'ru':
            'Корзина доступна после входа. Сначала выберите блюда в меню — после входа сможете добавить их.',
        'en':
            'Your cart needs an account. Browse the menu, then sign in to add items and checkout.',
        'ar':
            'السلة تحتاج حسابًا. تصفّح القائمة ثم سجّل الدخول لإضافة المنتجات والدفع.',
        'tt':
            'Кәрзин өчен аккаунт кирәк. Менюны карагыз, аннары кереп өстәгез һәм заказ бирегез.',
      });

  String get loginRequiredProfile => _t({
        'ru':
            'Войдите в аккаунт, чтобы просматривать профиль и оформлять заказы.',
        'en': 'Sign in to view your profile and place orders.',
        'ar': 'سجّل الدخول لعرض الملف وإتمام الطلبات.',
        'tt': 'Профильне карау һәм заказ бирү өчен аккаунтка керегез.',
      });

  String get signIn => _t({
        'ru': 'Войти',
        'en': 'Sign in',
        'ar': 'تسجيل الدخول',
        'tt': 'Керү',
      });

  String get loyaltyAccount => _t({
        'ru': 'Бонусный счет',
        'en': 'Loyalty balance',
        'ar': 'حساب المكافآت',
        'tt': 'Бонус хисабы',
      });

  String get points => _t({
        'ru': 'баллов',
        'en': 'points',
        'ar': 'نقاط',
        'tt': 'балл',
      });

  String get pointsShort => _t({
        'ru': 'баллов',
        'en': 'pts',
        'ar': 'نقاط',
        'tt': 'балл',
      });

  String get pointEqualsRuble => _t({
        'ru': '1 балл = 1 ₽',
        'en': '1 point = 1 ₽',
        'ar': 'نقطة واحدة = 1 ₽',
        'tt': '1 балл = 1 ₽',
      });

  String get usePoints => _t({
        'ru': 'Использовать',
        'en': 'Redeem',
        'ar': 'استخدام',
        'tt': 'Кулланырга',
      });

  String get used => _t({
        'ru': 'Использовано',
        'en': 'Applied',
        'ar': 'تم الاستخدام',
        'tt': 'Кулланылган',
      });

  String get availableToRedeem => _t({
        'ru': 'Доступно для списания',
        'en': 'Available to redeem',
        'ar': 'متاح للاسترداد',
        'tt': 'Списать өчен мөмкин',
      });

  String get maxToRedeem => _t({
        'ru': 'Максимум к списанию',
        'en': 'Maximum to redeem',
        'ar': 'الحد الأقصى للاسترداد',
        'tt': 'Максимум списать',
      });

  String pointsCount(Object n) => _t({
        'ru': '$n баллов',
        'en': '$n points',
        'ar': '$n نقاط',
        'tt': '$n балл',
      });

  String get max30Percent => _t({
        'ru': 'Не более 30% от суммы заказа',
        'en': 'No more than 30% of the order total',
        'ar': 'لا يزيد عن 30٪ من قيمة الطلب',
        'tt': 'Заказ суммасының 30% тан артык түгел',
      });

  String pointsRedeemed(Object n) => _t({
        'ru': 'Списано баллов: $n',
        'en': 'Points redeemed: $n',
        'ar': 'النقاط المستردة: $n',
        'tt': 'Списан балл: $n',
      });

  String discountAmount(Object s) => _t({
        'ru': 'Скидка: $s ₽',
        'en': 'Discount: $s ₽',
        'ar': 'الخصم: $s ₽',
        'tt': 'Ташлама: $s ₽',
      });

  String get usePointsTitle => _t({
        'ru': 'Использовать баллы',
        'en': 'Redeem points',
        'ar': 'استخدام النقاط',
        'tt': 'Баллларны куллану',
      });

  String get availablePointsLabel => _t({
        'ru': 'Доступно баллов',
        'en': 'Available points',
        'ar': 'النقاط المتاحة',
        'tt': 'Мөмкин балллар',
      });

  String get onePointEquals => _t({
        'ru': '1 балл =',
        'en': '1 point =',
        'ar': 'نقطة واحدة =',
        'tt': '1 балл =',
      });

  String get chooseRedeemAmount => _t({
        'ru': 'Выберите сумму списания:',
        'en': 'Choose amount to redeem:',
        'ar': 'اختر مبلغ الاسترداد:',
        'tt': 'Списать суммасын сайлагыз:',
      });

  String maxRedeemHint(Object max) => _t({
        'ru':
            'Максимум списания: $max баллов (30% от суммы заказа)',
        'en':
            'Max redemption: $max points (30% of order total)',
        'ar':
            'الحد الأقصى: $max نقطة (30٪ من قيمة الطلب)',
        'tt':
            'Максимум списать: $max балл (заказ суммасының 30%)',
      });

  String redeemedPointsSnack(Object n) => _t({
        'ru': 'Списано $n баллов',
        'en': 'Redeemed $n points',
        'ar': 'تم استرداد $n نقطة',
        'tt': '$n балл списан',
      });

  String allPoints(Object n) => _t({
        'ru': 'Все ($n)',
        'en': 'All ($n)',
        'ar': 'الكل ($n)',
        'tt': 'Барысы ($n)',
      });

  String promoApplied(Object code, Object discount) => _t({
        'ru': 'Промокод $code применен! Скидка: $discount ₽',
        'en': 'Promo $code applied! Discount: $discount ₽',
        'ar': 'تم تطبيق الرمز $code! الخصم: $discount ₽',
        'tt': 'Промокод $code кулланылды! Ташлама: $discount ₽',
      });

  // —— Menu / orders / payments / profile / promos errors ——
  String get menuLoadFailed => _t({
        'ru': 'Не удалось загрузить меню',
        'en': 'Failed to load menu',
        'ar': 'تعذر تحميل القائمة',
        'tt': 'Менюны йөкләп булмады',
      });

  String get dishesRefreshFailed => _t({
        'ru': 'Не удалось обновить блюда',
        'en': 'Failed to refresh dishes',
        'ar': 'تعذر تحديث الأطباق',
        'tt': 'Ашамлыкларны яңартып булмады',
      });

  String ordersLoadError(Object err) => _t({
        'ru': 'Ошибка загрузки заказов: $err',
        'en': 'Failed to load orders: $err',
        'ar': 'فشل تحميل الطلبات: $err',
        'tt': 'Заказларны йөкләү хатасы: $err',
      });

  String get ordersRefreshError => _t({
        'ru': 'Ошибка обновления заказов',
        'en': 'Failed to refresh orders',
        'ar': 'فشل تحديث الطلبات',
        'tt': 'Заказларны яңарту хатасы',
      });

  String get untitled => _t({
        'ru': 'Без названия',
        'en': 'Untitled',
        'ar': 'بدون عنوان',
        'tt': 'Исемсез',
      });

  String get paymentOnlineDefault => _t({
        'ru': 'Онлайн-оплата',
        'en': 'Online payment',
        'ar': 'دفع عبر الإنترنت',
        'tt': 'Онлайн түләү',
      });

  String get paymentOnlineMasked => _t({
        'ru': 'Онлайн · **** 1234',
        'en': 'Online · **** 1234',
        'ar': 'أونلاين · **** 1234',
        'tt': 'Онлайн · **** 1234',
      });

  String get paymentRetryCartError => _t({
        'ru':
            'Ошибка оплаты. Пожалуйста, удалите товары из корзины, добавьте заново и повторите попытку.',
        'en':
            'Payment error. Please remove items from the cart, add them again, and retry.',
        'ar':
            'خطأ في الدفع. يرجى حذف المنتجات من السلة وإضافتها مجدداً ثم المحاولة.',
        'tt':
            'Түләү хатасы. Зинһар, товарларны кәрзиннән бетерегез, яңадан өстәгез һәм кабатлап карагыз.',
      });

  String get paymentIdMissing => _t({
        'ru': 'Не найден paymentId для проверки.',
        'en': 'paymentId not found for verification.',
        'ar': 'لم يتم العثور على paymentId للتحقق.',
        'tt': 'Тикшерү өчен paymentId табылмады.',
      });

  String get paymentNotConfirmedYet => _t({
        'ru': 'Платёж ещё не подтверждён. Попробуйте через пару секунд.',
        'en': 'Payment is not confirmed yet. Try again in a few seconds.',
        'ar': 'لم يتم تأكيد الدفع بعد. حاول بعد ثوانٍ.',
        'tt': 'Түләү әле расланмаган. Берничә секундтан соң кабатлагыз.',
      });

  String get paymentStatusCheckFailed => _t({
        'ru': 'Не удалось проверить статус платежа.',
        'en': 'Failed to check payment status.',
        'ar': 'تعذر التحقق من حالة الدفع.',
        'tt': 'Түләү статусын тикшереп булмады.',
      });

  String get openPaymentPageFailed => _t({
        'ru': 'Не удалось открыть страницу оплаты',
        'en': 'Failed to open payment page',
        'ar': 'تعذر فتح صفحة الدفع',
        'tt': 'Түләү битен ачып булмады',
      });

  String get paymentSuccessStatus => _t({
        'ru': 'Успешно',
        'en': 'Successful',
        'ar': 'نجاح',
        'tt': 'Уңышлы',
      });

  String get paymentErrorStatus => _t({
        'ru': 'Ошибка',
        'en': 'Error',
        'ar': 'خطأ',
        'tt': 'Хата',
      });

  String get paymentPendingStatus => _t({
        'ru': 'Ожидает',
        'en': 'Pending',
        'ar': 'قيد الانتظار',
        'tt': 'Көтә',
      });

  String get profileLoadFailed => _t({
        'ru': 'Не удалось загрузить профиль',
        'en': 'Failed to load profile',
        'ar': 'تعذر تحميل الملف',
        'tt': 'Профильне йөкләп булмады',
      });

  String get profileSaveFailed => _t({
        'ru': 'Не удалось сохранить профиль',
        'en': 'Failed to save profile',
        'ar': 'تعذر حفظ الملف',
        'tt': 'Профильне саклап булмады',
      });

  String get account => _t({
        'ru': 'Аккаунт',
        'en': 'Account',
        'ar': 'الحساب',
        'tt': 'Аккаунт',
      });

  String get logout => _t({
        'ru': 'Выйти из аккаунта',
        'en': 'Log out',
        'ar': 'تسجيل الخروج',
        'tt': 'Аккаунттан чыгу',
      });

  String get deleteAccount => _t({
        'ru': 'Удалить аккаунт',
        'en': 'Delete account',
        'ar': 'حذف الحساب',
        'tt': 'Аккаунтны бетерү',
      });

  String get deleteAccountConfirm => _t({
        'ru': 'Вы уверены что хотите удалить аккаунт?',
        'en': 'Are you sure you want to delete your account?',
        'ar': 'هل أنت متأكد أنك تريد حذف الحساب؟',
        'tt': 'Аккаунтны бетерергә телисезме?',
      });

  String get promosLoadError => _t({
        'ru': 'Ошибка загрузки акций',
        'en': 'Failed to load promotions',
        'ar': 'فشل تحميل العروض',
        'tt': 'Акцияләрне йөкләү хатасы',
      });

  String get unitBox => _t({
        'ru': 'кор',
        'en': 'box',
        'ar': 'علبة',
        'tt': 'кор',
      });

  String get unitWeight => _t({
        'ru': 'вес',
        'en': 'weight',
        'ar': 'وزن',
        'tt': 'авырлык',
      });

  // —— Legal ——
  String get termsText => _legalTerms[_code] ?? _legalTerms['ru']!;
  String get privacyText => _legalPrivacy[_code] ?? _legalPrivacy['ru']!;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['ru', 'en', 'ar', 'tt'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

const _legalTerms = {
  'ru': '''
Условия использования приложения «Адам и Ева»

Дата вступления в силу: 01.01.2026

1. Общие положения

Настоящие Условия использования регулируют порядок использования мобильного приложения «Адам и Ева» (далее — «Приложение»).

Используя Приложение, пользователь подтверждает, что ознакомился и согласен с настоящими Условиями.

Если пользователь не согласен с Условиями, он должен прекратить использование Приложения.

2. Регистрация и аккаунт

Для использования некоторых функций Приложения может потребоваться регистрация с указанием имени и адреса электронной почты.

Пользователь обязуется предоставлять достоверную и актуальную информацию.

Пользователь несёт ответственность за сохранность своих данных доступа.

3. Описание сервиса

Приложение предоставляет пользователю возможность:

— Просматривать меню;
— Оформлять заказы;
— Управлять корзиной;
— Просматривать профиль.

Администрация оставляет за собой право изменять функциональность Приложения без предварительного уведомления.

4. Ограничение ответственности

Администрация не несёт ответственности за:

— Перебои в работе сети Интернет;
— Временную недоступность сервиса;
— Действия третьих лиц.

Приложение предоставляется «как есть».

5. Интеллектуальная собственность

Все материалы Приложения (дизайн, логотипы, тексты) являются собственностью правообладателя и защищены законодательством.

6. Изменение условий

Администрация вправе изменять настоящие Условия. Актуальная версия всегда доступна в Приложении.

7. Контактная информация

По вопросам, связанным с использованием Приложения, вы можете связаться с нами:

Email: kauroah@gmail.com
''',
  'en': '''
Terms of Use for the “Adam & Eve” app

Effective date: 01.01.2026

1. General

These Terms of Use govern the use of the “Adam & Eve” mobile application (the “App”).

By using the App, you confirm that you have read and agree to these Terms.

If you do not agree, you must stop using the App.

2. Registration and account

Some features may require registration with your name and email address.

You agree to provide accurate and up-to-date information.

You are responsible for keeping your access data secure.

3. Service description

The App lets you:

— Browse the menu;
— Place orders;
— Manage your cart;
— View your profile.

The administration may change App functionality without prior notice.

4. Limitation of liability

The administration is not liable for:

— Internet outages;
— Temporary service unavailability;
— Actions of third parties.

The App is provided “as is”.

5. Intellectual property

All App materials (design, logos, texts) belong to the rights holder and are protected by law.

6. Changes to the terms

The administration may update these Terms. The current version is always available in the App.

7. Contact

For questions about using the App:

Email: kauroah@gmail.com
''',
  'ar': '''
شروط استخدام تطبيق «آدم وحواء»

تاريخ السريان: 01.01.2026

1. أحكام عامة

تنظّم شروط الاستخدام هذه طريقة استخدام تطبيق «آدم وحواء» للجوّال (ويُشار إليه لاحقاً بـ«التطبيق»).

باستخدامك للتطبيق، تؤكد أنك اطّلعت على هذه الشروط ووافقت عليها.

إذا لم توافق، يجب عليك التوقف عن استخدام التطبيق.

2. التسجيل والحساب

قد تتطلب بعض الميزات التسجيل بالاسم والبريد الإلكتروني.

تتعهد بتقديم معلومات صحيحة ومحدّثة.

أنت مسؤول عن حماية بيانات الدخول الخاصة بك.

3. وصف الخدمة

يتيح لك التطبيق:

— تصفّح القائمة؛
— تقديم الطلبات؛
— إدارة السلة؛
— عرض الملف الشخصي.

تحتفظ الإدارة بحق تغيير وظائف التطبيق دون إشعار مسبق.

4. تحديد المسؤولية

لا تتحمل الإدارة المسؤولية عن:

— انقطاع الإنترنت؛
— عدم توفر الخدمة مؤقتاً؛
— أفعال أطراف ثالثة.

يُقدَّم التطبيق «كما هو».

5. الملكية الفكرية

جميع مواد التطبيق (التصميم، الشعارات، النصوص) ملك لصاحب الحقوق ومحمية بموجب القانون.

6. تعديل الشروط

يحق للإدارة تعديل هذه الشروط. النسخة الحالية متاحة دائماً داخل التطبيق.

7. معلومات التواصل

للاستفسارات المتعلقة باستخدام التطبيق:

Email: kauroah@gmail.com
''',
  'tt': '''
«Адам һәм Һава» кушымтасын куллану шартлары

Көчкә керү датасы: 01.01.2026

1. Гомуми нигезләмәләр

Бу Куллану шартлары «Адам һәм Һава» мобиль кушымтасын (алга таба — «Кушымта») куллану тәртибен көйли.

Кушымтаны кулланып, кулланучы бу Шартлар белән танышканлыгын һәм ризалыгын раслый.

Әгәр кулланучы Шартлар белән килешмәсә, ул Кушымтаны куллануны туктатырга тиеш.

2. Теркәлү һәм аккаунт

Кушымтаның кайбер функцияләрен куллану өчен исем һәм электрон почта белән теркәлү таләп ителергә мөмкин.

Кулланучы дөрес һәм актуаль мәгълүмат бирергә бурычлы.

Кулланучы үзенең керү мәгълүматларын саклау өчен җаваплы.

3. Сервис тасвирламасы

Кушымта мөмкинлек бирә:

— Менюны карарга;
— Заказлар рәсмиләштерергә;
— Кәрзинне идарә итәргә;
— Профильне карарга.

Администрация алдан хәбәр итмичә Кушымта функцияләрен үзгәртү хокукын саклый.

4. Җаваплылыкны чикләү

Администрация җаваплы түгел:

— Интернет өзелүләре өчен;
— Сервисның вакытлыча эшләмәве өчен;
— Өченче затлар гамәлләре өчен.

Кушымта «бар килеш» тәкъдим ителә.

5. Интеллектуаль милек

Кушымтаның барлык материаллары (дизайн, логотиплар, текстлар) хокук иясенең милке һәм закон белән саклана.

6. Шартларны үзгәртү

Администрация бу Шартларны үзгәртергә хокуклы. Актуаль версия һәрвакыт Кушымтада бар.

7. Элемтә мәгълүматы

Кушымтаны куллану буенча сораулар өчен:

Email: kauroah@gmail.com
''',
};

const _legalPrivacy = {
  'ru': '''
Политика конфиденциальности приложения «Адам и Ева»

Дата вступления в силу: 01.01.2026

1. Общие положения

Настоящая Политика конфиденциальности описывает, какие данные мы собираем, как их используем и как защищаем.

Используя Приложение, пользователь соглашается с настоящей Политикой.

2. Какие данные мы собираем

Мы можем собирать следующие данные:

— Имя пользователя;
— Адрес электронной почты;
— Технические данные устройства (тип устройства, версия ОС);
— Данные о заказах внутри приложения.

Мы НЕ собираем банковские данные пользователей.

3. Цели обработки данных

Персональные данные используются для:

— Создания и управления аккаунтом;
— Авторизации пользователя;
— Обработки заказов;
— Улучшения работы Приложения;
— Связи с пользователем при необходимости.

4. Хранение и защита данных

Мы принимаем разумные технические и организационные меры для защиты персональных данных от несанкционированного доступа, изменения или уничтожения.

Данные хранятся в защищённых сервисах и не передаются третьим лицам, за исключением случаев, предусмотренных законодательством.

5. Передача третьим лицам

Данные могут передаваться только:

— В рамках требований законодательства;
— Техническим подрядчикам, обеспечивающим работу сервиса (например, серверные провайдеры).

6. Права пользователя

Пользователь имеет право:

— Запросить информацию о своих данных;
— Требовать исправления или удаления данных;
— Отозвать согласие на обработку данных.

Для этого необходимо направить запрос по электронной почте.

7. Контактная информация

По вопросам обработки персональных данных:

Email: kauroah@gmail.com
''',
  'en': '''
Privacy Policy for the “Adam & Eve” app

Effective date: 01.01.2026

1. General

This Privacy Policy describes what data we collect, how we use it, and how we protect it.

By using the App, you agree to this Policy.

2. What data we collect

We may collect:

— Name;
— Email address;
— Device technical data (device type, OS version);
— Order data inside the App.

We do NOT collect users’ banking details.

3. Purposes of processing

Personal data is used to:

— Create and manage an account;
— Authenticate the user;
— Process orders;
— Improve the App;
— Contact the user when needed.

4. Storage and protection

We take reasonable technical and organizational measures to protect personal data from unauthorized access, alteration, or destruction.

Data is stored in secured services and is not shared with third parties except as required by law.

5. Sharing with third parties

Data may be shared only:

— As required by law;
— With technical contractors that run the service (e.g. hosting providers).

6. User rights

You may:

— Request information about your data;
— Request correction or deletion;
— Withdraw consent to processing.

To do so, send a request by email.

7. Contact

For personal data questions:

Email: kauroah@gmail.com
''',
  'ar': '''
سياسة خصوصية تطبيق «آدم وحواء»

تاريخ السريان: 01.01.2026

1. أحكام عامة

تصف سياسة الخصوصية هذه البيانات التي نجمعها وكيفية استخدامها وحمايتها.

باستخدامك للتطبيق، توافق على هذه السياسة.

2. البيانات التي نجمعها

قد نجمع:

— الاسم؛
— البريد الإلكتروني؛
— بيانات تقنية للجهاز (نوع الجهاز، إصدار النظام)؛
— بيانات الطلبات داخل التطبيق.

نحن لا نجمع البيانات البنكية للمستخدمين.

3. أغراض المعالجة

تُستخدم البيانات الشخصية من أجل:

— إنشاء الحساب وإدارته؛
— تسجيل الدخول؛
— معالجة الطلبات؛
— تحسين التطبيق؛
— التواصل معك عند الحاجة.

4. التخزين والحماية

نتخذ تدابير تقنية وتنظيمية معقولة لحماية البيانات من الوصول غير المصرح أو التعديل أو الإتلاف.

تُخزَّن البيانات في خدمات محمية ولا تُنقل لأطراف ثالثة إلا وفق القانون.

5. النقل لأطراف ثالثة

قد تُنقل البيانات فقط:

— وفق متطلبات القانون؛
— لمقاولين تقنيين يشغّلون الخدمة (مثل مزوّدي الاستضافة).

6. حقوق المستخدم

يحق لك:

— طلب معلومات عن بياناتك؛
— طلب تصحيحها أو حذفها؛
— سحب الموافقة على المعالجة.

لذلك أرسل طلباً عبر البريد الإلكتروني.

7. معلومات التواصل

لأسئلة معالجة البيانات الشخصية:

Email: kauroah@gmail.com
''',
  'tt': '''
«Адам һәм Һава» кушымтасының конфиденциальлек сәясәте

Көчкә керү датасы: 01.01.2026

1. Гомуми нигезләмәләр

Бу Конфиденциальлек сәясәте без нинди мәгълүмат җыюыбызны, аны ничек куллануыбызны һәм саклавыбызны тасвирлый.

Кушымтаны кулланып, кулланучы бу Сәясәт белән килешә.

2. Без нинди мәгълүмат җыябыз

Без түбәндәге мәгълүматны җыя алабыз:

— Кулланучы исеме;
— Электрон почта адресы;
— Җайланманың техник мәгълүматы (җайланма төре, ОС версиясе);
— Кушымта эчендәге заказ мәгълүматы.

Без кулланучыларның банк мәгълүматын ҖЫЙМЫЙБЫЗ.

3. Мәгълүматны эшкәртү максатлары

Шәхси мәгълүмат кулланыла:

— Аккаунт булдыру һәм идарә итү өчен;
— Кулланучыны авторизацияләү өчен;
— Заказларны эшкәртү өчен;
— Кушымта эшен яхшырту өчен;
— Кирәк булганда кулланучы белән элемтә өчен.

4. Саклау һәм яклау

Без шәхси мәгълүматны рөхсәтсез керүдән, үзгәртүдән яки юкка чыгарудан яклау өчен уңайлы техник һәм оештыру чараларын күребез.

Мәгълүмат сакланган сервисларда саклана һәм закон таләп иткән очраклардан тыш өченче затларга бирелми.

5. Өченче затларга тапшыру

Мәгълүмат бары тик:

— Закон таләпләре кысаларында;
— Сервис эшен тәэмин итүче техник подрядчикларга (мәсәлән, хостинг провайдерларына) бирелергә мөмкин.

6. Кулланучы хокуклары

Кулланучы хокуклы:

— Үз мәгълүматы турында сорарга;
— Мәгълүматны төзәтүне яки бетерүне таләп итәргә;
— Эшкәртүгә ризалыкны кире алырга.

Моның өчен электрон почта аша сорау җибәрергә кирәк.

7. Элемтә мәгълүматы

Шәхси мәгълүматны эшкәртү буенча сораулар өчен:

Email: kauroah@gmail.com
''',
};
