import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wheelboard/constants/apps_colors.dart';

/// Reusable share modal sheet matching the Figma "Share this Job" popup.
/// Usage example:
/// showModalBottomSheet(
///   context: context,
///   backgroundColor: Colors.transparent,
///   isScrollControlled: true,
///   builder: (_) => ShareSheet(
///     title: 'Share this Job',
///     subtitle: 'Share it with someone in need!',
///     options: [
///       ShareOption(
///         label: 'Twitter',
///         icon: _DefaultSocialIcon.twitter,
///         labelColor: const Color(0xFF1DA1F2),
///         onTap: () {},
///       ),
///       // ...more options
///     ],
///     linkText: 'https://example.com/article/social-share-modal',
///     onCopyLink: () {},
///     onClose: () => Get.back(),
///   ),
/// );
class ShareSheet extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<ShareOption> options;
  final String? linkText;
  final VoidCallback? onCopyLink;
  final VoidCallback? onClose;

  const ShareSheet({
    super.key,
    required this.title,
    required this.options,
    this.subtitle,
    this.linkText,
    this.onCopyLink,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black.withOpacity(0.9),
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                InkWell(
                  onTap: onClose,
                  borderRadius: BorderRadius.circular(20),
                  child: const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Icon(Icons.close, size: 22, color: Color(0xFF535353)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 18,
              runSpacing: 14,
              children: options
                  .map((option) => _ShareCircleButton(option: option))
                  .toList(),
            ),
            if (linkText != null) ...[
              const SizedBox(height: 16),
              _LinkCopyRow(
                linkText: linkText!,
                onCopy: onCopyLink,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ShareOption {
  final String label;
  final Widget icon;
  final Color? labelColor;
  final VoidCallback onTap;

  const ShareOption({
    required this.label,
    required this.icon,
    required this.onTap,
    this.labelColor,
  });
}

class _ShareCircleButton extends StatelessWidget {
  final ShareOption option;
  const _ShareCircleButton({required this.option});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: option.onTap,
          borderRadius: BorderRadius.circular(40),
          child: Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: Color(0xFFE4E5E7), // neutral circle bg from Figma
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: option.icon,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          option.label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: option.labelColor ?? Colors.grey[700],
          ),
        ),
      ],
    );
  }
}

class _LinkCopyRow extends StatelessWidget {
  final String linkText;
  final VoidCallback? onCopy;
  const _LinkCopyRow({required this.linkText, this.onCopy});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0x2634434B)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              linkText,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            onPressed: onCopy,
            padding: EdgeInsets.zero,
            icon: Icon(
              Icons.copy_outlined,
              size: 20,
              color: AppColors.buttonBg,
            ),
          ),
        ],
      ),
    );
  }
}

/// Small helper class exposing default social brand icons built from simple
/// Text/Emoji so the widget stays asset-light. Replace these with proper
/// assets or SVGs when available.
class DefaultSocialIcons {
  static Widget twitter = Text(
    't',
    style: GoogleFonts.poppins(
      color: const Color(0xFF1DA1F2),
      fontSize: 26,
      fontWeight: FontWeight.w800,
    ),
  );

  static Widget facebook = Text(
    'f',
    style: GoogleFonts.poppins(
      color: const Color(0xFF1877F2),
      fontSize: 28,
      fontWeight: FontWeight.w800,
    ),
  );

  static Widget reddit = Text(
    '👽',
    style: GoogleFonts.poppins(fontSize: 24),
  );

  static Widget whatsapp = Text(
    'wa',
    style: GoogleFonts.poppins(
      color: const Color(0xFF25D366),
      fontSize: 20,
      fontWeight: FontWeight.w800,
    ),
  );
}

