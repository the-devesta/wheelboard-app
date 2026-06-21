import 'constants.dart';

/// Single source of truth for turning a stored image value into a renderable
/// absolute URL. Mirrors the web `resolveMediaUrl` (wheelboard-fe/admin) so the
/// app, web, and admin all agree.
///
/// - Absolute URLs (http/https) and inline `data:` URIs pass through unchanged.
/// - Protocol-relative `//host/...` becomes `https://host/...`.
/// - Bare relative paths (legacy rows like `logos/<uuid>.jpg`,
///   `driver-images/<id>.jpg`) are served from the API ORIGIN — i.e.
///   `ApiConstants.origin` WITHOUT the `/api` suffix. Prefixing with the `/api`
///   base (the old bug in a couple of screens) produced `/api/logos/...` 404s.
class MediaUrl {
  MediaUrl._();

  /// Returns a renderable URL, or '' when there is nothing to show.
  static String resolve(String? value) {
    if (value == null) return '';
    final trimmed = value.trim();
    if (trimmed.isEmpty) return '';
    if (trimmed.startsWith('http://') ||
        trimmed.startsWith('https://') ||
        trimmed.startsWith('data:')) {
      return Uri.encodeFull(trimmed);
    }
    if (trimmed.startsWith('//')) return 'https:$trimmed';
    final path = trimmed
        .replaceAll('\\', '/')
        .replaceFirst(RegExp(r'^/+'), '');
    return Uri.encodeFull('${ApiConstants.origin}/$path');
  }

  /// Nullable variant for call sites that branch on `null` (e.g. show initials
  /// when there is no image).
  static String? resolveOrNull(String? value) {
    final result = resolve(value);
    return result.isEmpty ? null : result;
  }
}
