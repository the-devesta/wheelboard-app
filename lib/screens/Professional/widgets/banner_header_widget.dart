import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/auth/auth_service.dart';
import '../../../theme/design_system.dart';

/// Brand hero banner shown at the top of the professional home — greeting +
/// tagline over the brand gradient with a subtle truck backdrop.
class BannerHeaderWidget extends StatelessWidget {
  const BannerHeaderWidget({super.key});

  String get _firstName {
    try {
      final user = AuthService.to.currentUser.value;
      final first = user?.profile['firstName']?.toString() ?? '';
      if (first.isNotEmpty) return first;
      final full = user?.fullName ?? '';
      if (full.isNotEmpty) return full.split(' ').first;
      return 'Driver';
    } catch (_) {
      return 'Driver';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: AppPalette.brandGradient,
        borderRadius: AppRadius.rXl,
        boxShadow: [
          BoxShadow(
            color: AppPalette.primary.withValues(alpha: 0.30),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -8,
            bottom: -10,
            child: Icon(
              Iconsax.truck,
              size: 96,
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Welcome back,',
                  style: AppText.bodySm.on(Colors.white.withValues(alpha: 0.9))),
              const SizedBox(height: 2),
              Text(_firstName,
                  style: AppText.h1.on(Colors.white).size(22),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              AppSpacing.vGapSm,
              Text('Ready to hit the road? Check your trips and jobs below.',
                  style: AppText.caption
                      .on(Colors.white.withValues(alpha: 0.92))),
            ],
          ),
        ],
      ),
    );
  }
}
