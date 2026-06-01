import 'package:get/get.dart';
import '../models/menu_item_model.dart';
import '../utils/constants.dart';

class FoodMenuController extends GetxController {
  static FoodMenuController get to => Get.find();

  final RxList<MenuItemModel> allItems    = <MenuItemModel>[].obs;
  final RxList<MenuItemModel> filtered    = <MenuItemModel>[].obs;
  final RxString selectedCategory         = 'All'.obs;
  final RxString searchQuery              = ''.obs;
  final RxBool isLoading                  = true.obs;

  final List<String> categories = ['All', ...AppConstants.categories];

  @override
  void onInit() {
    super.onInit();
    allItems.value = _buildMenu();
    _applyFilters();
    isLoading.value = false;
    ever(searchQuery,      (_) => _applyFilters());
    ever(selectedCategory, (_) => _applyFilters());
  }

  void selectCategory(String c) => selectedCategory.value = c;
  void search(String q) => searchQuery.value = q;
  void clearSearch() => searchQuery.value = '';

  void _applyFilters() {
    var r = allItems.toList();
    if (selectedCategory.value != 'All')
      r = r.where((i) => i.category == selectedCategory.value).toList();
    if (searchQuery.value.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      r = r.where((i) => i.name.toLowerCase().contains(q) ||
          i.description.toLowerCase().contains(q)).toList();
    }
    filtered.value = r;
  }

  List<MenuItemModel> get featuredItems =>
      allItems.where((i) => i.isFeatured).toList();

  List<MenuItemModel> byCategory(String cat) =>
      allItems.where((i) => i.category == cat).toList();

  // ─────────────────────────────────────────────────────────────────
  List<MenuItemModel> _buildMenu() => [
    // ════ DEALS ════════════════════════════════════════════════════
    MenuItemModel(id:'d1',  name:'Hunger Deal 1',  category:'Deals', price:450,  description:'Nuggets Burger + Regular Fries + Regular Drink', tags:['deal']),
    MenuItemModel(id:'d2',  name:'Hunger Deal 2',  category:'Deals', price:550,  description:'Zinger Burger + Regular Fries + Regular Drink', tags:['deal','popular'], isFeatured:true),
    MenuItemModel(id:'d3',  name:'Hunger Deal 3',  category:'Deals', price:580,  description:'Zinger Burger + 1 Chicken Piece + Regular Drink', tags:['deal']),
    MenuItemModel(id:'d4',  name:'Hunger Deal 4',  category:'Deals', price:750,  description:'3 Chicken Pieces + 1 Liter Drink', tags:['deal']),
    MenuItemModel(id:'d5',  name:'Hunger Deal 5',  category:'Deals', price:1150, description:'2 Zinger Cheese + Regular Fries + 1 Liter Drink', tags:['deal']),
    MenuItemModel(id:'d6',  name:'Hunger Deal 6',  category:'Deals', price:1350, description:'2 Zinger Burger + 1 Small Pizza + 2 Regular Drinks', tags:['deal','bestseller'], isFeatured:true),
    MenuItemModel(id:'d7',  name:'Hunger Deal 7',  category:'Deals', price:1600, description:'4 Zinger Burger + 1 Regular Fries + 1 Liter Drink', tags:['deal']),
    MenuItemModel(id:'d8',  name:'Hunger Deal 8',  category:'Deals', price:850,  description:'10 pcs Hot Wings + 2 Regular Drinks', tags:['deal']),
    MenuItemModel(id:'d9',  name:'Hunger Deal 9',  category:'Deals', price:1450, description:'3 Chicken Pieces + Fried Rice + Regular Fries + 1 Liter Drink', tags:['deal']),
    MenuItemModel(id:'d10', name:'Hunger Deal 10', category:'Deals', price:2000, description:'8 Fried Chicken + Regular Fries + 1 Liter Drink', tags:['deal','family'], isFeatured:true),
    MenuItemModel(id:'d11', name:'Hunger Deal 11', category:'Deals', price:2000, description:'2 Zinger Cheese + 1 Medium Pizza + 1.5 Liter Drink', tags:['deal']),
    MenuItemModel(id:'d12', name:'Hunger Deal 12', category:'Deals', price:3200, description:'4 Zinger Cheese + Large Pizza + 1.5 Liter Drink', tags:['deal']),
    MenuItemModel(id:'d13', name:'Hunger Deal 13', category:'Deals', price:3750, description:'Large Pizza + 4 Zinger Burger + 10 Hot Wings + Family Fries + 1.5 Liter Drink', tags:['deal','family','value'], isFeatured:true),
    MenuItemModel(id:'pd1', name:'Pizza Deal 1',   category:'Deals', price:1300, description:'2 Small Pizza + 2 Regular Drinks', tags:['deal','pizza']),
    MenuItemModel(id:'pd2', name:'Pizza Deal 2',   category:'Deals', price:2200, description:'2 Regular Pizza + 1 Liter Drink', tags:['deal','pizza']),
    MenuItemModel(id:'pd3', name:'Pizza Deal 3',   category:'Deals', price:2950, description:'2 Large Pizza + 1.5 Liter Drink', tags:['deal','pizza']),
    MenuItemModel(id:'pd4', name:'Pizza Deal 4',   category:'Deals', price:3100, description:'1 Small + 1 Regular + 1 Large Pizza + 1.5 Liter Drink', tags:['deal','pizza','family']),
    // ════ BURGERS ═══════════════════════════════════════════════════
    MenuItemModel(id:'b1',  name:'Zinger Burger',          category:'Burgers', price:350, isFeatured:true,  description:'Crispy zinger fillet in a soft bun with fresh veggies', tags:['bestseller']),
    MenuItemModel(id:'b2',  name:'Crispy Culeslow Burger',  category:'Burgers', price:400, description:'Crispy fillet topped with creamy coleslaw'),
    MenuItemModel(id:'b3',  name:'Zinger Cheese',           category:'Burgers', price:450, isFeatured:true,  description:'Classic zinger with melted cheese slice', tags:['popular']),
    MenuItemModel(id:'b4',  name:'Grilled Chicken',         category:'Burgers', price:500, description:'Juicy grilled chicken breast with lettuce and mayo'),
    MenuItemModel(id:'b5',  name:'Tower Zinger',            category:'Burgers', price:550, description:'Double-stacked zinger tower with hash brown'),
    MenuItemModel(id:'b6',  name:'Burger Pizza',            category:'Burgers', price:550, description:'A burger meets pizza — loaded with toppings'),
    MenuItemModel(id:'b7',  name:'Fish Burger',             category:'Burgers', price:500, description:'Crispy fish fillet with tartar sauce and lettuce'),
    MenuItemModel(id:'b8',  name:'Mighty Zinger',           category:'Burgers', price:600, isSpicy:true, description:'Extra large zinger fillet with double sauce', tags:['spicy']),
    MenuItemModel(id:'b9',  name:'Grilled Big Bang',        category:'Burgers', price:700, description:'Signature grilled burger with smoky sauce', tags:['signature']),
    MenuItemModel(id:'b10', name:'Prime Beef Burger',       category:'Burgers', price:700, description:'100% beef patty with caramelized onions', tags:['premium']),
    MenuItemModel(id:'b11', name:'Nuggets Burger',          category:'Burgers', price:200, description:'Kids-friendly nugget burger', tags:['kids']),
    MenuItemModel(id:'b12', name:'Chicken Patty Burger',    category:'Burgers', price:250, description:'Simple chicken patty burger', tags:['kids']),
    // ════ PIZZA ══════════════════════════════════════════════════════
    MenuItemModel(id:'pc1', name:'Chicken Tikka',   category:'Pizza', price:600,  isFeatured:true, description:'Zesty chicken tikka on tomato sauce', tags:['classic'], sizes:{'S (7")':600,'R (11")':1100,'L (13")':1500,'XL (16")':1850}),
    MenuItemModel(id:'pc2', name:'Chicken Fajita',  category:'Pizza', price:600,  description:'Fajita-spiced chicken with bell peppers', tags:['classic'], sizes:{'S (7")':600,'R (11")':1100,'L (13")':1500,'XL (16")':1850}),
    MenuItemModel(id:'pc3', name:'Behari Kabab',    category:'Pizza', price:600,  isSpicy:true, description:'Smoky behari kabab with chutney drizzle', tags:['classic','spicy'], sizes:{'S (7")':600,'R (11")':1100,'L (13")':1500,'XL (16")':1850}),
    MenuItemModel(id:'pc4', name:'Pepperoni',       category:'Pizza', price:600,  description:'Classic pepperoni with mozzarella', tags:['classic'], sizes:{'S (7")':600,'R (11")':1100,'L (13")':1500,'XL (16")':1850}),
    MenuItemModel(id:'pc5', name:'Creamy Chicken',  category:'Pizza', price:600,  description:'White sauce base with tender chicken', tags:['classic'], sizes:{'S (7")':600,'R (11")':1100,'L (13")':1500,'XL (16")':1850}),
    MenuItemModel(id:'pc6', name:'Cheese Lover',    category:'Pizza', price:600,  description:'Four-cheese blend on pizza base', tags:['classic'], sizes:{'S (7")':600,'R (11")':1100,'L (13")':1500,'XL (16")':1850}),
    MenuItemModel(id:'ps1', name:'Hunger Crust',    category:'Pizza', price:1350, description:'Stuffed crust with premium toppings', tags:['special'], sizes:{'R (11")':1350,'L (13")':1900,'XL (16")':2200}),
    MenuItemModel(id:'ps2', name:'Hunger Crown',    category:'Pizza', price:1300, description:'Crown-shaped crust with fillings', tags:['special'], sizes:{'R (11")':1300,'L (13")':1900,'XL (16")':2200}),
    MenuItemModel(id:'ps3', name:'Hunger Special',  category:'Pizza', price:1300, isFeatured:true, description:'Signature special pizza', tags:['special'], sizes:{'R (11")':1300,'L (13")':1900,'XL (16")':2200}),
    MenuItemModel(id:'ps4', name:'Supreme Pizza',   category:'Pizza', price:1300, description:'Supreme loaded pizza with everything', tags:['special'], sizes:{'R (11")':1300,'L (13")':1900,'XL (16")':2200}),
    MenuItemModel(id:'ps5', name:'BBQ Pizza',       category:'Pizza', price:1300, description:'Smoky BBQ sauce base with grilled chicken', tags:['special'], sizes:{'R (11")':1300,'L (13")':1900,'XL (16")':2200}),
    MenuItemModel(id:'ps6', name:'Four Season Pizza', category:'Pizza', price:2800, isFeatured:true, description:'Fish, Kabab, Cheese and Tikka on one pizza', tags:['signature','premium']),
    // ════ FRIED CHICKEN ══════════════════════════════════════════════
    MenuItemModel(id:'fc1', name:'Leg Piece',         category:'Fried Chicken', price:200, description:'Crispy fried chicken leg piece'),
    MenuItemModel(id:'fc2', name:'Chest Piece',       category:'Fried Chicken', price:250, description:'Juicy crispy fried chicken chest piece'),
    MenuItemModel(id:'fc3', name:'Zinger Piece',      category:'Fried Chicken', price:250, description:'Spicy crispy zinger chicken piece'),
    MenuItemModel(id:'fc4', name:'Chicken Nuggets',   category:'Fried Chicken', price:500, description:'10 golden crispy chicken nuggets', tags:['popular']),
    MenuItemModel(id:'fc5', name:'Full Broast',       category:'Fried Chicken', price:1800, description:'Full broast chicken with fries', tags:['family']),
    MenuItemModel(id:'fc6', name:'Half Broast',       category:'Fried Chicken', price:900,  description:'Half broast chicken'),
    // ════ WINGS ══════════════════════════════════════════════════════
    MenuItemModel(id:'w1', name:'BBQ Wings',          category:'Wings', price:700, description:'10 pcs smoky BBQ glazed wings', tags:['popular']),
    MenuItemModel(id:'w2', name:'Crispy Wings',       category:'Wings', price:700, description:'10 pcs crispy battered wings'),
    MenuItemModel(id:'w3', name:'Mayo Wings',         category:'Wings', price:700, description:'10 pcs wings in creamy mayo'),
    MenuItemModel(id:'w4', name:'Grilled Wings Small',category:'Wings', price:500, description:'6 pcs healthy grilled wings'),
    MenuItemModel(id:'w5', name:'Grilled Wings Medium',category:'Wings',price:700, description:'10 pcs healthy grilled wings', tags:['popular']),
    // ════ FRIES ══════════════════════════════════════════════════════
    MenuItemModel(id:'fr1', name:'Plain Fries Regular', category:'Fries', price:200, description:'Golden salted fries — regular'),
    MenuItemModel(id:'fr2', name:'Plain Fries Large',   category:'Fries', price:300, description:'Golden salted fries — large'),
    MenuItemModel(id:'fr3', name:'Plain Fries Family',  category:'Fries', price:400, description:'Golden salted fries — family size'),
    MenuItemModel(id:'fr4', name:'Mayo Fries Regular',  category:'Fries', price:250, description:'Fries with creamy mayo'),
    MenuItemModel(id:'fr5', name:'Mayo Fries Large',    category:'Fries', price:350, description:'Large fries with creamy mayo', tags:['popular']),
    MenuItemModel(id:'fr6', name:'Mayo Fries Family',   category:'Fries', price:500, description:'Family fries with creamy mayo'),
    // ════ SHAWARMA ═══════════════════════════════════════════════════
    MenuItemModel(id:'sh1', name:'Chicken Shawarma',        category:'Shawarma', price:220, description:'Classic chicken shawarma with garlic sauce'),
    MenuItemModel(id:'sh2', name:'Chicken Cheese Shawarma', category:'Shawarma', price:250, description:'Chicken shawarma with melted cheese'),
    MenuItemModel(id:'sh3', name:'Zinger Shawarma',         category:'Shawarma', price:300, description:'Crispy zinger fillet in shawarma style', tags:['popular']),
    MenuItemModel(id:'sh4', name:'Zinger Cheese Shawarma',  category:'Shawarma', price:350, description:'Zinger shawarma with extra cheese'),
    // ════ PARATHA ROLL ═══════════════════════════════════════════════
    MenuItemModel(id:'pr1', name:'Pizza Paratha Roll',    category:'Paratha Roll', price:450, description:'Pizza-flavored filling in crispy paratha'),
    MenuItemModel(id:'pr2', name:'Chicken Paratha Roll',  category:'Paratha Roll', price:300, description:'Tender chicken in a hot paratha'),
    MenuItemModel(id:'pr3', name:'Chicken Cheese Paratha',category:'Paratha Roll', price:350, description:'Chicken and cheese stuffed paratha'),
    MenuItemModel(id:'pr4', name:'Zinger Paratha Roll',   category:'Paratha Roll', price:350, description:'Zinger fillet in crispy paratha'),
    MenuItemModel(id:'pr5', name:'Zinger Cheese Paratha', category:'Paratha Roll', price:400, description:'Zinger and cheese in crispy paratha'),
    // ════ BIRYANI ════════════════════════════════════════════════════
    MenuItemModel(id:'bi1', name:'Single Biryani', category:'Biryani', price:300, description:'Aromatic spiced biryani — single portion'),
    MenuItemModel(id:'bi2', name:'Double Biryani', category:'Biryani', price:500, description:'Aromatic spiced biryani — double portion', tags:['popular']),
    // ════ CHINESE ════════════════════════════════════════════════════
    MenuItemModel(id:'ch1', name:'Chicken Choman',        category:'Chinese', price:550, description:'Stir-fried chicken chow mein noodles'),
    MenuItemModel(id:'ch2', name:'Chicken Chilli Dry Rice',category:'Chinese', price:550, isSpicy:true, description:'Spicy chicken chilli with dry fried rice'),
    MenuItemModel(id:'ch3', name:'Chicken Shashilk Rice', category:'Chinese', price:550, description:'Chicken shashlik skewers with fried rice'),
    MenuItemModel(id:'ch4', name:'Special Fried Rice',    category:'Chinese', price:500, description:'Wok-tossed egg fried rice with veggies'),
    // ════ SOUP ═══════════════════════════════════════════════════════
    MenuItemModel(id:'so1', name:'Chicken Corn Soup (1 person)',    category:'Soup', price:200, description:'Chicken corn soup — single'),
    MenuItemModel(id:'so2', name:'Chicken Corn Soup (4 persons)',   category:'Soup', price:500, description:'Chicken corn soup — serves 4'),
    MenuItemModel(id:'so3', name:'Hot & Sour Soup (4 persons)',     category:'Soup', price:450, isSpicy:true, description:'Hot and sour soup — serves 4'),
    MenuItemModel(id:'so4', name:'Chicken Special Soup (4 persons)',category:'Soup', price:650, description:'Signature soup — serves 4', tags:['signature']),
    // ════ PASTA ══════════════════════════════════════════════════════
    MenuItemModel(id:'pa1', name:'Pizza Style Pasta', category:'Pasta', price:400, description:'Pasta in rich pizza-style tomato sauce'),
    MenuItemModel(id:'pa2', name:'Alfredo Pasta',     category:'Pasta', price:600, description:'Creamy white Alfredo sauce with chicken'),
    // ════ FISH & CHIPS ═══════════════════════════════════════════════
    MenuItemModel(id:'fi1', name:'Full Finger Fish', category:'Fish & Chips', price:2400, description:'Full platter of crispy battered finger fish'),
    MenuItemModel(id:'fi2', name:'Half Finger Fish', category:'Fish & Chips', price:1200, description:'Half platter crispy battered finger fish'),
    MenuItemModel(id:'fi3', name:'Pizza Fries',      category:'Fish & Chips', price:500,  description:'Pizza-topped loaded fries'),
  ];
}
