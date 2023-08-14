import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/http_exception.dart';
import 'product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [];

  final String? authToken;
  final String? userId;

  Products(this.authToken, this.userId, this._items);

  List<Product> get items {
    return [..._items];
  }

  List<Product>? get favoriteItems {
    final favoriteList = _items.where((product) => product.isFavorite).toList();
    return favoriteList.isNotEmpty ? favoriteList : null;
  }

// FETCH

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    var url = Uri.https(
      'shopinja-5c0d4-default-rtdb.firebaseio.com',
      '/products.json',
      {
        'auth': authToken,
        ...filterByUser
            ? {'orderBy': '"creatorId"', 'equalTo': '"$userId"'}
            : {}
      },
    );

    try {
      final response = await http.get(url);

      final extractedData = json.decode(response.body);
      if (extractedData == null || extractedData is! Map<String, dynamic>) {
        // Handle the case when extractedData is not valid or empty.
        _items = [];
        notifyListeners();
        return;
      }

      url = Uri.https(
        'shopinja-5c0d4-default-rtdb.firebaseio.com',
        '/userFavorites/$userId.json',
        {'auth': authToken},
      );

      final favoriteResponse = await http.get(url);
      var favoriteData = json.decode(favoriteResponse.body);
      if (favoriteData == null || favoriteData is! Map<String, dynamic>) {
        // Handle the case when favoriteData is not valid or empty.
        favoriteData = {};
      }

      final List<Product> loadedProducts = [];

      extractedData.forEach(
        (prodId, prodData) {
          loadedProducts.add(
            Product(
              description: prodData['description'],
              id: prodId,
              imageUrl: prodData['imageUrl'],
              price: prodData['price'],
              title: prodData['title'],
              isFavorite:
                  favoriteData == null ? false : favoriteData[prodId] ?? false,
            ),
          );
        },
      );
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  // Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
  //   // Correct format for the URL
  //   var url = Uri.https(
  //     'shopinja-5c0d4-default-rtdb.firebaseio.com',
  //     '/products.json',
  //     {
  //       'auth': authToken,
  //       ...filterByUser
  //           ? {'orderBy': '"creatorId"', 'equalTo': '"$userId"'}
  //           : {}
  //     },
  //   );

  //   try {
  //     final response = await http.get(url);

  //     final extractedData = json.decode(response.body) as Map<String, dynamic>?;

  //     if (extractedData == null) {
  //       // Handle the case when the extractedData is null or not of the expected type.
  //       _items = [];
  //       notifyListeners();
  //       return;
  //     }

  //     url = Uri.https(
  //       'shopinja-5c0d4-default-rtdb.firebaseio.com',
  //       '/userFavorites/$userId.json',
  //       {'auth': authToken},
  //     );

  //     final favoriteResponse = await http.get(url);
  //     final favoriteData = json.decode(favoriteResponse.body);

  //     final List<Product> loadedProducts = [];

  //     extractedData.forEach(
  //       (prodId, prodData) {
  //         loadedProducts.add(
  //           Product(
  //             description: prodData['description'],
  //             id: prodId,
  //             imageUrl: prodData['imageUrl'],
  //             price: prodData['price'],
  //             title: prodData['title'],
  //             isFavorite:
  //                 favoriteData == null ? false : favoriteData[prodId] ?? false,
  //           ),
  //         );
  //       },
  //     );
  //     _items = loadedProducts;
  //     notifyListeners();
  //   } catch (error) {
  //     rethrow;
  //   }
  // }

// ADD

  Future<void> addProduct(Product product) async {
    final url = Uri.https(
      'shopinja-5c0d4-default-rtdb.firebaseio.com',
      '/products.json',
      {'auth': authToken},
    );

    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'title': product.title,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'price': product.price,
            'creatorId': userId,
          },
        ),
      );

      final newProduct = Product(
        description: product.description,
        imageUrl: product.imageUrl,
        id: json.decode(response.body)['name'],
        price: product.price,
        title: product.title,
      );

      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

// UPDATE

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((element) => element.id == id);
    if (prodIndex >= 0) {
      final url = Uri.https(
        'shopinja-5c0d4-default-rtdb.firebaseio.com',
        '/products/$id.json',
        {'auth': authToken},
      );

      try {
        await http.patch(
          url,
          body: json.encode(
            {
              'title': newProduct.title,
              'description': newProduct.description,
              'imageUrl': newProduct.imageUrl,
              'price': newProduct.price,
            },
          ),
        );
      } catch (_) {
        rethrow;
      }
      _items[prodIndex] = newProduct;
      notifyListeners();
    }
  }

// DELETE

  Future<void> deleteProduct(String? id) async {
    final url = Uri.https(
      'shopinja-5c0d4-default-rtdb.firebaseio.com',
      '/products/$id.json',
      {'auth': authToken},
    );

    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    Product? existingProduct = _items[existingProductIndex];
    // _items.removeAt(existingProductIndex);
    _items.removeWhere((prod) => prod.id == id);
    notifyListeners();

    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('عملیات حذف با مشکل مواجه شد !');
    }
    existingProduct = null;
  }

  Product findById(String productId) {
    return _items.firstWhere((product) => product.id == productId);
  }
}
