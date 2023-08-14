import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// HTTP
import 'dart:convert';
import 'package:http/http.dart ' as http;

import '../models/http_exception.dart';
import './cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem(
      {required this.id,
      required this.amount,
      required this.products,
      required this.dateTime});
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  final String? authToken;
  final String? userId;

  Orders(this.authToken, this.userId, this._orders);

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    final url = Uri.https(
      'shopinja-5c0d4-default-rtdb.firebaseio.com',
      '/orders/$userId.json',
      {'auth': authToken},
    );

    final response = await http.get(url);
    final List<OrderItem> loadedOrders = [];
    final extractedData = json.decode(response.body) as Map<String, dynamic>?;
    if (extractedData == null) {
      // Handle the case when the extractedData is null or not of the expected type.
      _orders = [];
      notifyListeners();
      return;
    }

    extractedData.forEach(
      (orderId, orderData) {
        loadedOrders.add(
          // <-- Add the loaded order to the list
          OrderItem(
            id: orderId,
            amount: orderData['amount'],
            dateTime: DateTime.parse(orderData['dateTime']),
            products: (orderData['products'] as List<dynamic>)
                .map(
                  (ci) => CartItem(
                    id: ci['id'],
                    title: ci['title'],
                    quantity: ci['quantity'],
                    price: ci['price'],
                  ),
                )
                .toList(),
          ),
        );
      },
    );
    _orders = loadedOrders;
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url = Uri.https(
      'shopinja-5c0d4-default-rtdb.firebaseio.com',
      '/orders/$userId.json',
      {'auth': authToken},
    );

    final timestamp = DateTime.now();
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'amount': total,
            'dateTime': timestamp.toIso8601String(),
            'products': cartProducts
                .map(
                  (cartItem) => {
                    'id': cartItem.id,
                    'title': cartItem.title,
                    'quantity': cartItem.quantity,
                    'price': cartItem.price,
                  },
                )
                .toList(),
          },
        ),
      );
      _orders.insert(
        0,
        OrderItem(
          id: json.decode(response.body)['name'],
          amount: total,
          dateTime: timestamp,
          products: cartProducts,
        ),
      );
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> deleteAll() async {
    final url = Uri.https(
      'shopinja-5c0d4-default-rtdb.firebaseio.com',
      '/orders/$userId.json',
      {'auth': authToken},
    );
    // final url =
    //     Uri.https('shopinja-5c0d4-default-rtdb.firebaseio.com', '/orders.json');

    // Make a copy of _orders to a temp list
    var oldOrders = _orders;

    _orders = [];
    notifyListeners();

    final response = await http.delete(url);

    if (response.statusCode != 200) {
      // If the deletion was not successful, revert back to the old orders
      _orders = oldOrders;
      notifyListeners();
      throw HttpException('عملیات حذف با مشکل مواجه شد !');
    }

    // If the deletion was successful, remove the old orders
    oldOrders = [];
  }
}
