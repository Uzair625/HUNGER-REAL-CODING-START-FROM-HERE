import '../utils/constants.dart';

class MenuItemModel {
  final String id, name, category, description;
  final double price;
  final bool isAvailable, isFeatured, isSpicy;
  final List<String> tags;
  final Map<String, double>? sizes;

  MenuItemModel({
    required this.id, required this.name,
    required this.category, required this.description,
    required this.price,
    this.isAvailable = true, this.isFeatured = false,
    this.isSpicy = false, this.tags = const [], this.sizes,
  });

  String get imageAsset => AppConstants.imageAsset(name);
  double get displayPrice => sizes?.values.reduce((a,b) => a < b ? a : b) ?? price;
  bool get isMultiSize => sizes != null && sizes!.isNotEmpty;

  String get categoryEmoji {
    const m = {
      'Deals':'🔥','Burgers':'🍔','Pizza':'🍕','Fried Chicken':'🍗',
      'Wings':'🍖','Fries':'🍟','Shawarma':'🌯','Paratha Roll':'🫔',
      'Biryani':'🍛','Chinese':'🥡','Soup':'🍲','Pasta':'🍝','Fish & Chips':'🐟',
    };
    return m[category] ?? '🍴';
  }

  Map<String, dynamic> toMap() => {
    'name': name, 'category': category, 'description': description,
    'price': price, 'isAvailable': isAvailable, 'isFeatured': isFeatured,
    'isSpicy': isSpicy, 'tags': tags, 'sizes': sizes,
  };
}
