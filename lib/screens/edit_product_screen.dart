// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/appbar.dart';
import '../providers/product.dart';
import '../providers/products.dart';

class EditProductScreen extends StatefulWidget {
  const EditProductScreen({super.key});
  static const routeName = "/edit_product";

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  String snackBarText = '';

  Product _editedProduct =
      Product(description: '', id: '', imageUrl: '', price: 0.0, title: '');

  String? _editedTitle;
  double? _editedPrice;
  String? _editedDescription;
  String? _editedImageUrl;
  bool _isFavorite = false;

  var _isInit = true;
  var _isLoading = false;

  var _initValue = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': '',
  };

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImage);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final productId = ModalRoute.of(context)?.settings.arguments as String?;
      if (productId != null) {
        _editedProduct =
            Provider.of<Products>(context, listen: false).findById(productId);
        _initValue = {
          'title': _editedProduct.title,
          'description': _editedProduct.description,
          'price': _editedProduct.price.toString(),
          'imageUrl': '',
        };
        _imageUrlController.text = _editedProduct.imageUrl;
        _isFavorite =
            _editedProduct.isFavorite; // Initialize the favorite state
      } else {
        // New product creation scenario, set initial values to empty strings
        _initValue = {
          'title': '',
          'description': '',
          'price': '',
          'imageUrl': '',
        };
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImage);
    _imageUrlController.dispose();
    super.dispose();
  }

  // Update the image dynamically
  void _updateImage() {
    if (!_imageUrlFocusNode.hasFocus) {
      if ((!_imageUrlController.text.startsWith("http") &&
              !_imageUrlController.text.startsWith("https")) ||
          (!_imageUrlController.text.endsWith('.png') &&
              !_imageUrlController.text.endsWith('.jpg') &&
              !_imageUrlController.text.endsWith('jpeg'))) {
        return;
      }
      setState(() {});
    }
    setState(() {
      // Empty setState just to trigger the rebuild
    });
  }

  void _showStatusSnackbar(String task) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: Colors.green,
          ),
          const SizedBox(width: 8),
          Text(
            'محصول با موفقیت $task شد.',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      duration: const Duration(seconds: 2),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // SAVE FORM
  Future<void> _saveForm() async {
    final isValid = _form.currentState?.validate();
    if (!isValid!) {
      return;
    }

    _form.currentState?.save();

    final updatedProduct = Product(
      id: _editedProduct.id,
      title: _editedTitle ?? _editedProduct.title,
      description: _editedDescription ?? _editedProduct.description,
      price: _editedPrice ?? _editedProduct.price,
      imageUrl: _editedImageUrl ?? _editedProduct.imageUrl,
      isFavorite: _isFavorite,
    );

    setState(() {
      _isLoading = true;
    });

    try {
      if (_editedProduct.id != '') {
        await Provider.of<Products>(context, listen: false)
            .updateProduct(_editedProduct.id, updatedProduct);
        snackBarText = 'ویرایش';
      } else {
        // if (kDebugMode) {
        //   print('_editedProduct.id: ${_editedProduct.id}');
        // }
        // if (kDebugMode) {
        //   print('_editedProduct.title: ${_editedProduct.title}');
        // }

        await Provider.of<Products>(context, listen: false)
            .addProduct(updatedProduct);
        snackBarText = 'ذخیره';
      }

      setState(() {
        _isLoading = false;
      });

      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
    } catch (error) {
      setState(() {
        _isLoading = false;
      });

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("خطا !"),
          content: const Text(
            "مشکلی در افزودن سفارش به وجود آمده است.",
          ),
          actions: [
            TextButton(
              child: const Text("متوجه شدم"),
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    }
    _showStatusSnackbar(snackBarText);
  }

  @override
  Widget build(BuildContext context) {
    final appBarHeight = AppBar().preferredSize.height;
    final deviceHeight = MediaQuery.of(context).size.height;
    final backgroundImageHeight = deviceHeight - appBarHeight;
    return Scaffold(
      appBar: AppBar(
        title: const Text("محصول جدید"),
        systemOverlayStyle: AppBarContainer.customStatusBarStyle,
        backgroundColor:
            Colors.transparent, // Set the background to transparent
        flexibleSpace: const Center(
          child: AppBarContainer(),
        ),
        actions: [
          IconButton(
            onPressed: _saveForm,
            icon: const Icon(Icons.save_alt),
          )
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Container(
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
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _form,
                      child: ListView(
                        children: [
                          TextFormField(
                            initialValue: _initValue['title'],
                            decoration: const InputDecoration(
                              labelText: "نام محصول",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(15),
                                ),
                              ),
                            ),
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "لطفا نام محصول را وارد کنید.";
                              }
                              return null;
                            },
                            onSaved: (newValue) {
                              _editedTitle = newValue;
                            },
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          TextFormField(
                            initialValue: _initValue['price'],
                            decoration: const InputDecoration(
                              labelText: "قیمت",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(15),
                                ),
                              ),
                            ),
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "لطفا قیمت محصول را وارد کنید.";
                              }
                              if (double.tryParse(value) == null) {
                                return "لطفا عدد وارد کنید.";
                              }
                              if (double.parse(value) <= 0) {
                                return "لطفا عدد بزرگتر از صفر وارد کنید.";
                              }
                              return null;
                            },
                            onSaved: (newValue) {
                              _editedPrice = double.tryParse(newValue!) ?? 0.0;
                            },
                          ),
                          const SizedBox(height: 15),
                          TextFormField(
                            initialValue: _initValue['description'],
                            decoration: const InputDecoration(
                              labelText: "توضیحات",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(15),
                                ),
                              ),
                            ),
                            maxLines: 3,
                            keyboardType: TextInputType.multiline,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "لطفا توضیحات محصول را وارد کنید.";
                              }
                              if (value.length < 10) {
                                return "لطفا توضیحات محصول را بیشتر از 10 کاراکتر وارد کنید.";
                              }
                              return null;
                            },
                            onSaved: (newValue) {
                              _editedDescription = newValue;
                            },
                          ),
                          const SizedBox(height: 15),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                margin: const EdgeInsets.only(top: 8, left: 10),
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(width: 1, color: Colors.grey),
                                ),
                                child: _imageUrlController.text.isEmpty
                                    ? const Text("آدرس تصویر وارد نشده")
                                    : FittedBox(
                                        fit: BoxFit.cover,
                                        child: Image.network(
                                            _imageUrlController.text),
                                      ),
                              ),
                              Expanded(
                                child: TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: "آدرس تصویر",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(15),
                                      ),
                                    ),
                                  ),
                                  keyboardType: TextInputType.url,
                                  textInputAction: TextInputAction.done,
                                  controller: _imageUrlController,
                                  focusNode: _imageUrlFocusNode,
                                  onFieldSubmitted: (_) => _updateImage(),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return "لطفا آدرس تصویر را وارد کنید.";
                                    }
                                    if (!value.startsWith("http") &&
                                        !value.startsWith("https")) {
                                      return "لطفا آدرس تصویر معتبر وارد کنید.";
                                    }
                                    // if (!value.endsWith('.png') &&
                                    //     !value.endsWith('.jpg') &&
                                    //     !value.endsWith('jpeg')) {
                                    //   return "لطفا آدرس تصویر معتبر وارد کنید.";
                                    // }
                                    return null;
                                  },
                                  onSaved: (newValue) {
                                    _editedImageUrl = newValue;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
