import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AddServiceScreen extends StatefulWidget {
  const AddServiceScreen({super.key});

  @override
  State<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  String _pricingOption = 'Flat Price';
  final Set<String> _selectedDays = {'Mon'};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.grey.shade200,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Add New Service',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildServiceDetailsSection(),
              const SizedBox(height: 24),
              _buildPricingSection(),
              const SizedBox(height: 24),
              _buildBusinessHoursSection(),
              const SizedBox(height: 24),
              _buildLocationSection(),
              const SizedBox(height: 24),
              _buildImageGallerySection(),
              const SizedBox(height: 24),
              _buildVisibilitySection(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomButtons(),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ...children
        ],
      ),
    );
  }

  Widget _buildServiceDetailsSection() {
    return _buildSection(
      '',
      [
        const _CustomTextField(labelText: 'Service Title *'),
        const SizedBox(height: 16),
        const _CustomTextField(labelText: 'Contact number *'),
        const SizedBox(height: 16),
        const _CustomTextField(labelText: 'Whatsapp number (optional)'),
        const SizedBox(height: 16),
        const _CustomTextField(
          labelText: 'Description *',
          maxLines: 4,
        ),
        const SizedBox(height: 8),
        const Align(
          alignment: Alignment.centerRight,
          child: Text(
            '0/500',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      ],
    );
  }

  Widget _buildPricingSection() {
    return _buildSection(
      'Pricing Option *',
      [
        Row(
          children: [
            _buildRadio('Flat Price'),
            const SizedBox(width: 24),
            _buildRadio('On Request'),
          ],
        ),
        const SizedBox(height: 16),
        const _CustomTextField(
          labelText: 'Amount',
          prefixIcon: Icon(Icons.currency_rupee, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildRadio(String value) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _pricingOption = value;
        });
      },
      child: Row(
        children: [
          Radio<String>(
            value: value,
            groupValue: _pricingOption,
            onChanged: (newValue) {
              setState(() {
                _pricingOption = newValue!;
              });
            },
            activeColor: const Color(0xFF0075FF),
          ),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildBusinessHoursSection() {
    return _buildSection(
      'Business Hours',
      [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildDayChip('Mon'),
            _buildDayChip('Tue'),
            _buildDayChip('Wed'),
            _buildDayChip('Thu'),
            _buildDayChip('Fri'),
            _buildDayChip('Sat'),
            _buildDayChip('Sun'),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildTimePicker('From', '09:00')),
            const SizedBox(width: 16),
            Expanded(child: _buildTimePicker('To', '18:00')),
          ],
        )
      ],
    );
  }

  Widget _buildDayChip(String day) {
    final isSelected = _selectedDays.contains(day);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedDays.remove(day);
          } else {
            _selectedDays.add(day);
          }
        });
      },
      child: Chip(
        label: Text(day),
        backgroundColor:
            isSelected ? const Color(0xFFE83B4F) : Colors.grey.shade200,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  Widget _buildTimePicker(String label, String time) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(time),
              const Icon(Icons.access_time, color: Colors.grey),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return _buildSection(
      '',
      [
        const _CustomTextField(
          labelText: 'City',
          suffixIcon: Icon(Icons.arrow_drop_down),
        ),
        const SizedBox(height: 16),
        const _CustomTextField(
          labelText: 'Full Address (optional)',
          maxLines: 4,
        ),
      ],
    );
  }

  Widget _buildImageGallerySection() {
    return _buildSection(
      'Image Gallery',
      [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1,
          ),
          itemCount: 4,
          itemBuilder: (context, index) {
            return _buildImagePlaceholder();
          },
        ),
        const SizedBox(height: 8),
        const Text(
          'Max 4 images, .jpg/.png, 2MB each',
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
          style: BorderStyle.solid,
        ),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_a_photo, color: Color(0xFF00B894)),
          SizedBox(height: 8),
          Text(
            'Add Image',
            style: TextStyle(color: Color(0xFF00B894)),
          ),
        ],
      ),
    );
  }

  Widget _buildVisibilitySection() {
    return _buildSection(
      '',
      [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Service Visibility',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Mark as Available',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
            Switch(
              value: true,
              onChanged: (value) {},
              activeColor: const Color(0xFF00B894),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              child: const Text(
                'Save as Draft',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF36969),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Save & Publish',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomTextField extends StatelessWidget {
  final String labelText;
  final int maxLines;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  const _CustomTextField({
    required this.labelText,
    this.maxLines = 1,
    this.prefixIcon,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF0075FF)),
        ),
      ),
    );
  }
}
