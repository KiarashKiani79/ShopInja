import 'package:ShopInja/models/my_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/appbar.dart';
import '../providers/orders.dart' show Orders;
import '../widgets/order_item.dart';
import '../widgets/app_drawer.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});
  static const routeName = "/orders";

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  Future<void>? _ordersFuture;

  @override
  void initState() {
    // Fetch orders when the screen is initialized
    _ordersFuture =
        Provider.of<Orders>(context, listen: false).fetchAndSetOrders();
    super.initState();
  }

  Future<void> _refreshProducts() async {
    await Provider.of<Orders>(context, listen: false).fetchAndSetOrders();
  }

  @override
  Widget build(BuildContext context) {
    final appBarHeight = AppBar().preferredSize.height;
    final deviceHeight = MediaQuery.of(context).size.height;
    final backgroundImageHeight = deviceHeight - appBarHeight;
    return Scaffold(
      appBar: AppBar(
        title: const Text("سفارشات"),
        systemOverlayStyle: AppBarContainer.customStatusBarStyle,
        backgroundColor:
            Colors.transparent, // Set the background to transparent
        flexibleSpace: const Center(
          child: AppBarContainer(),
        ),
        actions: [
          PopupMenuButton(
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'clear',
                child: IntrinsicWidth(
                  child: Row(
                    children: [
                      Icon(Icons.delete),
                      SizedBox(width: 8),
                      Text('حذف همه'),
                    ],
                  ),
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'clear') {
                // Call the clear method here
                Provider.of<Orders>(context, listen: false).deleteAll();
              }
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),

      // Use FutureBuilder to handle the async operation and show loading spinner
      body: Container(
        height: backgroundImageHeight,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/bg.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: _refreshProducts,
              color: Theme.of(context).colorScheme.secondary,
              child: FutureBuilder(
                future: _ordersFuture,
                builder: (ctx, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // While waiting for the future to complete, show the loading spinner
                    return const Center(
                      child: CircularProgressIndicator(
                        backgroundColor: AppColors.turquoise,
                      ),
                    );
                  } else {
                    if (snapshot.error != null) {
                      // print('error_order: ${snapshot.error}');
                      // If there was an error fetching data, handle it here
                      return const Center(
                        child: Text('خطا در بارگزاری سفارش‌ها!'),
                      );
                    } else {
                      final ordersData = Provider.of<Orders>(context);
                      if (ordersData.orders.isEmpty) {
                        // If there are no orders, show a centered text widget
                        return const Center(
                          child: Text('سفارشی یافت نشد!'),
                        );
                      }
                      // If the future is completed successfully, show the orders
                      return ListView.builder(
                        itemCount: ordersData.orders.length,
                        itemBuilder: (context, index) =>
                            OrderItem(ordersData.orders[index]),
                      );
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
