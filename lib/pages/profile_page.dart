import 'package:flutter/material.dart';
import '../firebase/firebase_model.dart'; // Your FirebaseService
import '../login_signup/sigin_page.dart'; // Your SignInPage

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String userName = '';
  String userEmail = '';

  // Removed profileImageUrl as it's not needed for this minimalist design
  bool isLoading = true;

  // Define a custom color palette
  static const Color _primaryColor = Color(0xFF6A1B9A); // Deep Purple
  static const Color _accentColor = Color(0xFFFFA000); // Amber
  static const Color _backgroundColor = Color(
    0xFFF3E5F5,
  ); // Light Purple background

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      final userInfo = await FirebaseService().getCurrentUserInfo();
      if (mounted) {
        setState(() {
          userName = userInfo['name'] ?? 'User Name'; // Default for clarity
          userEmail =
              userInfo['email'] ?? 'user@example.com'; // Default for clarity
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false; // Stop loading even on error
        });
        _showSnackBar("Failed to load profile: ${e.toString()}", isError: true);
      }
    }
  }

  Future<void> _logout() async {
    try {
      await FirebaseService().SignOut();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SignInPage()),
        );
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar("Logout failed: ${e.toString()}", isError: true);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor, // Apply custom background color
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: _primaryColor))
          : Padding(
              padding: const EdgeInsets.all(
                30.0,
              ), // Increased padding for more space
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                // Center content vertically
                crossAxisAlignment: CrossAxisAlignment.center,
                // Center content horizontally
                children: [
                  const Spacer(flex: 2), // Pushes content towards center/top
                  // --- User Initials/Avatar ---
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: _primaryColor.withOpacity(0.7),
                    // Use primary color for avatar
                    child: Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // --- User Name ---
                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: _primaryColor, // Use primary color for name
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),

                  // --- User Email ---
                  Text(
                    userEmail,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors
                          .grey[700], // Slightly darker grey for readability
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(), // Pushes logout button towards bottom
                  // --- Logout Button ---
                  SizedBox(
                    width: double.infinity, // Button takes full width
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.logout, color: Colors.white),
                      label: const Text(
                        "Logout",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        backgroundColor:
                            _accentColor, // Use accent color for button
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            12,
                          ), // Slightly more rounded
                        ),
                        elevation: 5,
                      ),
                      onPressed: _logout,
                    ),
                  ),
                  const Spacer(flex: 1), // Ensures button isn't at very bottom
                ],
              ),
            ),
    );
  }
}
