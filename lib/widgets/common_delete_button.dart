import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CommonDeleteButton extends StatelessWidget {
  final String title;
  final String message;
  final String buttonText;
  final void Function(String password) onConfirm;

  const CommonDeleteButton({
    super.key,
    this.title = 'Delete Account',
    this.message = 'Are you sure you want to delete your account? This action cannot be undone.',
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
          final password = await showDialog<String>(
            context: context,
            builder: (_) => _DeleteAccountDialog(title: title, message: message),
          );

          if (password != null && password.isNotEmpty) {
            onConfirm(password);
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

class _DeleteAccountDialog extends StatefulWidget {
  final String title;
  final String message;

  const _DeleteAccountDialog({required this.title, required this.message});

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  final _passwordController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.message),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            obscureText: _obscure,
            decoration: InputDecoration(
              labelText: 'Password',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _passwordController.text),
          child: const Text(
            'Delete',
            style: TextStyle(color: Color(0xFFF36969)),
          ),
        ),
      ],
    );
  }
}
