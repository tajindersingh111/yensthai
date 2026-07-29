import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../controllers/notifications_controller.dart';
import '../core/yens_theme.dart';
import '../widgets/yens_app_drawer.dart';
import '../widgets/yens_main_header.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _selectedCategory = 'All';

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
      key: _scaffoldKey,
      backgroundColor: YensTheme.cream,
      drawer: const YensAppDrawer(),
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Standard main tab header with hamburger menu opening drawer
            YensMainHeader.main(
              onOpenDrawer: () => _scaffoldKey.currentState?.openDrawer(),
            ),

            // Tab Page Title & Actions
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Inbox',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w900,
                      fontSize: 28,
                      color: YensTheme.navy,
                    ),
                  ),
                  Consumer<NotificationsController>(
                    builder: (context, ctrl, _) {
                      final hasUnread = ctrl.items.any((item) => !item.read);
                      return TextButton(
                        onPressed: hasUnread 
                            ? () => ctrl.markAllRead() 
                            : null,
                        style: TextButton.styleFrom(
                          foregroundColor: YensTheme.navy,
                          disabledForegroundColor: Colors.grey.shade400,
                        ),
                        child: Text(
                          'Mark all read',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Category Chips
            _buildCategoryChips(),

            // Notification List
            Expanded(
              child: Consumer<NotificationsController>(
                builder: (context, ctrl, _) {
                  final filteredItems = ctrl.items.where((item) {
                    if (_selectedCategory == 'All') return true;
                    if (_selectedCategory == 'Offers') {
                      return item.type == AppNotificationType.offer;
                    }
                    if (_selectedCategory == 'Rewards') {
                      return item.type == AppNotificationType.reward;
                    }
                    if (_selectedCategory == 'Orders') {
                      return item.type == AppNotificationType.order;
                    }
                    return true;
                  }).toList();

                  if (filteredItems.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      return _NotificationCard(
                        item: item,
                        onTap: () {
                          ctrl.markRead(item.id);
                        },
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

  Widget _buildCategoryChips() {
    final categories = ['All', 'Offers', 'Rewards', 'Orders'];
    return Container(
      height: 48,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = _selectedCategory == cat;
          return ChoiceChip(
            label: Text(cat),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) {
                setState(() => _selectedCategory = cat);
              }
            },
            selectedColor: YensTheme.yellow,
            backgroundColor: Colors.white,
            labelStyle: GoogleFonts.outfit(
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
              color: YensTheme.navy,
              fontSize: 13,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            side: BorderSide(
              color: isSelected ? YensTheme.yellow : Colors.grey.shade200,
              width: 1.5,
            ),
            showCheckmark: false,
            elevation: isSelected ? 2 : 0,
            shadowColor: YensTheme.yellow.withOpacity(0.3),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: YensTheme.navy.withOpacity(0.04),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.mail_outline_rounded,
                size: 64,
                color: YensTheme.navy,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Your inbox is clear',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: YensTheme.navy,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No $_selectedCategory notifications found at the moment.',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.item, required this.onTap});

  final AppNotificationItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (icon, color, labelText) = switch (item.type) {
      AppNotificationType.order => (Icons.receipt_long_rounded, YensTheme.navy, 'Order Update'),
      AppNotificationType.offer => (Icons.local_offer_rounded, const Color(0xFFE65100), 'Special Offer'),
      AppNotificationType.reward => (Icons.stars_rounded, const Color(0xFFF57F17), 'Yens Rewards'),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: item.read ? Colors.white : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: item.read ? Colors.transparent : YensTheme.yellow,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: YensTheme.navy.withOpacity(item.read ? 0.04 : 0.08),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            splashColor: YensTheme.yellow.withOpacity(0.2),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon column
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const SizedBox(width: 16),
                  
                  // Text Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                labelText,
                                style: GoogleFonts.outfit(
                                  color: color,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const Spacer(),
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
                        const SizedBox(height: 8),
                        Text(
                          item.title,
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: YensTheme.navy,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.body,
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _formatTime(item.createdAt),
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            color: Colors.grey.shade400,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 60) {
      return diff.inMinutes <= 0 ? 'Just now' : '${diff.inMinutes}m ago';
    }
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${d.day}/${d.month}/${d.year}';
  }
}
