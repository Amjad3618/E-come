import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../pages/account_page.dart';
import '../pages/cart_page.dart';
import '../pages/home_page.dart';
import '../pages/order_page.dart';
import '../utils/color.dart';

class BottomNavController extends GetxController {
  var selectedIndex = 0.obs;
}

class BottomNavScreen extends StatelessWidget {
  BottomNavScreen({Key? key}) : super(key: key);

  final BottomNavController controller = Get.put(BottomNavController());

  final List<Widget> screens = [
    HomeScreen(),
    CartPage(), // ✅ Fixed typo here
    OrdersScreen(),
    AccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        body: IndexedStack(
          index: controller.selectedIndex.value,
          children: screens,
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: controller.selectedIndex.value,
          onTap: (index) => controller.selectedIndex.value = index,
          selectedItemColor: AppColors.primaryDark,
          unselectedItemColor: AppColors.primaryLight,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
            BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Orders'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
          ],
        ),
      ),
    );
  }
}
