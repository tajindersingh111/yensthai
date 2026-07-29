import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../controllers/notifications_controller.dart';
import '../../core/yens_theme.dart';
import '../../widgets/yens_main_header.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationsController>().ensureSeeded();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: YensTheme.cream,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            YensMainHeader.pushed(
              title: 'Notifications',
              onBack: () => Navigator.of(context).maybePop(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  Text(
                    'Updates',
                    style: GoogleFonts.dmSans(fontWeight: FontWeight.w800, fontSize: 16, color: Colors.black87),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => context.read<NotificationsController>().markAllRead(),
                    child: Text(
                      'Mark all read',
                      style: GoogleFonts.dmSans(color: YensTheme.navy, fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Consumer<NotificationsController>(
                builder: (context, ctrl, _) {
                  if (ctrl.items.isEmpty) {
                    return Center(
                      child: Text(
                        'No notifications yet',
                        style: GoogleFonts.dmSans(color: Colors.grey.shade600),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: ctrl.items.length,
                    itemBuilder: (context, index) {
                      final n = ctrl.items[index];
                      return TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: Duration(milliseconds: 280 + (index * 40).clamp(0, 200)),
                        curve: Curves.easeOutCubic,
                        builder: (context, t, child) {
                          return Opacity(
                            opacity: t,
                            child: Transform.translate(
                              offset: Offset(0, 12 * (1 - t)),
                              child: child,
                            ),
                          );
                        },
                        child: _NotificationTile(
                          item: n,
                          onTap: () {
                            context.read<NotificationsController>().markRead(n.id);
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.item, required this.onTap});

  final AppNotificationItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (item.type) {
      AppNotificationType.order => (Icons.receipt_long_rounded, YensTheme.navy),
      AppNotificationType.offer => (Icons.local_offer_rounded, Colors.deepOrange.shade700),
      AppNotificationType.reward => (Icons.stars_rounded, Colors.amber.shade800),
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: item.read ? Colors.white : YensTheme.yellowSoft,
        borderRadius: BorderRadius.circular(20),
        elevation: item.read ? 0 : 0.5,
        shadowColor: YensTheme.navy.withValues(alpha: 0.08),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: GoogleFonts.dmSans(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          if (!item.read)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: YensTheme.navy,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.body,
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          height: 1.35,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatTime(item.createdAt),
                        style: GoogleFonts.dmSans(fontSize: 11, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${d.day}/${d.month}/${d.year}';
  }
}
