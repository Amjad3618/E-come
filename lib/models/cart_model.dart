// lib/models/cart_model.dart - Updated Version
import 'package:cloud_firestore/cloud_firestore.dart';

class CartItem {
  final String id;
  final String productId;
  final String name;
  final double price;
  int quantity;
  final String imageUrl;
  final String userId;  // To associate cart with specific user

  CartItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.imageUrl,
    required this.userId,
  });

  // For updating quantity
  void updateQuantity(int newQuantity) {
    if (newQuantity > 0) {
      quantity = newQuantity;
    }
  }

  // Convert to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'price': price,
      'quantity': quantity,
      'imageUrl': imageUrl,
      'userId': userId,
      'addedAt': FieldValue.serverTimestamp(),
    };
  }

  // Create from Firestore document
  factory CartItem.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CartItem(
      id: doc.id,
      productId: data['productId'] ?? '',
      name: data['name'] ?? '',
      price: (data['price'] is int) ? (data['price'] as int).toDouble() : data['price'] ?? 0.0,
      quantity: data['quantity'] ?? 1,
      imageUrl: data['imageUrl'] ?? '',
      userId: data['userId'] ?? '',
    );
  }
}

class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId;  // Current user's ID

  CartService({required this.userId});

  // FIXED: Collection reference to match your Firestore structure
  CollectionReference get cartCollection => 
      _firestore.collection('carts').doc(userId).collection('items');

  // Add item to cart
  Future<void> addToCart(CartItem item) async {
    // Check if item already exists
    final existingItemQuery = await cartCollection
        .where('productId', isEqualTo: item.productId)
        .get();

    if (existingItemQuery.docs.isNotEmpty) {
      // Update quantity of existing item
      final existingDoc = existingItemQuery.docs.first;
      final existingItem = CartItem.fromDocument(existingDoc);
      await cartCollection.doc(existingDoc.id).update({
        'quantity': existingItem.quantity + item.quantity,
      });
    } else {
      // Add new item
      await cartCollection.add(item.toMap());
    }
  }

  // Update item quantity
  Future<void> updateQuantity(String itemId, int newQuantity) async {
    if (newQuantity < 1) return;
    
    await cartCollection.doc(itemId).update({
      'quantity': newQuantity,
    });
  }

  // Remove item from cart
  Future<void> removeItem(String itemId) async {
    await cartCollection.doc(itemId).delete();
  }

  // Clear entire cart
  Future<void> clearCart() async {
    final batch = _firestore.batch();
    final snapshots = await cartCollection.get();
    
    for (var doc in snapshots.docs) {
      batch.delete(doc.reference);
    }
    
    await batch.commit();
  }

  // Get cart stream
  Stream<List<CartItem>> getCartStream() {
    return cartCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => CartItem.fromDocument(doc)).toList();
    });
  }

  // Get cart items once
  Future<List<CartItem>> getCartItems() async {
    final snapshot = await cartCollection.get();
    return snapshot.docs.map((doc) => CartItem.fromDocument(doc)).toList();
  }

  // Calculate cart totals
  Future<Map<String, double>> calculateCartTotals() async {
    final items = await getCartItems();
    
    double subtotal = 0;
    for (var item in items) {
      subtotal += item.price * item.quantity;
    }
    
    const double shippingRate = 8.99;
    const double taxRate = 0.08;
    
    final shipping = (subtotal > 50) ? 0.0 : shippingRate; // Free shipping over $50
    final tax = subtotal * taxRate;
    final total = subtotal + shipping + tax;
    
    return {
      'subtotal': subtotal,
      'shipping': shipping,
      'tax': tax,
      'total': total,
    };
  }
}