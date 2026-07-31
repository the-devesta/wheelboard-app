import 'package:flutter/material.dart';

/// Shared skeleton placeholders.
///
/// A skeleton communicates "content is arriving, and this is its shape"; a
/// centred spinner communicates only "something is happening". Matching the
/// real layout also stops the page jumping when data lands.
///
/// One animation controller drives every shimmering child under a
/// [SkeletonTheme], so a list of placeholders costs one ticker rather than one
/// per row.

const Color _skeletonBase = Color(0xFFEFF1F4);

/// Provides a single shimmer animation to all descendant skeletons.
class SkeletonTheme extends StatefulWidget {
  final Widget child;

  const SkeletonTheme({super.key, required this.child});

  @override
  State<SkeletonTheme> createState() => _SkeletonThemeState();

  static Animation<double>? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_SkeletonScope>()
        ?.animation;
  }
}

class _SkeletonThemeState extends State<SkeletonTheme>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    // Left running, this keeps ticking (and rebuilding) for the life of the
    // route even after the real content has replaced the skeleton.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SkeletonScope(animation: _controller, child: widget.child);
  }
}

class _SkeletonScope extends InheritedWidget {
  final Animation<double> animation;

  const _SkeletonScope({required this.animation, required super.child});

  @override
  bool updateShouldNotify(_SkeletonScope oldWidget) =>
      oldWidget.animation != animation;
}

/// A single shimmering block. The building unit of every skeleton below.
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;

  const SkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) {
    final block = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: _skeletonBase,
        borderRadius: BorderRadius.circular(radius),
      ),
    );

    final animation = SkeletonTheme.maybeOf(context);
    if (animation == null) {
      // Rendered outside a SkeletonTheme — static, but still correct.
      return block;
    }

    return AnimatedBuilder(
      animation: animation,
      builder: (_, child) =>
          Opacity(opacity: 0.45 + (animation.value * 0.35), child: child),
      child: block,
    );
  }
}

/// A card-shaped placeholder approximating a fleet list row.
class SkeletonListCard extends StatelessWidget {
  final double height;

  const SkeletonListCard({super.key, this.height = 96});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE9ECEF)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonBox(width: 56, height: 56, radius: 12),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonBox(width: 140, height: 13),
                const SizedBox(height: 8),
                const SkeletonBox(width: 96, height: 11),
                const SizedBox(height: 10),
                Row(
                  children: const [
                    SkeletonBox(width: 64, height: 18, radius: 9),
                    SizedBox(width: 8),
                    SkeletonBox(width: 48, height: 18, radius: 9),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A scrollable run of card placeholders, shaped like a fleet list.
///
/// Not scrollable by the user: the skeleton is decorative and must not steal
/// the scroll position that the real list will take over.
class SkeletonListView extends StatelessWidget {
  final int itemCount;
  final EdgeInsets padding;

  const SkeletonListView({
    super.key,
    this.itemCount = 6,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return SkeletonTheme(
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: padding,
        itemCount: itemCount,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, __) => const SkeletonListCard(),
      ),
    );
  }
}

/// A detail-screen placeholder: a hero block followed by stacked info cards.
class SkeletonDetailView extends StatelessWidget {
  const SkeletonDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonTheme(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            SkeletonBox(height: 120, radius: 16),
            SizedBox(height: 16),
            SkeletonBox(width: 180, height: 16),
            SizedBox(height: 10),
            SkeletonBox(width: 120, height: 12),
            SizedBox(height: 20),
            SkeletonBox(height: 88, radius: 14),
            SizedBox(height: 12),
            SkeletonBox(height: 88, radius: 14),
            SizedBox(height: 12),
            SkeletonBox(height: 88, radius: 14),
          ],
        ),
      ),
    );
  }
}
