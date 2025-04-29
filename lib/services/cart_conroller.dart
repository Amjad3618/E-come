import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/product_model.dart';

class CartItem {
  final Product product;
  int quantity;
  final IconData icon; // For displaying in the cart UI

  CartItem({
    required this.product,
    required this.quantity,
    required this.icon,
  });

  double get total => product.newPrice * quantity;
}

class CartController extends GetxController {
  var cartItems = <CartItem>[].obs;

  double get subtotal => cartItems.fold(0, (sum, item) => sum + item.total);
  double get shipping => cartItems.isEmpty ? 0.0 : 8.99;
  double get tax => subtotal * 0.08;
  double get total => subtotal + shipping + tax;

  void addToCart(Product product, int quantity, IconData icon) {
    // Check if product already exists in cart
    int existingIndex = cartItems.indexWhere((item) => item.product.id == product.id);
    
    if (existingIndex != -1) {
      // Update quantity if product already exists
      cartItems[existingIndex].quantity += quantity;
      update();
    } else {
      // Add new item to cart
      cartItems.add(CartItem(
        product: product,
        quantity: quantity,
        icon: icon,
      ));
    }
    
    Get.snackbar(
      'Added to Cart',
      '${product.name} has been added to your cart',
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 2),
    );
  }

  void updateQuantity(int index, int newQuantity) {
    if (newQuantity < 1) return;
    cartItems[index].quantity = newQuantity;
    update();
  }

  void removeItem(int index) {
    cartItems.removeAt(index);
    update();
  }

  void clearCart() {
    cartItems.clear();
    update();
  }
}