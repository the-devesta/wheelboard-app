import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../controllers/service_provider_controller.dart';
import '../../models/add_service_model.dart';
import '../../models/update_service_model.dart';
import '../../models/service_model.dart';
import '../../utils/session_manager.dart';
import '../../utils/placeservices.dart';
import '../../widgets/custom_snackbar.dart';
import '../../widgets/custom_loader.dart';

class AddServiceScreen extends StatefulWidget {
  final ServiceModel? service; // Optional service for edit mode

  const AddServiceScreen({super.key, this.service});

  @override
  State<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  late final ServiceProviderController _controller;

  // Form Controllers
  final TextEditingController _serviceTitleController = TextEditingController();
  final TextEditingController _contactNumberController =
      TextEditingController();
  final TextEditingController _whatsappNumberController =
      TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _fullAddressController = TextEditingController();

  int _descriptionLength = 0;

  String _pricingOption = 'Flat Price';
  String _selectedCategory = 'Tyre Services';
  final Set<String> _selectedDays = {'Mon'};
  String _businessFrom = '09:00';
  String _businessTo = '18:00';
  bool _isVisible = true;
  List<File> _selectedImages = [];
  final ImagePicker _imagePicker = ImagePicker();

  // Google Places Service
  final PlacesService _placesService = PlacesService(
    apiKey: "AIzaSyDD1jdzyCZ_QhA4QpsL9qFRg38phVn8mPI",
  );
  List<Suggestion> _addressSuggestions = [];

  // Category options
  final List<String> _categoryOptions = [
    'Tyre Services',
    'Vehicle Services',
    'Tyre Retreader',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _controller = Get.put(ServiceProviderController(), permanent: false);
    _descriptionController.addListener(() {
      setState(() {
        _descriptionLength = _descriptionController.text.length;
      });
    });

    // Populate form if editing
    if (widget.service != null) {
      _populateFormForEdit();
    }
  }

  void _populateFormForEdit() {
    final service = widget.service!;
    _serviceTitleController.text = service.serviceTitle;
    _contactNumberController.text = service.contactNumber ?? '';
    _whatsappNumberController.text = service.whatsappNumber ?? '';
    _descriptionController.text = service.description ?? '';
    _priceController.text = service.amount?.toString() ?? '';
    _cityController.text = service.city;
    _fullAddressController.text = service.fullAddress;
    _pricingOption = service.pricingOption ?? 'Flat Price';

    // Set category from serviceCategory first, then fallback to businessType
    String categoryToSet = 'Tyre Services'; // Default
    if (service.serviceCategory != null &&
        service.serviceCategory!.isNotEmpty) {
      categoryToSet = service.serviceCategory!;
    } else if (service.businessType.isNotEmpty) {
      categoryToSet = service.businessType;
    }

    // Handle legacy 'Tyre Repair' mapping
    if (categoryToSet == 'Tyre Repair') {
      categoryToSet = 'Tyre Services';
    }

    // Validate that the category exists in _categoryOptions
    if (_categoryOptions.contains(categoryToSet)) {
      _selectedCategory = categoryToSet;
    } else {
      _selectedCategory = 'Tyre Services';
    }

    _isVisible = service.isAvailable;
    if (service.daysOpen != null && service.daysOpen!.isNotEmpty) {
      _selectedDays.clear();
      _selectedDays.addAll(service.daysOpen!.split(','));
    }
    if (service.businessHoursFrom != null) {
      _businessFrom = service.businessHoursFrom!;
    }
    if (service.businessHoursTo != null) {
      _businessTo = service.businessHoursTo!;
    }
    _descriptionLength = _descriptionController.text.length;
  }

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
        title: Text(
          widget.service != null ? 'Edit Service' : 'Add New Service',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
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
                      const SizedBox(height: 100), // Space for bottom buttons
                    ],
                  ),
                ),
              ),
            );
          },
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
          ...children,
        ],
      ),
    );
  }

  Widget _buildServiceDetailsSection() {
    return _buildSection('', [
      _CustomTextField(
        labelText: 'Service Title *',
        controller: _serviceTitleController,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Service title is required';
          }
          return null;
        },
      ),
      const SizedBox(height: 16),
      // Category Dropdown
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Category *',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: InputDecoration(
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
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            items: _categoryOptions.map((category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Text(category, style: const TextStyle(fontSize: 15)),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedCategory = value;
                });
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Category is required';
              }
              return null;
            },
          ),
        ],
      ),
      const SizedBox(height: 16),
      _CustomTextField(
        labelText: 'Contact number *',
        controller: _contactNumberController,
        keyboardType: TextInputType.phone,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Contact number is required';
          }
          if (value.length < 10) {
            return 'Please enter a valid contact number';
          }
          return null;
        },
      ),
      const SizedBox(height: 16),
      _CustomTextField(
        labelText: 'Whatsapp number (optional)',
        controller: _whatsappNumberController,
        keyboardType: TextInputType.phone,
      ),
      const SizedBox(height: 16),
      _CustomTextField(
        labelText: 'Description *',
        maxLines: 4,
        minLines: 1,
        controller: _descriptionController,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Description is required';
          }
          if (value.length > 500) {
            return 'Description cannot exceed 500 characters';
          }
          return null;
        },
      ),
      const SizedBox(height: 8),
      Align(
        alignment: Alignment.centerRight,
        child: Text(
          '$_descriptionLength/500',
          style: TextStyle(
            color: _descriptionLength > 500 ? Colors.red : Colors.grey,
          ),
        ),
      ),
    ]);
  }

  Widget _buildPricingSection() {
    return _buildSection('Pricing Option *', [
      Row(
        children: [
          _buildRadio('Flat Price'),
          const SizedBox(width: 24),
          _buildRadio('On Request'),
        ],
      ),
      const SizedBox(height: 16),
      _CustomTextField(
        labelText: _pricingOption == 'Flat Price'
            ? 'Amount *'
            : 'Amount (optional)',
        prefixIcon: const Icon(Icons.currency_rupee, color: Colors.grey),
        controller: _priceController,
        keyboardType: TextInputType.number,
        enabled: _pricingOption == 'Flat Price',
        validator: _pricingOption == 'Flat Price'
            ? (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Amount is required for flat price';
                }
                if (double.tryParse(value) == null ||
                    double.parse(value) <= 0) {
                  return 'Please enter a valid amount';
                }
                return null;
              }
            : null,
      ),
    ]);
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
    return _buildSection('Business Hours', [
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
      ),
    ]);
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
        backgroundColor: isSelected
            ? const Color(0xFFE83B4F)
            : Colors.grey.shade200,
        labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
      ),
    );
  }

  Widget _buildTimePicker(String label, String time) {
    final isFrom = label == 'From';
    final currentTime = isFrom ? _businessFrom : _businessTo;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _selectTime(context, isFrom),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(currentTime),
                const Icon(Icons.access_time, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectTime(BuildContext context, bool isFrom) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        final timeString =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
        if (isFrom) {
          _businessFrom = timeString;
        } else {
          _businessTo = timeString;
        }
      });
    }
  }

  Widget _buildLocationSection() {
    return _buildSection('Location', [
      // Full Address with Google Places Autocomplete
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Full Address *',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _fullAddressController,
            decoration: InputDecoration(
              hintText: 'Search for your business address',
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
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
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              filled: true,
              fillColor: Colors.white,
              suffixIcon: const Icon(
                Icons.location_on,
                color: Color(0xFF0075FF),
              ),
            ),
            onChanged: (value) async {
              if (value.isNotEmpty) {
                try {
                  final results = await _placesService.fetchSuggestions(value);
                  setState(() => _addressSuggestions = results);
                } catch (e) {
                  print('Error fetching address suggestions: $e');
                }
              } else {
                setState(() => _addressSuggestions = []);
              }
            },
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Address is required';
              }
              return null;
            },
          ),
          if (_addressSuggestions.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _addressSuggestions.length,
                separatorBuilder: (_, __) =>
                    Divider(height: 1, color: Colors.grey.shade200),
                itemBuilder: (context, index) {
                  final suggestion = _addressSuggestions[index];
                  return ListTile(
                    dense: true,
                    leading: const Icon(
                      Icons.location_on_outlined,
                      color: Color(0xFF0075FF),
                      size: 12,
                    ),
                    title: Text(
                      suggestion.description,
                      style: const TextStyle(fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: suggestion.subTitle.isNotEmpty
                        ? Text(
                            suggestion.subTitle,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        : null,
                    onTap: () {
                      setState(() {
                        _fullAddressController.text = suggestion.description;
                        // Auto-fill city if available
                        if (suggestion.city.isNotEmpty) {
                          _cityController.text = suggestion.city;
                        }
                        _addressSuggestions.clear();
                      });
                    },
                  );
                },
              ),
            ),
        ],
      ),
      const SizedBox(height: 16),
      _CustomTextField(
        labelText: 'City *',
        controller: _cityController,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'City is required';
          }
          return null;
        },
      ),
    ]);
  }

  Widget _buildImageGallerySection() {
    return _buildSection('Image Gallery', [
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
          if (index < _selectedImages.length) {
            return _buildImageItem(_selectedImages[index], index);
          }
          return _buildImagePlaceholder(index);
        },
      ),
      const SizedBox(height: 8),
      const Text(
        'Max 4 images, .jpg/.png, 2MB each',
        style: TextStyle(color: Colors.grey, fontSize: 12),
      ),
    ]);
  }

  Widget _buildImagePlaceholder(int index) {
    return GestureDetector(
      onTap: () => _pickImage(index),
      child: Container(
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
            Text('Add Image', style: TextStyle(color: Color(0xFF00B894))),
          ],
        ),
      ),
    );
  }

  Widget _buildImageItem(File image, int index) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            image,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedImages.removeAt(index);
              });
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage(int index) async {
    if (_selectedImages.length >= 4) {
      SnackBarHelper.error("Maximum 4 images allowed");
      return;
    }

    try {
      final ImageSource? source = await showModalBottomSheet<ImageSource>(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (BuildContext context) {
          return SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.camera_alt,
                    color: Color(0xFF00B894),
                  ),
                  title: const Text('Take Photo'),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.photo_library,
                    color: Color(0xFF00B894),
                  ),
                  title: const Text('Choose from Gallery'),
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
                ListTile(
                  leading: const Icon(Icons.cancel, color: Colors.grey),
                  title: const Text('Cancel'),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          );
        },
      );

      if (source != null) {
        final XFile? pickedFile = await _imagePicker.pickImage(
          source: source,
          imageQuality: 80,
          maxWidth: 1920,
          maxHeight: 1920,
        );

        if (pickedFile != null) {
          final file = File(pickedFile.path);
          final fileSizeInMB = await file.length() / (1024 * 1024);

          if (fileSizeInMB > 2) {
            SnackBarHelper.error("Image size should be less than 2MB");
            return;
          }

          setState(() {
            if (index < _selectedImages.length) {
              _selectedImages[index] = file;
            } else {
              _selectedImages.add(file);
            }
          });
        }
      }
    } catch (e) {
      SnackBarHelper.error("Failed to pick image: ${e.toString()}");
    }
  }

  Widget _buildVisibilitySection() {
    return _buildSection('', [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Service Visibility',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 4),
              Text('Mark as Available', style: TextStyle(color: Colors.grey)),
            ],
          ),
          Switch(
            value: _isVisible,
            onChanged: (value) {
              setState(() {
                _isVisible = value;
              });
            },
            activeColor: const Color(0xFF00B894),
          ),
        ],
      ),
    ]);
  }

  Widget _buildBottomButtons() {
    return Obx(
      () => Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _controller.isLoading.value
                    ? null
                    : () {
                        // Save as draft - same as publish but with isVisible = false
                        _saveService(isVisible: false);
                      },
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
                onPressed: _controller.isLoading.value
                    ? null
                    : () {
                        _saveService(isVisible: true);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF36969),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _controller.isLoading.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CustomLoader.small(color: Colors.white),
                      )
                    : const Text(
                        'Save & Publish',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveService({required bool isVisible}) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDays.isEmpty) {
      SnackBarHelper.error("Please select at least one day");
      return;
    }

    if (_pricingOption == 'Flat Price' &&
        _priceController.text.trim().isEmpty) {
      SnackBarHelper.error("Please enter amount for flat price");
      return;
    }

    try {
      final sessionManager = SessionManager();
      final userId = await sessionManager.getString("userId");

      if (userId == null || userId.isEmpty) {
        SnackBarHelper.error("User ID not found. Please login again.");
        return;
      }

      final daysOpen = _selectedDays.join(',');
      final isFlatPrice = _pricingOption == 'Flat Price';
      final price = isFlatPrice
          ? double.tryParse(_priceController.text.trim()) ?? 0.0
          : 0.0;

      Map<String, dynamic>? result;

      // Check if we're editing an existing service
      if (widget.service != null) {
        // Update existing service
        final updateModel = UpdateServiceModel(
          serviceId: widget.service!.serviceId,
          userId: userId,
          serviceTitle: _serviceTitleController.text.trim(),
          fullAddress: _fullAddressController.text.trim(),
          city: _cityController.text.trim(),
          contactNumber: _contactNumberController.text.trim(),
          whatsappNumber: _whatsappNumberController.text.trim().isEmpty
              ? null
              : _whatsappNumberController.text.trim(),
          description: _descriptionController.text.trim(),
          isFlatPrice: isFlatPrice,
          price: price,
          isVisible: isVisible,
          daysOpen: daysOpen,
          businessFrom: _businessFrom,
          businessTo: _businessTo,
          modifiedBy: userId,
          serviceCategory: _selectedCategory,
          newImages: _selectedImages.isNotEmpty ? _selectedImages : null,
        );

        result = await _controller.updateService(updateModel);
      } else {
        // Add new service
        final serviceModel = AddServiceModel(
          userId: userId,
          serviceTitle: _serviceTitleController.text.trim(),
          fullAddress: _fullAddressController.text.trim(),
          city: _cityController.text.trim(),
          contactNumber: _contactNumberController.text.trim(),
          whatsappNumber: _whatsappNumberController.text.trim().isEmpty
              ? null
              : _whatsappNumberController.text.trim(),
          description: _descriptionController.text.trim(),
          isFlatPrice: isFlatPrice,
          price: price,
          isVisible: isVisible,
          daysOpen: daysOpen,
          businessFrom: _businessFrom,
          businessTo: _businessTo,
          createdBy: userId,
          serviceCategory: _selectedCategory,
          images: _selectedImages,
        );

        result = await _controller.addService(serviceModel);
      }

      if (result != null && result['success'] == true) {
        // Clear form and go back
        if (widget.service == null) {
          _clearForm();
        }
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e) {
      SnackBarHelper.error("Failed to save service: ${e.toString()}");
    }
  }

  void _clearForm() {
    _serviceTitleController.clear();
    _contactNumberController.clear();
    _whatsappNumberController.clear();
    _descriptionController.clear();
    _priceController.clear();
    _cityController.clear();
    _fullAddressController.clear();
    setState(() {
      _pricingOption = 'Flat Price';
      _selectedDays.clear();
      _selectedDays.add('Mon');
      _businessFrom = '09:00';
      _businessTo = '18:00';
      _isVisible = true;
      _selectedImages.clear();
    });
  }

  @override
  void dispose() {
    _serviceTitleController.dispose();
    _contactNumberController.dispose();
    _whatsappNumberController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _cityController.dispose();
    _fullAddressController.dispose();
    super.dispose();
  }
}

class _CustomTextField extends StatelessWidget {
  final String labelText;
  final int? maxLines;
  final int? minLines;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool enabled;

  const _CustomTextField({
    required this.labelText,
    this.maxLines,
    this.minLines,
    this.prefixIcon,
    this.suffixIcon,
    this.controller,
    this.keyboardType,
    this.validator,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines ?? 1,
      minLines: minLines ?? 1,
      keyboardType: keyboardType,
      validator: validator,
      enabled: enabled,
      textInputAction: maxLines != null && maxLines! > 1
          ? TextInputAction.newline
          : TextInputAction.next,
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
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: maxLines != null && maxLines! > 1 ? 12 : 16,
        ),
      ),
    );
  }
}
