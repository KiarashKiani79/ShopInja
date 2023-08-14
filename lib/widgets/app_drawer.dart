import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';
import '../screens/orders_screen.dart';
import '../screens/user_products_screen.dart';
import '../models/gradient_icon.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});
  final String imageUrl =
      "https://cdn.discordapp.com/attachments/1061030678872989736/1131680358753116251/8c93d74d-e2ed-4430-9e62-3ae0d6428c2b.jpg";

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          SizedBox(
            height: 300,
            width: double.infinity,
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
            ),
          ),
          ListTile(
            leading: IconButton(
              icon: const GradientIcon(icon: Icons.shop),
              onPressed: () {},
            ),
            title: const Text("فروشگاه"),
            onTap: () {
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
          // const Divider(),
          ListTile(
            leading: IconButton(
              icon: const GradientIcon(icon: Icons.payment),
              onPressed: () {},
            ),
            title: const Text("سفارشات"),
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed(OrdersScreen.routeName);
            },
          ),
          // const Divider(),
          ListTile(
            leading: IconButton(
              icon: const GradientIcon(icon: Icons.shop_two),
              onPressed: () {},
            ),
            title: const Text("محصول من"),
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed(UserProductsScreen.routeName);
            },
          ),
          // const Divider(),
          ListTile(
            leading: IconButton(
              icon: const Icon(
                Icons.exit_to_app,
                color: Colors.red,
              ),
              onPressed: () {},
            ),
            title: const Text('خروج'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/');

              // Navigator.of(context)
              //     .pushReplacementNamed(UserProductsScreen.routeName);
              Provider.of<Auth>(context, listen: false).logout();
            },
          ),
        ],
      ),
    );
  }
}
