import 'package:flutter/material.dart';

class ExpenseTypeDropdown extends StatelessWidget {
  final String? selectedValue;
  final Function(String?) onChanged;
  final List<ExpenseTypeItem> items;

  const ExpenseTypeDropdown({
    super.key,
    required this.selectedValue,
    required this.onChanged,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      itemBuilder: (context) {
        return [
          PopupMenuItem<String>(
            enabled: false,
            child: Container(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 16,
                    color: Color(0xFFF36969),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Select expense type",
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFF36969),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ...items.map((item) {
            return PopupMenuItem<String>(
              value: item.value,
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: item.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF424242),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ];
      },
      onSelected: onChanged,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFD9D9D9), width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 13),
        child: Row(
          children: [
            Expanded(
              child: Text(
                selectedValue != null
                    ? items.firstWhere((e) => e.value == selectedValue, orElse: () => items.first).label
                    : "Select expense type",
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  color: selectedValue != null
                      ? const Color(0xFF424242)
                      : const Color(0xFFADAEBC),
                ),
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: Color(0xFF424242),
            ),
          ],
        ),
      ),
    );
  }
}

class ExpenseTypeItem {
  final String value;
  final String label;
  final Color color;

  ExpenseTypeItem({
    required this.value,
    required this.label,
    required this.color,
  });
}

