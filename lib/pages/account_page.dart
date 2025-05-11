import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_services.dart';
import '../models/user_model.dart';

class AccountScreen extends StatelessWidget {
  final AuthServices _authServices = Get.find<AuthServices>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings page
              // Get.to(() => SettingsScreen());
            },
          ),
        ],
      ),
      body: Obx(() {
        final user = _authServices.user;
        
        if (_authServices.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }
        
        if (user == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'You need to login first',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to login page
                    // Get.offAll(() => LoginPage());
                  },
                  child: Text('Go to Login'),
                ),
              ],
            ),
          );
        }
        
        return FutureBuilder<DocumentSnapshot>(
          future: _firestore.collection('Clients').doc(user.uid).get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            
            if (snapshot.hasError) {
              return Center(child: Text('Error loading profile data'));
            }
            
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Center(child: Text('User data not found'));
            }
            
            final userData = snapshot.data!.data() as Map<String, dynamic>;
            final userModel = UserModel.fromJson(userData);
            
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildProfileHeader(user.displayName ?? 'User', user.email ?? ''),
                  SizedBox(height: 20),
                  _buildProfileInfo(userModel, context),
                  SizedBox(height: 20),
                  _buildActionButtons(context),
                ],
              ),
            );
          },
        );
      }),
    );
  }
  
  Widget _buildProfileHeader(String name, String email) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue.shade800, Colors.blue.shade500],
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue.shade100,
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : "U",
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
            ),
          ),
          SizedBox(height: 15),
          Text(
            name,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 5),
          Text(
            email,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          SizedBox(height: 15),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to edit profile page
              // Get.to(() => EditProfileScreen());
            },
            icon: Icon(Icons.edit, size: 16),
            label: Text('Edit Profile'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue.shade800,
              elevation: 0,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildProfileInfo(UserModel userModel, BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Account Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
              Divider(height: 30),
              _buildInfoItem(context, 'Name', userModel.name),
              _buildInfoItem(context, 'Email', userModel.email),
              _buildInfoItem(context, 'User ID', userModel.uid),
              
              // You can add more user details here, like:
              // _buildInfoItem(context, 'Phone', userModel.phone ?? 'Not added'),
              // _buildInfoItem(context, 'Address', userModel.address ?? 'Not added'),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildInfoItem(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ),
          SizedBox(width: 20),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildActionButton(
            'My Orders' ,
            Icons.shopping_bag_outlined,
            Colors.orange,
            () {
              // Navigate to orders page
              // Get.to(() => OrdersScreen());
            },
          ),
          SizedBox(height: 12),
          _buildActionButton(
            'Shipping Addresses',
            Icons.location_on_outlined,
            Colors.green,
            () {
              // Navigate to addresses page
              // Get.to(() => AddressesScreen());
            },
          ),
          SizedBox(height: 12),
          _buildActionButton(
            'Payment Methods',
            Icons.credit_card_outlined,
            Colors.purple,
            () {
              // Navigate to payment methods page
              // Get.to(() => PaymentMethodsScreen());
            },
          ),
          SizedBox(height: 12),
          _buildActionButton(
            'Help & Support',
            Icons.help_outline,
            Colors.blue,
            () {
              // Navigate to help page
              // Get.to(() => HelpScreen());
            },
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () async {
              final result = await Get.dialog(
                AlertDialog(
                  title: Text('Logout'),
                  content: Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(result: false),
                      child: Text('CANCEL'),
                    ),
                    ElevatedButton(
                      onPressed: () => Get.back(result: true),
                      child: Text('LOGOUT'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              );
              
              if (result == true) {
                await _authServices.signOut();
              }
            },
            icon: Icon(Icons.logout),
            label: Text(
              'Logout',
              style: TextStyle(fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 12),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
          SizedBox(height: 30),
        ],
      ),
    );
  }
  
  Widget _buildActionButton(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color),
              ),
              SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Spacer(),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}