// lib/forgot_password_page.dart
import 'package:ecomerce_app/widgets/textform_widget.dart'; // Ensure this path is correct
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailCtrl = TextEditingController();
  final FocusNode _emailFocus = FocusNode();

  bool _isLoading = false;
  String? _feedbackMessage;
  bool _isFeedbackError = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  void _setLoading(bool loading) {
    if (mounted) {
      setState(() => _isLoading = loading);
    }
  }

  Future<void> _sendResetLink() async {
    FocusScope.of(context).unfocus(); // Dismiss keyboard
    if (mounted) {
      setState(() {
        _feedbackMessage = null; // Clear previous message
        _isFeedbackError = false;
      });
    }

    if (!(_formKey.currentState?.validate() ?? false)) return;

    _setLoading(true);
    try {
      await _auth.sendPasswordResetEmail(email: _emailCtrl.text.trim());
      if (mounted) {
        setState(() {
          _feedbackMessage =
              "Password reset link sent to ${_emailCtrl.text.trim()}. Please check your email (and spam folder).";
          _isFeedbackError = false;
        });
        _emailCtrl.clear(); // Clear field on success
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String errorMessage = "Failed to send reset link.";
        if (e.code == 'user-not-found' || e.code == 'invalid-email') {
          errorMessage =
              "No user found for that email, or the email is invalid.";
        } else if (e.code == 'too-many-requests') {
          errorMessage = "Too many requests. Please try again later.";
        } else {
          errorMessage = e.message ?? errorMessage;
        }
        setState(() {
          _feedbackMessage = errorMessage;
          _isFeedbackError = true;
        });
      }
      debugPrint(
        "Password Reset FirebaseAuthException: ${e.code} - ${e.message}",
      );
    } catch (e, s) {
      if (mounted) {
        setState(() {
          _feedbackMessage = "An unexpected error occurred. Please try again.";
          _isFeedbackError = true;
        });
      }
      debugPrint("Generic Password Reset Error: $e\n$s");
    } finally {
      _setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text("Reset Password"),
        backgroundColor: theme.colorScheme.onSecondaryContainer,
        // Or theme.appBarTheme.backgroundColor
        elevation: 1,
        // Subtle shadow
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 20.0,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const SizedBox(height: 20),
                  Text(
                    "Forgot Your Password?",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Enter your email address below and we'll send you a link to reset your password.",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 40),
                  TextformWidget(
                    // Assuming TextformWidget is defined
                    controller: _emailCtrl,
                    labelText: "Email Address",
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    focusNode: _emailFocus,
                    onEditingComplete: _sendResetLink,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty)
                        return 'Email cannot be empty';
                      if (!RegExp(
                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+$",
                      ).hasMatch(v.trim())) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  if (_isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      onPressed: _sendResetLink,
                      child: const Text(
                        'Send Reset Link',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  if (_feedbackMessage != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Text(
                        _feedbackMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _isFeedbackError
                              ? theme.colorScheme.error
                              : Colors.green.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
