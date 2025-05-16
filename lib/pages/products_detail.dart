import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../models/buy_now_model.dart';
import '../models/product_model.dart';
import '../models/cart_model.dart';
import '../utils/color.dart';
import '../widgets/buyer_widget.dart';
import 'cart_page.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({Key? key, required this.product})
    : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _currentImageIndex = 0;
  int _quantity = 1;
  bool _isAddingToCart = false;

  // Get current user ID
  String get _userId => FirebaseAuth.instance.currentUser?.uid ?? 'guest';

  // Initialize cart service
  late final CartService _cartService = CartService(userId: _userId);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        title: Text(
          'Product Detail',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart, color: Colors.white),
            onPressed: () {
              // Navigate to cart page
              Navigator.pushNamed(context, '/cart');
            },
          ),
          IconButton(
            icon: Icon(Icons.share, color: Colors.white),
            onPressed: () {
              // Share product functionality
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image Carousel
            _buildImageCarousel(),

            // Product Details
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    widget.product.name,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  SizedBox(height: 8),

                  // Product Category
                  Text(
                    'Category: ${widget.product.category}',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),

                  SizedBox(height: 12),

                  // Product Price
                  Row(
                    children: [
                      Text(
                        'Rs${widget.product.newPrice}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 12),
                      if (widget.product.oldPrice > widget.product.newPrice)
                        Text(
                          'Rs${widget.product.oldPrice}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      SizedBox(width: 12),
                      if (widget.product.oldPrice > widget.product.newPrice)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${(((widget.product.oldPrice - widget.product.newPrice) / widget.product.oldPrice) * 100).round()}% OFF',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),

                  SizedBox(height: 20),

                  // Quantity Selector
                  Row(
                    children: [
                      Text(
                        'Quantity:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 20),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove, color: Colors.white),
                              onPressed: () {
                                if (_quantity > 1) {
                                  setState(() {
                                    _quantity--;
                                  });
                                }
                              },
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              child: Text(
                                _quantity.toString(),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.add, color: Colors.white),
                              onPressed: () {
                                if (_quantity < widget.product.quantity) {
                                  setState(() {
                                    _quantity++;
                                  });
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Maximum available quantity reached!',
                                      ),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 12),

                  // Available Stock
                  Text(
                    'Available Stock: ${widget.product.quantity}',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),

                  SizedBox(height: 24),

                  // Product Description
                  Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    widget.product.desc,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.8),
                      height: 1.5,
                    ),
                  ),

                  SizedBox(height: 16),

                  // Creation Date
                  Text(
                    'Listed on: ${_formatTimestamp(widget.product.createdAt)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.day} ${_getMonthName(timestamp.month)} ${timestamp.year}';
  }

  String _getMonthName(int month) {
    const monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return monthNames[month - 1];
  }

  Widget _buildImageCarousel() {
    return Stack(
      children: [
        Container(
          color: Colors.white,
          width: double.infinity,
          child:
              widget.product.images.isEmpty
                  ? Container(
                    height: 300,
                    child: Center(
                      child: Icon(
                        Icons.image,
                        size: 100,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  )
                  : CarouselSlider(
                    options: CarouselOptions(
                      height: 300,
                      viewportFraction: 1.0,
                      enlargeCenterPage: false,
                      onPageChanged: (index, reason) {
                        setState(() {
                          _currentImageIndex = index;
                        });
                      },
                      autoPlay: widget.product.images.length > 1,
                      autoPlayInterval: Duration(seconds: 4),
                    ),
                    items:
                        widget.product.images.map((imageUrl) {
                          return Builder(
                            builder: (BuildContext context) {
                              return Container(
                                width: MediaQuery.of(context).size.width,
                                child: Image.network(
                                  imageUrl,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Center(
                                      child: Icon(
                                        Icons.broken_image,
                                        size: 80,
                                        color: Colors.grey.shade400,
                                      ),
                                    );
                                  },
                                  loadingBuilder: (
                                    context,
                                    child,
                                    loadingProgress,
                                  ) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value:
                                            loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    (loadingProgress
                                                            .expectedTotalBytes ??
                                                        1)
                                                : null,
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          );
                        }).toList(),
                  ),
        ),
        if (widget.product.images.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children:
                  widget.product.images.asMap().entries.map((entry) {
                    return Container(
                      width: 8,
                      height: 8,
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            _currentImageIndex == entry.key
                                ? AppColors.primaryDark
                                : Colors.grey.shade500,
                      ),
                    );
                  }).toList(),
            ),
          ),
      ],
    );
  }

  // Add to cart method
  Future<void> _addToCart() async {
    // Prevent multiple clicks
    if (_isAddingToCart) return;

    setState(() {
      _isAddingToCart = true;
    });

    try {
      // Create cart item
      final cartItem = CartItem(
        id: '', // ID will be assigned by Firestore
        productId: widget.product.id,
        name: widget.product.name,
        price: widget.product.newPrice,
        quantity: _quantity,
        imageUrl:
            widget.product.images.isNotEmpty ? widget.product.images[0] : '',
        userId: _userId,
      );

      // Add to cart in Firestore
      await _cartService.addToCart(cartItem);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added to Cart!'),
          backgroundColor: AppColors.primaryDark,
          duration: Duration(seconds: 2),
          action: SnackBarAction(
            label: 'VIEW CART',
            textColor: Colors.white,
            onPressed: () {
              Get.to(CartPage());
            },
          ),
        ),
      );
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add to cart: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() {
        _isAddingToCart = false;
      });
    }
  }

  // Buy now method
  // ignore: unused_element
  void _buyNow() {
    _addToCart().then((_) {
      // Navigate to cart page
      Navigator.pushNamed(context, '/cart');
    });
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _isAddingToCart ? null : _addToCart,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.white),
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child:
                  _isAddingToCart
                      ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                      : Text(
                        'Add to Cart',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child:ElevatedButton(
  onPressed: () {
    // Show the bottom sheet using showModalBottomSheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allow the bottom sheet to be larger
      backgroundColor: Colors.transparent,
      builder: (context) => BuyNowBottomSheet(
        productId: widget.product.id,
        productName: widget.product.name,
        productImage: widget.product.images.isNotEmpty ? widget.product.images[0] : '',
        productPrice: widget.product.newPrice,
        quantity: _quantity,
        orderService: OrderService(), // You might need to get this from your dependency injection system
      ),
    ).then((result) {
      // Handle the result when the bottom sheet is closed
      if (result != null && result['success'] == true) {
        // Show success message or navigate to order confirmation
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order placed successfully! Order ID: ${result['orderId']}'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Optionally navigate to order confirmation page
        // Navigator.pushNamed(context, '/order-confirmation', arguments: result['orderId']);
      }
    });
  },
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    padding: EdgeInsets.symmetric(vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
  child: Text(
    'Buy Now',
    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  ),
),
          ),
        ],
      ),
    );
  }
}
