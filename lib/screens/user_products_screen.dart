import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/appbar.dart';
import '../providers/products.dart';
import '../widgets/user_product_item.dart';
import '../widgets/app_drawer.dart';
import '../screens/edit_product_screen.dart';

import '../models/my_colors.dart';
// import 'package:flutter/services.dart';

class UserProductsScreen extends StatelessWidget {
  const UserProductsScreen({super.key});

  static const routeName = "/userProducts";

  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<Products>(context, listen: false)
        .fetchAndSetProducts(true);
  }

  @override
  Widget build(BuildContext context) {
    final appBarHeight = AppBar().preferredSize.height;
    final deviceHeight = MediaQuery.of(context).size.height;
    final backgroundImageHeight = deviceHeight - appBarHeight;
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('محصولات من'),
        systemOverlayStyle: AppBarContainer.customStatusBarStyle,
        backgroundColor:
            Colors.transparent, // Set the background to transparent
        flexibleSpace: const Center(
          child: AppBarContainer(),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(EditProductScreen.routeName);
            },
            icon: const Icon(Icons.add),
          )
        ],
      ),
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
            FutureBuilder(
              future: _refreshProducts(context),
              builder: (ctx, snapshot) =>
                  snapshot.connectionState == ConnectionState.waiting
                      ? const Center(
                          child: CircularProgressIndicator(
                              backgroundColor: AppColors.turquoise),
                        )
                      : RefreshIndicator(
                          onRefresh: () => _refreshProducts(context),
                          color: Theme.of(context).colorScheme.secondary,
                          child: Consumer<Products>(
                            builder: (ctx, productsData, _) => Padding(
                              padding: const EdgeInsets.all(8),
                              child: ListView.builder(
                                itemCount: productsData.items.length,
                                itemBuilder: (_, i) => Column(
                                  children: [
                                    UserProductItem(
                                      id: productsData.items[i].id,
                                      title: productsData.items[i].title,
                                      imageUrl: productsData.items[i].imageUrl,
                                      price: productsData.items[i].price,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
