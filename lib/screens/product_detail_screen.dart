import 'package:ShopInja/models/my_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products.dart';
import '../models/appbar.dart';
import 'package:persian_number_utility/persian_number_utility.dart';

class ProductDetailScreen extends StatelessWidget {
  static const routeName = '/product-detail';

  const ProductDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appBarHeight = AppBar().preferredSize.height;
    final deviceHeight = MediaQuery.of(context).size.height;
    final backgroundImageHeight = deviceHeight - appBarHeight;
    final productId = ModalRoute.of(context)?.settings.arguments as String;
    final loadedPruduct = Provider.of<Products>(
      context,
      listen: false,
    ).findById(productId);

    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: AppBarContainer.customStatusBarStyle,
        title: Text(loadedPruduct.title),
        backgroundColor:
            Colors.transparent, // Set the background to transparent
        flexibleSpace: const Center(
          child: AppBarContainer(),
        ),
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
            SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    height: 300,
                    width: double.infinity,
                    child: Hero(
                      tag: productId,
                      child: Image.network(
                        loadedPruduct.imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                    ),
                    child: Text(
                      loadedPruduct.description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      softWrap: true,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.turquoise,
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                      border: Border.all(),
                    ),
                    child: Text(
                      "${loadedPruduct.price.toStringAsFixed(0).toPersianDigit().seRagham()} تومان",
                      style: const TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(onPressed: () => {},shape: Icons.,),
    );
  }
}
