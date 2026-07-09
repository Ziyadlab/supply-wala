import '../models/app_models.dart';

class SampleData {
  static final suppliers = <Supplier>[
    Supplier(
      id: 'sup1',
      name: 'Fresh Farm Supplies',
      logoUrl:
          'https://images.unsplash.com/photo-1542838132-92c53300491e?w=500',
      category: 'Vegetables',
      rating: 4.8,
      location: 'Johar Town, Lahore',
      description:
          'Daily fresh vegetables, fruits, herbs, and bulk kitchen staples for restaurants.',
      highlights: ['Tomatoes', 'Potatoes', 'Onions', 'Greens'],
      phone: '+92 300 1112223',
    ),
    Supplier(
      id: 'sup2',
      name: 'Dairy Direct',
      logoUrl:
          'https://images.unsplash.com/photo-1628088062854-d1870b4553da?w=500',
      category: 'Dairy',
      rating: 4.6,
      location: 'Gulberg, Lahore',
      description:
          'Trusted dairy distributor with chilled delivery for milk, butter, cream, and cheese.',
      highlights: ['Milk cartons', 'Cheese', 'Butter', 'Yogurt'],
      phone: '+92 301 4447778',
    ),
    Supplier(
      id: 'sup3',
      name: 'Meat Master Wholesale',
      logoUrl:
          'https://images.unsplash.com/photo-1607623814075-e51df1bdc82f?w=500',
      category: 'Meat',
      rating: 4.7,
      location: 'Model Town, Lahore',
      description:
          'Hygienic wholesale chicken, beef, and seafood with restaurant-grade cuts.',
      highlights: ['Chicken', 'Beef', 'Fish', 'Mince'],
      phone: '+92 302 8889991',
    ),
    Supplier(
      id: 'sup4',
      name: 'Pak Packaging Hub',
      logoUrl:
          'https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?w=500',
      category: 'Packaging',
      rating: 4.4,
      location: 'DHA, Lahore',
      description:
          'Disposable boxes, paper bags, cups, wraps, and delivery packaging.',
      highlights: ['Takeaway boxes', 'Cups', 'Bags', 'Labels'],
      phone: '+92 303 5551212',
    ),
  ];

  static final products = <Product>[
    Product(
      id: 'p1',
      supplierId: 'sup1',
      name: 'Tomatoes',
      imageUrl:
          'https://images.unsplash.com/photo-1546470427-e26264be0b0d?w=500',
      category: 'Vegetables',
      price: 220,
      quantity: 150,
      unit: 'kg',
      isAvailable: true,
    ),
    Product(
      id: 'p2',
      supplierId: 'sup1',
      name: 'Potatoes',
      imageUrl:
          'https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=500',
      category: 'Vegetables',
      price: 130,
      quantity: 220,
      unit: 'kg',
      isAvailable: true,
    ),
    Product(
      id: 'p3',
      supplierId: 'sup1',
      name: 'Onions',
      imageUrl:
          'https://images.unsplash.com/photo-1618512496248-a07fe83aa8cb?w=500',
      category: 'Vegetables',
      price: 160,
      quantity: 180,
      unit: 'kg',
      isAvailable: true,
    ),
    Product(
      id: 'p4',
      supplierId: 'sup2',
      name: 'Milk Carton',
      imageUrl:
          'https://images.unsplash.com/photo-1563636619-e9143da7973b?w=500',
      category: 'Dairy',
      price: 310,
      quantity: 90,
      unit: 'carton',
      isAvailable: true,
    ),
    Product(
      id: 'p5',
      supplierId: 'sup2',
      name: 'Cheddar Cheese',
      imageUrl:
          'https://images.unsplash.com/photo-1486297678162-eb2a19b0a32d?w=500',
      category: 'Dairy',
      price: 1450,
      quantity: 45,
      unit: 'kg',
      isAvailable: true,
    ),
    Product(
      id: 'p6',
      supplierId: 'sup3',
      name: 'Chicken Breast',
      imageUrl:
          'https://images.unsplash.com/photo-1604503468506-a8da13d82791?w=500',
      category: 'Meat',
      price: 980,
      quantity: 80,
      unit: 'kg',
      isAvailable: true,
    ),
    Product(
      id: 'p7',
      supplierId: 'sup3',
      name: 'Beef Mince',
      imageUrl:
          'https://images.unsplash.com/photo-1588168333986-5078d3ae3976?w=500',
      category: 'Meat',
      price: 1600,
      quantity: 55,
      unit: 'kg',
      isAvailable: true,
    ),
    Product(
      id: 'p8',
      supplierId: 'sup4',
      name: 'Takeaway Box',
      imageUrl:
          'https://images.unsplash.com/photo-1604719312566-8912e9227c6a?w=500',
      category: 'Packaging',
      price: 22,
      quantity: 1200,
      unit: 'piece',
      isAvailable: true,
    ),
  ];

  static final orders = <AppOrder>[
    AppOrder(
      id: 'ORD-1001',
      restaurantName: 'Spice Bistro',
      supplierId: 'sup1',
      supplierName: 'Fresh Farm Supplies',
      items: [
        OrderItem(
          productName: 'Tomatoes',
          quantity: 10,
          unit: 'kg',
          price: 220,
        ),
        OrderItem(productName: 'Onions', quantity: 5, unit: 'kg', price: 160),
      ],
      status: OrderStatus.pending,
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      deliveryAddress: 'MM Alam Road, Lahore',
    ),
    AppOrder(
      id: 'ORD-1002',
      restaurantName: 'Spice Bistro',
      supplierId: 'sup2',
      supplierName: 'Dairy Direct',
      items: [
        OrderItem(
          productName: 'Milk Carton',
          quantity: 3,
          unit: 'carton',
          price: 310,
        ),
      ],
      status: OrderStatus.completed,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      deliveryAddress: 'MM Alam Road, Lahore',
    ),
  ];

  static final chats = <ChatThread>[
    ChatThread(
      id: 'c1',
      name: 'Fresh Farm Supplies',
      subtitle: 'Tomatoes are available for morning delivery.',
      avatarUrl: suppliers.first.logoUrl,
      messages: [
        ChatMessage(
          text: 'Do you have 20 kg tomatoes available?',
          isMine: true,
          sentAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        ChatMessage(
          text: 'Yes, fresh stock arrived today.',
          isMine: false,
          sentAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
      ],
    ),
    ChatThread(
      id: 'c2',
      name: 'Dairy Direct',
      subtitle: 'Milk cartons confirmed.',
      avatarUrl: suppliers[1].logoUrl,
      messages: [
        ChatMessage(
          text: 'Can you reserve 5 cartons?',
          isMine: true,
          sentAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        ChatMessage(
          text: 'Confirmed.',
          isMine: false,
          sentAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ],
    ),
  ];
}
