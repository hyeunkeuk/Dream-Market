import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping/widgets/auth/pickers/product_image.dart';
// import 'package:path/path.dart' as path;
// import 'package:path_provider/path_provider.dart' as syspaths;
import '../providers/product.dart';
import '../providers/products.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// import '../widgets/image_input.dart';
import 'dart:io';

// import 'package:image_picker/image_picker.dart';
// import '../widgets/pickers/user_image_picker.dart';

//called from user product item for edit
//called from user product screen for add
class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit_product_screen';
  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  var pageTitle;
  var user = FirebaseAuth.instance.currentUser;
  var products = FirebaseFirestore.instance.collection('products');
  final CollectionReference productsList =
      FirebaseFirestore.instance.collection('products');
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  List<File> _productImageList;
  final _form = GlobalKey<FormState>();
  bool showDone = false;

  var _editedProduct = Product(
    id: null,
    title: '',
    price: 0.0,
    description: '',
    imageUrl: [],
    category: '',
    location: '',
    status: 'Available',
  );
  var _initValues = {
    'title': '',
    'description': '',
    'price': 0.0,
    'image': [],
    'category': '',
    'location': '',
    'status': 'Available',
  };

  var _isInit = true;
  var _isLoading = false;
  var fetchedProductData;

  //Dropdown button parameters
  var categoryItems = [
    'Baby',
    'Beauty',
    'Clothes',
    'Electronics',
    'Foods',
    'Furnitures',
    'Others'
  ];

  var locationItems = [
    'Burnaby',
    'Coquitlam',
    'Delta',
    'Langley',
    'Maple Ridge',
    'New Westminster',
    'North Vancouver',
    'Pitt Meadows',
    'Port Coquitlam',
    'Port Moody',
    'Richmond',
    'Surrey',
    'Vancouver',
    'White Rock',
  ];

  String categoryDropdownvalue;
  String locationDropdownvalue;

  var userStatus;

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      fetchDatabaseList();
    }

    _isInit = false;
    super.didChangeDependencies();
  }

  Future<void> getUserData() async {
    _isLoading = true;

    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    setState(() {
      userStatus = userData['status'];
    });
    _isLoading = false;
  }

  fetchDatabaseList() async {
    _isLoading = true;

    dynamic resultant = await fetchProductData();

    if (resultant == null) {
      print('Unable to retrieve');
      setState(() {
        _isLoading = false;
      });
    } else {
      List<String> imageUrlList = [];

      for (int i = 0; i < resultant['imageUrl'].length; i++) {
        imageUrlList.add(resultant['imageUrl'][i].toString());
      }
      _editedProduct = Product(
        id: resultant.id,
        title: resultant['title'],
        description: resultant['description'],
        price: resultant['price'].toDouble(),
        imageUrl: imageUrlList,
        category: resultant['category'],
        location: resultant['location'],
        status: resultant['status'],
      );

      _initValues = {
        'title': _editedProduct.title,
        'description': _editedProduct.description,
        'price': _editedProduct.price,
        'imageUrl': _editedProduct.imageUrl,
        'category': _editedProduct.category,
        'location': _editedProduct.location,
        'status': _editedProduct.status,
      };
      categoryDropdownvalue = _editedProduct.category;
      locationDropdownvalue = _editedProduct.location;
      // _imageUrlController.text = _editedProduct.image;

      setState(() {
        fetchedProductData = resultant;
        _isLoading = false;
      });
    }
  }

  Future fetchProductData() async {
    _isLoading = true;

    final productData =
        ModalRoute.of(context).settings.arguments as List<Object>;
    if (productData != null) {
      pageTitle = "Edit";
      var productId = productData[0];
      try {
        return await productsList.doc(productId).get();
      } catch (error) {
        print('im in edit product screen' + error.toString());
        return null;
      }
    } else {
      pageTitle = "Add";
      return null;
    }
  }

  void dispose() {
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();

    super.dispose();
  }

  void _pickedImage(List<File> image) async {
    _productImageList = image;
  }

  void _updateCategory(String category) {
    categoryDropdownvalue = category;
  }

  void _updateLocation(String location) {
    locationDropdownvalue = location;
  }

  List<String> urlList = [];

  Future<void> getUrlList(String productId) async {
    urlList = [];
    for (var i = 0; i < _productImageList.length; i++) {
      final ref = FirebaseStorage.instance
          .ref()
          .child('product_image/${productId}')
          .child(i.toString() + '.jpg');
      await ref.putFile(_productImageList[i]).whenComplete(() async {
        await ref.getDownloadURL().then((urlValue) async {
          urlList.add(urlValue);
        });
      });
    }
  }

  Future<void> _saveForm() async {
    final isValid = _form.currentState.validate();
    if (!isValid) {
      print('Save form state is not valid');
      return;
    }

    if (categoryDropdownvalue == null) {
      await showDialog<Null>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('An error occured!'),
          content: Text('Please specify the categroy'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: Text('Okay'),
            ),
          ],
        ),
      );
      return;
    }
    if (locationDropdownvalue == null) {
      await showDialog<Null>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('An error occured!'),
          content: Text('Please specify the location'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: Text('Okay'),
            ),
          ],
        ),
      );
      return;
    }
    if (_productImageList == null || _productImageList.isEmpty) {
      await showDialog<Null>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('An error occured!'),
          content: Text('Please pick an image'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: Text('Okay'),
            ),
          ],
        ),
      );
      return;
    }
    _editedProduct = Product(
      id: _editedProduct.id,
      isFavorite: _editedProduct.isFavorite,
      title: _editedProduct.title,
      description: _editedProduct.description,
      price: _editedProduct.price,
      imageUrl: [],
      category: categoryDropdownvalue,
      location: locationDropdownvalue,
      status: _editedProduct.status,
    );
    _form.currentState.save();
    setState(() {
      _isLoading = true;
    });
    int index = -1;

    if (_productImageList != null && _productImageList.isNotEmpty) {
      try {
        await getUrlList(_editedProduct.id).whenComplete(() async {
          _editedProduct = Product(
            id: _editedProduct.id,
            isFavorite: _editedProduct.isFavorite,
            title: _editedProduct.title,
            description: _editedProduct.description,
            price: _editedProduct.price,
            imageUrl: urlList,
            category: categoryDropdownvalue,
            location: locationDropdownvalue,
            status: _editedProduct.status,
          );
          if (_editedProduct.id != null) {
            Provider.of<Products>(context, listen: false).updateProduct(
              user.uid,
              _editedProduct.id,
              _editedProduct,
            );

            setState(() {
              _isLoading = false;
            });
            Navigator.of(context).pop();
          } else {
            try {
              // String collectionName = 'products';
              // if (userStatus == 'admin') {
              //   collectionName = 'dream';
              // }
              // print(collectionName);

              var creatorData = await FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .get();

              var addedProduct =
                  await FirebaseFirestore.instance.collection('products').add(
                {
                  'title': _editedProduct.title,
                  'description': _editedProduct.description,
                  'imageUrl': _editedProduct.imageUrl,
                  'price': _editedProduct.price,
                  'creatorId': user.uid,
                  'creatorName': creatorData.data()['firstName'],
                  'category': _editedProduct.category,
                  'createdAt': Timestamp.now(),
                  'location': _editedProduct.location,
                  'status': _editedProduct.status,
                  'type': userStatus == 'admin' ? 'dream' : 'market'
                },
              );

              await getUrlList(addedProduct.id).whenComplete(() async {
                _editedProduct = Product(
                  id: _editedProduct.id,
                  isFavorite: _editedProduct.isFavorite,
                  title: _editedProduct.title,
                  description: _editedProduct.description,
                  price: _editedProduct.price,
                  imageUrl: urlList,
                  category: categoryDropdownvalue,
                  location: locationDropdownvalue,
                  status: _editedProduct.status,
                );
                FirebaseFirestore.instance
                    .collection('products')
                    .doc(addedProduct.id)
                    .update(
                  {
                    'title': _editedProduct.title,
                    'description': _editedProduct.description,
                    'imageUrl': _editedProduct.imageUrl,
                    'price': _editedProduct.price,
                    'creatorId': user.uid,
                    'category': _editedProduct.category,
                    'createdAt': Timestamp.now(),
                    'location': _editedProduct.location,
                    'status': _editedProduct.status,
                  },
                );
              });
            } catch (error) {
              await showDialog<Null>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text('An error occured!'),
                  content: Text(error.toString()),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                      },
                      child: Text(
                        'Okay',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
              );
            } finally {
              setState(
                () {
                  _isLoading = false;
                },
              );
              Navigator.of(context).pop();
            }
          }
        });
      } catch (error) {
        print('There is a problem uploading image in edit product screen' +
            error.toString());
      }
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text('${pageTitle} Product'),
        actions: <Widget>[
          IconButton(
            onPressed: _isLoading ? null : _saveForm,
            icon: Icon(Icons.save),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _form,
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        initialValue: _initValues['title'],
                        decoration: InputDecoration(
                          labelText: 'Title',
                        ),
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_priceFocusNode);
                        },
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please provide a value.';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _editedProduct = Product(
                            id: _editedProduct.id,
                            isFavorite: _editedProduct.isFavorite,
                            title: value,
                            description: _editedProduct.description,
                            price: _editedProduct.price,
                            imageUrl: _editedProduct.imageUrl,
                            category: _editedProduct.category,
                            location: _editedProduct.location,
                            status: _editedProduct.status,
                          );
                        },
                      ),
                      TextFormField(
                        initialValue: _initValues['price'].toString(),
                        decoration: InputDecoration(labelText: 'Price'),
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        focusNode: _priceFocusNode,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context)
                              .requestFocus(_descriptionFocusNode);
                        },
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter a price';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please entera valid number';
                          }
                          if (double.parse(value) <= 0) {
                            return 'Please enter a number greater than zero';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _editedProduct = Product(
                            id: _editedProduct.id,
                            isFavorite: _editedProduct.isFavorite,
                            title: _editedProduct.title,
                            description: _editedProduct.description,
                            price: double.parse(value),
                            imageUrl: _editedProduct.imageUrl,
                            category: _editedProduct.category,
                            location: _editedProduct.location,
                            status: _editedProduct.status,
                          );
                        },
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            child: Text(
                              'Category',
                              style: TextStyle(
                                  fontSize: 16, color: Colors.black54),
                            ),
                            // padding: EdgeInsets.only(
                            //   right: 16.0,
                            // ),
                          ),
                          DropdownButton(
                            // menuMaxHeight: 200,
                            // alignment: AlignmentDirectional.centerStart,
                            hint: categoryDropdownvalue == null
                                ? Text('Please choose a category')
                                : Text(categoryDropdownvalue),
                            value: categoryDropdownvalue,
                            icon: const Icon(Icons.keyboard_arrow_down),
                            items: categoryItems.map((String item) {
                              if (item == 'Baby') {
                                return DropdownMenuItem<String>(
                                  value: item,
                                  child: Text('Baby & Kids'),
                                );
                              }
                              return DropdownMenuItem<String>(
                                value: item,
                                child: Text(item),
                              );
                            }).toList(),
                            onChanged: (String newvalue) {
                              setState(() {
                                _updateCategory(newvalue);

                                // dropdownvalue = newvalue;
                              });
                            },
                          ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            child: Text(
                              'Location',
                              style: TextStyle(
                                  fontSize: 16, color: Colors.black54),
                            ),
                            // padding: EdgeInsets.only(
                            //   right: 16.0,
                            // ),
                          ),
                          DropdownButton(
                            menuMaxHeight: 300,
                            // alignment: AlignmentDirectional.topStart,
                            hint: locationDropdownvalue == null
                                ? Text('Please choose a location')
                                : Text(locationDropdownvalue),
                            value: locationDropdownvalue,
                            icon: const Icon(Icons.keyboard_arrow_down),
                            items: locationItems.map((String item) {
                              return DropdownMenuItem<String>(
                                value: item,
                                child: Text(item),
                              );
                            }).toList(),
                            onChanged: (String newvalue) {
                              setState(() {
                                _updateLocation(newvalue);

                                // dropdownvalue = newvalue;
                              });
                            },
                          ),
                        ],
                      ),
                      showDone
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Color.fromARGB(255, 191, 219, 241)),
                                  onPressed: () {
                                    setState(() {
                                      showDone = false;
                                    });
                                    FocusScope.of(context)
                                        .requestFocus(new FocusNode());
                                    // FocusScopeNode currentFocus = FocusScope.of(context);
                                  },
                                  child: Text('Done'),
                                ),
                              ],
                            )
                          : SizedBox.shrink(),
                      TextFormField(
                        onTap: () {
                          setState(() {
                            showDone = true;
                          });
                        },
                        initialValue: _initValues['description'],
                        decoration: InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                        minLines: 3,
                        maxLines: 10,
                        keyboardType: TextInputType.multiline,
                        focusNode: _descriptionFocusNode,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter a description';
                          }
                          // if (value.length < 10) {
                          //   return 'Please enter longer description';
                          // }
                          return null;
                        },
                        onSaved: (value) {
                          _editedProduct = Product(
                            id: _editedProduct.id,
                            isFavorite: _editedProduct.isFavorite,
                            title: _editedProduct.title,
                            description: value,
                            price: _editedProduct.price,
                            imageUrl: _editedProduct.imageUrl,
                            category: _editedProduct.category,
                            location: _editedProduct.location,
                            status: _editedProduct.status,
                          );
                        },
                      ),
                      ProductImagePicker(_pickedImage, _editedProduct.imageUrl),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
