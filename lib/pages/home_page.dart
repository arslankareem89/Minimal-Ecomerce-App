import 'package:ecomerce_app/login_signup/sigin_page.dart';
import 'package:ecomerce_app/pages/cart_page.dart';
import 'package:ecomerce_app/pages/profile_page.dart';
import 'package:ecomerce_app/section/homecartbottomsection.dart';
import 'package:ecomerce_app/section/hometopsection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../firebase/firebase_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  static const TextStyle optionStyle = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.bold,
  );

  static List<Widget> _widgetOption = <Widget>[
    HomePageIndex(),
    Carts(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: _widgetOption.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.cartShopping),
            label: "Cart",
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.user),
            label: "Profile",
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomePageIndex extends StatefulWidget {
  const HomePageIndex({super.key});

  @override
  State<HomePageIndex> createState() => _HomePageIndexState();
}

class _HomePageIndexState extends State<HomePageIndex> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              children: [
                Container(
                  //Text Today delaals
                  child: Text(
                    "Today Deals,",
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // HomeTopSection
                const SizedBox(height: 10),
                const HomeTopSection(),
                const SizedBox(height: 10),
                const Homecartbottomsection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
