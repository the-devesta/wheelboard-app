import 'package:flutter/material.dart';

/// Common Header Widget
/// Reusable header with logo (same as Feeds screen)
class CommonHeaderWidget extends StatelessWidget {
  const CommonHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 91,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFFCD2D2), width: 1)),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.only(left: 16, top: 42),
          child: Image.asset(
            'assets/logo-bg 3.png',
            width: 211,
            height: 49,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Image.asset(
                'assets/headingImg.png',
                height: 40,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 211,
                    height: 49,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image, size: 30),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
