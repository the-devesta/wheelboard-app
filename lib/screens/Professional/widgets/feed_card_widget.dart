import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../utils/responsive_utils.dart';

/// Reusable Feed Card Widget
/// Pixel-perfect match with Figma design
class FeedCardWidget extends StatelessWidget {
  final String profileImageUrl;
  final String profileName;
  final String imageUrl;
  final String title;
  final String description;
  final String postedTime;
  final VoidCallback? onProfileTap;
  final VoidCallback? onHeartTap;
  final VoidCallback? onShareTap;
  final VoidCallback? onEyeTap;
  final VoidCallback? onReadMoreTap;
  final bool isLiked;

  const FeedCardWidget({
    super.key,
    required this.profileImageUrl,
    required this.profileName,
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.postedTime,
    this.onProfileTap,
    this.onHeartTap,
    this.onShareTap,
    this.onEyeTap,
    this.onReadMoreTap,
    this.isLiked = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = ResponsiveUtils.isMobile(context)
        ? screenWidth *
              0.95 // 373px out of 393px base
        : 373.0;
    final cardHeight = ResponsiveUtils.isMobile(context)
        ? screenWidth *
              0.85 // Responsive height
        : 334.0;

    return Container(
      width: cardWidth,
      height: cardHeight,
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.getResponsiveSpacing(
          context,
          small: 10,
          medium: 12,
          large: 14,
        ),
        vertical: ResponsiveUtils.getResponsiveSpacing(
          context,
          small: 12,
          medium: 14,
          large: 16,
        ),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFBFB),
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveBorderRadius(
            context,
            small: 16,
            medium: 18,
            large: 20,
          ),
        ),
        border: Border.all(color: const Color(0xFFFCD2D2), width: 1),
      ),
      child: Stack(
        children: [
          // Profile Section
          Positioned(
            left: 14,
            top: 14,
            child: GestureDetector(
              onTap: onProfileTap,
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: NetworkImage(profileImageUrl),
                        fit: BoxFit.cover,
                        onError: (_, __) {},
                      ),
                    ),
                    child: profileImageUrl.isEmpty
                        ? Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFE0E0E0),
                            ),
                            child: const Icon(
                              Icons.person,
                              size: 20,
                              color: Color(0xFF535353),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    profileName,
                    style: GoogleFonts.poppins(
                      fontSize: ResponsiveUtils.getResponsiveFontSize(
                        context,
                        small: 14,
                        medium: 15,
                        large: 16,
                      ),
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF535353),
                      letterSpacing: -0.28,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Main Image - Centered horizontally, positioned at middle-34px vertically
          Positioned(
            left: 18, // (cardWidth - (cardWidth - 36)) / 2 = 18
            top:
                cardHeight / 2 -
                34 -
                76, // Center vertically minus 34px minus half image height
            child: Container(
              width: cardWidth - 36, // 373 - 36 = 337px (matching Figma)
              height: 152,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                  onError: (_, __) {},
                ),
              ),
              child: imageUrl.isEmpty
                  ? Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: const Color(0xFFE0E0E0),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.image,
                          size: 48,
                          color: Color(0xFF999999),
                        ),
                      ),
                    )
                  : null,
            ),
          ),

          // Action Buttons Row
          Positioned(
            left: 27,
            top: cardHeight - 120,
            child: Row(
              children: [
                // Heart Button
                GestureDetector(
                  onTap: onHeartTap,
                  child: Container(
                    width: 25,
                    height: 25,
                    decoration: BoxDecoration(
                      color: isLiked
                          ? const Color(0xFFFF5E5E).withOpacity(0.1)
                          : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      size: 22,
                      color: isLiked
                          ? const Color(0xFFF36969)
                          : const Color(0xFFFCACAC),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Share Button
                GestureDetector(
                  onTap: onShareTap,
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: SvgPicture.asset(
                      'assets/share.svg',
                      width: 20,
                      height: 20,
                      colorFilter: const ColorFilter.mode(
                        Color(0xFF535353),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Eye Button
                GestureDetector(
                  onTap: onEyeTap,
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: SvgPicture.asset(
                      'assets/eye.svg',
                      width: 20,
                      height: 20,
                      colorFilter: const ColorFilter.mode(
                        Color(0xFF535353),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Title
          Positioned(
            left: 27,
            top: cardHeight - 95,
            child: SizedBox(
              width: cardWidth - 56,
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(
                    context,
                    small: 14,
                    medium: 15,
                    large: 16,
                  ),
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                  letterSpacing: -0.28,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          // Description
          Positioned(
            left: 27,
            top: cardHeight - 67,
            child: SizedBox(
              width: cardWidth - 56,
              child: Text(
                description,
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(
                    context,
                    small: 12,
                    medium: 13,
                    large: 14,
                  ),
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                  letterSpacing: -0.24,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          // Footer with Posted Time and Read More - Centered
          Positioned(
            bottom: 26,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Posted $postedTime',
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      small: 13,
                      medium: 13,
                      large: 14,
                    ),
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF666666),
                    letterSpacing: -0.26,
                  ),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: onReadMoreTap,
                  child: Text(
                    'Read more',
                    style: GoogleFonts.poppins(
                      fontSize: ResponsiveUtils.getResponsiveFontSize(
                        context,
                        small: 15,
                        medium: 15,
                        large: 16,
                      ),
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF375DFB),
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
