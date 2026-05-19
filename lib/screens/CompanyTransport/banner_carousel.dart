import 'dart:async';
import 'package:flutter/material.dart';
import '../../utils/responsive_utils.dart';

class BannerCarousel extends StatefulWidget {
  const BannerCarousel({super.key});

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  final List<String> images = [
    'assets/truck.png', // Truck 1
    'assets/truck.png', // Truck 2
    'assets/truck.png', // Truck 3
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 4), (Timer timer) {
      if (_currentPage < images.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      _pageController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// Carousel
        SizedBox(
          height: ResponsiveUtils.getResponsiveSpacing(
            context,
            small: 100,
            medium: 120,
            large: 140,
          ),
          child: PageView.builder(
            controller: _pageController,
            itemCount: images.length,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemBuilder: (context, index) {
              return Padding(
                padding: ResponsiveUtils.getResponsiveHorizontalPadding(
                  context,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                    ResponsiveUtils.getResponsiveBorderRadius(
                      context,
                      small: 16,
                      medium: 18,
                      large: 20,
                    ),
                  ),
                  child: Image.asset(
                    images[index],
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              );
            },
          ),
        ),

        SizedBox(
          height: ResponsiveUtils.getResponsiveSpacing(
            context,
            small: 6,
            medium: 8,
            large: 10,
          ),
        ),

        /// Pagination dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(images.length, (index) {
            return AnimatedContainer(
              duration: Duration(milliseconds: 300),
              margin: EdgeInsets.symmetric(
                horizontal: ResponsiveUtils.getResponsiveSpacing(
                  context,
                  small: 3,
                  medium: 4,
                  large: 5,
                ),
              ),
              width: _currentPage == index
                  ? ResponsiveUtils.getResponsiveSpacing(
                      context,
                      small: 12,
                      medium: 14,
                      large: 16,
                    )
                  : ResponsiveUtils.getResponsiveSpacing(
                      context,
                      small: 6,
                      medium: 8,
                      large: 10,
                    ),
              height: ResponsiveUtils.getResponsiveSpacing(
                context,
                small: 6,
                medium: 8,
                large: 10,
              ),
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? Colors.teal
                    : Colors.teal.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(20),
              ),
            );
          }),
        ),
      ],
    );
  }
}
