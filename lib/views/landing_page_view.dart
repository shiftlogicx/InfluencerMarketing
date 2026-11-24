import 'package:flutter/material.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/pulse_logo.dart';
import 'auth_sso_dialog.dart';
import 'influencer_detail_modal.dart';

class LandingPageView extends StatelessWidget {
  final AppState appState;

  const LandingPageView({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 860;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // Apple ambient background glow
          Positioned(
            top: -120,
            left: MediaQuery.of(context).size.width / 2 - 320,
            width: 640,
            height: 480,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.appleBlue.withValues(alpha: 0.12),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.7],
                ),
              ),
            ),
          ),

          // Scrollable Landing Page
          SingleChildScrollView(
            child: Column(
              children: [
                // Frosted Top Header
                _buildHeader(context, isWide),

                // Hero Section
                _buildHero(context, isWide),

                const SizedBox(height: 60),

                // Dual Track Value Section (Brands vs Creators)
                _buildDualTrackSection(context, isWide),

                const SizedBox(height: 60),

                // Featured Regional Creators Teaser
                _buildFeaturedCreatorsPreview(context, isWide),

                const SizedBox(height: 60),

                // Pricing Overview
                _buildPricingSection(context, isWide),

                const SizedBox(height: 60),

                // Footer
                _buildFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isWide) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isWide ? 48 : 20, vertical: 18),
      decoration: BoxDecoration(
        color: AppTheme.background.withValues(alpha: 0.8),
        border: const Border(bottom: BorderSide(color: AppTheme.borderSubtle)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          Row(
            children: [
              const PulseLogoMark(size: 32, isBrand: true),
              const SizedBox(width: 10),
              Text(
                "Influencer Pulse",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
              ),
            ],
          ),

          // Action Buttons
          Row(
            children: [
              TextButton(
                onPressed: () {
                  appState.enterAppWithRole('brand');
                },
                child: const Text("Explore Creators", style: TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () {
                  AuthSsoDialog.show(context, appState);
                },
                icon: const Icon(Icons.phone_iphone, size: 16),
                label: const Text("Mobile OTP Login", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.appleBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHero(BuildContext context, bool isWide) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isWide ? 40 : 20, vertical: 60),
      constraints: const BoxConstraints(maxWidth: 1000),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.surfaceElevated,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.borderSubtle),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.flash_on, color: AppTheme.appleBlue, size: 14),
                SizedBox(width: 6),
                Text(
                  "REGIONAL MICRO-INFLUENCER MARKETPLACE • ZERO AGENCY MARGINS",
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textSecondary, letterSpacing: 0.6),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Direct brand collaborations.\nZero agency markups.",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: isWide ? 56 : 36,
                  height: 1.12,
                  letterSpacing: -1.5,
                ),
          ),
          const SizedBox(height: 18),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Text(
              "Connect directly with regional food bloggers, tech reviewers, and lifestyle creators in Pune, Mumbai, Bangalore, and across India. Unblur verified phone, WhatsApp, and work emails with complete transparent pricing.",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16, height: 1.55),
            ),
          ),
          const SizedBox(height: 36),
          Wrap(
            spacing: 16,
            runSpacing: 14,
            alignment: WrapAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  AuthSsoDialog.show(context, appState, targetRole: 'brand', onCompleted: () {
                    appState.enterAppWithRole('brand');
                  });
                },
                icon: const Icon(Icons.business_center, size: 18),
                label: const Text("I'm a Brand Looking to Hire", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.appleBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  AuthSsoDialog.show(context, appState, targetRole: 'influencer', onCompleted: () {
                    appState.enterAppWithRole('influencer');
                  });
                },
                icon: const Icon(Icons.stars, color: AppTheme.appleGold, size: 18),
                label: const Text("I'm a Creator Joining the Roster", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.appleGold,
                  side: const BorderSide(color: AppTheme.appleGold),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDualTrackSection(BuildContext context, bool isWide) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 1100),
      padding: EdgeInsets.symmetric(horizontal: isWide ? 40 : 20),
      child: LayoutBuilder(
        builder: (ctx, constraints) {
          final isNarrow = constraints.maxWidth < 750;

          return Flex(
            direction: isNarrow ? Axis.vertical : Axis.horizontal,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // For Brands Card
              Expanded(
                flex: isNarrow ? 0 : 1,
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppTheme.appleBlue.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.appleBlue.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text("FOR BRANDS & BUSINESSES", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.appleBlue, letterSpacing: 0.6)),
                      ),
                      const SizedBox(height: 16),
                      Text("Hire Local Influence at Real Rates", style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 10),
                      const Text(
                        "Stop paying 30-50% margins to talent agencies. Filter by location and niche, review past campaign photos, and unblur direct WhatsApp & phone coordinates with our ₹49/month pass.",
                        style: TextStyle(color: AppTheme.textSecondary, height: 1.5, fontSize: 13),
                      ),
                      const SizedBox(height: 20),
                      _buildCheckItem("Geo-filtered discovery (Pune, Mumbai, etc.)"),
                      _buildCheckItem("Direct WhatsApp, Phone, and Work Email unblur"),
                      _buildCheckItem("Zero commission on creator deals"),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          if (appState.isAuthenticated) {
                            appState.enterAppWithRole('brand');
                          } else {
                            AuthSsoDialog.show(context, appState, targetRole: 'brand', onCompleted: () {
                              appState.enterAppWithRole('brand');
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.appleBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text("Browse Regional Creators"),
                      )
                    ],
                  ),
                ),
              ),

              if (!isNarrow) const SizedBox(width: 24) else const SizedBox(height: 24),

              // For Creators Card
              Expanded(
                flex: isNarrow ? 0 : 1,
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppTheme.appleGold.withValues(alpha: 0.35)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.appleGold.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text("FOR CREATORS & INFLUENCERS", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.appleGold, letterSpacing: 0.6)),
                      ),
                      const SizedBox(height: 16),
                      Text("Get Inbound Leads from Local Brands", style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 10),
                      const Text(
                        "Build your professional creator portfolio, set your reel rate, and claim your early access Gold Pass. Receive real-time lead alerts whenever a verified brand views your profile.",
                        style: TextStyle(color: AppTheme.textSecondary, height: 1.5, fontSize: 13),
                      ),
                      const SizedBox(height: 20),
                      _buildCheckItem("Gold Tier: ~₹149~ FREE for early access"),
                      _buildCheckItem("Real-time brand profile view lead alerts"),
                      _buildCheckItem("Keep 100% of your collaboration fees"),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          if (appState.isAuthenticated) {
                            appState.enterAppWithRole('influencer');
                          } else {
                            AuthSsoDialog.show(context, appState, targetRole: 'influencer', onCompleted: () {
                              appState.enterAppWithRole('influencer');
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.appleGold,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text("Join as Creator (Claim Free Gold)"),
                      )
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCheckItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle, size: 16, color: AppTheme.appleGreen),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedCreatorsPreview(BuildContext context, bool isWide) {
    final sample = appState.influencers.take(3).toList();

    return Container(
      constraints: const BoxConstraints(maxWidth: 1100),
      padding: EdgeInsets.symmetric(horizontal: isWide ? 40 : 20),
      child: Column(
        children: [
          Text("Featured Regional Creators", style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          const Text("Live preview of verified creators across Maharashtra and Karnataka", style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isWide ? 3 : 1,
              crossAxisSpacing: 18,
              mainAxisSpacing: 18,
              childAspectRatio: 0.85,
            ),
            itemCount: sample.length,
            itemBuilder: (ctx, idx) {
              final creator = sample[idx];
              return InkWell(
                onTap: () => InfluencerDetailModal.show(context, creator, appState),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.borderSubtle),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                        child: Image.network(
                          creator.portfolioImages[0],
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(creator.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                                Text("₹${creator.pricePerReel.toInt()} / reel", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.appleGold)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text("${creator.category} • ${creator.city}", style: const TextStyle(fontSize: 12, color: AppTheme.appleBlue)),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              height: 36,
                              child: ElevatedButton(
                                onPressed: () => InfluencerDetailModal.show(context, creator, appState),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.surfaceElevated,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  elevation: 0,
                                  side: const BorderSide(color: AppTheme.borderSubtle),
                                ),
                                child: const Text("View Profile", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPricingSection(BuildContext context, bool isWide) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 900),
      padding: EdgeInsets.symmetric(horizontal: isWide ? 40 : 20),
      child: Column(
        children: [
          Text("Transparent, Fair Pricing", style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          const Text("Zero hidden fees. Built on Razorpay API.", style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          const SizedBox(height: 28),
          LayoutBuilder(
            builder: (ctx, constraints) {
              final isNarrow = constraints.maxWidth < 600;

              return Flex(
                direction: isNarrow ? Axis.vertical : Axis.horizontal,
                children: [
                  Expanded(
                    flex: isNarrow ? 0 : 1,
                    child: Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.appleBlue.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Brand Access Pass", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                          const SizedBox(height: 8),
                          const Text("₹49 / month", style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppTheme.appleBlue)),
                          const SizedBox(height: 12),
                          const Text("Unblur verified WhatsApp, phone & work email coordinates across all regional creators in India.", style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                        ],
                      ),
                    ),
                  ),
                  if (!isNarrow) const SizedBox(width: 20) else const SizedBox(height: 16),
                  Expanded(
                    flex: isNarrow ? 0 : 1,
                    child: Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.appleGold.withValues(alpha: 0.4)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Creator Early Access Gold", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text("₹149", style: TextStyle(fontSize: 18, color: AppTheme.textTertiary, decoration: TextDecoration.lineThrough)),
                              const SizedBox(width: 8),
                              const Text("FREE (90 Days)", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppTheme.appleGold)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text("Full brand view visibility, portfolio showcase, and direct lead notifications to your work email.", style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      alignment: Alignment.center,
      child: const Text(
        "Influencer Pulse Technologies • Support: shiftlogiciq@gmail.com",
        style: TextStyle(fontSize: 12, color: AppTheme.textTertiary),
      ),
    );
  }
}
