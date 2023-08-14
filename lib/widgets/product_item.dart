import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth.dart';
import '../providers/product.dart';

import '../screens/product_detail_screen.dart';
import '../providers/cart.dart';
import '../models/gradient_icon.dart';
import 'package:marquee/marquee.dart';

class ProductItem extends StatelessWidget {
  const ProductItem({super.key});

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context, listen: false);
    final cart = Provider.of<Cart>(context, listen: false);
    final authData = Provider.of<Auth>(context, listen: false);

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        footer: GridTileBar(
          leading: Consumer<Product>(
            builder: (context, product, _) => IconButton(
              icon: Icon(
                product.isFavorite ? Icons.favorite : Icons.favorite_border,
              ),
              color: Theme.of(context).primaryColorLight,
              onPressed: () {
                product.toggleFavoriteStatus(
                  authData.token,
                  authData.userId,
                );
              },
            ),
          ),
          title: Marquee(
            text: product.title,

            style: const TextStyle(
              fontFamily: 'Vazirmatn',
              package: 'persian_fonts',
              fontWeight: FontWeight.bold,
            ),
            blankSpace: 10,
            velocity: 20, // You can adjust the velocity (scrolling speed) here
            startPadding: 0,
            crossAxisAlignment: CrossAxisAlignment.center,
          ),
          backgroundColor: const Color.fromARGB(207, 0, 0, 0),
          trailing: IconButton(
            icon: const GradientIcon(
              icon: Icons.shopping_cart,
            ),
            onPressed: () {
              cart.addItem(
                product.id,
                product.title,
                product.price,
              );
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                    "به سبد خرید اضافه شد",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  duration: const Duration(seconds: 1),
                  action: SnackBarAction(
                    label: "بازگشت",
                    onPressed: () => cart.removeSingleItem(product.id),
                  ),
                ),
              );
            },
          ),
        ),
        child: GestureDetector(
            onTap: () => Navigator.of(context).pushNamed(
                  ProductDetailScreen.routeName,
                  arguments: product.id,
                ),
            child: Hero(
              tag: product.id,
              child: FadeInImage(
                placeholder: const AssetImage('assets/loadingProduct.png'),
                image: NetworkImage(product.imageUrl),
                fit: BoxFit.cover,
              ),
            )),
      ),
    );
  }
}
