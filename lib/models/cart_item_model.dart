import 'menu_item_model.dart';

class CartItemModel {
  final MenuItemModel item;
  int quantity;
  final String? selectedSize;

  CartItemModel({required this.item, this.quantity = 1, this.selectedSize});

  double get unitPrice => selectedSize != null
      ? (item.sizes?[selectedSize!] ?? item.price)
      : item.price;

  double get totalPrice => unitPrice * quantity;

  String get displayName => selectedSize != null
      ? '${item.name} ($selectedSize)' : item.name;
}
