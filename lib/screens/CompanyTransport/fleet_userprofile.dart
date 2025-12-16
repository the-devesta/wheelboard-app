import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wheelboard/apihelperclass/api_helper.dart';
import 'package:wheelboard/utils/constants.dart';
import 'package:wheelboard/widgets/custom_loader.dart';

class FleetUserprofile extends StatefulWidget {
  final String? companyId;
  const FleetUserprofile({super.key, this.companyId});

  @override
  State<FleetUserprofile> createState() => _FleetUserprofileState();
}

class _FleetUserprofileState extends State<FleetUserprofile> {
  bool _isLoading = true;
  Map<String, dynamic>? _profileData;

  @override
  void initState() {
    super.initState();
    _fetchCompanyProfile();
  }

  Future<void> _fetchCompanyProfile() async {
    if (widget.companyId == null || widget.companyId!.isEmpty) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final endpoint = 'api/Post/CompProfile/${widget.companyId}';
      final response = await HttpHelper.getData(
        endpoint: endpoint,
        headers: {'Accept': '*/*'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _profileData = data;
            _isLoading = false;
          });
        }
      } else {
        print('Failed to fetch profile: ${response.statusCode}');
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error fetching profile: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CustomLoader(message: "Loading Profile...")),
      );
    }

    if (_profileData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Profile Not Found")),
        body: const Center(child: Text("Could not load company profile.")),
      );
    }

    // Extract data
    final profileName = _profileData!['profileName'] ?? 'Unknown';
    final email = _profileData!['email'] ?? '';
    final phone = _profileData!['phone'] ?? '';
    final address = _profileData!['address'] ?? '';
    final rawImage = _profileData!['profileImage'] ?? '';
    final profileType = _profileData!['profileType'] ?? 'Company';

    // Process Image URL
    String profileImageUrl = 'https://i.pravatar.cc/150?img=12';
    if (rawImage.isNotEmpty) {
      if (rawImage.startsWith('http')) {
        profileImageUrl = rawImage;
      } else {
        profileImageUrl = ApiConstants.baseUrl + rawImage;
      }
    }
    // Fix double slashes and backslashes
    profileImageUrl = profileImageUrl
        .replaceAll(r'\', '/') // Start with backslash replacement
        .replaceAll(r'//', '/')
        .replaceAll('https:/', 'https://');

    return Stack(
      children: [
        // Background SVG
        Positioned.fill(
          child: SvgPicture.asset('assets/bgDesign.svg', fit: BoxFit.cover),
        ),

        Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.all(10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.black,
                          ),
                        ),
                        const Spacer(),
                        const Text(
                          "Company Profile",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const Spacer(flex: 2),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Profile Image
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 48,
                      backgroundImage: NetworkImage(profileImageUrl),
                      onBackgroundImageError: (_, __) {},
                    ),
                  ),

                  // Role Tag
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF13C77B),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      profileType,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Name & Contact
                  Text(
                    profileName,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors
                          .black, // Dark text on light bg or handle contrast
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (email.isNotEmpty)
                    Text(
                      email,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  if (phone.isNotEmpty)
                    Text(
                      phone,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),

                  const SizedBox(height: 8),

                  // Location
                  if (address.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 18,
                            color: Colors.redAccent,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              address,
                              style: const TextStyle(color: Colors.black87),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
