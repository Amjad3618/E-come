// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/color.dart';

class OrdersScreen extends StatefulWidget {
  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  String _selectedFilter = 'all'; // all, pending, confirmed, shipped, delivered, cancelled
  
  // Cache for product details to avoid repeated fetches
  Map<String, Map<String, dynamic>> _productCache = {};
  
  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;
    
    if (currentUser == null) {
      return _buildNotLoggedInView();
    }
    
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        title: Text(
          'My Orders',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.filter_list, color: Colors.white),
            onSelected: (value) {
              setState(() {
                _selectedFilter = value;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'all', child: Text('All Orders')),
              PopupMenuItem(value: 'pending', child: Text('Pending')),
              PopupMenuItem(value: 'confirmed', child: Text('Confirmed')),
              PopupMenuItem(value: 'shipped', child: Text('Shipped')),
              PopupMenuItem(value: 'delivered', child: Text('Delivered')),
              PopupMenuItem(value: 'cancelled', child: Text('Cancelled')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          _buildFilterChips(),
          
          // Orders list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getOrdersStream(currentUser.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }
                
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, size: 64, color: Colors.red),
                        SizedBox(height: 16),
                        Text(
                          'Error loading orders',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Please check your internet connection',
                          style: TextStyle(color: Colors.white70),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {}); // Retry
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                          ),
                          child: Text('Retry', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                }
                
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState();
                }
                
                final allOrders = snapshot.data!.docs;
                print('Total orders found: ${allOrders.length}'); // Debug print
                
                // Filter orders by current user if needed, or show all
                final filteredOrders = allOrders.where((doc) {
                  final orderData = doc.data() as Map<String, dynamic>;
                  // You can uncomment this line if you want to show only current user's orders
                  // return orderData['userId'] == currentUser.uid;
                  return true; // Show all orders
                }).toList();
                
                print('Filtered orders: ${filteredOrders.length}'); // Debug print
                
                if (filteredOrders.isEmpty) {
                  return _buildEmptyState();
                }
                
                return RefreshIndicator(
                  onRefresh: () async {
                    // Clear cache on refresh
                    _productCache.clear();
                    setState(() {}); // Trigger rebuild
                  },
                  color: AppColors.primary,
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) {
                      final orderDoc = filteredOrders[index];
                      final orderData = orderDoc.data() as Map<String, dynamic>;
                      
                      return _buildOrderCard(orderDoc.id, orderData);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  // Method to fetch product details from products collection
  Future<Map<String, dynamic>?> _fetchProductDetails(String productId) async {
    // Check cache first
    if (_productCache.containsKey(productId)) {
      return _productCache[productId];
    }
    
    try {
      final productDoc = await _firestore
          .collection('products')
          .doc(productId)
          .get();
      
      if (productDoc.exists) {
        final productData = productDoc.data() as Map<String, dynamic>;
        // Cache the result
        _productCache[productId] = productData;
        return productData;
      }
    } catch (e) {
      print('Error fetching product details: $e');
    }
    
    return null;
  }
  
  // Method to cancel order
  Future<void> _cancelOrder(String orderId) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': 'cancelled',
        'cancelledAt': FieldValue.serverTimestamp(),
      });
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order cancelled successfully'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error cancelling order: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to cancel order. Please try again.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
  
  // Method to show cancel confirmation dialog
  void _showCancelConfirmationDialog(String orderId, String productName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.primaryDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.orange, size: 24),
              SizedBox(width: 8),
              Text(
                'Cancel Order',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to cancel this order?',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                'Product: $productName',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              SizedBox(height: 12),
              Text(
                'This action cannot be undone.',
                style: TextStyle(
                  color: Colors.red.shade300,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: Text(
                'Keep Order',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                _cancelOrder(orderId); // Cancel the order
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('Cancel Order'),
            ),
          ],
        );
      },
    );
  }
  
  // Helper method to check if order can be cancelled
  bool _canCancelOrder(String status) {
    return status.toLowerCase() == 'pending' || status.toLowerCase() == 'confirmed';
  }
  
  Widget _buildNotLoggedInView() {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        title: Text('My Orders', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primaryDark,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.white70),
            SizedBox(height: 16),
            Text(
              'Please log in to view your orders',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Navigate to login screen
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFilterChips() {
    final filters = [
      {'key': 'all', 'label': 'All'},
      {'key': 'pending', 'label': 'Pending'},
      {'key': 'confirmed', 'label': 'Confirmed'},
      {'key': 'shipped', 'label': 'Shipped'},
      {'key': 'delivered', 'label': 'Delivered'},
      {'key': 'cancelled', 'label': 'Cancelled'},
    ];
    
    return Container(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter['key'];
          
          return Padding(
            padding: EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter['label']!),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = filter['key']!;
                });
              },
              backgroundColor: AppColors.primaryDark,
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.white70),
          SizedBox(height: 16),
          Text(
            _selectedFilter == 'all' ? 'No orders found' : 'No ${_selectedFilter} orders',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          SizedBox(height: 8),
          Text(
            'Your orders will appear here once you make a purchase',
            style: TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildOrderCard(String orderId, Map<String, dynamic> orderData) {
    final status = orderData['status'] ?? 'pending';
    final orderDate = (orderData['orderDate'] as Timestamp?)?.toDate() ?? DateTime.now();
    final productId = orderData['productId'] ?? '';
    
    // Use data from order first, then fallback to fetching from products collection
    final productName = orderData['productName'] ?? 'Unknown Product';
    final productImage = orderData['productImage'] ?? '';
    final quantity = orderData['quantity'] ?? 1;
    final totalAmount = (orderData['totalAmount'] ?? 0.0).toDouble();
    final productPrice = (orderData['productPrice'] ?? 0.0).toDouble();
    
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      color: AppColors.primaryDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showOrderDetails(orderId, orderData),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order #${orderId.substring(0, 8)}',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          _formatDate(orderDate),
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(status),
                ],
              ),
              
              SizedBox(height: 12),
              
              // Product info with enhanced data fetching
              FutureBuilder<Map<String, dynamic>?>(
                future: productId.isNotEmpty ? _fetchProductDetails(productId) : null,
                builder: (context, productSnapshot) {
                  // Use fetched product data if available, otherwise use order data
                  final enhancedProductData = productSnapshot.data;
                  final displayName = enhancedProductData?['name'] ?? productName;
                  final displayImage = enhancedProductData?['imageUrl'] ?? productImage;
                  final displayDescription = enhancedProductData?['description'] ?? '';
                  
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product image with better error handling
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey.shade800,
                          child: displayImage.isNotEmpty
                              ? Image.network(
                                  displayImage,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.image_not_supported,
                                      color: Colors.white70,
                                      size: 30,
                                    );
                                  },
                                )
                              : Icon(
                                  Icons.shopping_bag,
                                  color: Colors.white70,
                                  size: 30,
                                ),
                        ),
                      ),
                      
                      SizedBox(width: 12),
                      
                      // Product details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (displayDescription.isNotEmpty) ...[
                              SizedBox(height: 2),
                              Text(
                                displayDescription,
                                style: TextStyle(color: Colors.white60, fontSize: 11),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            SizedBox(height: 4),
                            Text(
                              'Quantity: $quantity',
                              style: TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Rs${totalAmount.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
              
              SizedBox(height: 12),
              
              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Cancel Order button (only show for pending/confirmed orders)
                  if (_canCancelOrder(status)) ...[
                    TextButton.icon(
                      onPressed: () => _showCancelConfirmationDialog(orderId, productName),
                      icon: Icon(Icons.cancel, size: 16, color: Colors.red),
                      label: Text('Cancel', style: TextStyle(color: Colors.red)),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      ),
                    ),
                    SizedBox(width: 8),
                  ],
                  
                  // View Details button
                  TextButton.icon(
                    onPressed: () => _showOrderDetails(orderId, orderData),
                    icon: Icon(Icons.visibility, size: 16, color: AppColors.primary),
                    label: Text('View Details', style: TextStyle(color: AppColors.primary)),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor = Colors.white;
    
    switch (status.toLowerCase()) {
      case 'pending':
        backgroundColor = Colors.orange;
        break;
      case 'confirmed':
        backgroundColor = Colors.blue;
        break;
      case 'shipped':
        backgroundColor = Colors.purple;
        break;
      case 'delivered':
        backgroundColor = Colors.green;
        break;
      case 'cancelled':
        backgroundColor = Colors.red;
        break;
      default:
        backgroundColor = Colors.grey;
    }
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  Stream<QuerySnapshot> _getOrdersStream(String userId) {
    // Get ALL orders from orders collection (not filtering by userId)
    Query query = _firestore.collection('orders');
    
    if (_selectedFilter != 'all') {
      query = query.where('status', isEqualTo: _selectedFilter);
    }
    
    return query.snapshots();
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
  
  void _showOrderDetails(String orderId, Map<String, dynamic> orderData) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildOrderDetailsSheet(orderId, orderData),
    );
  }
  
  Widget _buildOrderDetailsSheet(String orderId, Map<String, dynamic> orderData) {
    final orderDate = (orderData['orderDate'] as Timestamp?)?.toDate() ?? DateTime.now();
    final productImage = orderData['productImage'] ?? '';
    final productId = orderData['productId'] ?? '';
    final status = orderData['status'] ?? 'pending';
    final productName = orderData['productName'] ?? 'Unknown Product';
    
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.scaffold,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            
            // Title
            Center(
              child: Text(
                'Order Details',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            SizedBox(height: 20),
            
            // Enhanced product details with additional data
            FutureBuilder<Map<String, dynamic>?>(
              future: productId.isNotEmpty ? _fetchProductDetails(productId) : null,
              builder: (context, productSnapshot) {
                final enhancedProductData = productSnapshot.data;
                final displayImage = enhancedProductData?['imageUrl'] ?? productImage;
                
                return Column(
                  children: [
                    // Product Image (larger in details)
                    if (displayImage.isNotEmpty)
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 120,
                            height: 120,
                            color: Colors.grey.shade800,
                            child: Image.network(
                              displayImage,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(color: AppColors.primary),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.image_not_supported,
                                  color: Colors.white70,
                                  size: 50,
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    
                    SizedBox(height: 20),
                    
                    // Order info
                    _buildDetailSection('Order Information', [
                      _buildDetailRow('Order ID', '#${orderId.substring(0, 12)}'),
                      _buildDetailRow('Date', _formatDate(orderDate)),
                      _buildDetailRow('Status', _getStatusText(orderData['status'] ?? 'pending')),
                    ]),
                    
                    // Enhanced Product info
                    _buildDetailSection('Product Details', [
                      _buildDetailRow('Product', enhancedProductData?['name'] ?? orderData['productName'] ?? 'Unknown'),
                      if (enhancedProductData?['description'] != null)
                        _buildDetailRow('Description', enhancedProductData!['description']),
                      if (enhancedProductData?['category'] != null)
                        _buildDetailRow('Category', enhancedProductData!['category']),
                      _buildDetailRow('Quantity', '${orderData['quantity'] ?? 1}'),
                      _buildDetailRow('Price', 'Rs${(orderData['productPrice'] ?? 0.0).toStringAsFixed(2)}'),
                      _buildDetailRow('Total Amount', 'Rs${(orderData['totalAmount'] ?? 0.0).toStringAsFixed(2)}'),
                    ]),
                  ],
                );
              },
            ),
            
            // Shipping info
            _buildDetailSection('Shipping Information', [
              _buildDetailRow('Name', orderData['name'] ?? 'N/A'),
              _buildDetailRow('Address', orderData['address'] ?? 'N/A'),
              _buildDetailRow('City', orderData['city'] ?? 'N/A'),
              _buildDetailRow('Postal Code', orderData['postalCode'] ?? 'N/A'),
              _buildDetailRow('Email', orderData['email'] ?? 'N/A'),
              _buildDetailRow('Phone', orderData['phoneNumber'] ?? 'N/A'),
            ]),
            
            // Order notes if available
            if (orderData['notes'] != null && orderData['notes'].toString().isNotEmpty)
              _buildDetailSection('Order Notes', [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade700),
                  ),
                  child: Text(
                    orderData['notes'],
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ),
              ]),
            
            SizedBox(height: 20),
            
            // Action buttons
            Row(
              children: [
                // Cancel Order button (only show for pending/confirmed orders)
                if (_canCancelOrder(status))
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context); // Close details sheet first
                        _showCancelConfirmationDialog(orderId, productName);
                      },
                      icon: Icon(Icons.cancel, size: 18),
                      label: Text('Cancel Order'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                
                // Add spacing if both buttons are present
                if (_canCancelOrder(status)) SizedBox(width: 12),
                
                // Close button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text('Close', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        ...children,
        SizedBox(height: 20),
      ],
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
  
  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending - Waiting for confirmation';
      case 'confirmed':
        return 'Confirmed - Order accepted';
      case 'shipped':
        return 'Shipped - On the way';
      case 'delivered':
        return 'Delivered - Order completed';
      case 'cancelled':
        return 'Cancelled - Order cancelled';
      default:
        return status;
    }
  }
}