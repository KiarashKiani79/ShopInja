import 'package:ShopInja/providers/cart.dart';
import 'package:flutter/material.dart';
import 'package:persian_number_utility/persian_number_utility.dart';
import '../providers/orders.dart' as ord;

class OrderItem extends StatefulWidget {
  final ord.OrderItem order;

  const OrderItem(this.order, {Key? key}) : super(key: key);

  @override
  State<OrderItem> createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  bool _isExpanded = false;
  double _expandedContainerHeight = 95.0; // Initial height

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _calculateExpandedHeight();
      } else {
        _expandedContainerHeight =
            95.0; // Reset to initial height when collapsed
      }
    });
  }

  void _calculateExpandedHeight() {
    double totalHeight = 95.0; // Initial height

    for (var product in widget.order.products) {
      double productHeight = calculateProductHeight(product);
      totalHeight += productHeight;
    }

    setState(() {
      _expandedContainerHeight = totalHeight;
    });
  }

  double calculateProductHeight(CartItem product) {
    // Calculate and return height for each product's content
    return 80.0; // Example value, adjust based on your content
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _expandedContainerHeight,
      curve: Curves.easeIn,
      child: Card(
        margin: const EdgeInsets.all(10),
        child: Column(
          children: [
            ListTile(
              title: Text(
                "${widget.order.amount.toStringAsFixed(0).toPersianDigit().seRagham()} تومان",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              subtitle: Text(
                widget.order.dateTime.toPersianDate(
                  twoDigits: true,
                  showTime: true,
                  changeDirectionShowTimw: true,
                  timeSeprator: '  -  ',
                ),
              ),
              trailing: IconButton(
                icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
                onPressed: _toggleExpand,
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeIn,
              height: _isExpanded ? _expandedContainerHeight - 95.0 : 0,
              child: ListView.builder(
                itemBuilder: (context, index) {
                  final product = widget.order.products[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "قیمت: ${product.price.toStringAsFixed(0).toPersianDigit().seRagham()} تومان",
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "تعداد: ${product.quantity.toString().toPersianDigit()}",
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        const Divider(),
                      ],
                    ),
                  );
                },
                itemCount: widget.order.products.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
