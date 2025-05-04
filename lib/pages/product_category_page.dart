import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import '../utils/color.dart';
import 'products_detail.dart';

class CategoryProductsScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const CategoryProductsScreen({
    Key? key,
    required this.categoryId,
    required this.categoryName,
  }) : super(key: key);

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  bool _isLoading = true;
  String? _error;
  List<Product> _products = [];

  @override
  void initState() {
    super.initState();
    _fetchCategoryProducts();
  }

  // Method to fetch products for the selected category
  Future<void> _fetchCategoryProducts() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      print('Fetching products for category ID: ${widget.categoryId}');
      print('Category Name: ${widget.categoryName}');

      // Query products collection with properly structured query
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('shop_products')
          .where('category_id', isEqualTo: widget.categoryId)
          .get();

      print('Found ${snapshot.docs.length} products in category ${widget.categoryId}');

      // If no products found with category_id, try with category field as a fallback
      if (snapshot.docs.isEmpty) {
        print('Trying alternate query with category field');
        final fallbackSnapshot = await FirebaseFirestore.instance
            .collection('shop_products')
            .where('category', isEqualTo: widget.categoryId)
            .get();
            
        print('Fallback query found ${fallbackSnapshot.docs.length} products');
        
        setState(() {
          _products = fallbackSnapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _products = snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching products: $e');
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primaryDark,
        title: Text(
          widget.categoryName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.categoryName} Products',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_error != null)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 60,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading products',
                        style: const TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _fetchCategoryProducts,
                        child: const Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else if (_products.isEmpty)
              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.category_outlined,
                        color: Colors.grey,
                        size: 60,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No products found in this category',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _fetchCategoryProducts,
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: _products.length,
                    itemBuilder: (context, index) {
                      final product = _products[index];
                      return _buildProductCard(product);
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    String imageUrl = product.images.isNotEmpty ? product.images[0] : '';
    
    return GestureDetector(
      onTap: () {
        // Navigate to product detail page when clicked
        _navigateToProductDetail(product);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          color: AppColors.primaryDark,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                width: double.infinity,
                child: imageUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            print("Error loading image: $error");
                            return Icon(
                              Icons.image,
                              size: 60,
                              color: Colors.grey.shade400,
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
                                strokeWidth: 2.0,
                              ),
                            );
                          },
                        ),
                      )
                    : Icon(
                        Icons.image,
                        size: 60,
                        color: Colors.grey.shade400,
                      ),
              ),
            ),
            // Product Details
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: [
                        Text(
                          'In Stock: ${product.quantity}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          '₹${product.newPrice}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (product.oldPrice > product.newPrice)
                          Text(
                            '₹${product.oldPrice}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white60,
                              decoration: TextDecoration.lineThrough,
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
      ),
    );
  }

  void _navigateToProductDetail(Product product) {
    // Navigate to product detail screen
    print('Navigating to product: ${product.name} (ID: ${product.id})');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(product: product),
      ),
    );
  }
}