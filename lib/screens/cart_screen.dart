import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/appbar.dart';
import '../widgets/cart_item.dart';
import '../providers/cart.dart' show Cart;
import '../providers/orders.dart';
import 'package:persian_number_utility/persian_number_utility.dart';
import '../models/my_colors.dart';

class CartScreen extends StatelessWidget {
  static const routeName = '/cart';

  const CartScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("سبد خرید"),
        systemOverlayStyle: AppBarContainer.customStatusBarStyle,
        backgroundColor:
            Colors.transparent, // Set the background to transparent
        flexibleSpace: const Center(
          child: AppBarContainer(),
        ),
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(15),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'مجموع:',
                    style: TextStyle(fontSize: 20),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      "${cart.totalAmount.toStringAsFixed(0).toPersianDigit().seRagham()} تومان",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  OrderButton(cart: cart)
                ],
              ),
            ),
          ),
          cart.cartCount == 0
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 200),
                  child: Container(
                    alignment: Alignment.bottomCenter,
                    height: 100,
                    width: 100,
                    child: Image.asset(
                      "assets/emptyCart.png",
                      fit: BoxFit.cover,
                    ),
                    // decoration: const BoxDecoration(
                    //   image: DecorationImage(
                    //     image: AssetImage("assets/emptyCart.png"),
                    //     fit: BoxFit.cover,
                    //   ),
                    // ),
                  ),
                )
              : Expanded(
                  child: ListView.builder(
                    itemCount: cart.cartCount,
                    itemBuilder: (context, index) => CartItem(
                        id: cart.items.values.toList()[index].id,
                        productId: cart.items.keys.toList()[index],
                        title: cart.items.values.toList()[index].title,
                        quantity: cart.items.values.toList()[index].quantity,
                        price: cart.items.values.toList()[index].price),
                  ),
                ),
        ],
      ),
    );
  }
}

class OrderButton extends StatefulWidget {
  const OrderButton({
    super.key,
    required this.cart,
  });

  final Cart cart;

  @override
  State<OrderButton> createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: (widget.cart.totalAmount <= 0 || _isLoading) //
          ? null
          : () async {
              setState(
                () {
                  _isLoading = true;
                },
              );
              try {
                await Provider.of<Orders>(context, listen: false).addOrder(
                    widget.cart.items.values.toList(), widget.cart.totalAmount);
                widget.cart.clear();
                setState(
                  () {
                    _isLoading = false;
                  },
                );
              } catch (error) {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text("خطا !"),
                    content:
                        const Text("مشکلی در افزودن محصول به وجود آمده است."),
                    actions: [
                      TextButton(
                        child: const Text("متوجه شدم"),
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          // Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                );
              }
            },
      child: _isLoading
          ? const CircularProgressIndicator(
              color: AppColors.tomatoRed,
            )
          : const Row(
              children: [
                Icon(
                  Icons.shopping_cart_checkout_sharp,
                  // color: Colors.black,
                ),
                SizedBox(width: 8),
                Text(
                  "ثبت",
                  // style: TextStyle(color: Colors.black),
                ),
              ],
            ),
    );
  }
}
