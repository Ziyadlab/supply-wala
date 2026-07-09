import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/sample_data.dart';
import '../models/app_models.dart';

class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
    : super(notifier: state);

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found');
    return scope!.notifier!;
  }
}

class AppState extends ChangeNotifier {
  AppState() {
    ready = _restoreSession();
  }

  late final Future<void> ready;
  AppUser? currentUser;
  bool hasSeenOnboarding = false;
  bool isLoading = false;
  String? error;

  final List<Supplier> suppliers = List.of(SampleData.suppliers);
  final List<Product> products = List.of(SampleData.products);
  final List<AppOrder> orders = List.of(SampleData.orders);
  final List<ChatThread> chats = List.of(SampleData.chats);
  final List<CartItem> cart = [];

  String supplierSearch = '';
  String categoryFilter = 'All';
  String locationFilter = '';
  double ratingFilter = 0;
  static final Map<String, UserRole> _memoryRoleByEmail = {};
  static final Map<String, String> _memoryNameByEmail = {};
  static final Map<String, String> _memoryBusinessByEmail = {};

  bool get isLoggedIn => currentUser != null;
  bool get isRestaurant => currentUser?.role == UserRole.restaurant;
  bool get isSupplier => currentUser?.role == UserRole.supplier;

  List<String> get categories => [
    'All',
    ...{for (final s in suppliers) s.category},
  ];

  List<Supplier> get filteredSuppliers {
    return suppliers.where((supplier) {
      final query = supplierSearch.toLowerCase();
      final productsForSupplier = supplierProducts(
        supplier.id,
      ).map((p) => p.name.toLowerCase()).join(' ');
      final matchesQuery =
          query.isEmpty ||
          supplier.name.toLowerCase().contains(query) ||
          supplier.category.toLowerCase().contains(query) ||
          productsForSupplier.contains(query);
      final matchesCategory =
          categoryFilter == 'All' || supplier.category == categoryFilter;
      final matchesLocation =
          locationFilter.trim().isEmpty ||
          supplier.location.toLowerCase().contains(
            locationFilter.trim().toLowerCase(),
          );
      final matchesRating = supplier.rating >= ratingFilter;
      return matchesQuery &&
          matchesCategory &&
          matchesLocation &&
          matchesRating;
    }).toList();
  }

  List<Product> supplierProducts(String supplierId) {
    return products
        .where((product) => product.supplierId == supplierId)
        .toList();
  }

  Supplier? supplierById(String id) {
    for (final supplier in suppliers) {
      if (supplier.id == id) return supplier;
    }
    return null;
  }

  double get cartTotal => cart.fold(0, (sum, item) => sum + item.total);

  int get cartCount => cart.fold(0, (sum, item) => sum + item.quantity);

  int get inventoryCount {
    final supplierId = _activeSupplierId;
    return products.where((product) => product.supplierId == supplierId).length;
  }

  String get _activeSupplierId => suppliers.first.id;

  List<Product> get myInventory => supplierProducts(_activeSupplierId);

  List<AppOrder> get visibleOrders {
    if (isSupplier) {
      return orders;
    }
    return orders;
  }

  int get pendingOrders =>
      visibleOrders.where((o) => o.status == OrderStatus.pending).length;
  int get completedOrders =>
      visibleOrders.where((o) => o.status == OrderStatus.completed).length;

  bool get _canUseFirebaseAuth => Firebase.apps.isNotEmpty;

  Future<void> _restoreSession() async {
    if (!_canUseFirebaseAuth) return;
    final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) return;
    currentUser = await _appUserFromFirebase(firebaseUser, UserRole.restaurant);
    notifyListeners();
  }

  Future<AppUser> _appUserFromFirebase(
    firebase_auth.User firebaseUser,
    UserRole selectedRole,
  ) async {
    final displayParts = (firebaseUser.displayName ?? '').split('|');
    final roleName = displayParts.isNotEmpty ? displayParts.first : '';
    final storedRole = await _roleForEmail(firebaseUser.email ?? '');
    final role =
        storedRole ??
        (roleName == UserRole.supplier.name
            ? UserRole.supplier
            : roleName == UserRole.restaurant.name
            ? UserRole.restaurant
            : selectedRole);
    final storedName = await _valueForEmail(firebaseUser.email ?? '', 'name');
    final storedBusiness = await _valueForEmail(
      firebaseUser.email ?? '',
      'business',
    );
    final name =
        storedName ??
        (displayParts.length > 1 && displayParts[1].trim().isNotEmpty
            ? displayParts[1]
            : (role == UserRole.restaurant
                  ? 'Restaurant Owner'
                  : 'Supplier Owner'));
    final business =
        storedBusiness ??
        (displayParts.length > 2 && displayParts[2].trim().isNotEmpty
            ? displayParts[2]
            : (role == UserRole.restaurant
                  ? 'My Restaurant'
                  : 'My Supplier Business'));
    return AppUser(
      name: name,
      email: firebaseUser.email ?? '',
      role: role,
      businessName: business,
      location: 'Lahore, Pakistan',
      phone: '+92 300 1234567',
      avatarUrl: role == UserRole.restaurant
          ? 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=500'
          : suppliers.first.logoUrl,
    );
  }

  Future<bool> login(String email, String password, UserRole role) async {
    return _withLoading(() async {
      if (!email.contains('@') || password.length < 6) {
        error = 'Enter a valid email and at least 6 character password.';
        return false;
      }
      if (!_canUseFirebaseAuth) {
        error = 'Firebase is not initialized. Run FlutterFire configure first.';
        return false;
      }
      try {
        final credential = await firebase_auth.FirebaseAuth.instance
            .signInWithEmailAndPassword(
              email: email.trim(),
              password: password,
            );
        currentUser = await _appUserFromFirebase(credential.user!, role);
        error = null;
        return true;
      } on firebase_auth.FirebaseAuthException catch (exception) {
        error = _friendlyFirebaseError(exception);
        return false;
      }
    });
  }

  Future<bool> signInWithGoogle(UserRole role) async {
    return _withLoading(() async {
      if (!_canUseFirebaseAuth) {
        error = 'Firebase is not initialized. Run FlutterFire configure first.';
        return false;
      }
      try {
        late final firebase_auth.UserCredential credential;
        final googleProvider = firebase_auth.GoogleAuthProvider()
          ..addScope('email');

        if (kIsWeb) {
          credential = await firebase_auth.FirebaseAuth.instance
              .signInWithPopup(googleProvider);
        } else if (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS) {
          final googleUser = await GoogleSignIn.instance.authenticate();
          final googleAuth = googleUser.authentication;
          final firebaseCredential = firebase_auth
              .GoogleAuthProvider.credential(idToken: googleAuth.idToken);
          credential = await firebase_auth.FirebaseAuth.instance
              .signInWithCredential(firebaseCredential);
        } else {
          credential = await firebase_auth.FirebaseAuth.instance
              .signInWithProvider(googleProvider);
        }

        final user = credential.user;
        if (user == null) {
          error = 'Google sign in did not return a Firebase user.';
          return false;
        }
        await _ensureProfileForProviderUser(user, role);
        currentUser = await _appUserFromFirebase(user, role);
        error = null;
        return true;
      } on firebase_auth.FirebaseAuthException catch (exception) {
        error = _friendlyFirebaseError(exception);
        return false;
      } on GoogleSignInException catch (exception) {
        error = exception.code == GoogleSignInExceptionCode.canceled
            ? 'Google sign in was cancelled.'
            : exception.description ?? 'Google sign in failed.';
        return false;
      } catch (exception) {
        error = 'Google sign in failed. $exception';
        return false;
      }
    });
  }

  Future<bool> signup({
    required String name,
    required String businessName,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    return _withLoading(() async {
      if (name.trim().isEmpty ||
          businessName.trim().isEmpty ||
          !email.contains('@') ||
          password.length < 6) {
        error = 'Please complete all fields with valid information.';
        return false;
      }
      if (!_canUseFirebaseAuth) {
        error = 'Firebase is not initialized. Run FlutterFire configure first.';
        return false;
      }
      try {
        final credential = await firebase_auth.FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: email.trim(),
              password: password,
            );
        await credential.user?.updateDisplayName(
          '${role.name}|${name.trim()}|${businessName.trim()}',
        );
        await _saveLocalProfile(
          email: email.trim(),
          role: role,
          name: name.trim(),
          businessName: businessName.trim(),
        );
        currentUser = await _appUserFromFirebase(credential.user!, role);
        error = null;
        return true;
      } on firebase_auth.FirebaseAuthException catch (exception) {
        error = _friendlyFirebaseError(exception);
        return false;
      }
    });
  }

  Future<bool> forgotPassword(String email) async {
    return _withLoading(() async {
      if (!email.contains('@')) {
        error = 'Enter a valid email address.';
        return false;
      }
      if (!_canUseFirebaseAuth) {
        error = 'Firebase is not initialized. Run FlutterFire configure first.';
        return false;
      }
      try {
        await firebase_auth.FirebaseAuth.instance.sendPasswordResetEmail(
          email: email.trim(),
        );
      } on firebase_auth.FirebaseAuthException catch (exception) {
        error = _friendlyFirebaseError(exception);
        return false;
      }
      error = null;
      return true;
    });
  }

  Future<T> _withLoading<T>(Future<T> Function() action) async {
    isLoading = true;
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 450));
    final result = await action();
    isLoading = false;
    notifyListeners();
    return result;
  }

  void completeOnboarding() {
    hasSeenOnboarding = true;
    notifyListeners();
  }

  Future<void> logout() async {
    if (_canUseFirebaseAuth) {
      await firebase_auth.FirebaseAuth.instance.signOut();
      if (!kIsWeb) {
        try {
          await GoogleSignIn.instance.signOut();
        } catch (_) {}
      }
    }
    currentUser = null;
    cart.clear();
    notifyListeners();
  }

  String _friendlyFirebaseError(firebase_auth.FirebaseAuthException exception) {
    switch (exception.code) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'Email or password is incorrect.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'weak-password':
        return 'Use a stronger password.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled in Firebase Authentication.';
      case 'popup-closed-by-user':
      case 'cancelled-popup-request':
        return 'Google sign in was cancelled.';
      case 'network-request-failed':
        return 'Network error. Check your internet connection.';
      default:
        return exception.message ?? 'Firebase authentication failed.';
    }
  }

  Future<void> _ensureProfileForProviderUser(
    firebase_auth.User firebaseUser,
    UserRole role,
  ) async {
    final email = firebaseUser.email ?? '';
    if (email.isEmpty) return;
    final existingRole = await _roleForEmail(email);
    if (existingRole != null) return;
    final name = (firebaseUser.displayName?.trim().isNotEmpty ?? false)
        ? firebaseUser.displayName!.trim()
        : (role == UserRole.restaurant ? 'Restaurant Owner' : 'Supplier Owner');
    final businessName = role == UserRole.restaurant
        ? 'My Restaurant'
        : 'My Supplier Business';
    await _saveLocalProfile(
      email: email,
      role: role,
      name: name,
      businessName: businessName,
    );
  }

  Future<void> _saveLocalProfile({
    required String email,
    required UserRole role,
    required String name,
    required String businessName,
  }) async {
    final normalized = email.toLowerCase();
    _memoryRoleByEmail[normalized] = role;
    _memoryNameByEmail[normalized] = name;
    _memoryBusinessByEmail[normalized] = businessName;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_roleKey(normalized), role.name);
    await prefs.setString(_profileKey(normalized, 'name'), name);
    await prefs.setString(_profileKey(normalized, 'business'), businessName);
  }

  Future<UserRole?> _roleForEmail(String email) async {
    final normalized = email.toLowerCase();
    final memoryRole = _memoryRoleByEmail[normalized];
    if (memoryRole != null) return memoryRole;
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_roleKey(normalized));
    if (stored == UserRole.restaurant.name) return UserRole.restaurant;
    if (stored == UserRole.supplier.name) return UserRole.supplier;
    return null;
  }

  Future<String?> _valueForEmail(String email, String field) async {
    final normalized = email.toLowerCase();
    if (field == 'name' && _memoryNameByEmail.containsKey(normalized)) {
      return _memoryNameByEmail[normalized];
    }
    if (field == 'business' && _memoryBusinessByEmail.containsKey(normalized)) {
      return _memoryBusinessByEmail[normalized];
    }
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_profileKey(normalized, field));
  }

  String _roleKey(String email) => 'role:$email';
  String _profileKey(String email, String field) => 'profile:$email:$field';

  void setFilters({
    String? query,
    String? category,
    String? location,
    double? rating,
  }) {
    supplierSearch = query ?? supplierSearch;
    categoryFilter = category ?? categoryFilter;
    locationFilter = location ?? locationFilter;
    ratingFilter = rating ?? ratingFilter;
    notifyListeners();
  }

  void addToCart(Product product, [int quantity = 1]) {
    CartItem? existing;
    for (final item in cart) {
      if (item.product.id == product.id) {
        existing = item;
        break;
      }
    }
    if (existing == null) {
      cart.add(CartItem(product: product, quantity: quantity));
    } else {
      existing.quantity += quantity;
    }
    notifyListeners();
  }

  void updateCartQuantity(CartItem item, int quantity) {
    if (quantity <= 0) {
      cart.remove(item);
    } else {
      item.quantity = quantity;
    }
    notifyListeners();
  }

  void removeCartItem(CartItem item) {
    cart.remove(item);
    notifyListeners();
  }

  AppOrder? checkout(String address) {
    if (cart.isEmpty) return null;
    final firstSupplier = supplierById(cart.first.product.supplierId)!;
    final order = AppOrder(
      id: 'ORD-${1000 + orders.length + 1}',
      restaurantName: currentUser?.businessName ?? 'Restaurant',
      supplierId: firstSupplier.id,
      supplierName: firstSupplier.name,
      items: cart
          .map(
            (item) => OrderItem(
              productName: item.product.name,
              quantity: item.quantity,
              unit: item.product.unit,
              price: item.product.price,
            ),
          )
          .toList(),
      status: OrderStatus.pending,
      createdAt: DateTime.now(),
      deliveryAddress: address,
    );
    orders.insert(0, order);
    cart.clear();
    notifyListeners();
    return order;
  }

  void addOrUpdateProduct(Product product) {
    final index = products.indexWhere((item) => item.id == product.id);
    if (index == -1) {
      products.add(product);
    } else {
      products[index] = product;
    }
    notifyListeners();
  }

  void deleteProduct(Product product) {
    products.removeWhere((item) => item.id == product.id);
    notifyListeners();
  }

  void updateOrderStatus(AppOrder order, OrderStatus status) {
    order.status = status;
    notifyListeners();
  }

  ChatThread openChat(String name, String avatarUrl) {
    ChatThread? existing;
    for (final chat in chats) {
      if (chat.name == name) {
        existing = chat;
        break;
      }
    }
    if (existing != null) return existing;
    final chat = ChatThread(
      id: 'c${chats.length + 1}',
      name: name,
      subtitle: 'New conversation',
      avatarUrl: avatarUrl,
      messages: [],
    );
    chats.insert(0, chat);
    notifyListeners();
    return chat;
  }

  void sendMessage(ChatThread thread, String text) {
    if (text.trim().isEmpty) return;
    thread.messages.add(
      ChatMessage(text: text.trim(), isMine: true, sentAt: DateTime.now()),
    );
    thread.subtitle = text.trim();
    notifyListeners();
  }

  VoiceOrderDraft simulateVoiceOrder() {
    const transcript = 'Add 5 kg tomatoes and 2 cartons of milk to my cart.';
    return parseVoiceOrder(transcript);
  }

  VoiceOrderDraft parseVoiceOrder(String transcript) {
    final parsedItems = <CartItem>[];
    final normalized = transcript.toLowerCase();
    for (final product in products) {
      final productWords = product.name.toLowerCase().split(' ');
      final matchedWord = productWords.firstWhere(
        (word) => normalized.contains(_singular(word)),
        orElse: () => '',
      );
      if (matchedWord.isEmpty) continue;
      parsedItems.add(
        CartItem(
          product: product,
          quantity: _quantityNearProduct(normalized, matchedWord),
        ),
      );
    }
    return VoiceOrderDraft(
      transcript: transcript,
      items: parsedItems,
      notes: parsedItems.isEmpty
          ? 'No matching inventory item was found. Try saying a product name like tomatoes, milk, chicken, or boxes.'
          : 'Voice parser matched available inventory items. You can edit quantities before adding them to cart.',
    );
  }

  String _singular(String word) =>
      word.endsWith('s') ? word.substring(0, word.length - 1) : word;

  int _quantityNearProduct(String transcript, String productWord) {
    final productIndex = transcript.indexOf(_singular(productWord));
    if (productIndex <= 0) return 1;
    final beforeProduct = transcript.substring(0, productIndex);
    final matches = RegExp(r'\d+').allMatches(beforeProduct).toList();
    if (matches.isEmpty) return 1;
    return int.tryParse(matches.last.group(0) ?? '1') ?? 1;
  }

  void confirmVoiceDraft(VoiceOrderDraft draft) {
    for (final item in draft.items) {
      addToCart(item.product, item.quantity);
    }
  }

  void updateProfile({
    required String name,
    required String businessName,
    required String location,
    required String phone,
  }) {
    final user = currentUser;
    if (user == null) return;
    user.name = name;
    user.businessName = businessName;
    user.location = location;
    user.phone = phone;
    _saveLocalProfile(
      email: user.email,
      role: user.role,
      name: name,
      businessName: businessName,
    );
    notifyListeners();
  }
}
