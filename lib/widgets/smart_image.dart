import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

import '../core/auth/auth_service.dart';
import '../utils/app_logger.dart';
import '../utils/constants.dart';
import '../utils/media_url.dart';

/// One image widget that renders whatever the backend actually stored:
///
/// - **base64 data-URLs** (`data:image/…;base64,…`) — this app persists vehicle,
///   post and KYC images as base64 in the DB, and `Image.network` CANNOT render
///   a `data:` URI (it throws → every image fell back to a placeholder/truck).
///   These are decoded and drawn with `Image.memory`.
/// - **relative paths** (`fleet/vehicles/<id>.jpg`) — resolved against the API
///   origin via [MediaUrl].
/// - **absolute URLs** (hosted Firebase/GCS, or our own API) — loaded directly.
///
/// Auth headers are attached ONLY for images served from our own API origin —
/// sending a Bearer token to a public GCS/Firebase URL makes it reject the
/// request, which is another way images silently failed.
class SmartImage extends StatelessWidget {
  final String? source;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;

  const SmartImage({
    super.key,
    required this.source,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    final raw = source?.trim() ?? '';
    if (raw.isEmpty) return _fallback();

    if (raw.startsWith('data:')) {
      final bytes = _decodeDataUri(raw);
      if (bytes == null) return _fallback();
      return Image.memory(
        bytes,
        width: width,
        height: height,
        fit: fit,
        gaplessPlayback: true,
        errorBuilder: (_, __, ___) => _fallback(),
      );
    }

    final url = MediaUrl.resolve(raw);
    if (url.isEmpty) return _fallback();
    return Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      headers: _headersFor(url),
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : _loading(),
      errorBuilder: (_, Object error, __) {
        // Surfaces the exact URL + reason when an image fails to load, so a
        // broken image is diagnosable instead of a silent placeholder.
        AppLogger.e('🖼️ SmartImage failed: $url → $error');
        return _fallback();
      },
    );
  }

  static Uint8List? _decodeDataUri(String dataUri) {
    final comma = dataUri.indexOf(',');
    if (comma < 0) return null;
    // Strip any whitespace/newlines the payload may contain, then normalize
    // padding — vehicle images are large base64 PNGs and a stray char or
    // missing `=` padding would otherwise make base64Decode throw.
    final data = dataUri.substring(comma + 1).replaceAll(RegExp(r'\s'), '');
    try {
      return base64.decode(base64.normalize(data));
    } catch (_) {
      try {
        return base64Decode(data);
      } catch (_) {
        return null;
      }
    }
  }

  static Map<String, String>? _headersFor(String url) {
    if (!url.startsWith(ApiConstants.origin)) return null; // external → no auth
    final token = AuthService.to.currentToken;
    if (token.isEmpty) return null;
    return {'Authorization': 'Bearer $token', 'Accept': '*/*'};
  }

  Widget _loading() => Container(
        width: width,
        height: height,
        color: const Color(0xFFF3F4F6),
        alignment: Alignment.center,
        child: const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFF25C5C)),
        ),
      );

  Widget _fallback() =>
      placeholder ??
      Container(
        width: width,
        height: height,
        color: const Color(0xFFF3F4F6),
        alignment: Alignment.center,
        child: const Icon(Icons.image_outlined, color: Color(0xFF9CA3AF), size: 28),
      );
}
