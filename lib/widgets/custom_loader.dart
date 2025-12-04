import 'package:flutter/material.dart';
import '../constants/apps_colors.dart';

/// Custom Loader Widget
/// A beautiful, reusable loading indicator with optional message
class CustomLoader extends StatelessWidget {
  final String? message;
  final Color? color;
  final double? size;
  final bool showMessage;

  const CustomLoader({
    super.key,
    this.message,
    this.color,
    this.size,
    this.showMessage = true,
  });

  /// Full screen loader with optional message
  const CustomLoader.fullScreen({
    super.key,
    this.message,
    this.color,
    this.size,
    this.showMessage = true,
  });

  /// Small inline loader
  const CustomLoader.small({
    super.key,
    this.message,
    this.color,
    this.size = 20,
    this.showMessage = false,
  });

  /// Medium sized loader
  const CustomLoader.medium({
    super.key,
    this.message,
    this.color,
    this.size = 40,
    this.showMessage = true,
  });

  @override
  Widget build(BuildContext context) {
    final loaderColor = color ?? AppColors.buttonBg;
    final loaderSize = size ?? 50.0;

    Widget loaderWidget = SizedBox(
      width: loaderSize,
      height: loaderSize,
      child: CircularProgressIndicator(
        strokeWidth: 4,
        valueColor: AlwaysStoppedAnimation<Color>(loaderColor),
        backgroundColor: loaderColor.withOpacity(0.1),
      ),
    );

    if (showMessage && message != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            loaderWidget,
            const SizedBox(height: 20),
            Text(
              message!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (showMessage && message == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            loaderWidget,
            const SizedBox(height: 20),
            Text(
              "Loading...",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return Center(child: loaderWidget);
  }
}

/// Custom Loader with overlay (blocks interaction)
class CustomLoaderOverlay extends StatelessWidget {
  final String? message;
  final Color? backgroundColor;
  final Color? loaderColor;

  const CustomLoaderOverlay({
    super.key,
    this.message,
    this.backgroundColor,
    this.loaderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor ?? Colors.black.withOpacity(0.3),
      child: CustomLoader(
        message: message ?? "Please wait...",
        color: loaderColor ?? AppColors.buttonBg,
        showMessage: true,
      ),
    );
  }
}

/// Shimmer loader for list items
class CustomShimmerLoader extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const CustomShimmerLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
    );
  }
}

/// List shimmer loader
class CustomListShimmerLoader extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  final EdgeInsets? padding;

  const CustomListShimmerLoader({
    super.key,
    this.itemCount = 5,
    this.itemHeight = 100,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: padding ?? const EdgeInsets.all(16),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: CustomShimmerLoader(
            width: double.infinity,
            height: itemHeight,
            borderRadius: BorderRadius.circular(12),
          ),
        );
      },
    );
  }
}

