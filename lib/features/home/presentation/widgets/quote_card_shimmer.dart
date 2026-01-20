import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class QuoteCardShimmer extends StatelessWidget {
  const QuoteCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 300,
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[800]!,
        highlightColor: Colors.grey[700]!,
        child: Stack(
          children: [
            // Mimic Content Padding
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  // Quote Text Placeholders
                  Container(
                    width: double.infinity,
                    height: 24,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    height: 24,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    height: 24,
                    color: Colors.white,
                  ),

                  const SizedBox(height: 20),

                  // Author and Actions Row
                  Row(
                    children: [
                      // Author Name
                      Expanded(
                        child: Container(height: 20, color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      // Share Icon
                      Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Favorite Button
                      Container(
                        width: 100,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
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
  }
}
