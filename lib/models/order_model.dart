enum OrderStatus {
  pending,
  processing,
  shipped,
  delivered,
  cancelled,
  refunded
}

class OrderItem {
  final String id;
  final String productId;
  final String productName;
  final double price;
  final int quantity;
  final double total;
  final String? variant;
  final List<String>? options;
  
  OrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.total,
    this.variant,
    this.options,
  });
  
  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      id: map['id'] ?? '',
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      quantity: map['quantity'] ?? 0,
      total: (map['total'] ?? 0.0).toDouble(),
      variant: map['variant'],
      options: map['options'] != null ? List<String>.from(map['options']) : null,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'price': price,
      'quantity': quantity,
      'total': total,
      'variant': variant,
      'options': options,
    };
  }
}

class Order {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final OrderStatus status;
  final double subtotal;
  final double tax;
  final double shippingCost;
  final double total;
  final String shippingAddress;
  final String paymentMethod;
  final String trackingNumber;
  final DateTime orderDate;
  final DateTime? deliveryDate;
  final bool isPaid;
  final String? couponCode;
  final double discountAmount;

  Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.status,
    required this.subtotal,
    required this.tax,
    required this.shippingCost,
    required this.total,
    required this.shippingAddress,
    required this.paymentMethod,
    this.trackingNumber = '',
    required this.orderDate,
    this.deliveryDate,
    this.isPaid = false,
    this.couponCode,
    this.discountAmount = 0.0,
  });

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      items: List<OrderItem>.from(
        (map['items'] ?? []).map((x) => OrderItem.fromMap(x)),
      ),
      status: OrderStatus.values.firstWhere(
        (e) => e.toString() == 'OrderStatus.${map['status'] ?? 'pending'}',
        orElse: () => OrderStatus.pending,
      ),
      subtotal: (map['subtotal'] ?? 0.0).toDouble(),
      tax: (map['tax'] ?? 0.0).toDouble(),
      shippingCost: (map['shippingCost'] ?? 0.0).toDouble(),
      total: (map['total'] ?? 0.0).toDouble(),
      shippingAddress: map['shippingAddress'] ?? '',
      paymentMethod: map['paymentMethod'] ?? '',
      trackingNumber: map['trackingNumber'] ?? '',
      orderDate: map['orderDate'] != null 
          ? DateTime.parse(map['orderDate']) 
          : DateTime.now(),
      deliveryDate: map['deliveryDate'] != null 
          ? DateTime.parse(map['deliveryDate']) 
          : null,
      isPaid: map['isPaid'] ?? false,
      couponCode: map['couponCode'],
      discountAmount: (map['discountAmount'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'items': items.map((x) => x.toMap()).toList(),
      'status': status.toString().split('.').last,
      'subtotal': subtotal,
      'tax': tax,
      'shippingCost': shippingCost,
      'total': total,
      'shippingAddress': shippingAddress,
      'paymentMethod': paymentMethod,
      'trackingNumber': trackingNumber,
      'orderDate': orderDate.toIso8601String(),
      'deliveryDate': deliveryDate?.toIso8601String(),
      'isPaid': isPaid,
      'couponCode': couponCode,
      'discountAmount': discountAmount,
    };
  }
  
  // Calculate order total
  double calculateTotal() {
    return subtotal + tax + shippingCost - discountAmount;
  }
  
  // Check if order can be cancelled
  bool canBeCancelled() {
    return status == OrderStatus.pending || status == OrderStatus.processing;
  }
  
  // Create a copy of an order with some updated fields
  Order copyWith({
    String? id,
    String? userId,
    List<OrderItem>? items,
    OrderStatus? status,
    double? subtotal,
    double? tax,
    double? shippingCost,
    double? total,
    String? shippingAddress,
    String? paymentMethod,
    String? trackingNumber,
    DateTime? orderDate,
    DateTime? deliveryDate,
    bool? isPaid,
    String? couponCode,
    double? discountAmount,
  }) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      status: status ?? this.status,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      shippingCost: shippingCost ?? this.shippingCost,
      total: total ?? this.total,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      orderDate: orderDate ?? this.orderDate,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      isPaid: isPaid ?? this.isPaid,
      couponCode: couponCode ?? this.couponCode,
      discountAmount: discountAmount ?? this.discountAmount,
    );
  }}