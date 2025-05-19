import 'package:flutter/material.dart';
import 'package:adoption_ui_app/main/widgets/custom_app_bar.dart';
import 'package:adoption_ui_app/theme/color.dart';
import 'package:adoption_ui_app/marketplace/models/cart_item.dart';
import 'package:adoption_ui_app/marketplace/services/cart_service.dart';
import 'package:adoption_ui_app/marketplace/screens/checkout_page.dart';

class MarketplaceCart extends StatefulWidget {
  @override
  _MarketplaceCartState createState() => _MarketplaceCartState();
}

class _MarketplaceCartState extends State<MarketplaceCart>
    with TickerProviderStateMixin {
  final CartService _cartService = CartService();
  int? selectedItemIndex;
  bool _isDisposed = false;
  final List<AnimationController> _removeControllers = [];

  // Add selection animation controller
  late AnimationController _selectionController;
  late Animation<double> _selectionAnimation;

  List<CartItem> cartItems = [];
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  // Add this to cache the stream data
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    // Initialize animation controller first
    _selectionController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _selectionAnimation = CurvedAnimation(
      parent: _selectionController,
      curve: Curves.easeInOut,
    );

    // Get current cart items directly
    cartItems = List.from(_cartService.cartItems);
    _updateAnimationControllers();

    // Listen to cart changes
    _cartService.cartStream.listen((updatedItems) {
      if (!_isDisposed && mounted) {
        setState(() {
          _updateItemsList(updatedItems);
        });
      }
    });

    // Listen for item removals
    _cartService.onItemRemoved.listen((itemId) {
      if (!_isDisposed) {
        _removeItemById(itemId);
      }
    });
  }

  void _removeItemById(String itemId) {
    final index = cartItems.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      _removeItem(
        index,
      ); // Call the existing _removeItem method to remove the item
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    for (var controller in _removeControllers) {
      if (controller.isAnimating) {
        controller.stop();
      }
      controller.dispose();
    }
    _removeControllers.clear();
    _selectionController.dispose();
    super.dispose();
  }

  void _updateAnimationControllers() {
    // Dispose existing controllers
    for (var controller in _removeControllers) {
      if (controller.isAnimating) {
        controller.stop();
      }
      controller.dispose();
    }
    _removeControllers.clear();

    // Create new controllers for current items
    for (int i = 0; i < cartItems.length; i++) {
      _removeControllers.add(
        AnimationController(vsync: this, duration: Duration(milliseconds: 300)),
      );
    }
  }

  void _updateItemsList(List<CartItem> newItems) {
    if (!mounted || _isDisposed) return;

    setState(() {
      // Simple approach - just replace the list and recreate controllers
      cartItems = List.from(newItems);
      _updateAnimationControllers();
    });
  }

  Future<void> _removeItem(int index) async {
    if (_isDisposed || index < 0 || index >= cartItems.length || _isDeleting)
      return;

    try {
      _isDeleting = true;

      // Capture the item to remove before any modifications
      final itemToRemove = cartItems[index];

      // Ensure the controller exists and animate it
      if (index < _removeControllers.length) {
        await _removeControllers[index].forward();
      }

      if (_isDisposed) return;

      // Remove the item from the animated list with fade-out animation
      if (_listKey.currentState != null) {
        _listKey.currentState!.removeItem(
          index,
          (context, animation) => SizeTransition(
            sizeFactor: animation,
            child: FadeTransition(
              opacity: animation, // Fade out the deleted item
              child: _buildCartItemCard(itemToRemove, index),
            ),
          ),
          duration: Duration(milliseconds: 300),
        );
      }

      if (_isDisposed) return;

      // Update state atomically
      setState(() {
        if (index < _removeControllers.length) {
          if (_removeControllers[index].isAnimating) {
            _removeControllers[index].stop();
          }
          _removeControllers[index].dispose();
          _removeControllers.removeAt(index);
        }
        cartItems.removeAt(index);
        if (selectedItemIndex == index) {
          selectedItemIndex = null;
          _selectionController.reverse();
        } else if (selectedItemIndex != null && selectedItemIndex! > index) {
          selectedItemIndex = selectedItemIndex! - 1;
        }
      });

      // Remove from cart service
      _cartService.removeFromCart(itemToRemove.id);
    } catch (e) {
      debugPrint('Error during item removal: $e');
    } finally {
      if (!_isDisposed) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  void _updateQuantity(String itemId, int delta) {
    final index = cartItems.indexWhere((item) => item.id == itemId);
    if (index >= 0) {
      final newQuantity = cartItems[index].quantity + delta;
      if (newQuantity <= 0) {
        _removeItem(index);
      } else {
        _cartService.updateQuantity(itemId, newQuantity);
      }
    }
  }

  void _handleLongPress(int index) {
    if (_isDisposed) return;
    setState(() {
      if (selectedItemIndex == index) {
        selectedItemIndex = null;
        _selectionController.reverse();
      } else {
        selectedItemIndex = index;
        _selectionController.forward(from: 0.0);
      }
    });
  }

  void _handleTap(int index) {
    if (_isDisposed) return;
    setState(() {
      if (selectedItemIndex == index) {
        selectedItemIndex = null;
        _selectionController.reverse();
      } else {
        selectedItemIndex = index;
        _selectionController.forward(from: 0.0);
      }
    });
  }

  Widget _buildCartItemCard(CartItem item, int index) {
    if (index >= _removeControllers.length) {
      return SizedBox.shrink();
    }

    final removeColorAnimation = ColorTween(
      begin: AppColor.secondary,
      end: Colors.transparent,
    ).animate(_removeControllers[index]);

    final removeBackgroundAnimation = ColorTween(
      begin: AppColor.secondary.withOpacity(0.15),
      end: Colors.transparent,
    ).animate(_removeControllers[index]);

    return GestureDetector(
      onLongPress: () => _handleLongPress(index),
      onTap: () => _handleTap(index),
      child: AnimatedBuilder(
        animation: _selectionAnimation,
        builder: (context, child) {
          final borderWidth =
              selectedItemIndex == index
                  ? 2.0 * _selectionAnimation.value
                  : 0.0;
          final borderColor =
              selectedItemIndex == index
                  ? AppColor.secondary.withOpacity(_selectionAnimation.value)
                  : Colors.transparent;

          return Container(
            margin: EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: AppColor.cardColor,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: AppColor.shadowColor.withOpacity(0.08),
                  blurRadius: 25,
                  offset: Offset(0, 8),
                ),
              ],
              border: Border.all(color: borderColor, width: borderWidth),
            ),
            child: Stack(
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25),
                        bottomLeft: Radius.circular(25),
                      ),
                      child: Image.asset(
                        item.image,
                        width: 120,
                        height: 140,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 120,
                            height: 140,
                            color: Colors.grey[200],
                            child: Icon(
                              Icons.image_not_supported,
                              size: 50,
                              color: Colors.grey[400],
                            ),
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppColor.mainColor,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              item.category,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColor.labelColor,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '\$${item.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColor.secondary,
                              ),
                            ),
                            SizedBox(height: 12),
                            Row(
                              children: [
                                _buildQuantityButton(
                                  icon: Icons.remove,
                                  onTap: () => _updateQuantity(item.id, -1),
                                ),
                                Container(
                                  margin: EdgeInsets.symmetric(horizontal: 8),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColor.appBgColor,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${item.quantity}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColor.textColor,
                                    ),
                                  ),
                                ),
                                _buildQuantityButton(
                                  icon: Icons.add,
                                  onTap: () => _updateQuantity(item.id, 1),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: 15,
                  right: 15,
                  child: GestureDetector(
                    onTap: () => _removeItem(index),
                    child: AnimatedBuilder(
                      animation: _removeControllers[index],
                      builder: (context, child) {
                        return Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: removeBackgroundAnimation.value,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.delete_outline,
                            color: removeColorAnimation.value,
                            size: 20,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                if (selectedItemIndex == index)
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: AnimatedBuilder(
                        animation: _selectionAnimation,
                        builder: (context, child) {
                          return Container(
                            color: AppColor.secondary.withOpacity(
                              0.05 * _selectionAnimation.value,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColor.secondary.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColor.secondary, size: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.appBgColor,
      appBar: CustomAppBar(showBackButton: true),
      bottomNavigationBar:
          cartItems.isNotEmpty ? _buildCheckoutSection() : null,
      body: cartItems.isEmpty ? _buildEmptyCart() : _buildCartItemsList(),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 64,
            color: AppColor.secondary.withOpacity(0.5),
          ),
          SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: TextStyle(color: AppColor.labelColor, fontSize: 16),
          ),
          SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              // Pop and return a reset command to the marketplace page
              Navigator.pop(context, {'action': 'reset_filters'});
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.secondary,
              elevation: 0,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              "Back to Shopping",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutSection() {
    double subtotal = _cartService.totalPrice;
    double shipping = 5.99;
    double tax = subtotal * 0.08;
    double total = subtotal + shipping + tax;

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColor.cardColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: AppColor.shadowColor.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Subtotal:",
                style: TextStyle(fontSize: 16, color: AppColor.labelColor),
              ),
              Text(
                "\$${subtotal.toStringAsFixed(2)}",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColor.textColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Shipping:",
                style: TextStyle(fontSize: 16, color: AppColor.labelColor),
              ),
              Text(
                "\$${shipping.toStringAsFixed(2)}",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColor.textColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Tax (8%):",
                style: TextStyle(fontSize: 16, color: AppColor.labelColor),
              ),
              Text(
                "\$${tax.toStringAsFixed(2)}",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColor.textColor,
                ),
              ),
            ],
          ),
          Divider(height: 24, thickness: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total:",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColor.textColor,
                ),
              ),
              Text(
                "\$${total.toStringAsFixed(2)}",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColor.secondary,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Container(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CheckoutPage(totalAmount: total),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.secondary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                "Checkout",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Extract list building to separate method
  Widget _buildCartItemsList() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColor.secondary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.shopping_cart, color: AppColor.secondary),
                      SizedBox(width: 12),
                      Text(
                        '${cartItems.length} Items • \$${_cartService.totalPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: AppColor.secondary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Clear cart button
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: GestureDetector(
                  onTap: () {
                    if (cartItems.isNotEmpty) {
                      _cartService.clearCart();
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColor.secondary.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.delete_sweep,
                      color: AppColor.secondary,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: AnimatedList(
            key: _listKey,
            initialItemCount: cartItems.length,
            padding: EdgeInsets.symmetric(horizontal: 20),
            itemBuilder: (context, index, animation) {
              return SlideTransition(
                position: animation.drive(
                  Tween(begin: Offset(1.0, 0.0), end: Offset.zero),
                ),
                child: _buildCartItemCard(cartItems[index], index),
              );
            },
          ),
        ),
      ],
    );
  }
}
