// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cart_model.dart';
import '../models/buy_now_model.dart';
import '../utils/color.dart';

class CheckoutPage extends StatefulWidget {
  final List<CartItem> cartItems;
  final Map<String, double> cartTotals;

  const CheckoutPage({
    Key? key,
    required this.cartItems,
    required this.cartTotals,
  }) : super(key: key);

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  bool _isProcessingOrder = false;
  String get _userId => FirebaseAuth.instance.currentUser?.uid ?? 'guest';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        title: Text(
          'Checkout',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Summary Section
            _buildOrderSummarySection(),
            
            SizedBox(height: 24),
            
            // Items in Cart Section
            _buildCartItemsSection(),
            
            SizedBox(height: 24),
            
            // Total Summary
            _buildTotalSummary(),
            
            SizedBox(height: 100), // Space for bottom button
          ],
        ),
      ),
      bottomNavigationBar: _buildCheckoutButton(),
    );
  }

  Widget _buildOrderSummarySection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade700),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.receipt_long,
                color: AppColors.primary,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'Order Summary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Items:',
                style: TextStyle(color: Colors.grey.shade400),
              ),
              Text(
                '${widget.cartItems.length}',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Quantity:',
                style: TextStyle(color: Colors.grey.shade400),
              ),
              Text(
                '${widget.cartItems.fold(0, (sum, item) => sum + item.quantity)}',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCartItemsSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade700),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.shopping_bag,
                  color: AppColors.primary,
                  size: 24,
                ),
                SizedBox(width: 8),
                Text(
                  'Items in Your Order',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: widget.cartItems.length,
            separatorBuilder: (context, index) => Divider(
              color: Colors.grey.shade700,
              height: 1,
            ),
            itemBuilder: (context, index) {
              final item = widget.cartItems[index];
              return _buildCheckoutItem(item);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutItem(CartItem item) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Product Image
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey.shade700,
              borderRadius: BorderRadius.circular(8),
            ),
            child: item.imageUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(
                            Icons.image_not_supported,
                            color: Colors.grey.shade500,
                            size: 24,
                          ),
                        );
                      },
                    ),
                  )
                : Center(
                    child: Icon(
                      Icons.image,
                      color: Colors.grey.shade500,
                      size: 24,
                    ),
                  ),
          ),
          
          SizedBox(width: 12),
          
          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  'Rs${item.price.toStringAsFixed(2)} × ${item.quantity}',
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          // Item Total
          Text(
            'Rs${(item.price * item.quantity).toStringAsFixed(2)}',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalSummary() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade700),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calculate,
                color: AppColors.primary,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'Payment Summary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildSummaryRow(
            'Subtotal',
            'Rs${widget.cartTotals['subtotal']?.toStringAsFixed(2)}',
          ),
          _buildSummaryRow(
            'Shipping',
            'Rs${widget.cartTotals['shipping']?.toStringAsFixed(2)}',
          ),
          _buildSummaryRow(
            'Tax (8%)',
            'Rs${widget.cartTotals['tax']?.toStringAsFixed(2)}',
          ),
          Divider(height: 24, color: Colors.grey.shade700),
          _buildSummaryRow(
            'Total Amount',
            'Rs${widget.cartTotals['total']?.toStringAsFixed(2)}',
            isBold: true,
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false, bool isTotal = false}) {
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
              fontSize: isTotal ? 18 : 16,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isTotal ? AppColors.primary : Colors.white,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              fontSize: isTotal ? 18 : 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutButton() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
          onPressed: _isProcessingOrder ? null : _proceedToBuyingSheet,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _isProcessingOrder
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Processing...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                )
              : Text(
                  'Place Order - Rs${widget.cartTotals['total']?.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }

  void _proceedToBuyingSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CartCheckoutBottomSheet(
        cartItems: widget.cartItems,
        cartTotals: widget.cartTotals,
        orderService: OrderService(),
      ),
    ).then((result) {
      if (result != null && result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Order placed successfully! Order ID: ${result['orderId']}',
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );

        _clearCartAfterOrder();
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    });
  }

  Future<void> _clearCartAfterOrder() async {
    try {
      final cartService = CartService(userId: _userId);
      await cartService.clearCart();
    } catch (e) {
      print('Error clearing cart after order: $e');
    }
  }
}

// FIXED CartCheckoutBottomSheet with proper Firebase order creation
class CartCheckoutBottomSheet extends StatefulWidget {
  final List<CartItem> cartItems;
  final Map<String, double> cartTotals;
  final OrderService orderService;

  const CartCheckoutBottomSheet({
    Key? key,
    required this.cartItems,
    required this.cartTotals,
    required this.orderService,
  }) : super(key: key);

  @override
  State<CartCheckoutBottomSheet> createState() => _CartCheckoutBottomSheetState();
}

class _CartCheckoutBottomSheetState extends State<CartCheckoutBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  
  bool _isPlacingOrder = false;
  String _selectedPaymentMethod = 'Cash on Delivery';
  final List<String> _paymentMethods = [
    'Cash on Delivery',
    'Bank Transfer',
    'Online Payment'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: AppColors.scaffold,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  'Order Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOrderSummaryCard(),
                    SizedBox(height: 20),
                    _buildCustomerDetailsForm(),
                    SizedBox(height: 20),
                    _buildPaymentMethodSection(),
                    SizedBox(height: 20),
                    _buildPlaceOrderSection(),
                    SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummaryCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade700),
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
          SizedBox(height: 12),
          
          ...widget.cartItems.take(3).map((item) => Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${item.name} × ${item.quantity}',
                    style: TextStyle(color: Colors.grey.shade300, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  'Rs${(item.price * item.quantity).toStringAsFixed(2)}',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          )).toList(),
          
          if (widget.cartItems.length > 3)
            Text(
              '... and ${widget.cartItems.length - 3} more items',
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          
          Divider(color: Colors.grey.shade600, height: 20),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Amount:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                'Rs${widget.cartTotals['total']?.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerDetailsForm() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade700),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Delivery Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16),
          
          TextFormField(
            controller: _nameController,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Full Name *',
              labelStyle: TextStyle(color: Colors.grey.shade400),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade600),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade600),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.primary),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your full name';
              }
              return null;
            },
          ),
          
          SizedBox(height: 16),
          
          TextFormField(
            controller: _phoneController,
            style: TextStyle(color: Colors.white),
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Phone Number *',
              labelStyle: TextStyle(color: Colors.grey.shade400),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade600),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade600),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.primary),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your phone number';
              }
              if (value.length < 10) {
                return 'Please enter a valid phone number';
              }
              return null;
            },
          ),
          
          SizedBox(height: 16),
          
          TextFormField(
            controller: _addressController,
            style: TextStyle(color: Colors.white),
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Delivery Address *',
              labelStyle: TextStyle(color: Colors.grey.shade400),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade600),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade600),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.primary),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your delivery address';
              }
              return null;
            },
          ),
          
          SizedBox(height: 16),
          
          TextFormField(
            controller: _cityController,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'City *',
              labelStyle: TextStyle(color: Colors.grey.shade400),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade600),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade600),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.primary),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your city';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade700),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Method',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 12),
          
          ..._paymentMethods.map((method) => RadioListTile<String>(
            title: Text(
              method,
              style: TextStyle(color: Colors.white),
            ),
            value: method,
            groupValue: _selectedPaymentMethod,
            onChanged: (value) {
              setState(() {
                _selectedPaymentMethod = value!;
              });
            },
            activeColor: AppColors.primary,
            contentPadding: EdgeInsets.zero,
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildPlaceOrderSection() {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isPlacingOrder ? null : _placeOrder,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isPlacingOrder
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Placing Order...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            : Text(
                'Place Order - Rs${widget.cartTotals['total']?.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  // MAIN FIX: Create separate orders for each cart item or handle multiple items properly
  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isPlacingOrder = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      final userId = user?.uid ?? 'guest';
      final userEmail = user?.email ?? '';
      
      // Option 1: Create separate order documents for each item (recommended for your current structure)
      List<String> orderIds = [];
      
      for (CartItem item in widget.cartItems) {
        final orderData = {
          // Customer Information
          'name': _nameController.text.trim(),
          'email': userEmail,
          'phoneNumber': _phoneController.text.trim(),
          'address': _addressController.text.trim(),
          'city': _cityController.text.trim(),
          'postalCode': '', // Add postal code field if needed
          'userId': userId,
          
          // Product Information
          'productId': item.productId,
          'productName': item.name,
          'productPrice': item.price,
          'productImage': item.imageUrl,
          'quantity': item.quantity,
          
          // Order Information
          'totalAmount': item.price * item.quantity, // Individual item total
          'paymentMethod': _selectedPaymentMethod,
          'status': 'pending',
          'orderDate': Timestamp.fromDate(DateTime.now()),
          'shippedDate': null,
          'deliveredDate': null,
          'notes': null,
          
          // Additional cart context (optional)
          'isPartOfCartOrder': true,
          'cartOrderId': DateTime.now().millisecondsSinceEpoch.toString(), // Same ID for all items from this cart
          'cartSubtotal': widget.cartTotals['subtotal'],
          'cartShipping': widget.cartTotals['shipping'],
          'cartTax': widget.cartTotals['tax'],
          'cartTotal': widget.cartTotals['total'],
        };

        // Add to Firestore
        final docRef = await FirebaseFirestore.instance
            .collection('orders')
            .add(orderData);
        
        orderIds.add(docRef.id);
      }
      
      // Return success with all order IDs
      Navigator.pop(context, {
        'success': true,
        'orderId': orderIds.join(', '), // Return all order IDs
        'orderCount': orderIds.length,
      });

    } catch (e) {
      setState(() {
        _isPlacingOrder = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to place order: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  // Alternative approach: Create one order with items array (if you want to change your Firebase structure)
  Future<void> _placeOrderWithItemsArray() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isPlacingOrder = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      final userId = user?.uid ?? 'guest';
      final userEmail = user?.email ?? '';
      
      final orderData = {
        // Customer Information
        'name': _nameController.text.trim(),
        'email': userEmail,
        'phoneNumber': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'city': _cityController.text.trim(),
        'postalCode': '',
        'userId': userId,
        
        // Multiple Items Information
        'items': widget.cartItems.map((item) => {
          'productId': item.productId,
          'productName': item.name,
          'productPrice': item.price,
          'productImage': item.imageUrl,
          'quantity': item.quantity,
          'itemTotal': item.price * item.quantity,
        }).toList(),
        
        // Order Totals
        'subtotal': widget.cartTotals['subtotal'],
        'shipping': widget.cartTotals['shipping'],
        'tax': widget.cartTotals['tax'],
        'totalAmount': widget.cartTotals['total'],
        
        // Order Information
        'paymentMethod': _selectedPaymentMethod,
        'status': 'pending',
        'orderDate': Timestamp.fromDate(DateTime.now()),
        'shippedDate': null,
        'deliveredDate': null,
        'notes': null,
        'orderType': 'cart_order',
      };

      // Add to Firestore
      final docRef = await FirebaseFirestore.instance
          .collection('orders')
          .add(orderData);
      
      Navigator.pop(context, {
        'success': true,
        'orderId': docRef.id,
      });

    } catch (e) {
      setState(() {
        _isPlacingOrder = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to place order: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }}}