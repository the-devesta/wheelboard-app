import 'package:flutter/material.dart';

Future<void> showSwitchProfilePopup(
  BuildContext context, {
  VoidCallback? onSwitchToBusiness,
  VoidCallback? onLogout,
}) {
  return showGeneralDialog(
    context: context,
    barrierLabel: 'Switch Profile',
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.35), // dim background
    pageBuilder: (_, __, ___) => const SizedBox.shrink(),
    transitionBuilder: (context, anim, _, __) {
      final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: curved,
          child: Center(
            // 👈 put in the center
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _SwitchProfileCard(
                onBack: () => Navigator.of(context).pop(),
                onSwitchToBusiness: () {
                  Navigator.of(context).pop();
                  onSwitchToBusiness?.call();
                },
                onLogout: () {
                  Navigator.of(context).pop();
                  onLogout?.call();
                },
              ),
            ),
          ),
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 220),
  );
}

class _SwitchProfileCard extends StatelessWidget {
  const _SwitchProfileCard({
    required this.onBack,
    this.onSwitchToBusiness,
    this.onLogout,
  });

  final VoidCallback onBack;
  final VoidCallback? onSwitchToBusiness;
  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16), // rounded like screenshot
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header row: back arrow + centered title
            Row(
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.arrow_back, color: Colors.black87),
                  onPressed: onBack,
                ),
                const Expanded(
                  child: Text(
                    'Switch Profile',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      height: 1.2,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF3A3A3A),
                    ),
                  ),
                ),
                // spacer to balance the back button
                const SizedBox(width: 48),
              ],
            ),
            const SizedBox(height: 12),

            // Option: Switch to Business Account
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Switch to Business Account',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF444444),
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: onSwitchToBusiness,
            ),

            const SizedBox(height: 8),

            // Logout (red)
            Align(
              alignment: Alignment.centerLeft,
              child: InkWell(
                onTap: onLogout,
                borderRadius: BorderRadius.circular(6),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFFE53935), // red
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
