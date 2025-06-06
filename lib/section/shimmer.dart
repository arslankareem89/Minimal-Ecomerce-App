import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerEffectImage extends StatelessWidget {
  const ShimmerEffectImage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      shrinkWrap: true,
      // ✅ Important if nested
      physics: BouncingScrollPhysics(),
      // Optional: smoother scroll
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.all(8),
          width: 200,
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 180, width: 200, color: Colors.white),
                SizedBox(height: 8),
                Container(height: 15, width: 150, color: Colors.white),
                SizedBox(height: 10),
                Container(height: 10, width: 100, color: Colors.white),
              ],
            ),
          ),
        );
      },
    );
  }
}
