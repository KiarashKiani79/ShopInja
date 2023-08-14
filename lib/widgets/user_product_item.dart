import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/edit_product_screen.dart';
import '../providers/products.dart';
import 'package:persian_number_utility/persian_number_utility.dart';

class UserProductItem extends StatelessWidget {
  final String id;
  final String title;
  final String imageUrl;
  final double price;

  const UserProductItem({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.price,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    return Dismissible(
      key: Key(id), // Unique key for each item
      direction: DismissDirection.horizontal, // Allow horizontal swiping
      secondaryBackground: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 5,
          vertical: 4,
        ),
        color: Colors.red, // Background color for delete action
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 30,
        ),
      ),
      background: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 5,
          vertical: 4,
        ),
        color: Colors.blue, // Background color for edit action
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.edit,
          color: Colors.white,
          size: 30,
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          // User swiped from right to left (delete action)
          final confirmDelete = await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('حذف محصول'),
              content:
                  const Text('آیا مطمئن هستید که می‌خواهید محصول را حذف کنید؟'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop(false); // Cancel
                  },
                  child: const Text(
                    'انصراف',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop(true); // Confirm delete
                  },
                  child: const Text(
                    'حذف',
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          );
          return confirmDelete ?? false;
        } else if (direction == DismissDirection.startToEnd) {
          // User swiped from left to right (edit action)
          Navigator.of(context)
              .pushNamed(EditProductScreen.routeName, arguments: id);
        }
        return false; // Don't dismiss by default
      },
      onDismissed: (direction) async {
        if (direction == DismissDirection.endToStart) {
          // Delete action
          try {
            await Provider.of<Products>(context, listen: false)
                .deleteProduct(id);
          } catch (error) {
            scaffoldMessenger.showSnackBar(
              const SnackBar(
                content: Text(
                  "حذف محصول با مشکل مواجه شد",
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
        }
      },

      child: Card(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(200),
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
              child: Image.network(
                imageUrl,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 50),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "${price.toStringAsFixed(0).toPersianDigit().seRagham()} تومان",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            )
          ],
        ),
        // child: ListTile(
        //   leading: ClipRRect(
        //     borderRadius: BorderRadius.circular(8),
        //     child: Image.network(
        //       imageUrl,
        //       // width: 50,
        //       // height: 50,
        //       fit: BoxFit.cover,
        //     ),
        //   ),
        //   title: Text(title),
        //   trailing: Text(
        //       "${price.toStringAsFixed(0).toPersianDigit().seRagham()} تومان"),

        // ),
      ),
    );
  }
}
