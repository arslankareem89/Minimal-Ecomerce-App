import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> signUp(String email, String password, String name) async {
    try {
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      if (userCredential.user != null) {
        await _createUserDatabase(userCredential.user!.uid, name);
      }
      return userCredential.user;
    } catch (e) {
      debugPrint('Error signing up: $e');
      return null;
    }
  }

  Future<User?> signIn(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } catch (e) {
      debugPrint('Error signing in: $e');
      return null;
    }
  }

  Future<void> SignOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint('Error signing out: $e');
    }
  }

  Future<Map<String, String>> getCurrentUserInfo() async {
    User? user = _auth.currentUser;

    if (user != null) {
      final userRef = _firestore.collection('users').doc(user.uid);
      final userData = await userRef.get();

      if (userData.exists) {
        final data = userData.data();
        return {
          'name': data?['name'] ?? '',
          'email': data?['email'] ?? '',
          'uid': user.uid,
        };
      } else {
        debugPrint('User document not found in Firestore');
      }
    }
    return {'name': '', 'email': '', 'uid': ''};
  }

  Future<void> addToCart(String itemName, double itemPrice) async {
    try {
      String userId = _auth.currentUser!.uid;

      await _firestore.collection('users').doc(userId).collection('items').add({
        'name': itemName,
        'price': itemPrice,
      });
    } catch (e) {
      debugPrint('Error adding item to cart: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getCartItems() async {
    try {
      String userId = _auth.currentUser!.uid;

      final cartSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('items')
          .get();

      List<Map<String, dynamic>> cartItems = [];

      for (var doc in cartSnapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id; // Add docId to map
        cartItems.add(data);
      }

      return cartItems;
    } catch (e) {
      debugPrint('Error getting cart items: $e');
      return [];
    }
  }

  Future<void> deleteCartItemById(String docId) async {
    try {
      String userId = _auth.currentUser!.uid;
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('items')
          .doc(docId)
          .delete();
    } catch (e) {
      debugPrint('Error deleting cart item: $e');
    }
  }

  Future<void> _createUserDatabase(String userId, String name) async {
    try {
      final email = _auth.currentUser?.email ?? '';
      await _firestore.collection('users').doc(userId).set({
        'name': name,
        'email': email,
        'uid': userId,
      });
    } catch (e) {
      debugPrint('Error creating user database: $e');
    }
  }
}
