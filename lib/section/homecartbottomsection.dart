import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;

// Assuming these are in your project structure:
import 'package:ecomerce_app/section/shimmer.dart';
import 'package:ecomerce_app/detailscreen/product_detail.dart';
import 'package:ecomerce_app/firebase/firebasecart.dart';

import '../cache/categoriescache.dart';

class Homecartbottomsection extends StatefulWidget {
  const Homecartbottomsection({super.key});

  @override
  State<Homecartbottomsection> createState() => _HomecartbottomsectionState();
}

class _HomecartbottomsectionState extends State<Homecartbottomsection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String selectedCategory = '';
  List<dynamic> products = [];

  // CHANGE THIS LINE: Initialize _productsFuture immediately
  // with a Future that completes without a value.
  late Future<void> _productsFuture =
      Future.value(); // Default value to avoid LateInitializationError

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);

    // Initialize with the first category or a default
    if (categoriescache.isNotEmpty) {
      selectedCategory = categoriescache.first;
    } else {
      selectedCategory =
          "smartphones"; // Default if cache is unexpectedly empty
    }

    // Now, trigger the actual data fetch and assign it to _productsFuture
    // This is safe because _productsFuture already holds a valid (completed) Future.
    _productsFuture = _fetchProductsForCategory(selectedCategory);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _fetchProductsForCategory(String category) async {
    String apiCategory = category.toLowerCase().replaceAll(' ', '-');
    if (category.isEmpty) {
      apiCategory = "smartphones";
    }

    // Clear products immediately to show loading state if data is old
    if (mounted) {
      setState(() {
        products = [];
      });
    }

    try {
      final response = await http.get(
        Uri.parse('https://dummyjson.com/products/category/$apiCategory'),
      );

      if (mounted) {
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          setState(() {
            products = data["products"];
          });
        } else {
          setState(() {
            products = [];
          });
          throw Exception('Failed to load products: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          products = [];
        });
      }
      throw Exception('Error fetching products: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 350,
      child: Column(
        children: [
          // Category selection bar
          Container(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categoriescache.length,
              itemBuilder: (context, index) {
                final category = categoriescache[index];
                final displayCategory = category
                    .split('-')
                    .map((word) => word[0].toUpperCase() + word.substring(1))
                    .join(' ');
                return GestureDetector(
                  onTap: () {
                    if (selectedCategory != category) {
                      setState(() {
                        selectedCategory = category;
                        // Assign the new future when category changes
                        _productsFuture = _fetchProductsForCategory(category);
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    margin: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: selectedCategory == category
                          ? Colors.orange[100]
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      displayCategory,
                      style: TextStyle(
                        color: selectedCategory == category
                            ? Colors.orange[700]
                            : Colors.black87,
                        fontWeight: selectedCategory == category
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),

          // Products display based on FutureBuilder
          Expanded(
            child: FutureBuilder<void>(
              future: _productsFuture, // This will now always have a value
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const ShimmerEffectImage();
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Error: ${snapshot.error}. Tap to retry.",
                      textAlign: TextAlign.center,
                    ),
                  );
                } else {
                  if (products.isEmpty) {
                    return Center(
                      child: Text("No products found in this category."),
                    );
                  }
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      final String title =
                          product["title"] as String? ?? "No Title";
                      final String thumbnailUrl =
                          product["thumbnail"] as String? ??
                          'https://picsum.photos/200/300';
                      final num price = product["price"] as num? ?? 0;
                      final num rating = product["rating"] as num? ?? 0;

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => productdetail(
                                productdetails: [product],
                                herokey: "product_home_cart_$index",
                              ),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(
                            left: 8,
                            right: 4,
                            bottom: 8,
                            top: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 3,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          width: 200,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Hero(
                                tag: "product_home_cart_$index",
                                child: Container(
                                  height: 150,
                                  width: 200,
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10),
                                    ),
                                    image: DecorationImage(
                                      image: NetworkImage(thumbnailUrl),
                                      fit: BoxFit.cover,
                                      onError: (exception, stackTrace) {
                                        print('Image load error: $exception');
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      style: const TextStyle(
                                        overflow: TextOverflow.ellipsis,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      "\$${price.toStringAsFixed(2)}",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              FontAwesomeIcons.solidStar,
                                              color: Colors.amber,
                                              size: 15,
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              rating.toString(),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                          ],
                                        ),
                                        GestureDetector(
                                          child: Icon(
                                            FontAwesomeIcons.cartPlus,
                                            color: Colors.orange[400],
                                            size: 22,
                                          ),
                                          onTap: () async {
                                            addToCart(title, price.toDouble(), [
                                              product,
                                            ], context);
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
