import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:persian_fonts/persian_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/cart.dart';
import '../providers/products.dart';
import 'cart_screen.dart';
import '../widgets/products_grid.dart';
import '../widgets/app_drawer.dart';

import '../models/my_colors.dart';

enum FilterOptions { Favorites, All }

class ProductsOverviewScreen extends StatefulWidget {
  const ProductsOverviewScreen({super.key});

  @override
  State<ProductsOverviewScreen> createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  var _showOnlyFavorites = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _refreshProducts() async {
    await Provider.of<Products>(context, listen: false).fetchAndSetProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Consumer<Cart>(
            builder: (_, cart, ch) => Badge(
              label: Text(cart.cartCount.toString()),
              backgroundColor: Theme.of(context).colorScheme.secondary,
              child: ch,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.shopping_cart,
              ),
              onPressed: () => Navigator.of(context).pushNamed(
                CartScreen.routeName,
              ),
            ),
          ),
          PopupMenuButton(
            onSelected: (value) {
              setState(() {
                if (value == FilterOptions.Favorites) {
                  _showOnlyFavorites = true;
                } else {
                  _showOnlyFavorites = false;
                }
              });
            },
            icon: const Icon(Icons.more_vert),
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: FilterOptions.Favorites,
                child: Text("موارد دلخواه"),
              ),
              const PopupMenuItem(
                value: FilterOptions.All,
                child: Text("همه"),
              ),
            ],
          ),
        ],
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        backgroundColor:
            Colors.transparent, // Set the background to transparent
        flexibleSpace: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.4,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(200),
                bottomRight: Radius.circular(200),
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.topRight,
                colors: [
                  AppColors.deepSkyBlue,
                  AppColors.turquoise,
                ],
              ),
            ),
            child: Center(
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'شاپ',
                      style: PersianFonts.Shabnam.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        // color: Theme.of(context).colorScheme.onPrimary,
                        color: AppColors.turquoise,
                        // backgroundColor: AppColors.tomatoRed,
                        backgroundColor: Colors.black,
                      ),
                    ),
                    TextSpan(
                      text: 'اینجا',
                      style: PersianFonts.Shabnam.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          // color: const Color(0xFFFF6347),
                          color: Colors.black),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      drawer: const AppDrawer(),
      body: Container(
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
                future: Provider.of<Products>(context, listen: false)
                    .fetchAndSetProducts(),
                builder: (_, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // If the future is still waiting for data, show a loading spinner
                    return const Center(
                        child: CircularProgressIndicator(
                      backgroundColor: AppColors.turquoise,
                    ));
                  } else if (snapshot.error != null) {
                    print('Errore: ${snapshot.error}');
                    //         if (snapshot.data != null) {
                    //   print('Response Data: ${snapshot.data}');
                    // }
                    // If there was an error while fetching data, show an error message
                    return const Center(child: Text('خطا در برقراری ارتباط !'));
                  } else {
                    // If the future has completed successfully, show the products grid
                    return ProductsGrid(_showOnlyFavorites);
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
