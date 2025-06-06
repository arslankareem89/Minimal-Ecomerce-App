import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../firebase/firebase_model.dart';
import '../login_signup/sigin_page.dart';
import '../login_signup/signup_page.dart';

class Carts extends StatefulWidget {
  const Carts({super.key});

  @override
  State<Carts> createState() => _CartsState();
}

class _CartsState extends State<Carts> {
  List<Map<String, dynamic>> cartItems = [];

  Future<void> fetchCart() async {
    final cart = await FirebaseService().getCartItems();
    setState(() {
      cartItems = cart;
    });
  }

  Future<void> deleteCartItem(int index) async {
    final item = cartItems[index];
    final docId = item['id'];
    await FirebaseService().deleteCartItemById(docId);
    setState(() {
      cartItems.removeAt(index);
    });
  }

  @override
  void initState() {
    super.initState();
    fetchCart();
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: Text("Your Cart")),
      body: SafeArea(
        child: isLoggedIn
            ? cartItems.isNotEmpty
                  ? ListView.builder(
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        final item = cartItems[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: ListTile(
                            title: Text(item['name']),
                            subtitle: Text("Price: \$${item['price']}"),
                            trailing: IconButton(
                              icon: Icon(
                                FontAwesomeIcons.trashCan,
                                color: Colors.red,
                              ),
                              onPressed: () => deleteCartItem(index),
                            ),
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Text(
                        'Cart is empty',
                        style: TextStyle(fontSize: 20),
                      ),
                    )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Login to view cart', style: TextStyle(fontSize: 24)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => SignInPage()),
                        );
                      },
                      child: Text('Login'),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => SignupPage()),
                        );
                      },
                      child: Text('Sign Up'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
