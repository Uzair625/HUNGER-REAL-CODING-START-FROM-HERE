import 'package:cloud_firestore/cloud_firestore.dart';

class OrderItemSnapshot {
  final String name, category;
  final String? selectedSize;
  final int quantity;
  final double unitPrice, totalPrice;

  OrderItemSnapshot({
    required this.name, required this.category,
    this.selectedSize, required this.quantity,
    required this.unitPrice, required this.totalPrice,
  });

  Map<String, dynamic> toMap() => {
    'name': name, 'category': category, 'selectedSize': selectedSize,
    'quantity': quantity, 'unitPrice': unitPrice, 'totalPrice': totalPrice,
  };

  factory OrderItemSnapshot.fromMap(Map<String, dynamic> d) => OrderItemSnapshot(
    name: d['name'] ?? '', category: d['category'] ?? '',
    selectedSize: d['selectedSize'], quantity: d['quantity'] ?? 1,
    unitPrice: (d['unitPrice'] ?? 0).toDouble(),
    totalPrice: (d['totalPrice'] ?? 0).toDouble(),
  );
}

class OrderModel {
  final String id, userId, customerPhone, customerName, deliveryAddress, paymentMethod, status;
  final List<OrderItemSnapshot> items;
  final double subtotal, deliveryFee, discount, total;
  final DateTime createdAt;
  final double? latitude, longitude;

  OrderModel({
    required this.id, required this.userId, required this.customerPhone,
    required this.customerName, required this.deliveryAddress,
    required this.paymentMethod, required this.status,
    required this.items, required this.subtotal, required this.deliveryFee,
    required this.discount, required this.total, required this.createdAt,
    this.latitude, this.longitude,
  });

  bool get hasLocation => latitude != null && longitude != null;
  String get googleMapsUrl => hasLocation
      ? 'https://www.google.com/maps?q=$latitude,$longitude'
      : '';

  String get statusLabel {
    switch (status) {
      case 'placed':     return '🕐 Order Placed';
      case 'confirmed':  return '✅ Confirmed';
      case 'preparing':  return '👨‍🍳 Preparing';
      case 'on_the_way': return '🛵 On the Way';
      case 'delivered':  return '🎉 Delivered';
      default:           return status;
    }
  }

  Map<String, dynamic> toMap() => {
    'id': id, 'userId': userId, 'customerPhone': customerPhone,
    'customerName': customerName, 'deliveryAddress': deliveryAddress,
    'paymentMethod': paymentMethod, 'status': status,
    'items': items.map((i) => i.toMap()).toList(),
    'subtotal': subtotal, 'deliveryFee': deliveryFee,
    'discount': discount, 'total': total,
    'createdAt': Timestamp.fromDate(createdAt),
    if (latitude != null) 'latitude': latitude,
    if (longitude != null) 'longitude': longitude,
  };

  factory OrderModel.fromMap(Map<String, dynamic> d) => OrderModel(
    id: d['id'] ?? '',
    userId: d['userId'] ?? '',
    customerPhone: d['customerPhone'] ?? '',
    customerName: d['customerName'] ?? '',
    deliveryAddress: d['deliveryAddress'] ?? '',
    paymentMethod: d['paymentMethod'] ?? '',
    status: d['status'] ?? 'placed',
    items: (d['items'] as List<dynamic>? ?? [])
        .map((i) => OrderItemSnapshot.fromMap(i as Map<String, dynamic>))
        .toList(),
    subtotal: (d['subtotal'] ?? 0).toDouble(),
    deliveryFee: (d['deliveryFee'] ?? 0).toDouble(),
    discount: (d['discount'] ?? 0).toDouble(),
    total: (d['total'] ?? 0).toDouble(),
    createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    latitude: d['latitude']?.toDouble(),
    longitude: d['longitude']?.toDouble(),
  );
}