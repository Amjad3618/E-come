// services/order_service.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Observable variables
  final RxString selectedFilter = 'all'.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxMap<String, Map<String, dynamic>> productCache = <String, Map<String, dynamic>>{}.obs;
  
  // Filter options
  final List<Map<String, String>> filterOptions = [
    {'key': 'all', 'label': 'All'},
    {'key': 'pending', 'label': 'Pending'},
    {'key': 'confirmed', 'label': 'Confirmed'},
    {'key': 'shipped', 'label': 'Shipped'},
    {'key': 'delivered', 'label': 'Delivered'},
    {'key': 'cancelled', 'label': 'Cancelled'},
  ];
  
  // Get current user
  User? get currentUser => _auth.currentUser;
  
  // Change filter
  void changeFilter(String filter) {
    selectedFilter.value = filter;
  }
  
  // Get orders stream
  Stream<QuerySnapshot> getOrdersStream() {
    Query query = _firestore.collection('orders');
    
    if (selectedFilter.value != 'all') {
      query = query.where('status', isEqualTo: selectedFilter.value);
    }
    
    return query.snapshots();
  }
  
  // Fetch product details with caching
  Future<Map<String, dynamic>?> fetchProductDetails(String productId) async {
    try {
      // Check cache first
      if (productCache.containsKey(productId)) {
        return productCache[productId];
      }
      
      final productDoc = await _firestore
          .collection('products')
          .doc(productId)
          .get();
      
      if (productDoc.exists) {
        final productData = productDoc.data() as Map<String, dynamic>;
        // Cache the result
        productCache[productId] = productData;
        return productData;
      }
    } catch (e) {
      print('Error fetching product details: $e');
      errorMessage.value = 'Error fetching product details: $e';
    }
    
    return null;
  }
  
  // Cancel order
  Future<bool> cancelOrder(String orderId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      await _firestore.collection('orders').doc(orderId).update({
        'status': 'cancelled',
        'cancelledAt': FieldValue.serverTimestamp(),
      });
      
      isLoading.value = false;
      return true;
    } catch (e) {
      print('Error cancelling order: $e');
      errorMessage.value = 'Failed to cancel order. Please try again.';
      isLoading.value = false;
      return false;
    }
  }
  
  // Check if order can be cancelled
  bool canCancelOrder(String status) {
    return status.toLowerCase() == 'pending' || status.toLowerCase() == 'confirmed';
  }
  
  // Clear product cache
  void clearProductCache() {
    productCache.clear();
  }
  
  // Format date
  String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
  
  // Get status text with description
  String getStatusText(String status) {
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
  
  // Clear error message
  void clearError() {
    errorMessage.value = '';
  }
}



class OrderController extends GetxController {
  final OrderService _orderService = Get.find<OrderService>();
  
  // Getters to access service properties
  String get selectedFilter => _orderService.selectedFilter.value;
  bool get isLoading => _orderService.isLoading.value;
  String get errorMessage => _orderService.errorMessage.value;
  List<Map<String, String>> get filterOptions => _orderService.filterOptions;
  
  // Check if user is logged in
  bool get isLoggedIn => _orderService.currentUser != null;
  
  @override
  void onInit() {
    super.onInit();
    // Initialize any additional setup if needed
  }
  
  // Change filter
  void changeFilter(String filter) {
    _orderService.changeFilter(filter);
  }
  
  // Get orders stream
// ...existing code...
Stream<QuerySnapshot<Object?>> getOrdersStream() {
  return FirebaseFirestore.instance
      .collection('orders')
      .snapshots()
      .cast<QuerySnapshot<Object?>>();
}
// ...existing code...
  // Fetch product details
  Future<Map<String, dynamic>?> fetchProductDetails(String productId) {
    return _orderService.fetchProductDetails(productId);
  }
  
  // Cancel order with UI feedback
  Future<void> cancelOrder(String orderId) async {
    final success = await _orderService.cancelOrder(orderId);
    
    if (success) {
      Get.snackbar(
        'Success',
        'Order cancelled successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.primaryColor,
        colorText: Get.theme.colorScheme.onPrimary,
        duration: const Duration(seconds: 2),
      );
    } else {
      Get.snackbar(
        'Error',
        _orderService.errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        duration: const Duration(seconds: 3),
      );
    }
  }
  
  // Check if order can be cancelled
  bool canCancelOrder(String status) {
    return _orderService.canCancelOrder(status);
  }
  
  // Refresh orders (clear cache)
  void refreshOrders() {
    _orderService.clearProductCache();
  }
  
  // Format date
  String formatDate(DateTime date) {
    return _orderService.formatDate(date);
  }
  
  // Get status text
  String getStatusText(String status) {
    return _orderService.getStatusText(status);
  }
  
  // Show cancel confirmation dialog
  void showCancelConfirmationDialog(String orderId, String productName) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Get.theme.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.warning, color: Get.theme.colorScheme.secondary, size: 24),
            const SizedBox(width: 8),
            Text(
              'Cancel Order',
              style: TextStyle(color: Get.theme.colorScheme.onSurface, fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to cancel this order?',
              style: TextStyle(color: Get.theme.colorScheme.onSurface, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Product: $productName',
              style: TextStyle(color: Get.theme.colorScheme.onSurface.withOpacity(0.7), fontSize: 14),
            ),
            const SizedBox(height: 12),
            Text(
              'This action cannot be undone.',
              style: TextStyle(
                color: Get.theme.colorScheme.error.withOpacity(0.8),
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Keep Order',
              style: TextStyle(color: Get.theme.colorScheme.onSurface.withOpacity(0.7)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back(); // Close dialog
              cancelOrder(orderId); // Cancel the order
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Get.theme.colorScheme.error,
              foregroundColor: Get.theme.colorScheme.onError,
            ),
            child: const Text('Cancel Order'),
          ),
        ],
      ),
    );
  }
  
  // Clear error message
  void clearError() {
    _orderService.clearError();
  }
}