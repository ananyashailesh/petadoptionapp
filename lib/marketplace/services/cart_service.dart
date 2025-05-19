import 'dart:async';import 'package:adoption_ui_app/marketplace/models/cart_item.dart';

class CartService {
  static final CartService _instance = CartService._internal();

  factory CartService() {
    return _instance;
  }

  // In-memory cart data
  final List<CartItem> _cartItems = [];

  // Stream controller for cart updates
  final StreamController<List<CartItem>> _cartStreamController =
      StreamController<List<CartItem>>.broadcast();

  // Stream of cart items for UI to listen to
  Stream<List<CartItem>> get cartStream => _cartStreamController.stream;

  // Stream controller for individual item removal
  final _itemRemovedController = StreamController<String>.broadcast();

  // Stream for UI to listen to individual item removals
  Stream<String> get onItemRemoved => _itemRemovedController.stream;

  // Debouncer for cart updates
  Timer? _debounceTimer;

  CartService._internal() {
    // Add initial empty cart to stream immediately
    _cartStreamController.add([]);
  }

  // Notify listeners immediately without debounce
  void _notifyListeners() {
    // Always send a copy of the list to avoid modification issues
    _cartStreamController.add(List<CartItem>.from(_cartItems));
  }

  // Get all cart items
  List<CartItem> get cartItems => List.unmodifiable(_cartItems);

  // Get cart item count
  int get itemCount => _cartItems.fold(0, (sum, item) => sum + item.quantity);

  // Get total cart price
  double get totalPrice =>
      _cartItems.fold(0, (sum, item) => sum + item.totalPrice);

  // Add item to cart
  void addToCart(CartItem item) {
    final existingIndex = _cartItems.indexWhere(
      (cartItem) => cartItem.id == item.id,
    );

    if (existingIndex >= 0) {
      // Increment quantity if item already exists
      final existingItem = _cartItems[existingIndex];
      _cartItems[existingIndex] = existingItem.copyWith(
        quantity: existingItem.quantity + 1,
      );
    } else {
      // Add new item
      _cartItems.add(item);
    }

    // Notify listeners immediately
    _notifyListeners();
  }

  // Update item quantity
  void updateQuantity(String itemId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(itemId);
      return;
    }

    final index = _cartItems.indexWhere((item) => item.id == itemId);
    if (index >= 0) {
      _cartItems[index] = _cartItems[index].copyWith(quantity: quantity);
      _notifyListeners();
    }
  }

  // Remove item from cart
  void removeFromCart(String itemId) {
    _cartItems.removeWhere((item) => item.id == itemId);
    _notifyListeners();
    _itemRemovedController.add(itemId);
  }

  // Clear cart
  void clearCart() {
    _cartItems.clear();
    _notifyListeners();
  }

  // Dispose resources
  void dispose() {
    _debounceTimer?.cancel();
    _cartStreamController.close();
    _itemRemovedController.close();
  }
}
