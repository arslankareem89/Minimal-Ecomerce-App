// lib/pages/signup_page.dart
import 'package:ecomerce_app/login_signup/sigin_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../firebase/firebase_model.dart';
import '../pages/home_page.dart';

// Assuming you might have these, adjust imports as needed

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  String? _userName;
  String? _email;
  String? _password;
  String? _confirmPassword;

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        final user = await FirebaseService().signUp(
          email.text,
          passwordController.text,
          name.text,
        );

        if (user != null) {
          // Only navigate if sign-up was successful
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        }
      } catch (e) {
        // Show error message if sign-up fails
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  String? _validateUsername(String? value) {
    if (value!.isEmpty) {
      return "Username is required";
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Email is required";
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return "Enter a valid email";
    }
    return null; // Valid
  }

  String? _validatePassword(String? value) {
    if (value!.isEmpty) {
      return "Password is required";
    }
    if (value.length < 6) {
      return "Password must be at least 6 characters";
    }
  }

  String? _validateConfirmPassword(String? value) {
    if (value!.isEmpty) {
      return "Password is required";
    }
    if (value != passwordController.text) {
      return "Password Must be same";
    }
  }

  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text("Create Account"),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 1,
        // Kept the AppBar back button for navigation, assuming it's still desired
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate back to Sign In page
            // If you also want to control this, make this onPressed empty or remove leading
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const SignInPage()),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.blueGrey.shade200, Colors.blueGrey.shade500],
            ),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).padding.top + 20),
                Text(
                  "Create Your Account",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: Container(
                    margin: MediaQuery.of(
                      context,
                    ).padding.add(EdgeInsets.symmetric(horizontal: 20)),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      backgroundBlendMode: BlendMode.hardLight,
                      border: Border.fromBorderSide(
                        BorderSide(color: Colors.black),
                      ),
                      color: Colors.white54,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          TextFormField(
                            validator: _validateUsername,
                            controller: name,
                            onChanged: (value) {
                              _userName = value;
                            },
                            decoration: InputDecoration(
                              hintText: "Username",
                              prefixIcon: Icon(Icons.email),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  strokeAlign: BorderSide.strokeAlignOutside,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          //email textfield
                          TextFormField(
                            validator: _validateEmail,
                            onChanged: (value) {
                              _email = value;
                            },
                            controller: email,
                            decoration: InputDecoration(
                              hintText: "Email",
                              prefixIcon: Icon(Icons.email),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  strokeAlign: BorderSide.strokeAlignOutside,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          //pasword textfield
                          TextFormField(
                            obscureText: true,
                            validator: _validatePassword,
                            onChanged: (value) {
                              _password = value;
                            },
                            controller: passwordController,
                            decoration: InputDecoration(
                              hintText: "Password",
                              prefixIcon: Icon(Icons.email),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  strokeAlign: BorderSide.strokeAlignOutside,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          TextFormField(
                            obscureText: true,
                            validator: _validateConfirmPassword,
                            controller: confirmPasswordController,
                            onChanged: (value) {
                              _confirmPassword = value;
                            },
                            decoration: InputDecoration(
                              hintText: "Confirmed Password",

                              prefixIcon: Icon(Icons.email),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  strokeAlign: BorderSide.strokeAlignOutside,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          //signup button
                          ElevatedButton(
                            onPressed: _submitForm,
                            style: ElevatedButton.styleFrom(
                              maximumSize: Size(200, 50),
                              minimumSize: Size(200, 50),

                              elevation: 100,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                            ),
                            child: Text("Signup"),
                          ),
                          SizedBox(height: 20),
                          //sign up button
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SignInPage(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              maximumSize: Size(200, 50),
                              minimumSize: Size(150, 50),
                              elevation: 100,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 10),
                            ),
                            child: Text("Login"),
                          ),
                          //Sizebox
                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
