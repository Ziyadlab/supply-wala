import 'package:flutter/material.dart';

enum UserRole { restaurant, supplier }

enum OrderStatus {
  pending,
  accepted,
  preparing,
  dispatched,
  completed,
  rejected,
}

extension UserRoleLabel on UserRole {
  String get label => this == UserRole.restaurant ? 'Restaurant' : 'Supplier';
}

extension OrderStatusLabel on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.accepted:
        return 'Accepted';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.dispatched:
        return 'Dispatched';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.rejected:
        return 'Rejected';
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.completed:
        return Colors.green;
      case OrderStatus.rejected:
        return Colors.red;
      case OrderStatus.pending:
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }
}

class AppUser {
  AppUser({
    required this.name,
    required this.email,
    required this.role,
    required this.businessName,
    required this.location,
    required this.phone,
    required this.avatarUrl,
  });

  String name;
  String email;
  UserRole role;
  String businessName;
  String location;
  String phone;
  String avatarUrl;
}

class Product {
  Product({
    required this.id,
    required this.supplierId,
    required this.name,
    required this.imageUrl,
    required this.category,
    required this.price,
    required this.quantity,
    required this.unit,
    required this.isAvailable,
  });

  final String id;
  final String supplierId;
  String name;
  String imageUrl;
  String category;
  double price;
  int quantity;
  String unit;
  bool isAvailable;
}

class Supplier {
  Supplier({
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.category,
    required this.rating,
    required this.location,
    required this.description,
    required this.highlights,
    required this.phone,
  });

  final String id;
  String name;
  String logoUrl;
  String category;
  double rating;
  String location;
  String description;
  List<String> highlights;
  String phone;
}

class CartItem {
  CartItem({required this.product, required this.quantity});

  final Product product;
  int quantity;

  double get total => quantity * product.price;
}

class OrderItem {
  OrderItem({
    required this.productName,
    required this.quantity,
    required this.unit,
    required this.price,
  });

  final String productName;
  final int quantity;
  final String unit;
  final double price;

  double get total => quantity * price;
}

class AppOrder {
  AppOrder({
    required this.id,
    required this.restaurantName,
    required this.supplierId,
    required this.supplierName,
    required this.items,
    required this.status,
    required this.createdAt,
    required this.deliveryAddress,
  });

  final String id;
  final String restaurantName;
  final String supplierId;
  final String supplierName;
  final List<OrderItem> items;
  OrderStatus status;
  final DateTime createdAt;
  final String deliveryAddress;

  double get total => items.fold(0, (sum, item) => sum + item.total);
}

class ChatThread {
  ChatThread({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.avatarUrl,
    required this.messages,
  });

  final String id;
  final String name;
  String subtitle;
  final String avatarUrl;
  final List<ChatMessage> messages;
}

class ChatMessage {
  ChatMessage({required this.text, required this.isMine, required this.sentAt});

  final String text;
  final bool isMine;
  final DateTime sentAt;
}

class VoiceOrderDraft {
  VoiceOrderDraft({
    required this.transcript,
    required this.items,
    required this.notes,
  });

  final String transcript;
  final List<CartItem> items;
  final String notes;
}
