"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.items = exports.categories = void 0;
exports.getCategories = getCategories;
exports.getItemsByCategory = getItemsByCategory;
exports.getMenuItem = getMenuItem;
// Seed with mock data from Flutter
exports.categories = [
    { id: "shawarma", title: "Шаурма" },
    { id: "box", title: "Бокс с шаурмой" },
    { id: "roll", title: "Ролл" },
    { id: "eurobox", title: "Евро-бокс" },
    { id: "pizza", title: "Пицца" },
    { id: "salads", title: "Закуски и салаты" },
    { id: "main", title: "Основные блюда" },
    { id: "breakfast", title: "Завтрак" },
    { id: "sauces", title: "Соусы" },
];
exports.items = [
    { id: "sh1", name: "Шаурма «Арабская» с курицей", price: 269, image: "assets/images/Chicken-Shawarma-8.jpg", categoryId: "shawarma" },
    { id: "sh2", name: "Шаурма «Турецкая» с курицей и овощами", price: 299, image: "assets/images/Chicken-Shawarma-8.jpg", categoryId: "shawarma" },
    { id: "sh3", name: "Шаурма «Классическая»", price: 299, image: "assets/images/Chicken-Shawarma-8.jpg", categoryId: "shawarma" },
    { id: "sh4", name: "Шаурма «Адам и Ева» с курицей, грибами и сыром", price: 350, image: "assets/images/Chicken-Shawarma-8.jpg", categoryId: "shawarma" },
    { id: "sh5", name: "Шаурма с мясом", price: 350, image: "assets/images/Chicken-Shawarma-8.jpg", categoryId: "shawarma" },
    { id: "sh6", name: "Шаурма «Экстра» (с картофелем фри)", price: 400, image: "assets/images/Chicken-Shawarma-8.jpg", categoryId: "shawarma" },
    { id: "sh7", name: "Шаурма «Экстра» с картофелем фри и сыром «Моцарелла»", price: 450, image: "assets/images/Chicken-Shawarma-8.jpg", categoryId: "shawarma" },
    { id: "sh8", name: "Мини-шаурма с курицей", price: 175, image: "assets/images/Chicken-Shawarma-8.jpg", categoryId: "shawarma" },
    { id: "sh9", name: "Мини-шаурма с говядиной", price: 225, image: "assets/images/Chicken-Shawarma-8.jpg", categoryId: "shawarma" },
    { id: "bx1", name: "Бокс с арабской шаурмой (курица)", price: 485, image: "assets/images/Chicken-Shawarma-8.jpg", categoryId: "box" },
    { id: "bx2", name: "Бокс с арабской шаурмой (курица) двойной", price: 649, image: "assets/images/Chicken-Shawarma-8.jpg", categoryId: "box" },
    { id: "bx3", name: "Бокс с арабской шаурмой (говядина)", price: 599, image: "assets/images/Chicken-Shawarma-8.jpg", categoryId: "box" },
    { id: "bx4", name: "Бокс «Mix» с шаурмой (курица)", price: 629, image: "assets/images/Chicken-Shawarma-8.jpg", categoryId: "box" },
    { id: "bx5", name: "Бокс с шаурмой куриной", price: 525, image: "assets/images/Chicken-Shawarma-8.jpg", categoryId: "box" },
    { id: "bx6", name: "Фатта шаурма с говядиной", price: 599, image: "assets/images/Chicken-Shawarma-8.jpg", categoryId: "box" },
    { id: "rl1", name: "Ролл «Зингер»", price: 349, image: "assets/images/Chicken-Shawarma-8.jpg", categoryId: "roll" },
    { id: "rl2", name: "Ролл «Криспи»", price: 349, image: "assets/images/Chicken-Shawarma-8.jpg", categoryId: "roll" },
    { id: "rl3", name: "Ролл «Мексикано»", price: 349, image: "assets/images/Chicken-Shawarma-8.jpg", categoryId: "roll" },
    { id: "rl4", name: "Ролл «Фахита»", price: 319, image: "assets/images/Chicken-Shawarma-8.jpg", categoryId: "roll" },
    { id: "rl5", name: "Ролл «Шиш Тавук»", price: 295, image: "assets/images/Chicken-Shawarma-8.jpg", categoryId: "roll" },
    { id: "rl6", name: "Ролл с картофелем фри и моцареллой", price: 290, image: "assets/images/Chicken-Shawarma-8.jpg", categoryId: "roll" },
    { id: "rl7", name: "Ролл с картофелем фри", price: 220, image: "assets/images/Chicken-Shawarma-8.jpg", categoryId: "roll" },
    { id: "eb1", name: "Бокс с бургером «Криспи»", price: 479, image: "assets/images/Chicken-Shawarma-8.jpg", categoryId: "eurobox" },
    { id: "eb2", name: "Бокс с говяжьим бургером", price: 599, image: "assets/images/Chicken-Shawarma-8.jpg", categoryId: "eurobox" },
    { id: "eb3", name: "Бокс с куриным бургером", price: 549, image: "assets/images/Chicken-Shawarma-8.jpg", categoryId: "eurobox" },
    { id: "eb4", name: "Бокс с куриным мини-бургером", price: 399, image: "assets/images/Chicken-Shawarma-8.jpg", categoryId: "eurobox" },
    { id: "eb5", name: "Бокс с говяжьим мини-бургером", price: 599, image: "assets/images/Chicken-Shawarma-8.jpg", categoryId: "eurobox" },
    { id: "eb6", name: "Бокс «Криспи»", price: 399, image: "assets/images/Chicken-Shawarma-8.jpg", categoryId: "eurobox" },
    { id: "eb7", name: "Бокс «Фахита»", price: 420, image: "assets/images/Chicken-Shawarma-8.jpg", categoryId: "eurobox" },
    { id: "eb8", name: "Бокс «Шиш Тавук»", price: 450, image: "assets/images/Chicken-Shawarma-8.jpg", categoryId: "eurobox" },
    { id: "eb9", name: "Бокс «Кебаб»", price: 469, image: "assets/images/Chicken-Shawarma-8.jpg", categoryId: "eurobox" },
    { id: "pz1", name: "Пицца «Адам и Ева»", price: 575, image: "assets/images/Chicken-Shawarma-8.jpg", categoryId: "pizza" },
    { id: "pz2", name: "Пицца «Криспи»", price: 595, image: "assets/images/Chicken-Shawarma-8.jpg", categoryId: "pizza" },
    { id: "pz3", name: "Пицца «Мексикано»", price: 595, image: "assets/images/Chicken-Shawarma-8.jpg", categoryId: "pizza" },
    { id: "pz4", name: "Пицца с шаурмой (курица)", price: 675, image: "assets/images/Chicken-Shawarma-8.jpg", categoryId: "pizza" },
    { id: "pz5", name: "Пицца с шаурмой (говядина)", price: 675, image: "assets/images/Chicken-Shawarma-8.jpg", categoryId: "pizza" },
    { id: "pz6", name: "Пицца «Фахита»", price: 595, image: "assets/images/Chicken-Shawarma-8.jpg", categoryId: "pizza" },
    { id: "pz7", name: "Пицца «Вегетарианская»", price: 485, image: "assets/images/Chicken-Shawarma-8.jpg", categoryId: "pizza" },
    { id: "pz8", name: "Мини-пицца «Маргарита»", price: 325, image: "assets/images/Chicken-Shawarma-8.jpg", categoryId: "pizza" },
    { id: "pz9", name: "Лахмаджун", price: 230, image: "assets/images/Chicken-Shawarma-8.jpg", categoryId: "pizza" },
    { id: "pz10", name: "Пиде с сыром", price: 350, image: "assets/images/Chicken-Shawarma-8.jpg", categoryId: "pizza" },
    { id: "pz11", name: "Пиде с мясом", price: 450, image: "assets/images/Chicken-Shawarma-8.jpg", categoryId: "pizza" },
    { id: "sl1", name: "Салат «Греческий» с сыром Фета", price: 349, image: "assets/images/Chicken-Shawarma-8.jpg", categoryId: "salads" },
    { id: "sl2", name: "Салат «Цезарь» с курицей", price: 299, image: "assets/images/Chicken-Shawarma-8.jpg", categoryId: "salads" },
    { id: "sl3", name: "Салат «Коул Слоу»", price: 209, image: "assets/images/Chicken-Shawarma-8.jpg", categoryId: "salads" },
    { id: "sl4", name: "Запечённый бейби-картофель", price: 199, image: "assets/images/Chicken-Shawarma-8.jpg", categoryId: "salads" },
    { id: "sl5", name: "Сирийская бебе", price: 149, image: "assets/images/Chicken-Shawarma-8.jpg", categoryId: "salads" },
    { id: "sl6", name: "Самса с курицей", price: 200, image: "assets/images/Chicken-Shawarma-8.jpg", categoryId: "salads" },
    { id: "sl7", name: "Узбекская самса с сыром", price: 200, image: "assets/images/Chicken-Shawarma-8.jpg", categoryId: "salads" },
    { id: "mn1", name: "Рис «Манди»", price: 445, image: "assets/images/Chicken-Shawarma-8.jpg", categoryId: "main" },
    { id: "mn2", name: "Рис «Кабса»", price: 385, image: "assets/images/Chicken-Shawarma-8.jpg", categoryId: "main" },
    { id: "mn3", name: "Шиш Тавук (филе куриной грудки на углях)", price: 399, image: "assets/images/Chicken-Shawarma-8.jpg", categoryId: "main" },
    { id: "mn4", name: "Чечевичный суп", price: 185, image: "assets/images/Chicken-Shawarma-8.jpg", categoryId: "main" },
    { id: "bf1", name: "Турецкий завтрак", price: 589, image: "assets/images/Chicken-Shawarma-8.jpg", categoryId: "breakfast" },
    { id: "bf2", name: "Турецкий завтрак двойной", price: 789, image: "assets/images/Chicken-Shawarma-8.jpg", categoryId: "breakfast" },
    { id: "bf3", name: "Кебаб с сыром", price: 349, image: "assets/images/Chicken-Shawarma-8.jpg", categoryId: "breakfast" },
    { id: "bf4", name: "Манакіш с орегано", price: 139, image: "assets/images/Chicken-Shawarma-8.jpg", categoryId: "breakfast" },
    { id: "bf5", name: "Манакіш с сыром", price: 159, image: "assets/images/Chicken-Shawarma-8.jpg", categoryId: "breakfast" },
    { id: "bf6", name: "Мини-манакіш с сыром", price: 120, image: "assets/images/Chicken-Shawarma-8.jpg", categoryId: "breakfast" },
    { id: "bf7", name: "Мини-манакіш с орегано", price: 110, image: "assets/images/Chicken-Shawarma-8.jpg", categoryId: "breakfast" },
    { id: "bf8", name: "Мини-манакіш острый", price: 120, image: "assets/images/Chicken-Shawarma-8.jpg", categoryId: "breakfast" },
    { id: "sc1", name: "Соус «Чесночный»", price: 50, image: "assets/images/Chicken-Shawarma-8.jpg", categoryId: "sauces" },
    { id: "sc2", name: "Соус «Сырный»", price: 50, image: "assets/images/Chicken-Shawarma-8.jpg", categoryId: "sauces" },
    { id: "sc3", name: "Соус «Барбекю»", price: 50, image: "assets/images/Chicken-Shawarma-8.jpg", categoryId: "sauces" },
    { id: "sc4", name: "Соус «Фирменный»", price: 50, image: "assets/images/Chicken-Shawarma-8.jpg", categoryId: "sauces" },
    { id: "sc5", name: "Кетчуп", price: 50, image: "assets/images/Chicken-Shawarma-8.jpg", categoryId: "sauces" },
];
function getCategories() {
    return exports.categories;
}
function getItemsByCategory(categoryId) {
    return exports.items.filter((i) => i.categoryId === categoryId);
}
function getMenuItem(itemId) {
    return exports.items.find((i) => i.id === itemId);
}
//# sourceMappingURL=menu.service.js.map