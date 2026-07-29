import 'package:flutter/foundation.dart';

/// In-app notifications: orders, offers, rewards. Extend with push later.
class AppNotificationItem {
  AppNotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    this.read = false,
  });

  final String id;
  final String title;
  final String body;
  final AppNotificationType type;
  final DateTime createdAt;
  bool read;
}

enum AppNotificationType { order, offer, reward }

class NotificationsController extends ChangeNotifier {
  final List<AppNotificationItem> _items = [];

  List<AppNotificationItem> get items => List.unmodifiable(_items);

  int get unreadCount => _items.where((e) => !e.read).length;

  void ensureSeeded() {
    if (_items.isNotEmpty) return;
    final now = DateTime.now();
    _items.addAll([
      AppNotificationItem(
        id: 'seed_offer_1',
        title: 'Weekend treat',
        body: '20% off soft serve this Saturday & Sunday at all Yens stores.',
        type: AppNotificationType.offer,
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      AppNotificationItem(
        id: 'seed_reward_1',
        title: 'Points milestone',
        body: 'You are 50 points away from your next reward. Order today to unlock!',
        type: AppNotificationType.reward,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      AppNotificationItem(
        id: 'seed_order_1',
        title: 'Order update',
        body: 'Your last order was confirmed. Thank you for choosing Yens!',
        type: AppNotificationType.order,
        createdAt: now.subtract(const Duration(days: 2)),
        read: true,
      ),
    ]);
    notifyListeners();
  }

  void addOrderUpdate({required String title, required String body}) {
    final id = 'ord_${DateTime.now().millisecondsSinceEpoch}';
    _items.insert(
      0,
      AppNotificationItem(
        id: id,
        title: title,
        body: body,
        type: AppNotificationType.order,
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void addOffer({required String title, required String body}) {
    _items.insert(
      0,
      AppNotificationItem(
        id: 'off_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        body: body,
        type: AppNotificationType.offer,
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void markRead(String id) {
    final i = _items.indexWhere((e) => e.id == id);
    if (i >= 0 && !_items[i].read) {
      _items[i].read = true;
      notifyListeners();
    }
  }

  void markAllRead() {
    for (final e in _items) {
      e.read = true;
    }
    notifyListeners();
  }
}
