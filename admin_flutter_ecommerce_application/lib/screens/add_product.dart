import 'dart:io';

import 'package:admin_flutter_ecommerce_application/db/product.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../db/brand.dart';
import '../db/category.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AddProduct extends StatefulWidget {
  @override
  _AddProductState createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  CategoryService _categoryService = CategoryService();
  BrandService _brandService = BrandService();
  ProductService _productService = ProductService();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController productNameController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  List<DocumentSnapshot> brands = <DocumentSnapshot>[];
  List<DocumentSnapshot> categories = <DocumentSnapshot>[];
  List<DropdownMenuItem<String>> categoriesDropDown =
      <DropdownMenuItem<String>>[];
  List<DropdownMenuItem<String>> brandsDropDown = <DropdownMenuItem<String>>[];
  String _currentCategory;
  String _currentBrand;
  Color white = Colors.white;
  Color black = Colors.white;
  Color grey = Colors.white;
  Color red = Colors.red;
  List<String> selectedSizes = <String>[];
  File _image1;
  File _image2;
  File _image3;
  bool isLoading = false;
  @override
  void initState() {
    _getCategories();
    _getBrands();

    // _currentCategory = categoriesDropDown[0].value;
  }

  List<DropdownMenuItem<String>> getCategoriesDropdown() {
    List<DropdownMenuItem<String>> items = List();
    for (int i = 0; i < categories.length; i++) {
      setState(() {
        items.insert(
            0,
            DropdownMenuItem(
                child: Text(categories[i].data['category']),
                value: categories[i]['category']));
      });
    }
    return items;
  }

  List<DropdownMenuItem<String>> getBrandsDropdown() {
    List<DropdownMenuItem<String>> items = List();
    for (int i = 0; i < brands.length; i++) {
      setState(() {
        items.insert(
            0,
            DropdownMenuItem(
                child: Text(brands[i].data['brand']),
                value: brands[i]['brand']));
      });
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          elevation: 0.0,
          backgroundColor: white,
          leading: Icon(
            Icons.close,
            color: black,
          ),
          title: Text("add product", style: TextStyle(color: Colors.black))),
      body: Form(
        key: _formKey,
        child: isLoading ? CircularProgressIndicator() : ListView(children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: OutlineButton(
                      borderSide: BorderSide(color: black, width: 2.5),
                      onPressed: () {
                        _selectedImage(
                            ImagePicker.pickImage(source: ImageSource.gallery),
                            1);
                      },
                      child: _displayChild1()),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: OutlineButton(
                      borderSide:
                          BorderSide(color: grey.withOpacity(0.5), width: 2.5),
                      onPressed: () {
                        _selectedImage(
                            ImagePicker.pickImage(source: ImageSource.gallery),
                            2);
                      },
                      child: _displayChild2()),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: OutlineButton(
                      borderSide:
                          BorderSide(color: grey.withOpacity(0.5), width: 2.5),
                      onPressed: () {
                        _selectedImage(
                            ImagePicker.pickImage(source: ImageSource.gallery),
                            3);
                      },
                      child: _displayChild3()),
                ),
              ),
            ],
          ),
          Text(
            "Enter a product name with 10 characters at maximum",
            textAlign: TextAlign.center,
            style: TextStyle(color: red, fontSize: 12),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextFormField(
              controller: productNameController,
              decoration: InputDecoration(
                hintText: "Product name",
              ),
              validator: (value) {
                if (value.isEmpty) {
                  return "You must enter the product name";
                } else if (value.length > 10) {
                  return "Product name can't have more than 10 letters";
                }
              },
            ),
          ),

          //select category
          Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Category: ', style: TextStyle(color: red)),
              ),
              DropdownButton(
                  items: categoriesDropDown,
                  onChanged: changeSelectedCategory,
                  value: _currentCategory),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Brand: ', style: TextStyle(color: red)),
              ),
              DropdownButton(
                  items: brandsDropDown,
                  onChanged: changeSelectedBrand,
                  value: _currentBrand),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextFormField(
              controller: quantityController,
              initialValue: "1",
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Quantity",
              ),
              validator: (value) {
                if (value.isEmpty) {
                  return "You must enter a quantity";
                }
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextFormField(
              controller: priceController,
              initialValue: "0.00",
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Price",
              ),
              validator: (value) {
                if (value.isEmpty) {
                  return "You must enter a price";
                }
              },
            ),
          ),

          Text(
            "Available Sizes",
            textAlign: TextAlign.center,
          ),

          Row(
            children: <Widget>[
              Checkbox(
                  value: selectedSizes.contains('S'),
                  onChanged: (value) => changeSelectedSize('S')),
              Text("S"),
              Checkbox(
                  value: selectedSizes.contains('M'),
                  onChanged: (value) => changeSelectedSize('M')),
              Text("M"),
              Checkbox(
                  value: selectedSizes.contains('L'),
                  onChanged: (value) => changeSelectedSize('L')),
              Text("L"),
              Checkbox(
                  value: selectedSizes.contains('XL'),
                  onChanged: (value) => changeSelectedSize('XL')),
              Text("XL"),
              Checkbox(
                  value: selectedSizes.contains('XXL'),
                  onChanged: (value) => changeSelectedSize('XXL')),
              Text("XXL"),
            ],
          ),

          Row(
            children: <Widget>[
              Checkbox(
                  value: selectedSizes.contains('26'),
                  onChanged: (value) => changeSelectedSize('26')),
              Text("26"),
              Checkbox(
                  value: selectedSizes.contains('28'),
                  onChanged: (value) => changeSelectedSize('28')),
              Text("28"),
              Checkbox(
                  value: selectedSizes.contains('30'),
                  onChanged: (value) => changeSelectedSize('30')),
              Text("30"),
              Checkbox(
                  value: selectedSizes.contains('32'),
                  onChanged: (value) => changeSelectedSize('32')),
              Text("32"),
              Checkbox(
                  value: selectedSizes.contains('34'),
                  onChanged: (value) => changeSelectedSize('34')),
              Text("34"),
            ],
          ),

          Row(
            children: <Widget>[
              Checkbox(
                  value: selectedSizes.contains('36'),
                  onChanged: (value) => changeSelectedSize('36')),
              Text("36"),
              Checkbox(
                  value: selectedSizes.contains('38'),
                  onChanged: (value) => changeSelectedSize('38')),
              Text("38"),
              Checkbox(
                  value: selectedSizes.contains('40'),
                  onChanged: (value) => changeSelectedSize('40')),
              Text("40"),
              Checkbox(
                  value: selectedSizes.contains('42'),
                  onChanged: (value) => changeSelectedSize('42')),
              Text("42"),
              Checkbox(
                  value: selectedSizes.contains('44'),
                  onChanged: (value) => changeSelectedSize('44')),
              Text("44"),
            ],
          ),
          FlatButton(
            color: red,
            textColor: white,
            child: Text('add product'),
            onPressed: () {
              validateAndUpload();
            },
          )
        ]),
      ),
    );
  }

  void _getBrands() async {
    List<DocumentSnapshot> data = await _brandService.getBrands();
    setState(() {
      brands = data;
      brandsDropDown = getBrandsDropdown();
      _currentBrand = brands[0].data['brand'];
    });
  }

  void _getCategories() async {
    List<DocumentSnapshot> data = await _categoryService.getCategories();
    setState(() {
      categories = data;
      categoriesDropDown = getCategoriesDropdown();
      _currentCategory = categories[0].data['category'];
    });
  }

  changeSelectedCategory(String selectedCategory) {
    setState(() => _currentCategory = selectedCategory);
  }

  changeSelectedBrand(String selectedBrand) {
    setState(() => _currentBrand = selectedBrand);
  }

  void changeSelectedSize(String size) {
    if (selectedSizes.contains(size)) {
      setState(() {
        selectedSizes.remove(size);
      });
    } else {
      setState(() {
        selectedSizes.insert(0, size);
      });
    }
  }

  void _selectedImage(Future<File> pickImage, int imageNumber) async {
    File tempImg = await pickImage;
    switch (imageNumber) {
      case 1:
        setState(() => _image1 = tempImg);
        break;
      case 2:
        setState(() => _image2 = tempImg);
        break;
      case 3:
        setState(() => _image3 = tempImg);
        break;
    }
  }

  Widget _displayChild1() {
    if (_image1 == null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(14.0, 50.0, 14.0, 50.0),
        child: Icon(Icons.add, color: grey),
      );
    } else {
      return Image.file(_image1, fit: BoxFit.fill, width: double.infinity);
    }
  }

  Widget _displayChild2() {
    if (_image2 == null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(14.0,50.0, 14.0, 50.0),
        child: Icon(Icons.add, color: grey),
      );
    } else {
      return Image.file(_image2, fit: BoxFit.fill, width: double.infinity);
    }
  }

  Widget _displayChild3() {
    if (_image3 == null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(14.0, 50.0, 14.0, 50.0),
        child: Icon(Icons.add, color: grey),
      );
    } else {
      return Image.file(_image3, fit: BoxFit.fill, width: double.infinity);
    }
  }

  void validateAndUpload() async {
    if (_formKey.currentState.validate()) {
      setState(()=> isLoading = true);
      if (_image1 != null && _image2 != null && _image3 != null) {
        if (selectedSizes.isNotEmpty) {
          String imageUrl1;
          String imageUrl2;
          String imageUrl3;
          final FirebaseStorage storage = FirebaseStorage.instance;
          final String picture1 =
              "1${DateTime.now().millisecondsSinceEpoch.toString()}.jpg";
          StorageUploadTask task1 =
              storage.ref().child(picture1).putFile(_image1);

          final String picture2 =
              "2${DateTime.now().millisecondsSinceEpoch.toString()}.jpg";
          StorageUploadTask task2 =
              storage.ref().child(picture1).putFile(_image2);

          final String picture3 =
              "3${DateTime.now().millisecondsSinceEpoch.toString()}.jpg";
          StorageUploadTask task3 =
              storage.ref().child(picture1).putFile(_image3);
          StorageTaskSnapshot snapshot1 =
              await task1.onComplete.then((snapshot) => snapshot);
          StorageTaskSnapshot snapshot2 =
              await task2.onComplete.then((snapshot) => snapshot);

          task3.onComplete.then((snapshot3) async {
            imageUrl1 = await snapshot1.ref.getDownloadURL();
            imageUrl2 = await snapshot2.ref.getDownloadURL();
            imageUrl3 = await snapshot3.ref.getDownloadURL();
            List<String> imageList = [imageUrl1,imageUrl2,imageUrl3];
            _productService.uploadProduct(
              productName: productNameController.text,
              price: double.parse(priceController.text),
              sizes: selectedSizes,
              images: imageList,
              quantity: int.parse(quantityController.text)
              );
              _formKey.currentState.reset();
            
              Fluttertoast.showToast(msg: "Product added");
              Navigator.pop(context);
            
          });
        } else {
          setState(()=> isLoading = true);
          Fluttertoast.showToast(msg: " Please select at least one size");
        }
      } else {
        setState(()=> isLoading = true);
        Fluttertoast.showToast(msg: "All the images must be provided");
      }
    }
  }
}



