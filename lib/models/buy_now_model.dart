import 'package:cloud_firestore/cloud_firestore.dart';

// Enum for predefined order statuses
enum OrderStatus {
  pending,
  processing,
  shipped,
  onTheWay,
  delivered,
  cancelled
}

// Extension to get string values for the enum
extension OrderStatusExtension on OrderStatus {
  String get value {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.onTheWay:
        return 'On the Way';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  // Convert string to enum
  static OrderStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return OrderStatus.pending;
      case 'processing':
        return OrderStatus.processing;
      case 'shipped':
        return OrderStatus.shipped;
      case 'on the way':
        return OrderStatus.onTheWay;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }
}

class OrderModel {
  final String id;
  final String userId;
  final String productId;
  final String productName;
  final String productImage;
  final double productPrice;
  final int quantity;
  final double totalAmount;
  
  // Customer details
  final String name;
  final String address;
  final String city;
  final String postalCode;
  final String email;
  final String phoneNumber;
  
  // Order tracking
  String status;
  final DateTime orderDate;
  DateTime? shippedDate;
  DateTime? deliveredDate;
  
  // Optional notes
  final String? notes;

  OrderModel({
    required this.id,
    required this.userId,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.productPrice,
    required this.quantity,
    required this.totalAmount,
    required this.name,
    required this.address,
    required this.city,
    required this.postalCode,
    required this.email,
    required this.phoneNumber,
    this.status = 'Pending',
    required this.orderDate,
    this.shippedDate,
    this.deliveredDate,
    this.notes,
  });

  // Factory constructor to create an OrderModel from JSON
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      productId: json['productId'] ?? '',
      productName: json['productName'] ?? '',
      productImage: json['productImage'] ?? '',
      productPrice: (json['productPrice'] ?? 0.0).toDouble(),
      quantity: json['quantity'] ?? 0,
      totalAmount: (json['totalAmount'] ?? 0.0).toDouble(),
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      postalCode: json['postalCode'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      status: json['status'] ?? 'Pending',
      orderDate: (json['orderDate'] as Timestamp).toDate(),
      shippedDate: json['shippedDate'] != null 
          ? (json['shippedDate'] as Timestamp).toDate() 
          : null,
      deliveredDate: json['deliveredDate'] != null 
          ? (json['deliveredDate'] as Timestamp).toDate() 
          : null,
      notes: json['notes'],
    );
  }

  // Method to convert OrderModel to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'productPrice': productPrice,
      'quantity': quantity,
      'totalAmount': totalAmount,
      'name': name,
      'address': address,
      'city': city,
      'postalCode': postalCode,
      'email': email,
      'phoneNumber': phoneNumber,
      'status': status,
      'orderDate': Timestamp.fromDate(orderDate),
      'shippedDate': shippedDate != null ? Timestamp.fromDate(shippedDate!) : null,
      'deliveredDate': deliveredDate != null ? Timestamp.fromDate(deliveredDate!) : null,
      'notes': notes,
    };
  }

  // Create a copy of the order with updated fields
  OrderModel copyWith({
    String? id,
    String? userId,
    String? productId,
    String? productName,
    String? productImage,
    double? productPrice,
    int? quantity,
    double? totalAmount,
    String? name,
    String? address,
    String? city,
    String? postalCode,
    String? email,
    String? phoneNumber,
    String? status,
    DateTime? orderDate,
    DateTime? shippedDate,
    DateTime? deliveredDate,
    String? notes,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productImage: productImage ?? this.productImage,
      productPrice: productPrice ?? this.productPrice,
      quantity: quantity ?? this.quantity,
      totalAmount: totalAmount ?? this.totalAmount,
      name: name ?? this.name,
      address: address ?? this.address,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      status: status ?? this.status,
      orderDate: orderDate ?? this.orderDate,
      shippedDate: shippedDate ?? this.shippedDate,
      deliveredDate: deliveredDate ?? this.deliveredDate,
      notes: notes ?? this.notes,
    );
  }

  // Update the status of the order
  void updateStatus(String newStatus) {
    status = newStatus;
    
    // Set dates for specific statuses
    final now = DateTime.now();
    if (newStatus == OrderStatus.shipped.value && shippedDate == null) {
      shippedDate = now;
    } else if (newStatus == OrderStatus.delivered.value && deliveredDate == null) {
      deliveredDate = now;
    }
  }

  static fromMap(Map<String, dynamic> map) {}
}

// Service class to handle order operations with Firestore
class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String ordersCollection = 'orders';

  // Create a new order
  Future<String> createOrder(OrderModel order) async {
    final docRef = _firestore.collection(ordersCollection).doc();
    final orderWithId = order.copyWith(id: docRef.id);
    
    await docRef.set(orderWithId.toJson());
    return docRef.id;
  }

  // Get order by ID
  Future<OrderModel?> getOrderById(String orderId) async {
    final doc = await _firestore.collection(ordersCollection).doc(orderId).get();
    if (doc.exists) {
      return OrderModel.fromJson(doc.data()!);
    }
    return null;
  }

  // Get all orders for a user
 Stream<List<OrderModel>> getUserOrders(String userId) {
  try {
    // Simplified query that doesn't require the composite index
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('orderDate', descending: true)  // Only order by one field
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => OrderModel.fromJson(doc.data()))
              .toList();
        });
  } catch (e) {
    print('Error getting user orders: $e');
    return Stream.value([]);
  }
}

  // Get all orders (for admin)
  Stream<List<OrderModel>> getAllOrders() {
    return _firestore
        .collection(ordersCollection)
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => OrderModel.fromJson(doc.data()))
          .toList();
    });
  }

  // Update order status
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    // First get the current order
    final orderDoc = await _firestore.collection(ordersCollection).doc(orderId).get();
    if (!orderDoc.exists) {
      throw Exception('Order not found');
    }
    
    final order = OrderModel.fromJson(orderDoc.data()!);
    
    // Update status and any related fields
    // ignore: unused_local_variable
    final updatedOrder = order.copyWith(status: newStatus);
    
    // Update dates based on status
    final now = DateTime.now();
    Map<String, dynamic> updates = {
      'status': newStatus,
    };
    
    if (newStatus == OrderStatus.shipped.value && order.shippedDate == null) {
      updates['shippedDate'] = Timestamp.fromDate(now);
    } else if (newStatus == OrderStatus.delivered.value && order.deliveredDate == null) {
      updates['deliveredDate'] = Timestamp.fromDate(now);
    }
    
    // Update in Firestore
    await _firestore.collection(ordersCollection).doc(orderId).update(updates);
  }
}