import { createClient } from '@supabase/supabase-js';

const supabaseUrl = "https://nwaphgvmxtaalyxpgfdt.supabase.co";
const supabaseServiceKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im53YXBoZ3ZteHRhYWx5eHBnZmR0Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2MDYxNDM2MywiZXhwIjoyMDc2MTkwMzYzfQ.ReZcP4FIdvDgkdY1TbxlJ_RD_YsBjs9XZzFAHFdQvAo";

const supabase = createClient(supabaseUrl, supabaseServiceKey, {
  auth: {
    autoRefreshToken: false,
    persistSession: false
  }
});

async function seedDatabase() {
  console.log('🌱 Seeding Supabase database...');

  try {
    // Create categories
    const categories = [
      { title: "Шаурма", slug: "shawarma", position: 1 },
      { title: "Бокс с шаурмой", slug: "box", position: 2 },
      { title: "Ролл", slug: "roll", position: 3 },
      { title: "Евро-бокс", slug: "eurobox", position: 4 },
      { title: "Пицца", slug: "pizza", position: 5 },
      { title: "Закуски и салаты", slug: "salads", position: 6 },
      { title: "Основные блюда", slug: "main", position: 7 },
      { title: "Завтрак", slug: "breakfast", position: 8 },
      { title: "Соусы", slug: "sauces", position: 9 },
    ];

    for (const category of categories) {
      const { error } = await supabase
        .from('Category')
        .upsert(category, { onConflict: 'slug' });
      
      if (error) {
        console.error('Error creating category:', error);
      } else {
        console.log(`✅ Category created: ${category.title}`);
      }
    }

    // Create menu items
    const menuItems = [
      // ШАУРМА
      { categorySlug: "shawarma", title: "Шаурма «Арабская» с курицей", slug: "sh1", basePrice: 269 },
      { categorySlug: "shawarma", title: "Шаурма «Турецкая» с курицей и овощами", slug: "sh2", basePrice: 299 },
      { categorySlug: "shawarma", title: "Шаурма «Классическая»", slug: "sh3", basePrice: 299 },
      { categorySlug: "shawarma", title: "Шаурма «Адам и Ева» с курицей, грибами и сыром", slug: "sh4", basePrice: 350 },
      { categorySlug: "shawarma", title: "Шаурма с мясом", slug: "sh5", basePrice: 350 },
      { categorySlug: "shawarma", title: "Шаурма «Экстра» (с картофелем фри)", slug: "sh6", basePrice: 400 },
      { categorySlug: "shawarma", title: "Шаурма «Экстра» с картофелем фри и сыром «Моцарелла»", slug: "sh7", basePrice: 450 },
      { categorySlug: "shawarma", title: "Мини-шаурма с курицей", slug: "sh8", basePrice: 175 },
      { categorySlug: "shawarma", title: "Мини-шаурма с говядиной", slug: "sh9", basePrice: 225 },
      
      // БОКС С ШАУРМОЙ
      { categorySlug: "box", title: "Бокс с арабской шаурмой (курица)", slug: "bx1", basePrice: 485 },
      { categorySlug: "box", title: "Бокс с арабской шаурмой (курица) двойной", slug: "bx2", basePrice: 649 },
      { categorySlug: "box", title: "Бокс с арабской шаурмой (говядина)", slug: "bx3", basePrice: 599 },
      { categorySlug: "box", title: "Бокс «Mix» с шаурмой (курица)", slug: "bx4", basePrice: 629 },
      { categorySlug: "box", title: "Бокс с шаурмой куриной", slug: "bx5", basePrice: 525 },
      { categorySlug: "box", title: "Фатта шаурма с говядиной", slug: "bx6", basePrice: 599 },
      
      // РОЛЛ
      { categorySlug: "roll", title: "Ролл «Зингер»", slug: "rl1", basePrice: 349 },
      { categorySlug: "roll", title: "Ролл «Криспи»", slug: "rl2", basePrice: 349 },
      { categorySlug: "roll", title: "Ролл «Мексикано»", slug: "rl3", basePrice: 349 },
      { categorySlug: "roll", title: "Ролл «Фахита»", slug: "rl4", basePrice: 319 },
      { categorySlug: "roll", title: "Ролл «Шиш Тавук»", slug: "rl5", basePrice: 295 },
      { categorySlug: "roll", title: "Ролл с картофелем фри и моцареллой", slug: "rl6", basePrice: 290 },
      { categorySlug: "roll", title: "Ролл с картофелем фри", slug: "rl7", basePrice: 220 },
      
      // ЕВРО-БОКС
      { categorySlug: "eurobox", title: "Бокс с бургером «Криспи»", slug: "eb1", basePrice: 479 },
      { categorySlug: "eurobox", title: "Бокс с говяжьим бургером", slug: "eb2", basePrice: 599 },
      { categorySlug: "eurobox", title: "Бокс с куриным бургером", slug: "eb3", basePrice: 549 },
      { categorySlug: "eurobox", title: "Бокс с куриным мини-бургером", slug: "eb4", basePrice: 399 },
      { categorySlug: "eurobox", title: "Бокс с говяжьим мини-бургером", slug: "eb5", basePrice: 599 },
      { categorySlug: "eurobox", title: "Бокс «Криспи»", slug: "eb6", basePrice: 399 },
      { categorySlug: "eurobox", title: "Бокс «Фахита»", slug: "eb7", basePrice: 420 },
      { categorySlug: "eurobox", title: "Бокс «Шиш Тавук»", slug: "eb8", basePrice: 450 },
      { categorySlug: "eurobox", title: "Бокс «Кебаб»", slug: "eb9", basePrice: 469 },
      
      // ПИЦЦА
      { categorySlug: "pizza", title: "Пицца «Адам и Ева»", slug: "pz1", basePrice: 575 },
      { categorySlug: "pizza", title: "Пицца «Криспи»", slug: "pz2", basePrice: 595 },
      { categorySlug: "pizza", title: "Пицца «Мексикано»", slug: "pz3", basePrice: 595 },
      { categorySlug: "pizza", title: "Пицца с шаурмой (курица)", slug: "pz4", basePrice: 675 },
      { categorySlug: "pizza", title: "Пицца с шаурмой (говядина)", slug: "pz5", basePrice: 675 },
      { categorySlug: "pizza", title: "Пицца «Фахита»", slug: "pz6", basePrice: 595 },
      { categorySlug: "pizza", title: "Пицца «Вегетарианская»", slug: "pz7", basePrice: 485 },
      { categorySlug: "pizza", title: "Мини-пицца «Маргарита»", slug: "pz8", basePrice: 325 },
      { categorySlug: "pizza", title: "Лахмаджун", slug: "pz9", basePrice: 230 },
      { categorySlug: "pizza", title: "Пиде с сыром", slug: "pz10", basePrice: 350 },
      { categorySlug: "pizza", title: "Пиде с мясом", slug: "pz11", basePrice: 450 },
      
      // ЗАКУСКИ И САЛАТЫ
      { categorySlug: "salads", title: "Салат «Греческий» с сыром Фета", slug: "sl1", basePrice: 349 },
      { categorySlug: "salads", title: "Салат «Цезарь» с курицей", slug: "sl2", basePrice: 299 },
      { categorySlug: "salads", title: "Салат «Коул Слоу»", slug: "sl3", basePrice: 209 },
      { categorySlug: "salads", title: "Запечённый бейби-картофель", slug: "sl4", basePrice: 199 },
      { categorySlug: "salads", title: "Сирийская бебе", slug: "sl5", basePrice: 149 },
      { categorySlug: "salads", title: "Самса с курицей", slug: "sl6", basePrice: 200 },
      { categorySlug: "salads", title: "Узбекская самса с сыром", slug: "sl7", basePrice: 200 },
      
      // ОСНОВНЫЕ БЛЮДА
      { categorySlug: "main", title: "Рис «Манди»", slug: "mn1", basePrice: 445 },
      { categorySlug: "main", title: "Рис «Кабса»", slug: "mn2", basePrice: 385 },
      { categorySlug: "main", title: "Шиш Тавук (филе куриной грудки на углях)", slug: "mn3", basePrice: 399 },
      { categorySlug: "main", title: "Чечевичный суп", slug: "mn4", basePrice: 185 },
      
      // ЗАВТРАК
      { categorySlug: "breakfast", title: "Турецкий завтрак", slug: "bf1", basePrice: 589 },
      { categorySlug: "breakfast", title: "Турецкий завтрак двойной", slug: "bf2", basePrice: 789 },
      { categorySlug: "breakfast", title: "Кебаб с сыром", slug: "bf3", basePrice: 349 },
      { categorySlug: "breakfast", title: "Манакіш с орегано", slug: "bf4", basePrice: 139 },
      { categorySlug: "breakfast", title: "Манакіш с сыром", slug: "bf5", basePrice: 159 },
      { categorySlug: "breakfast", title: "Мини-манакіш с сыром", slug: "bf6", basePrice: 120 },
      { categorySlug: "breakfast", title: "Мини-манакіш с орегано", slug: "bf7", basePrice: 110 },
      { categorySlug: "breakfast", title: "Мини-манакіш острый", slug: "bf8", basePrice: 120 },
      
      // СОУСЫ
      { categorySlug: "sauces", title: "Соус «Чесночный»", slug: "sc1", basePrice: 50 },
      { categorySlug: "sauces", title: "Соус «Сырный»", slug: "sc2", basePrice: 50 },
      { categorySlug: "sauces", title: "Соус «Барбекю»", slug: "sc3", basePrice: 50 },
      { categorySlug: "sauces", title: "Соус «Фирменный»", slug: "sc4", basePrice: 50 },
      { categorySlug: "sauces", title: "Кетчуп", slug: "sc5", basePrice: 50 },
    ];

    // Get all categories first
    const { data: categoriesData, error: categoriesError } = await supabase
      .from('Category')
      .select('id, slug');

    if (categoriesError) {
      throw new Error(`Failed to fetch categories: ${categoriesError.message}`);
    }

    const categoryMap = new Map(categoriesData?.map(c => [c.slug, c.id]) || []);

    for (const item of menuItems) {
      const categoryId = categoryMap.get(item.categorySlug);
      if (!categoryId) {
        console.error(`Category not found: ${item.categorySlug}`);
        continue;
      }

      const { error } = await supabase
        .from('MenuItem')
        .upsert({
          categoryId,
          title: item.title,
          slug: item.slug,
          description: null,
          imageUrl: "assets/images/Chicken-Shawarma-8.jpg",
          basePrice: item.basePrice,
          isActive: true,
          isPopular: false,
        }, { onConflict: 'slug' });

      if (error) {
        console.error(`Error creating menu item ${item.slug}:`, error);
      } else {
        console.log(`✅ Menu item created: ${item.title}`);
      }
    }

    // Create sample promos
    const promos = [
      {
        code: "WELCOME10",
        title: "Welcome 10%",
        description: "10% off your first order",
        type: "percent",
        value: 10,
        active: true,
      },
      {
        code: "SAVE50",
        title: "Save 50",
        description: "50 rubles off orders over 500",
        type: "fixed",
        value: 50,
        minSubtotal: 500,
        active: true,
      },
    ];

    for (const promo of promos) {
      const { error } = await supabase
        .from('Promo')
        .upsert(promo, { onConflict: 'code' });

      if (error) {
        console.error(`Error creating promo ${promo.code}:`, error);
      } else {
        console.log(`✅ Promo created: ${promo.title}`);
      }
    }

    console.log('🎉 Database seeding completed successfully!');

  } catch (error) {
    console.error('❌ Error seeding database:', error);
    process.exit(1);
  }
}

seedDatabase();
