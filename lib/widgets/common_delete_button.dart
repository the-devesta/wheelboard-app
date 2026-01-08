import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CommonDeleteButton extends StatelessWidget {
  final String title;
  final String message;
  final String buttonText;
  final VoidCallback onConfirm;

  const CommonDeleteButton({
    super.key,
    this.title = 'Delete Account',
    this.message = 'Are you sure you want to delete your account?',
    this.buttonText = 'Delete Account',
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: OutlinedButton.icon(
        onPressed: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              title: Text(title),
              content: Text(message),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text(
                    'Delete',
                    style: TextStyle(color: Color(0xFFF36969)),
                  ),
                ),
              ],
            ),
          );

          if (confirm == true) {
            onConfirm();
          }
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFF36969), width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        icon: const Icon(Icons.cancel, color: Color(0xFFF36969), size: 20),
        label: Text(
          buttonText,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFF36969),
          ),
        ),
      ),
    );
  }
}
