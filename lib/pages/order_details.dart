// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart';
// import 'package:get/get.dart';

// import '../utils/color.dart';

// // ORDER STATUS ENUM
// enum OrderStatus {
//   pending('Pending'),
//   processing('Processing'),
//   shipped('Shipped'),
//   onTheWay('On the Way'),
//   delivered('Delivered'),
//   cancelled('Cancelled');

//   const OrderStatus(this.value);
//   final String value;
// }

// // ORDER MODEL CLASS
// class OrderModel {
//   final String id;
//   final String userId;
//   final String productId;
//   final String productName;
//   final String productImage;
//   final double productPrice;
//   final int quantity;
//   final double totalAmount;
//   final DateTime orderDate;
//   final String status;
//   final String address;
//   final String city;
//   final String postalCode;
//   final String? notes;
//   final DateTime? shippedDate;
//   final DateTime? deliveredDate;

//   OrderModel({
//     required this.id,
//     required this.userId,
//     required this.productId,
//     required this.productName,
//     required this.productImage,
//     required this.productPrice,
//     required this.quantity,
//     required this.totalAmount,
//     required this.orderDate,
//     required this.status,
//     required this.address,
//     required this.city,
//     required this.postalCode,
//     this.notes,
//     this.shippedDate,
//     this.deliveredDate,
//   });

//   factory OrderModel.fromMap(String id, Map<String, dynamic> map) {
//     return OrderModel(
//       id: id,
//       userId: map['userId'] ?? '',
//       productId: map['productId'] ?? '',
//       productName: map['productName'] ?? '',
//       productImage: map['productImage'] ?? '',
//       productPrice: (map['productPrice'] ?? 0.0).toDouble(),
//       quantity: map['quantity'] ?? 0,
//       totalAmount: (map['totalAmount'] ?? 0.0).toDouble(),
//       orderDate: (map['orderDate'] as Timestamp).toDate(),
//       status: map['status'] ?? OrderStatus.pending.value,
//       address: map['address'] ?? '',
//       city: map['city'] ?? '',
//       postalCode: map['postalCode'] ?? '',
//       notes: map['notes'],
//       shippedDate: map['shippedDate'] != null ? (map['shippedDate'] as Timestamp).toDate() : null,
//       deliveredDate: map['deliveredDate'] != null ? (map['deliveredDate'] as Timestamp).toDate() : null,
//     );
//   }
// }

// // ORDER SERVICE CLASS
// class OrderService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   Stream<List<OrderModel>> getUserOrders(String userId) {
//     try {
//       // Fixed query with proper index structure to resolve the error
//       return _firestore
//           .collection('shop_orders')
//           .where('userId', isEqualTo: userId)
//           .orderBy('orderDate', descending: true)
//           .orderBy(FieldPath.documentId, descending: true)
//           .snapshots()
//           .map((snapshot) {
//             return snapshot.docs
//                 .map((doc) => OrderModel.fromMap(doc.id, doc.data()))
//                 .toList();
//           });
//     } catch (e) {
//       print('Error getting user orders: $e');
//       return Stream.value([]);
//     }
//   }
// }

// // USER ORDERS PAGE
// class UserOrdersPage extends StatefulWidget {
//   const UserOrdersPage({Key? key}) : super(key: key);

//   @override
//   _UserOrdersPageState createState() => _UserOrdersPageState();
// }

// class _UserOrdersPageState extends State<UserOrdersPage> {
//   final OrderService _orderService = OrderService();
//   late String _userId;
//   String _filterStatus = 'All';

//   @override
//   void initState() {
//     super.initState();
//     _userId = FirebaseAuth.instance.currentUser?.uid ?? '';
//     if (_userId.isEmpty) {
//       // Navigate back if not logged in - Fixed GetX navigation
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         Get.offNamed('/login'); // Fixed GetX navigation
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_userId.isEmpty) {
//       return Scaffold(
//         backgroundColor: AppColors.scaffold,
//         body: Center(
//           child: Text(
//             'Please login to view your orders',
//             style: TextStyle(color: Colors.white),
//           ),
//         ),
//       );
//     }

//     return Scaffold(
//       backgroundColor: AppColors.scaffold,
//       appBar: AppBar(
//         backgroundColor: AppColors.primaryDark,
//         title: Text(
//           'My Orders',
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//         ),
//         actions: [
//           PopupMenuButton<String>(
//             icon: Icon(Icons.filter_list, color: Colors.white),
//             onSelected: (value) {
//               setState(() {
//                 _filterStatus = value;
//               });
//             },
//             itemBuilder: (context) => [
//               PopupMenuItem(
//                 value: 'All',
//                 child: Text('All Orders'),
//               ),
//               ...OrderStatus.values.map((status) => PopupMenuItem(
//                     value: status.value,
//                     child: Text(status.value),
//                   )),
//             ],
//           ),
//         ],
//       ),
//       body: StreamBuilder<List<OrderModel>>(
//         stream: _orderService.getUserOrders(_userId),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           }

//           if (snapshot.hasError) {
//             return Center(
//               child: Text(
//                 'Error: ${snapshot.error}',
//                 style: TextStyle(color: Colors.red),
//               ),
//             );
//           }

//           final orders = snapshot.data ?? [];
          
//           // Filter orders if a status filter is applied
//           final filteredOrders = _filterStatus == 'All'
//               ? orders
//               : orders.where((order) => order.status == _filterStatus).toList();

//           if (filteredOrders.isEmpty) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     Icons.shopping_bag_outlined,
//                     size: 80,
//                     color: Colors.grey,
//                   ),
//                   SizedBox(height: 16),
//                   Text(
//                     _filterStatus == 'All'
//                         ? 'You haven\'t placed any orders yet'
//                         : 'No ${ _filterStatus.toLowerCase()} orders found',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 18,
//                     ),
//                   ),
//                   SizedBox(height: 24),
//                   ElevatedButton(
//                     onPressed: () {
//                       // Fixed GetX navigation
//                       Get.offNamed('/'); // or Get.off(() => HomePage());
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColors.primary,
//                       padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//                     ),
//                     child: Text('Browse Products'),
//                   ),
//                 ],
//               ),
//             );
//           }

//           return ListView.builder(
//             padding: EdgeInsets.all(12),
//             itemCount: filteredOrders.length,
//             itemBuilder: (context, index) {
//               final order = filteredOrders[index];
//               return _buildOrderCard(order);
//             },
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildOrderCard(OrderModel order) {
//     // Format the date
//     final dateFormat = DateFormat('MMM dd, yyyy • hh:mm a');
//     final formattedDate = dateFormat.format(order.orderDate);
    
//     // Get color for status
//     Color statusColor;
//     switch (order.status) {
//       case 'Pending':
//         statusColor = Colors.orange;
//         break;
//       case 'Processing':
//         statusColor = Colors.blue;
//         break;
//       case 'Shipped':
//         statusColor = Colors.purple;
//         break;
//       case 'On the Way':
//         statusColor = Colors.teal;
//         break;
//       case 'Delivered':
//         statusColor = Colors.green;
//         break;
//       case 'Cancelled':
//         statusColor = Colors.red;
//         break;
//       default:
//         statusColor = Colors.grey;
//     }

//     return Card(
//       margin: EdgeInsets.only(bottom: 16),
//       color: AppColors.primaryDark.withOpacity(0.5),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Order ID and Date
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Order #${order.id.substring(0, 8)}',
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                     color: Colors.white,
//                   ),
//                 ),
//                 Text(
//                   formattedDate,
//                   style: TextStyle(
//                     color: Colors.grey,
//                     fontSize: 14,
//                   ),
//                 ),
//               ],
//             ),
//             Divider(color: Colors.grey.shade700),
            
//             // Product summary
//             ListTile(
//               contentPadding: EdgeInsets.zero,
//               leading: ClipRRect(
//                 borderRadius: BorderRadius.circular(8),
//                 child: Image.network(
//                   order.productImage,
//                   width: 60,
//                   height: 60,
//                   fit: BoxFit.cover,
//                   errorBuilder: (context, error, stackTrace) {
//                     return Container(
//                       width: 60,
//                       height: 60,
//                       color: Colors.grey.shade700,
//                       child: Icon(Icons.image_not_supported, color: Colors.white),
//                     );
//                   },
//                 ),
//               ),
//               title: Text(
//                 order.productName,
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//               ),
//               subtitle: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Qty: ${order.quantity} • Rs${order.productPrice.toStringAsFixed(2)}',
//                     style: TextStyle(color: Colors.grey),
//                   ),
//                   SizedBox(height: 4),
//                   Text(
//                     'Total: Rs${order.totalAmount.toStringAsFixed(2)}',
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       color: AppColors.primary,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
            
//             Divider(color: Colors.grey.shade700),
            
//             // Shipping Information
//             Text(
//               'Shipping Details',
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//                 fontSize: 15,
//               ),
//             ),
//             SizedBox(height: 8),
            
//             // Address information
//             _buildInfoRow(Icons.location_on, '${order.address}, ${order.city}, ${order.postalCode}'),
            
//             if (order.notes != null && order.notes!.isNotEmpty)
//               _buildInfoRow(Icons.note, order.notes!),
            
//             SizedBox(height: 16),
            
//             // Order status
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Status',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 Container(
//                   padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                   decoration: BoxDecoration(
//                     color: statusColor.withOpacity(0.2),
//                     borderRadius: BorderRadius.circular(20),
//                     border: Border.all(color: statusColor),
//                   ),
//                   child: Text(
//                     order.status,
//                     style: TextStyle(
//                       color: statusColor,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
            
//             // Show tracking information if shipped
//             if (order.status == OrderStatus.shipped.value || 
//                 order.status == OrderStatus.onTheWay.value ||
//                 order.status == OrderStatus.delivered.value) 
//               _buildTrackingInfo(order),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoRow(IconData icon, String text) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(icon, size: 16, color: Colors.grey),
//           SizedBox(width: 8),
//           Expanded(
//             child: Text(
//               text,
//               style: TextStyle(color: Colors.white),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTrackingInfo(OrderModel order) {
//     final dateFormat = DateFormat('MMM dd, yyyy');
    
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         SizedBox(height: 16),
//         Divider(color: Colors.grey.shade700),
//         SizedBox(height: 8),
        
//         Text(
//           'Order Timeline',
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//             fontSize: 15,
//           ),
//         ),
//         SizedBox(height: 16),
        
//         // Order placed
//         _buildTimelineItem(
//           icon: Icons.shopping_cart_checkout,
//           title: 'Order Placed',
//           date: dateFormat.format(order.orderDate),
//           isCompleted: true,
//         ),
        
//         // Processing
//         _buildTimelineItem(
//           icon: Icons.inventory,
//           title: 'Processing',
//           date: order.status == OrderStatus.pending.value ? 'Waiting' : 'Completed',
//           isCompleted: order.status != OrderStatus.pending.value,
//         ),
        
//         // Shipped
//         _buildTimelineItem(
//           icon: Icons.local_shipping,
//           title: 'Shipped',
//           date: order.shippedDate != null ? dateFormat.format(order.shippedDate!) : 'Waiting',
//           isCompleted: order.shippedDate != null,
//         ),
        
//         // On the way
//         _buildTimelineItem(
//           icon: Icons.delivery_dining,
//           title: 'On the Way',
//           date: order.status == OrderStatus.onTheWay.value || order.status == OrderStatus.delivered.value ? 'In transit' : 'Waiting',
//           isCompleted: order.status == OrderStatus.onTheWay.value || order.status == OrderStatus.delivered.value,
//         ),
        
//         // Delivered
//         _buildTimelineItem(
//           icon: Icons.check_circle,
//           title: 'Delivered',
//           date: order.deliveredDate != null ? dateFormat.format(order.deliveredDate!) : 'Waiting',
//           isCompleted: order.deliveredDate != null,
//           isLast: true,
//         ),
//       ],
//     );
//   }

//   Widget _buildTimelineItem({
//     required IconData icon,
//     required String title,
//     required String date,
//     required bool isCompleted,
//     bool isLast = false,
//   }) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Column(
//           children: [
//             Container(
//               padding: EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: isCompleted ? AppColors.primary : Colors.grey.shade700,
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 icon,
//                 color: Colors.white,
//                 size: 16,
//               ),
//             ),
//             if (!isLast)
//               Container(
//                 width: 2,
//                 height: 30,
//                 color: isCompleted ? AppColors.primary : Colors.grey.shade700,
//               ),
//           ],
//         ),
//         SizedBox(width: 12),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 title,
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   color: isCompleted ? Colors.white : Colors.grey,
//                 ),
//               ),
//               SizedBox(height: 4),
//               Text(
//                 date,
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: Colors.grey,
//                 ),
//               ),
//               SizedBox(height: isLast ? 0 : 16),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }