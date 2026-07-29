import 'package:flutter/material.dart';

class TimeOffer {
  const TimeOffer({
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.icon,
    required this.accent,
  });

  final String title;
  final String subtitle;
  final String badge;
  final IconData icon;
  final Color accent;
}

/// Rotates promotional offers by local time window.
List<TimeOffer> offersForNow() {
  final h = DateTime.now().hour;
  if (h >= 6 && h < 11) {
    return const [
      TimeOffer(
        title: 'Morning boost',
        subtitle: 'Milk tea + soft serve — double points until 11:00',
        badge: 'AM',
        icon: Icons.wb_sunny_outlined,
        accent: Color(0xFFFFB74D),
      ),
    ];
  }
  if (h >= 11 && h < 15) {
    return const [
      TimeOffer(
        title: 'Lunch rush',
        subtitle: 'Fruit tea combos — 15% off in-store pickup',
        badge: 'LUNCH',
        icon: Icons.local_drink_outlined,
        accent: Color(0xFF4FC3F7),
      ),
    ];
  }
  if (h >= 15 && h < 19) {
    return const [
      TimeOffer(
        title: 'Afternoon treat',
        subtitle: 'Shakes & sundaes — free topping after 3pm',
        badge: 'PM',
        icon: Icons.icecream_outlined,
        accent: Color(0xFFBA68C8),
      ),
    ];
  }
  return const [
    TimeOffer(
      title: 'Evening unwind',
      subtitle: 'Late-night soft serve — bonus streak progress',
      badge: 'NIGHT',
      icon: Icons.nightlight_round,
      accent: Color(0xFF7986CB),
    ),
  ];
}
