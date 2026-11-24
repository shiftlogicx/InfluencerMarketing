import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/influencer.dart';
import '../models/profile_view.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';

class NotificationEngineView extends StatelessWidget {
  final AppState appState;

  const NotificationEngineView({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    final creator = appState.activeInfluencer;
    final views = appState.profileViews;
    final isGoldOrBurgundy = creator.isGold || creator.isBurgundy;
    final isWide = MediaQuery.of(context).size.width > 860;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: isWide ? 40 : 16, vertical: 24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(context, creator),

              const SizedBox(height: 28),

              // Metric KPI Tiles
              _buildMetricCards(creator, views.length),

              const SizedBox(height: 28),

              // Recent Brand Profile Views Feed
              _buildViewsFeed(context, views, isGoldOrBurgundy, creator),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Influencer creator) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.surfaceElevated,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.borderSubtle),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.trending_up, color: AppTheme.appleGold, size: 14),
              SizedBox(width: 6),
              Text(
                "REAL-TIME BRAND ENGAGEMENT",
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.appleGold, letterSpacing: 0.8),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Brand Inquiries & Profile Views",
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: 6),
                const Text(
                  "Whenever a local business searches your niche and views your media kit, an inbound alert is logged here.",
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: creator.isBurgundy
                    ? AppTheme.royalBurgundy.withValues(alpha: 0.2)
                    : (creator.isGold ? AppTheme.appleGold.withValues(alpha: 0.2) : AppTheme.surfaceElevated),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: creator.isBurgundy
                      ? AppTheme.royalBurgundy
                      : (creator.isGold ? AppTheme.appleGold : AppTheme.borderSubtle),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    creator.isBurgundy ? Icons.diamond : (creator.isGold ? Icons.stars : Icons.person_outline),
                    size: 16,
                    color: creator.isBurgundy ? Colors.white : (creator.isGold ? AppTheme.appleGold : AppTheme.textSecondary),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    creator.membershipTier.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: creator.isBurgundy ? Colors.white : (creator.isGold ? AppTheme.appleGold : AppTheme.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCards(Influencer creator, int totalViews) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final isSmall = constraints.maxWidth < 650;

        return GridView.count(
          crossAxisCount: isSmall ? 2 : 4,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: isSmall ? 1.4 : 1.7,
          children: [
            _buildMetricTile("Search Feed Impressions", "${creator.impressionsCount + 48}", "+34% this week", Icons.remove_red_eye_outlined, AppTheme.appleBlue),
            _buildMetricTile("Direct Profile Views", "${creator.viewsCount + totalViews}", "100% verified brands", Icons.touch_app_outlined, AppTheme.appleGold),
            _buildMetricTile("Profile Click Rate", "${((creator.viewsCount + totalViews) / (creator.impressionsCount + 48) * 100).toStringAsFixed(1)}%", "High engagement", Icons.trending_up, AppTheme.appleGreen),
            _buildMetricTile("Avg Inquiry Response", "< 2 hrs", "Same-day bookings", Icons.bolt, AppTheme.appleOrange),
          ],
        );
      },
    );
  }

  Widget _buildMetricTile(String title, String value, String sub, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
              Icon(icon, size: 16, color: color),
            ],
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white),
          ),
          Text(sub, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildViewsFeed(BuildContext context, List<ProfileView> views, bool isGoldOrBurgundy, Influencer creator) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Recent Brand Views",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.appleGold.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  "INBOUND BRAND ACTIVITY",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.appleGold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          if (views.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text("No brand views recorded yet.", style: TextStyle(color: AppTheme.textSecondary)),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: views.length,
              separatorBuilder: (_, __) => const Divider(color: AppTheme.borderFaint, height: 20),
              itemBuilder: (ctx, idx) {
                final view = views[idx];
                return _buildViewItem(context, view, isGoldOrBurgundy);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildViewItem(BuildContext context, ProfileView view, bool isGoldOrBurgundy) {
    final timeStr = DateFormat('hh:mm a, dd MMM').format(view.createdAt);
    final isDirectInquiry = view.isDirectConnect ||
        view.brandCategory.contains("Connection") ||
        view.brandCategory.contains("Inquiry");
    final areaText = view.brandArea.isNotEmpty ? view.brandArea : "Koregaon Park";
    final locationCity = view.brandLocation.contains(',')
        ? view.brandLocation.split(',').last.trim()
        : "Pune";
    final phoneText = view.brandPhone.isNotEmpty ? view.brandPhone : "+91 98220 81132";
    final isUnlocked = view.isUnlockedByCreator;

    // Stage 2: Direct Inquiry from brand
    if (isDirectInquiry) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.appleGreen.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.appleGreen.withValues(alpha: 0.35)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.appleGreen.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.send_rounded, color: AppTheme.appleGreen, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        view.brandName,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.verified, size: 14, color: AppTheme.appleBlue),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.appleGreen.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          "DIRECT INQUIRY LEAD",
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppTheme.appleGreen, letterSpacing: 0.4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Directly Visible Phone Number & Location
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E2822),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppTheme.appleGreen.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.phone_android, size: 12, color: AppTheme.appleGreen),
                            const SizedBox(width: 4),
                            Text(
                              phoneText,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "• $areaText, $locationCity",
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white70),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Brand sent a direct collaboration inquiry • ${view.brandEmail}",
                    style: const TextStyle(fontSize: 11, color: Color(0xFF8E8E93)),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(timeStr, style: const TextStyle(fontSize: 11, color: AppTheme.textTertiary)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.appleGreen.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text("Ready to Book", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.appleGreen)),
                ),
              ],
            )
          ],
        ),
      );
    }

    // Stage 1: Brand ONLY viewed profile (did not send direct inquiry)
    if (isUnlocked) {
      // Unlocked State: reveals brand name and verified phone number
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.borderSubtle),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.appleBlue.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.business, color: AppTheme.appleBlue, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        view.brandName,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.verified, size: 14, color: AppTheme.appleBlue),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.appleBlue.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text("IDENTITY UNBLURRED", style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppTheme.appleBlue)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.phone_android, size: 12, color: AppTheme.appleBlue),
                      const SizedBox(width: 4),
                      Text(phoneText, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                      const SizedBox(width: 8),
                      Text("• $areaText, $locationCity • ${view.brandEmail}", style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(timeStr, style: const TextStyle(fontSize: 11, color: AppTheme.textTertiary)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.appleBlue.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text("Profile Viewed", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.appleBlue)),
                ),
              ],
            )
          ],
        ),
      );
    } else {
      // Locked State: First initials visible, rest literally blurred, location clearly visible!
      final rawName = view.brandName.trim();
      final initials = rawName.length >= 2 ? rawName.substring(0, 2) : (rawName.isNotEmpty ? rawName : "Br");
      final restOfName = rawName.length >= 2 ? rawName.substring(2) : "and Enterprise";

      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.appleGold.withValues(alpha: 0.3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.appleGold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.visibility_outlined, color: AppTheme.appleGold, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // First initials visible, rest of brand name literally blurred
                  Row(
                    children: [
                      Text(
                        initials,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.5),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: ImageFiltered(
                          imageFilter: ImageFilter.blur(sigmaX: 7.0, sigmaY: 7.0),
                          child: Text(
                            restOfName,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white70),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.appleGold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text("IDENTITY BLURRED", style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppTheme.appleGold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),

                  // Location clearly visible!
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 13, color: AppTheme.appleBlue),
                      const SizedBox(width: 4),
                      Text(
                        "From $areaText, $locationCity",
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: ImageFiltered(
                          imageFilter: ImageFilter.blur(sigmaX: 5.5, sigmaY: 5.5),
                          child: const Text("• +91 98•••••••• • brand@••••.in", style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    "Brand from $areaText inspected your media kit & reel pricing.",
                    style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () {
                appState.unlockProfileViewDetails(view.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Brand Identity Unlocked (~₹149~ FREE)! Reach out on ${view.brandPhone}."),
                    backgroundColor: AppTheme.appleGreen,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.appleGold,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Unblur Brand", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                  Text("~₹149~ ₹0 FREE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF6B4500))),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }
}
