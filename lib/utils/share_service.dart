import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../widgets/custom_snackbar.dart';

/// A centralized service for sharing content across the app.
/// This ensures consistent sharing experience with proper Wheelboard URLs.
class ShareService {
  // Wheelboard website URL - Replace with actual production URL when available
  static const String wheelboardWebsiteUrl = 'https://wheelboard.in';
  static const String wheelboardAppUrl = 'https://wheelboard.in/app';

  /// Share a job posting with deep link
  static Future<void> shareJob({
    required String jobId,
    required String jobTitle,
    required String city,
    required String jobType,
    required String jobDuration,
    required int openings,
    required int salary,
    required String description,
  }) async {
    final jobUrl = '$wheelboardWebsiteUrl/jobs/$jobId';

    final shareText =
        '''
🚛 Job Opening: $jobTitle

📍 Location: $city
📋 Type: $jobType
⏱ Duration: $jobDuration
👥 Openings: $openings
💰 Salary: ₹$salary

📝 $description

👇 Apply Now on WheelBoard!
$jobUrl

Download WheelBoard App: $wheelboardAppUrl
''';

    await Share.share(shareText.trim(), subject: 'Job Opportunity: $jobTitle');
  }

  /// Share a feed/post with deep link
  static Future<void> sharePost({
    required String postId,
    required String content,
    required String userName,
    required String category,
  }) async {
    final postUrl = '$wheelboardWebsiteUrl/feeds/$postId';

    final shareText =
        '''
📢 $userName shared on WheelBoard

${content.length > 200 ? '${content.substring(0, 200)}...' : content}

📂 Category: $category

👇 View Full Post:
$postUrl

Download WheelBoard App: $wheelboardAppUrl
''';

    await Share.share(
      shareText.trim(),
      subject: 'Post from $userName on WheelBoard',
    );
  }

  /// Share a generic text with Wheelboard branding
  static Future<void> shareGeneric({
    required String title,
    required String content,
    String? url,
  }) async {
    final shareUrl = url ?? wheelboardWebsiteUrl;

    final shareText =
        '''
$title

$content

$shareUrl

Download WheelBoard App: $wheelboardAppUrl
''';

    await Share.share(shareText.trim(), subject: title);
  }

  /// Share vehicle details
  static Future<void> shareVehicle({
    required String vehicleId,
    required String vehicleName,
    required String vehicleType,
    required String registrationNo,
    String? additionalInfo,
  }) async {
    final vehicleUrl = '$wheelboardWebsiteUrl/vehicles/$vehicleId';

    final shareText =
        '''
🚛 Vehicle: $vehicleName

📋 Type: $vehicleType
🔢 Registration: $registrationNo
${additionalInfo != null ? '\n📝 $additionalInfo\n' : ''}
👇 View on WheelBoard:
$vehicleUrl

Download WheelBoard App: $wheelboardAppUrl
''';

    await Share.share(shareText.trim(), subject: 'Vehicle: $vehicleName');
  }

  /// Share professional profile
  static Future<void> shareProfessional({
    required String professionalId,
    required String name,
    required String role,
    String? experience,
    String? skills,
  }) async {
    final profileUrl = '$wheelboardWebsiteUrl/professionals/$professionalId';

    final shareText =
        '''
👤 Professional: $name

💼 Role: $role
${experience != null ? '📆 Experience: $experience\n' : ''}${skills != null ? '🎯 Skills: $skills\n' : ''}
👇 View Profile on WheelBoard:
$profileUrl

Download WheelBoard App: $wheelboardAppUrl
''';

    await Share.share(shareText.trim(), subject: 'Professional: $name');
  }

  /// Share booking details
  static Future<void> shareBooking({
    required String bookingId,
    required String serviceTitle,
    required String customerName,
    required String scheduledDate,
    required String scheduledTime,
  }) async {
    final shareText =
        '''
📅 Booking Details: $serviceTitle

👤 Customer: $customerName
📆 Date: $scheduledDate
🕒 Time: $scheduledTime
🆔 Booking ID: #$bookingId

Shared via WheelBoard
''';

    await Share.share(shareText.trim(), subject: 'Booking: $serviceTitle');
  }

  /// Share service details
  static Future<void> shareService({
    required String serviceId,
    required String title,
    required String businessName,
    required String category,
    required String description,
    required String location,
    required String price,
  }) async {
    final serviceUrl = '$wheelboardWebsiteUrl/services/$serviceId';

    final shareText =
        '''
🛠 Service: $title
🏢 Business: $businessName
📂 Category: $category
📍 Location: $location
💰 Price: $price

📝 $description

👇 View Details on WheelBoard:
$serviceUrl

Download WheelBoard App: $wheelboardAppUrl
''';

    await Share.share(shareText.trim(), subject: 'Service: $title');
  }

  /// Copy link to clipboard
  static Future<void> copyLink(String url) async {
    await Clipboard.setData(ClipboardData(text: url));
    SnackBarHelper.success('Link copied to clipboard!');
  }

  /// Get job URL for sharing
  static String getJobUrl(String jobId) {
    return '$wheelboardWebsiteUrl/jobs/$jobId';
  }

  /// Get post URL for sharing
  static String getPostUrl(String postId) {
    return '$wheelboardWebsiteUrl/feeds/$postId';
  }

  /// Get app download URL
  static String getAppDownloadUrl() {
    return wheelboardAppUrl;
  }
}
