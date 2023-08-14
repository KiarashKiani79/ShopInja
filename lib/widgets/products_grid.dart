import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';
import '../widgets/product_item.dart';

class ProductsGrid extends StatelessWidget {
  final bool showFavorites;

  const ProductsGrid(this.showFavorites, {super.key});

  @override
  Widget build(BuildContext context) {
    final providerData = Provider.of<Products>(context);
    final loadedProducts = showFavorites
        ? providerData.favoriteItems ??
            [] // Provide an empty list as fallback when favoriteItems is null
        : providerData.items;
    return loadedProducts.isEmpty // Check if loadedProducts is empty
        ? const Center(
            child: Text("موردی یافت نشد!", style: TextStyle(fontSize: 20)),
          )
        : GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3 / 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemBuilder: (context, index) => ChangeNotifierProvider.value(
              value: loadedProducts[index],
              child: const ProductItem(),
            ),
            itemCount: loadedProducts.length,
          );
  }
}
