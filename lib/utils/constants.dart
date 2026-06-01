class AppConstants {
  AppConstants._();
  static const String appName    = 'Hunger Point';
  static const String appTagline = 'Fast & Fresh Delivery';
  static const String appVersion = '1.0.0';

  // Firestore
  static const String colUsers  = 'users';
  static const String colMenu   = 'menu_items';
  static const String colOrders = 'orders';

  // Prefs
  static const String prefUserId      = 'user_id';
  static const String prefGuestMode   = 'guest_mode';
  static const String prefUserName    = 'user_name';
  static const String prefUserPhone   = 'user_phone';
  static const String prefUserEmail   = 'user_email';
  static const String prefUserDob     = 'user_dob';
  static const String prefUserAddress = 'user_address';
  static const String prefOnboarded   = 'onboarded';

  // Auth modes
  static const String authPhone = 'phone';
  static const String authGuest = 'guest';

  // Menu categories
  static const List<String> categories = [
    'Deals','Burgers','Pizza','Fried Chicken',
    'Wings','Fries','Shawarma','Paratha Roll',
    'Biryani','Chinese','Soup','Pasta','Fish & Chips',
  ];

  // Order status
  static const String statusPlaced    = 'placed';
  static const String statusConfirmed = 'confirmed';
  static const String statusPreparing = 'preparing';
  static const String statusOnWay     = 'on_the_way';
  static const String statusDelivered = 'delivered';

  // Payment methods
  static const String payCOD       = 'cash_on_delivery';
  static const String payEasypaisa = 'easypaisa';
  static const String payJazzCash  = 'jazzcash';
  static const String payBank      = 'bank_transfer';

  // Restaurant info
  static const String phone1         = '0938-310299';
  static const String phone2         = '0308-5888899';
  static const String complaintPhone = '0312-8340383';
  static const String address        = 'Taj Plaza Shewa Adda, Near HBL Bank';
  static const double deliveryFee    = 50.0;
  static const int    minDelivery    = 1000;
  static const double bulkDiscount   = 10.0;
  static const double bulkMinOrder   = 4000.0;

  // Image asset paths — organised by category folder
  static const String _b  = 'assets/images/burgers/';
  static const String _pz = 'assets/images/pizza/';
  static const String _fc = 'assets/images/fried_chicken/';
  static const String _w  = 'assets/images/wings/';
  static const String _fr = 'assets/images/fries/';
  static const String _sh = 'assets/images/shawarma/';
  static const String _pr = 'assets/images/paratha_roll/';
  static const String _bi = 'assets/images/biryani/';
  static const String _ch = 'assets/images/chinese/';
  static const String _so = 'assets/images/soup/';
  static const String _pa = 'assets/images/pasta/';
  static const String _fi = 'assets/images/fish_chips/';
  static const String _d  = 'assets/images/deals/';

  static const Map<String, String> _itemImages = {
    // ── BURGERS ──────────────────────────────────────────────────────
    'Zinger Burger':          '${_b}zinger_burger.png',
    'Crispy Culeslow Burger': '${_b}crispy_culeslow_burger.png',
    'Zinger Cheese':          '${_b}zinger_cheese.png',
    'Grilled Chicken':        '${_b}grilled_chicken.png',
    'Tower Zinger':           '${_b}tower_zinger.png',
    'Burger Pizza':           '${_b}burger_pizza.png',
    'Fish Burger':            '${_b}fish_burger.png',
    'Mighty Zinger':          '${_b}mighty_zinger.png',
    'Grilled Big Bang':       '${_b}grilled_big_bang.png',
    'Prime Beef Burger':      '${_b}prime_beef_burger.png',
    'Nuggets Burger':         '${_b}nuggets_burger.png',
    'Chicken Patty Burger':   '${_b}chicken_patty_burger.png',
    // ── PIZZA ─────────────────────────────────────────────────────────
    'Chicken Tikka':          '${_pz}chicken_tikka.png',
    'Chicken Fajita':         '${_pz}chicken_fajita.png',
    'Behari Kabab':           '${_pz}behari_kabab.png',
    'Pepperoni':              '${_pz}pepperoni.png',
    'Creamy Chicken':         '${_pz}creamy_chicken.png',
    'Cheese Lover':           '${_pz}cheese_lover.png',
    'Hunger Crust':           '${_pz}hunger_crust.png',
    'Hunger Crown':           '${_pz}hunger_crown.png',
    'Hunger Special':         '${_pz}hunger_special.png',
    'Supreme Pizza':          '${_pz}supreme_pizza.png',
    'BBQ Pizza':              '${_pz}bbq_pizza.png',
    'Four Season Pizza':      '${_pz}four_season_pizza.png',
    // ── FRIED CHICKEN ─────────────────────────────────────────────────
    'Leg Piece':              '${_fc}leg_piece.png',
    'Chest Piece':            '${_fc}chest_piece.png',
    'Zinger Piece':           '${_fc}zinger_piece.png',
    'Chicken Nuggets':        '${_fc}chicken_nuggets.png',
    'Full Broast':            '${_fc}full_broast.png',
    'Half Broast':            '${_fc}half_broast.png',
    // ── WINGS ─────────────────────────────────────────────────────────
    'BBQ Wings':              '${_w}bbq_wings.png',
    'Crispy Wings':           '${_w}crispy_wings.png',
    'Mayo Wings':             '${_w}mayo_wings.png',
    'Grilled Wings Small':    '${_w}grilled_wings_small.png',
    'Grilled Wings Medium':   '${_w}grilled_wings_medium.png',
    // ── FRIES ─────────────────────────────────────────────────────────
    'Plain Fries Regular':    '${_fr}plain_fries_regular.png',
    'Plain Fries Large':      '${_fr}plain_fries_large.png',
    'Plain Fries Family':     '${_fr}plain_fries_family.png',
    'Mayo Fries Regular':     '${_fr}mayo_fries_regular.png',
    'Mayo Fries Large':       '${_fr}mayo_fries_large.png',
    'Mayo Fries Family':      '${_fr}mayo_fries_family.png',
    // ── SHAWARMA ──────────────────────────────────────────────────────
    'Chicken Shawarma':             '${_sh}chicken_shawarma.png',
    'Chicken Cheese Shawarma':      '${_sh}chicken_cheese_shawarma.png',
    'Zinger Shawarma':              '${_sh}zinger_shawarma.png',
    'Zinger Cheese Shawarma':       '${_sh}zinger_cheese_shawarma.png',
    // ── PARATHA ROLL ──────────────────────────────────────────────────
    'Pizza Paratha Roll':           '${_pr}pizza_paratha_roll.png',
    'Chicken Paratha Roll':         '${_pr}chicken_paratha_roll.png',
    'Chicken Cheese Paratha':       '${_pr}chicken_cheese_paratha.png',
    'Zinger Paratha Roll':          '${_pr}zinger_paratha_roll.png',
    'Zinger Cheese Paratha':        '${_pr}zinger_cheese_paratha.png',
    // ── BIRYANI ───────────────────────────────────────────────────────
    'Single Biryani':         '${_bi}single_biryani.png',
    'Double Biryani':         '${_bi}double_biryani.png',
    // ── CHINESE ───────────────────────────────────────────────────────
    'Chicken Choman':               '${_ch}chicken_choman.png',
    'Chicken Chilli Dry Rice':      '${_ch}chicken_chilli_dry_rice.png',
    'Chicken Shashilk Rice':        '${_ch}chicken_shashilk_rice.png',
    'Special Fried Rice':           '${_ch}special_fried_rice.png',
    // ── SOUP ──────────────────────────────────────────────────────────
    'Chicken Corn Soup (1 person)':     '${_so}chicken_corn_soup.png',
    'Chicken Corn Soup (4 persons)':    '${_so}chicken_corn_soup.png',
    'Hot & Sour Soup (4 persons)':      '${_so}hot_sour_soup.png',
    'Chicken Special Soup (4 persons)': '${_so}chicken_special_soup.png',
    // ── PASTA ─────────────────────────────────────────────────────────
    'Pizza Style Pasta':      '${_pa}pizza_style_pasta.png',
    'Alfredo Pasta':          '${_pa}alfredo_pasta.png',
    // ── FISH & CHIPS ──────────────────────────────────────────────────
    'Full Finger Fish':       '${_fi}full_finger_fish.png',
    'Half Finger Fish':       '${_fi}half_finger_fish.png',
    'Pizza Fries':            '${_fi}pizza_fries.png',
    // ── DEALS ─────────────────────────────────────────────────────────
    'Hunger Deal 1':          '${_d}hunger_deal_1.png',
    'Hunger Deal 2':          '${_d}hunger_deal_2.png',
    'Hunger Deal 3':          '${_d}hunger_deal_3.png',
    'Hunger Deal 4':          '${_d}hunger_deal_4.png',
    'Hunger Deal 5':          '${_d}hunger_deal_5.png',
    'Hunger Deal 6':          '${_d}hunger_deal_6.png',
    'Hunger Deal 7':          '${_d}hunger_deal_7.png',
    'Hunger Deal 8':          '${_d}hunger_deal_8.png',
    'Hunger Deal 9':          '${_d}hunger_deal_9.png',
    'Hunger Deal 10':         '${_d}hunger_deal_10.png',
    'Hunger Deal 11':         '${_d}hunger_deal_11.png',
    'Hunger Deal 12':         '${_d}hunger_deal_12.png',
    'Hunger Deal 13':         '${_d}hunger_deal_13.png',
    'Pizza Deal 1':           '${_d}pizza_deal_1.png',
    'Pizza Deal 2':           '${_d}pizza_deal_2.png',
    'Pizza Deal 3':           '${_d}pizza_deal_3.png',
    'Pizza Deal 4':           '${_d}pizza_deal_4.png',
  };

  // Returns asset path if file exists in mapping, else empty string (emoji fallback shown)
  static String imageAsset(String itemName) => _itemImages[itemName] ?? '';

  static String categoryAsset(String category) => '';
}
