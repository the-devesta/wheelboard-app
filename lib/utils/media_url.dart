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
  ///
  /// Absolute URLs and data URIs are returned AS-IS — exactly like the web
  /// `resolveMediaUrl`. They must NOT be re-encoded: Firebase Storage download
  /// URLs already percent-encode the object path (`/o/feed-images%2F<id>.jpg`),
  /// and running `Uri.encodeFull` over them turned `%2F` into `%252F`, which
  /// 404s. Only bare relative paths get the API origin prefixed.
  static String resolve(String? value) {
    if (value == null) return '';
    final trimmed = value.trim();
    if (trimmed.isEmpty) return '';
    if (trimmed.startsWith('http://') ||
        trimmed.startsWith('https://') ||
        trimmed.startsWith('data:')) {
      // Self-heal a previously double-encoded Firebase Storage path. A correct
      // download URL has `%2F`; a legacy over-encoded one has `%252F` (the `%`
      // got re-encoded to `%25`). No valid URL contains `%252F`, so collapsing
      // it back is always safe.
      return trimmed.contains('%252F')
          ? trimmed.replaceAll('%252F', '%2F')
          : trimmed;
    }
    if (trimmed.startsWith('//')) return 'https:$trimmed';
    final path = trimmed
        .replaceAll('\\', '/')
        .replaceFirst(RegExp(r'^/+'), '');
    return '${ApiConstants.origin}/$path';
  }

  /// Nullable variant for call sites that branch on `null` (e.g. show initials
  /// when there is no image).
  static String? resolveOrNull(String? value) {
    final result = resolve(value);
    return result.isEmpty ? null : result;
  }
}
