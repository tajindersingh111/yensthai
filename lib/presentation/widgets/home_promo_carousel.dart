import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:yensss/core/yens_theme.dart';
import 'package:yensss/data/repositories/yens_repository.dart';
import 'package:yensss/widgets/translation_widgets.dart';

/// Possible states for the weekly special fetch.
enum _WeeklySpecialStatus { loading, active, empty, error }

class HomePromoCarousel extends StatefulWidget {
  final Map<String, dynamic>? featuredProduct;
  final VoidCallback onProductTap;

  const HomePromoCarousel({
    super.key,
    this.featuredProduct,
    required this.onProductTap,
  });

  @override
  State<HomePromoCarousel> createState() => _HomePromoCarouselState();
}

class _HomePromoCarouselState extends State<HomePromoCarousel> {
  final PageController _pageController = PageController(viewportFraction: 1.0);
  int _currentPage = 0;
  Timer? _autoScrollTimer;

  // Weekly special & Executive Hub promotions state
  _WeeklySpecialStatus _status = _WeeklySpecialStatus.loading;
  WeeklySpecial? _weeklySpecial;
  List<Map<String, dynamic>> _hubPromotions = [];

  @override
  void initState() {
    super.initState();
    _fetchWeeklySpecial();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _fetchWeeklySpecial({bool forceRefresh = false}) async {
    if (!mounted) return;
    setState(() => _status = _WeeklySpecialStatus.loading);
    try {
      final repo = context.read<YensRepository>();
      final special = await repo.fetchActiveWeeklySpecial(forceRefresh: forceRefresh);
      final hubPromos = await repo.fetchCustomerAppPromotions();
      if (!mounted) return;

      _hubPromotions = hubPromos;

      // Client-side validity guard: don't show expired/future specials
      if ((special != null && special.isCurrentlyActive) || hubPromos.isNotEmpty) {
        setState(() {
          _weeklySpecial = special;
          _status = _WeeklySpecialStatus.active;
        });
      } else {
        setState(() {
          _weeklySpecial = null;
          _status = _WeeklySpecialStatus.empty;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _status = _WeeklySpecialStatus.error);
    }
    _restartAutoScroll();
  }

  List<_PromoSlide> get _slides {
    final slides = <_PromoSlide>[];

    // Priority 1: Executive Hub Marketing > Customer App Promotional Blocks (up to 3 blocks)
    if (_hubPromotions.isNotEmpty) {
      for (final promo in _hubPromotions) {
        final title = promo['title']?.toString() ?? '';
        final subtitle = promo['subtitle']?.toString() ?? '';
        final badge = promo['badgeText']?.toString() ?? 'PROMOTION';
        final imageUrl = promo['artworkUrl']?.toString();
        final start = promo['startDate']?.toString();
        final end = promo['endDate']?.toString();
        String? footerText;
        if (start != null && start.isNotEmpty && end != null && end.isNotEmpty) {
          footerText = 'Valid: $start – $end';
        }

        slides.add(_PromoSlide(
          type: _SlideType.weeklySpecial,
          title: title,
          subtitle: subtitle,
          badge: badge,
          imageUrl: imageUrl,
          accent: const Color(0xFF0F172A),
          footerText: footerText,
        ));
      }
    }

    // Priority 2: Live weekly special
    if (slides.isEmpty && _status == _WeeklySpecialStatus.active && _weeklySpecial != null) {
      final ws = _weeklySpecial!;
      final validity = '${ws.startDate} – ${ws.endDate}';
      slides.add(_PromoSlide(
        type: _SlideType.weeklySpecial,
        title: ws.title,
        subtitle: ws.description.isNotEmpty ? ws.description : 'Limited time offer',
        badge: 'WEEKLY SPECIAL',
        imageUrl: ws.imageUrl,
        accent: const Color(0xFF0D47A1),
        footerText: 'Valid: $validity',
        bonusPoints: ws.bonusPoints > 0 ? '+${ws.bonusPoints} bonus pts' : null,
      ));
    }

    // Priority 3: Featured product (fallback if needed)
    if (slides.isEmpty && widget.featuredProduct != null) {
      final p = widget.featuredProduct!;
      slides.add(_PromoSlide(
        type: _SlideType.featuredProduct,
        title: '${p['name'] ?? 'Seasonal Special'}',
        subtitle: '${p['description'] ?? 'Authentic flavor, crafted with excellence.'}',
        badge: 'FEATURED',
        imageUrl: p['imageUrl']?.toString(),
      ));
    }

    return slides;
  }

  void _restartAutoScroll() {
    _autoScrollTimer?.cancel();
    final count = _slides.length;
    if (count <= 1) return;
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_pageController.hasClients) return;
      final next = (_currentPage + 1) % count;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Loading skeleton
    if (_status == _WeeklySpecialStatus.loading) {
      return _buildSkeleton();
    }

    // Error state
    if (_status == _WeeklySpecialStatus.error) {
      return _buildErrorState();
    }

    final slides = _slides;

    // Empty state (no featured product AND no active special)
    if (slides.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        SizedBox(
          height: 260,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (idx) => setState(() => _currentPage = idx),
            itemCount: slides.length,
            itemBuilder: (context, index) => _buildSlideCard(slides[index]),
          ),
        ),
        if (slides.length > 1) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(slides.length, (index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 6,
                width: _currentPage == index ? 24 : 6,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? YensTheme.navy
                      : Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }

  Widget _buildSlideCard(_PromoSlide slide) {
    final accentColor = slide.accent ?? YensTheme.navy;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 235,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [accentColor, accentColor.withValues(alpha: 0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: 0.25),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Decorative circle
            Positioned(
              top: -50, right: -50,
              child: Container(
                width: 200, height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.04),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(28),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Badge chip
                        UnconstrainedBox(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: YensTheme.yellow,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              slide.badge,
                              style: GoogleFonts.outfit(
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                color: YensTheme.navy,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Title
                        YensTranslateText(
                          slide.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            height: 1.1,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Subtitle
                        YensTranslateText(
                          slide.subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.75),
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (slide.bonusPoints != null) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: YensTheme.yellow.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: YensTheme.yellow.withValues(alpha: 0.4)),
                            ),
                            child: Text(
                              slide.bonusPoints!,
                              style: GoogleFonts.outfit(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: YensTheme.yellow,
                              ),
                            ),
                          ),
                        ],
                        const Spacer(),
                        if (slide.footerText != null)
                          Text(
                            slide.footerText!,
                            style: GoogleFonts.outfit(
                              fontSize: 10,
                              color: Colors.white.withValues(alpha: 0.5),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        const SizedBox(height: 6),
                        // CTA button
                        ElevatedButton(
                          onPressed: widget.onProductTap,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: YensTheme.yellow,
                            foregroundColor: YensTheme.navy,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                          ),
                          child: YensTranslateText(
                            'Explore Now',
                            sourceLanguage: 'en',
                            style: GoogleFonts.outfit(
                                fontWeight: FontWeight.w900, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildSlideImage(slide),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlideImage(_PromoSlide slide) {
    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(22),
      ),
      clipBehavior: Clip.antiAlias,
      child: slide.imageUrl != null && slide.imageUrl!.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: slide.imageUrl!,
              fit: BoxFit.contain,
              placeholder: (_, __) => const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: YensTheme.yellow),
                ),
              ),
              errorWidget: (_, __, ___) =>
                  const Icon(Icons.icecream_rounded, size: 56, color: YensTheme.yellow),
            )
          : const Icon(Icons.icecream_rounded, size: 56, color: YensTheme.yellow),
    );
  }

  /// Shimmer-style loading skeleton card.
  Widget _buildSkeleton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 235,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          color: Colors.grey.shade200,
        ),
        child: _ShimmerBox(
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          width: 80, height: 18,
                          decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(6))),
                      const SizedBox(height: 14),
                      Container(
                          width: double.infinity, height: 28,
                          decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(6))),
                      const SizedBox(height: 10),
                      Container(
                          width: 160, height: 14,
                          decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(6))),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(28),
                child: Container(
                  width: 110, height: 110,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(22)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// No active campaign empty state.
  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          color: YensTheme.yellowSoft,
          border: Border.all(color: YensTheme.yellow.withValues(alpha: 0.4)),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.local_offer_outlined,
                  color: YensTheme.navy.withValues(alpha: 0.4), size: 40),
              const SizedBox(height: 12),
              YensTranslateText(
                'No active offers right now',
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: YensTheme.navy.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 4),
              YensTranslateText(
                'Check back soon for weekly specials!',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: YensTheme.navy.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Error state with retry button.
  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          color: Colors.red.shade50,
          border: Border.all(color: Colors.red.shade100),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wifi_off_rounded,
                  color: Colors.red.shade300, size: 36),
              const SizedBox(height: 10),
              YensTranslateText(
                'Could not load promotions',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.red.shade400,
                ),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () => _fetchWeeklySpecial(forceRefresh: true),
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: Text('Retry',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
                style: TextButton.styleFrom(foregroundColor: YensTheme.navy),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Internal data models
// ---------------------------------------------------------------------------

enum _SlideType { featuredProduct, weeklySpecial }

class _PromoSlide {
  final _SlideType type;
  final String title;
  final String subtitle;
  final String badge;
  final String? imageUrl;
  final Color? accent;
  final String? footerText;
  final String? bonusPoints;

  const _PromoSlide({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.badge,
    this.imageUrl,
    this.accent,
    this.footerText,
    this.bonusPoints,
  });
}

// ---------------------------------------------------------------------------
// Shimmer animation box
// ---------------------------------------------------------------------------

class _ShimmerBox extends StatefulWidget {
  final Widget child;
  const _ShimmerBox({required this.child});

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, child) => Opacity(opacity: _anim.value, child: child),
      child: widget.child,
    );
  }
}
