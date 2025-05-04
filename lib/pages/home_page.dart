import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/product_model.dart';
import '../utils/color.dart';
import 'product_category_page.dart';
import 'products_detail.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final List<Map<String, dynamic>> _banners = [
    {
      'title': 'Summer Sale',
      'subtitle': 'Up to 50% Off',
      'color': Colors.blue.shade50,
      'textColor': Colors.blue.shade900,
    },
    {
      'title': 'New Arrivals',
      'subtitle': 'Discover the Trend',
      'color': Colors.amber.shade50,
      'textColor': Colors.amber.shade900,
    },
    {
      'title': 'Special Offer',
      'subtitle': 'Free Shipping on Orders Over \$50',
      'color': Colors.green.shade50,
      'textColor': Colors.green.shade900,
    },
  ];
  
  late Timer _timer;
  bool _isLoading = true;
  List<Map<String, dynamic>> _categories = [];
  List<Product> _products = []; // List to store products

  @override
  void initState() {
    super.initState();
    // Start auto-sliding timer
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_currentPage < _banners.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeIn,
        );
      }
    });

    // Fetch categories and products from Firestore
    _fetchCategories();
    _fetchProducts();
  }

  // Method to fetch categories from Firestore
  Future<void> _fetchCategories() async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('shop_categories')
          .get();

      setState(() {
        _categories = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'id': doc.id,
            'name': data['name'] ?? 'Unknown Category',
            'imageUrl': data['image'] ?? '',
            'desc': data['desc'] ?? '',
          };
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching categories: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Method to fetch products from Firestore
  Future<void> _fetchProducts() async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('shop_products')
          .get();

      setState(() {
        _products = snapshot.docs
            .map((doc) => Product.fromFirestore(doc))
            .toList();
      });
    } catch (e) {
      print('Error fetching products: $e');
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: AppColors.primaryDark,
        title: Text(
          'E---->COM',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Auto Sliding Banner Carousel
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: _pageController,
                      onPageChanged: (int page) {
                        setState(() {
                          _currentPage = page;
                        });
                      },
                      itemCount: _banners.length,
                      itemBuilder: (context, index) {
                        final banner = _banners[index];
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: banner['color'],
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  banner['title'],
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: banner['textColor'],
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  banner['subtitle'],
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: banner['textColor'].withOpacity(0.8),
                                  ),
                                ),
                                SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {},
                                  child: Text('Shop Now'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: banner['textColor'],
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    // Page Indicator
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _banners.length,
                          (index) => Container(
                            width: 8,
                            height: 8,
                            margin: EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentPage == index
                                  ? AppColors.primaryDark
                                  : Colors.black.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 20),
              
              // Categories Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Categories',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate to all categories page
                    },
                    child: Text('See All'),
                  ),
                ],
              ),
              SizedBox(height: 10),
              
              // Categories from Firestore
              _isLoading
                ? Center(child: CircularProgressIndicator())
                : _categories.isEmpty
                  ? Center(child: Text('No categories found', style: TextStyle(color: Colors.white)))
                  : SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          final category = _categories[index];
                          return _buildCategoryItemFromFirestore(
                            category['imageUrl'],
                            category['name'],
                            category['id'],
                          );
                        },
                      ),
                    ),
              
              SizedBox(height: 20),
              
              // Featured Products
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Featured Products',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text('See All'),
                  ),
                ],
              ),
              SizedBox(height: 16),
              
              // Display products from Firestore
              _products.isEmpty
                ? Center(
                    child: _isLoading
                      ? CircularProgressIndicator()
                      : Text('No products found', style: TextStyle(color: Colors.white))
                  )
                : GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: _products.length,
                    itemBuilder: (context, index) {
                      final product = _products[index];
                      return _buildProductCard(
                        product: product,
                        onPressed: () {
                          // Navigate to product details page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailScreen(product: product),
                            ),
                          );
                        },
                      );
                    },
                  ),
              
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // Method to build category items from Firestore data
  Widget _buildCategoryItemFromFirestore(String imageUrl, String label, String categoryId) {
    return GestureDetector(
      onTap: () {
        // Navigate to category products page
        _navigateToCategoryProducts(categoryId, label);
      },
      child: Container(
        width: 100, // Made wider for better display
        margin: EdgeInsets.only(right: 16),
        child: Column(
          children: [
            // Category Image Container
            Container(
              height: 80, // Bigger image for better visibility
              width: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryDark.withOpacity(0.8),
                border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: imageUrl.isNotEmpty 
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        print("Error loading image: $error");
                        return Icon(
                          Icons.category,
                          size: 40,
                          color: Colors.white,
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
                            color: Colors.white,
                          ),
                        );
                      },
                    )
                  : Icon(
                      Icons.category,
                      size: 40,
                      color: Colors.white,
                    ),
              ),
            ),
            SizedBox(height: 8),
            // Category Name
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // Navigation method for category products
  void _navigateToCategoryProducts(String categoryId, String categoryName) {
    print('Navigating to products in category: $categoryName (ID: $categoryId)');
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryProductsScreen(
          categoryId: categoryId,
          categoryName: categoryName,
        ),
      ),
    );
  }

  // Updated method to build product card
  Widget _buildProductCard({required Product product, required VoidCallback onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          color: AppColors.primaryDark,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
                width: double.infinity,
                child: product.images.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                      child: Image.network(
                        product.images[0],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Icon(
                              Icons.image,
                              size: 60,
                              color: Colors.grey.shade400,
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
                            ),
                          );
                        },
                      ),
                    )
                  : Center(
                      child: Icon(
                        Icons.image,
                        size: 60,
                        color: Colors.grey.shade400,
                      ),
                    ),
              ),
            ),
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
                      style: TextStyle(
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
                          '₹${product.newPrice}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8),
                        if (product.oldPrice > product.newPrice)
                          Text(
                            '₹${product.oldPrice}',
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              color: Colors.grey,
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
}