import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/product_service.dart';
import 'package:flutter_application_1/widgets/button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../constants/labels.dart';
import '../models/product_data_model.dart';
import '../services/navigation.dart';

class Product extends StatefulWidget {
  const Product({super.key});

  @override
  State<Product> createState() => _ProductState();
}

class _ProductState extends State<Product> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isEditing = false;
  final TextEditingController idController = TextEditingController();
  final TextEditingController userIDController = TextEditingController();
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController imageLinkController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  ProductDataModel? productData;
  String? token;
  String? productID;
  List<bool> dropdownItems = [true, false];
  bool isPublished = false;
  Map<String, dynamic>? data = {};
  bool success = false;
  String? errorMessage;
  String appbarTitle = Label.singleProduct;
  bool urlIsValid = false;

  void initData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString("token");
    productID = prefs.getString("productID");
    productData = (await ProductService(context)
        .getProduct(token: token!, productID: productID!));
    idController.text = productData?.id.toString() ?? "";
    userIDController.text = productData?.userId.toString() ?? "";
    productNameController.text = productData?.name ?? "";
    imageLinkController.text = productData?.imageLink ?? "";
    descriptionController.text = productData?.description ?? "";
    priceController.text = productData?.price ?? "";
    isPublished = publishStatus(productData?.isPublished ?? 0);
    setState(() {});
  }

  void getEditData() async {
    data = await ProductService(context).editProduct(
      token: token!,
      productID: productID!,
      name: productNameController.text,
      imageLink: imageLinkController.text,
      description: descriptionController.text,
      price: priceController.text,
      isPublished: isPublished,
    );
    setState(() {
      if (data!.containsKey("errors")) {
        success = false;
        errorMessage = data?["message"];
      } else {
        success = true;
      }
    });
  }

  bool publishStatus(int isPublished) {
    if (isPublished == 1) {
      return true;
    }
    return false;
  }

  void onPressed() {
    if (!isEditing) {
      isEditing = true;
      appbarTitle = Label.editProduct;
    } else {
      isEditing = false;
      appbarTitle = Label.singleProduct;
      getEditData();

      Future.delayed(const Duration(seconds: 2)).then((value) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text(Label.editSuccessful)));
        } else {
          errorMessage != null
              ? ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(errorMessage!)))
              : null;
        }
      });
    }
    setState(() {});
  }

  void checkUrlValidity(String url) async {
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        urlIsValid = true;
      }
    } on SocketException {
      urlIsValid = false;
    }

    urlIsValid = false;
  }

  String getUrl(String url) {
    checkUrlValidity(url);
    if (urlIsValid) {
      return url;
    }
    return "https://cdn-icons-png.flaticon.com/512/71/71768.png";
  }

  @override
  void initState() {
    initData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.indigo[600],
          title: Text(appbarTitle),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigation(context).backToHome();
            },
          ),
        ),
        body: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.disabled,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 50.0, vertical: 30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      CircleAvatar(
                        radius: 40.0,
                        backgroundColor: Colors.indigo[600],
                        backgroundImage: productData?.imageLink != null
                            ? NetworkImage(productData!.imageLink)
                            : null,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Text(Label.createdAt),
                          Text(productData?.createdAt.toIso8601String() ?? ""),
                          const Text(Label.updatedAt),
                          Text(productData?.updatedAt.toIso8601String() ?? ""),
                        ],
                      ),
                    ],
                  ),
                  SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                                flex: 1,
                                child: TextFormField(
                                  enabled: false,
                                  controller: idController,
                                  onSaved: (value) {},
                                  decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: Label.id),
                                )),
                            const SizedBox(width: 10.0),
                            Expanded(
                                flex: 1,
                                child: TextFormField(
                                  enabled: false,
                                  controller: userIDController,
                                  onSaved: (value) {},
                                  decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: Label.userID),
                                )),
                          ],
                        ),
                        const SizedBox(height: 20.0),
                        TextFormField(
                          enabled: isEditing,
                          controller: productNameController,
                          onSaved: (value) {},
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: Label.productName),
                        ),
                        const SizedBox(height: 20.0),
                        TextFormField(
                          enabled: isEditing,
                          controller: imageLinkController,
                          onSaved: (value) {},
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: Label.imageLink),
                        ),
                        const SizedBox(height: 20.0),
                        TextFormField(
                          enabled: isEditing,
                          controller: descriptionController,
                          onSaved: (value) {},
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: Label.description),
                        ),
                        const SizedBox(height: 20.0),
                        TextFormField(
                          enabled: isEditing,
                          controller: priceController,
                          keyboardType: TextInputType.number,
                          onSaved: (value) {},
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: Label.price),
                        ),
                        const SizedBox(height: 20.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<bool>(
                                value: isPublished,
                                decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: Label.published),
                                items: dropdownItems
                                    .map((item) => DropdownMenuItem<bool>(
                                          value: item,
                                          child: Text(item.toString()),
                                        ))
                                    .toList(),
                                onChanged: isEditing
                                    ? (item) =>
                                        setState(() => isPublished = item!)
                                    : null,
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                  MainButton(
                    onPressed: onPressed,
                    buttonLabel: isEditing ? Label.save : Label.edit,
                  ),
                ],
              ),
            )),
      ),
    );
  }
}
