import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/color.dart';
import '../models/cart_model.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool _isLoading = true;
  List<CartItem> _cartItems = [];
  Map<String, double> _cartTotals = {
    'subtotal': 0.0,
    'shipping': 0.0,
    'tax': 0.0,
    'total': 0.0,
  };
  
  // Get current user ID - IMPORTANT: Make sure this matches the logged-in user ID
  String get _userId => FirebaseAuth.instance.currentUser?.uid ?? 'guest';
  
  // Initialize cart service
  late final CartService _cartService = CartService(userId: _userId);

  @override
  void initState() {
    super.initState();
    _loadCartItems();
  }

  // Load cart items from Firestore
  Future<void> _loadCartItems() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Get cart items
      final items = await _cartService.getCartItems();
      
      // Calculate totals
      final totals = await _cartService.calculateCartTotals();
      
      setState(() {
        _cartItems = items;
        _cartTotals = totals;
        _isLoading = false;
      });
      
      // Debug: Print loaded items
      print('Loaded ${items.length} cart items for user: $_userId');
      for (var item in items) {
        print('Cart item: ${item.name}, price: ${item.price}, quantity: ${item.quantity}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      // Show error message with more details for debugging
      print('Error loading cart: ${e.toString()}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load cart: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Update item quantity
  Future<void> _updateQuantity(CartItem item, int newQuantity) async {
    if (newQuantity < 1) return;
    
    try {
      // Update in Firestore
      await _cartService.updateQuantity(item.id, newQuantity);
      
      // Reload cart
      _loadCartItems();
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update quantity: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Remove item from cart
  Future<void> _removeItem(CartItem item) async {
    try {
      // Remove from Firestore
      await _cartService.removeItem(item.id);
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Item removed from cart'),
          backgroundColor: AppColors.primaryDark,
          duration: Duration(seconds: 2),
        ),
      );
      
      // Reload cart
      _loadCartItems();
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to remove item: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Clear entire cart
  Future<void> _clearCart() async {
    try {
      // Clear in Firestore
      await _cartService.clearCart();
      
      // Reload cart
      _loadCartItems();
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cart cleared successfully'),
          backgroundColor: AppColors.primaryDark,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to clear cart: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Navigate to checkout
  void _proceedToCheckout() {
    // Navigate to checkout page
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        elevation: 0,
        backgroundColor: AppColors.primaryDark,
        title: Text(
          'Your Cart',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.white),
            onPressed: _isLoading || _cartItems.isEmpty
                ? null
                : () {
                    // Show confirmation dialog
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: Colors.grey.shade800,
                        title: Text('Clear Cart?', style: TextStyle(color: Colors.white)),
                        content: Text('Are you sure you want to remove all items?', 
                            style: TextStyle(color: Colors.white)),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _clearCart();
                            },
                            child: Text('Clear'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
          ),
        ],
      ),
      body: _isLoading 
          ? _buildLoadingView()
          : _cartItems.isEmpty
              ? _buildEmptyCart()
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: _cartItems.length,
                        itemBuilder: (context, index) {
                          final item = _cartItems[index];
                          return _buildCartItem(item);
                        },
                      ),
                    ),
                    _buildOrderSummary(),
                  ],
                ),
      bottomNavigationBar: _isLoading || _cartItems.isEmpty
          ? null
          : Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryDark,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: ElevatedButton(
                  onPressed: _proceedToCheckout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Proceed to Checkout',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppColors.primaryDark,
          ),
          SizedBox(height: 16),
          Text(
            'Loading your cart...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Browse our products and start shopping',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          SizedBox(height: 24),
          
        ],
      ),
    );
  }

  Widget _buildCartItem(CartItem item) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade700),
        color: Colors.grey.shade800,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey.shade700,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
            ),
            child: item.imageUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                    child: Image.network(
                      item.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // Print the error for debugging
                        print('Error loading image: $error');
                        return Center(
                          child: Icon(
                            Icons.image_not_supported,
                            size: 40,
                            color: Colors.grey.shade500,
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / 
                                  (loadingProgress.expectedTotalBytes ?? 1)
                                : null,
                            color: AppColors.primary,
                          ),
                        );
                      },
                    ),
                  )
                : Center(
                    child: Icon(
                      Icons.image,
                      size: 40,
                      color: Colors.grey.shade500,
                    ),
                  ),
          ),
          // Product Details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, size: 16, color: Colors.white),
                        onPressed: () => _removeItem(item),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Rs${item.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade600),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            _buildQuantityButton(
                              icon: Icons.remove,
                              onPressed: () => _updateQuantity(item, item.quantity - 1),
                            ),
                            Container(
                              width: 40,
                              alignment: Alignment.center,
                              child: Text(
                                '${item.quantity}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            _buildQuantityButton(
                              icon: Icons.add,
                              onPressed: () => _updateQuantity(item, item.quantity + 1),
                            ),
                          ],
                        ),
                      ),
                      Spacer(),
                      Text(
                        'Rs${(item.price * item.quantity).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        height: 32,
        width: 32,
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 16,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16),
          _buildSummaryRow('Subtotal', 'Rs${_cartTotals['subtotal']?.toStringAsFixed(2)}'),
          _buildSummaryRow('Shipping', 'Rs${_cartTotals['shipping']?.toStringAsFixed(2)}'),
          _buildSummaryRow('Tax (8%)', 'Rs${_cartTotals['tax']?.toStringAsFixed(2)}'),
          Divider(height: 24, color: Colors.grey.shade700),
          _buildSummaryRow(
            'Total',
            'Rs${_cartTotals['total']?.toStringAsFixed(2)}',
            isBold: true,
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.local_shipping_outlined,
                size: 16,
                color: Colors.green,
              ),
              SizedBox(width: 8),
              Text(
                'Free shipping on orders over Rs50',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isBold ? Colors.white : Colors.grey.shade400,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 18 : 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isBold ? AppColors.primary : Colors.white,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              fontSize: isBold ? 18 : 14,
            ),
          ),
        ],
      ),
    );
  }
}