import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Learning Module Card Widget
/// Displays a related learning module with thumbnail and metadata
class LearningModuleCardWidget extends StatelessWidget {
  final String title;
  final String type; // 'Video' or 'Article'
  final VoidCallback? onTap;

  const LearningModuleCardWidget({
    super.key,
    required this.title,
    required this.type,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            Container(
              height: 84,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Center(
                child: Icon(
                  type == 'Video'
                      ? Icons.play_circle_outline
                      : Icons.article_outlined,
                  size: 24,
                  color: Colors.grey[600],
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF111827),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        type == 'Video'
                            ? Icons.play_circle_outline
                            : Icons.article_outlined,
                        size: 11,
                        color: const Color(0xFF6B7280),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        type,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF6B7280),
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
