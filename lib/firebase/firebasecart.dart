import 'package:ecomerce_app/firebase/firebase_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../login_signup/sigin_page.dart';
import 'firebasecart.dart';

void addToCart(
  String tittle,
  double price,
  List productdetails,
  BuildContext context,
) {
  // List ProductDetails = productdetails;
  User? user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: Duration(seconds: 2),
        content: Text('Please login to add to cart'),
        action: SnackBarAction(
          label: 'Login',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SignInPage()),
            );
          },
        ),
      ),
    );
    return;
  } else {
    FirebaseService().addToCart(tittle, price);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.orange[500],
        content: Text(
          'Item added to cart successfully',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
