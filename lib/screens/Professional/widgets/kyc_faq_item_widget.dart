import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// KYC FAQ Item Widget
/// Expandable FAQ question and answer
class KycFaqItemWidget extends StatefulWidget {
  final String question;
  final String answer;

  const KycFaqItemWidget({
    super.key,
    required this.question,
    required this.answer,
  });

  @override
  State<KycFaqItemWidget> createState() => _KycFaqItemWidgetState();
}

class _KycFaqItemWidgetState extends State<KycFaqItemWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.question,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF222222),
                      ),
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    size: 13,
                    color: const Color(0xFF2F80ED),
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Text(
                widget.answer,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF7B7B7B),
                  height: 1.4,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
