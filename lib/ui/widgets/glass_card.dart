import 'dart:ui';
import 'package:flutter/material.dart';
import '../../data/models/post_model.dart';

class GlassCard extends StatelessWidget {
  final PostModel post;

  const GlassCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25), // 🔥 biroz kuchliroq
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.white.withOpacity(0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.title,
                  style: const TextStyle(
                    color: Colors.black, // 🔥 QORA
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  post.blocks.isNotEmpty ? post.blocks.first : "",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black87, // 🔥 QORA
                  ),
                ),
                const SizedBox(height: 15),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "${post.createdAt.day}.${post.createdAt.month}.${post.createdAt.year}",
                    style: const TextStyle(
                      color: Colors.black54, // 🔥 QORA
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
