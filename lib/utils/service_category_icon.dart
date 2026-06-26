import 'package:flutter/material.dart';

/// Maps a service category / business-type string to a professional icon and
/// accent colour, so service & booking cards render a meaningful icon instead
/// of a generic placeholder image. Keyword-based, so it tolerates the free-text
/// category values the backend returns.
class ServiceCategoryIcon {
  final IconData icon;
  final Color color;
  const ServiceCategoryIcon(this.icon, this.color);

  static ServiceCategoryIcon of(String? raw) {
    final s = (raw ?? '').toLowerCase();
    bool has(List<String> keys) => keys.any(s.contains);

    if (has(['tyre', 'tire', 'wheel', 'alignment', 'balanc'])) {
      return const ServiceCategoryIcon(Icons.tire_repair, Color(0xFF0EA5E9));
    }
    if (has(['fuel', 'diesel', 'petrol', 'gas'])) {
      return const ServiceCategoryIcon(Icons.local_gas_station, Color(0xFFF59E0B));
    }
    if (has(['tow', 'crane', 'recovery', 'breakdown'])) {
      return const ServiceCategoryIcon(Icons.fire_truck, Color(0xFFEF4444));
    }
    if (has(['wash', 'clean', 'detail'])) {
      return const ServiceCategoryIcon(Icons.local_car_wash, Color(0xFF06B6D4));
    }
    if (has(['electric', 'battery', 'wiring'])) {
      return const ServiceCategoryIcon(
          Icons.electrical_services, Color(0xFFEAB308));
    }
    if (has(['spare', 'part', 'accessor'])) {
      return const ServiceCategoryIcon(Icons.settings_suggest, Color(0xFF8B5CF6));
    }
    if (has(['paint', 'body', 'dent'])) {
      return const ServiceCategoryIcon(Icons.format_paint, Color(0xFFEC4899));
    }
    if (has(['insurance', 'policy'])) {
      return const ServiceCategoryIcon(Icons.verified_user, Color(0xFF10B981));
    }
    if (has(['crew', 'driver', 'labour', 'labor', 'helper', 'manpower'])) {
      return const ServiceCategoryIcon(Icons.groups, Color(0xFF6366F1));
    }
    if (has(['transport', 'logistic', 'freight', 'load', 'fleet'])) {
      return const ServiceCategoryIcon(Icons.local_shipping, Color(0xFF0284C7));
    }
    if (has([
      'repair',
      'mechanic',
      'maintenance',
      'garage',
      'workshop',
      'service',
      'spanner',
    ])) {
      return const ServiceCategoryIcon(Icons.handyman, Color(0xFFF36969));
    }
    // Professional fallback — never a placeholder image.
    return const ServiceCategoryIcon(
        Icons.miscellaneous_services, Color(0xFFF36969));
  }
}

/// A rounded, tinted tile rendering the professional icon for a service
/// category. Drop-in replacement for placeholder service thumbnails.
class ServiceIconTile extends StatelessWidget {
  const ServiceIconTile({
    super.key,
    this.category,
    this.size = 56,
    this.radius = 12,
  });

  final String? category;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final c = ServiceCategoryIcon.of(category);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: c.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Icon(c.icon, color: c.color, size: size * 0.5),
    );
  }
}
