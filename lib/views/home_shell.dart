import 'package:flutter/material.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/pulse_logo.dart';
import 'brand_discovery_view.dart';
import 'influencer_detail_modal.dart';
import 'influencer_onboarding_wizard.dart';
import 'landing_page_view.dart';
import 'notification_engine_view.dart';
import 'profile_settings_modal.dart';
import 'support_faq_view.dart';
import 'paywall_modal.dart';

class HomeShell extends StatefulWidget {
  final AppState appState;

  const HomeShell({super.key, required this.appState});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _selectedTabIndex = 0;

  @override
  void didUpdateWidget(covariant HomeShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.appState.currentRole != widget.appState.currentRole) {
      _selectedTabIndex = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.appState;

    // If user is not inside the app dashboard, show the Public Landing Page!
    if (!state.isInApp) {
      return LandingPageView(appState: state);
    }

    final isBrand = state.isBrand;
    final isSubscribed = state.brandUser.isSubscribed;
    final isWide = MediaQuery.of(context).size.width > 920;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // Ambient background glow
          Positioned(
            top: -150,
            left: MediaQuery.of(context).size.width / 2 - 300,
            width: 600,
            height: 400,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    (isBrand ? AppTheme.appleBlue : AppTheme.appleGold).withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.7],
                ),
              ),
            ),
          ),

          // Main Column layout
          Column(
            children: [
              // Top Frosted Navigation Bar
              _buildTopNavBar(isWide, state, isBrand, isSubscribed),

              // Active Tab Content
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _buildCurrentTabContent(state, isBrand),
                ),
              ),
            ],
          ),

          // Bottom Floating Status Banner
          if (state.statusBanner != null)
            Positioned(
              bottom: 24,
              left: 24,
              right: 24,
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 580),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceElevated,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.appleBlue.withValues(alpha: 0.4)),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black87,
                        blurRadius: 30,
                        spreadRadius: 4,
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline, color: AppTheme.appleGreen, size: 18),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          state.statusBanner!,
                          style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w500),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 16, color: AppTheme.textSecondary),
                        onPressed: () => state.clearStatusBanner(),
                      )
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTopNavBar(bool isWide, AppState state, bool isBrand, bool isSubscribed) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isWide ? 32 : 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.background.withValues(alpha: 0.85),
        border: const Border(bottom: BorderSide(color: AppTheme.borderSubtle)),
      ),
      child: Row(
        children: [
          // Logo & Return to Landing Page
          InkWell(
            onTap: () {
              state.goToHome();
            },
            child: Row(
              children: [
                PulseLogoMark(size: 32, isBrand: isBrand),
                const SizedBox(width: 10),
                Text(
                  "Influencer Pulse",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: (isBrand ? AppTheme.appleBlue : AppTheme.appleGold).withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isBrand ? "BRAND" : "CREATOR",
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: isBrand ? AppTheme.appleBlue : AppTheme.appleGold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // If Brand, place Brand Profile option on the left-hand side as requested!
          if (isBrand) ...[
            const SizedBox(width: 14),
            InkWell(
              onTap: () => ProfileSettingsModal.show(context, state),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.borderSubtle),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.menu, size: 14, color: AppTheme.appleBlue),
                    const SizedBox(width: 6),
                    if (state.userPhotoUrl.isNotEmpty) ...[
                      CircleAvatar(
                        radius: 8,
                        backgroundImage: NetworkImage(state.userPhotoUrl),
                      ),
                      const SizedBox(width: 6),
                    ],
                    const Text(
                      "Brand Profile",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // If Creator, place Creator Profile option on the left-hand side as requested!
          if (!isBrand) ...[
            const SizedBox(width: 14),
            InkWell(
              onTap: () => setState(() => _selectedTabIndex = 99),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _selectedTabIndex == 99
                      ? AppTheme.appleGold.withValues(alpha: 0.2)
                      : AppTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _selectedTabIndex == 99 ? AppTheme.appleGold : AppTheme.borderSubtle,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 9,
                      backgroundImage: NetworkImage(
                        state.activeInfluencer.portfolioImages.isNotEmpty
                            ? state.activeInfluencer.portfolioImages[0]
                            : "https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=200&q=80",
                      ),
                    ),
                    const SizedBox(width: 7),
                    Text(
                      "Creator Profile",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: _selectedTabIndex == 99 ? FontWeight.w700 : FontWeight.w500,
                        color: _selectedTabIndex == 99 ? AppTheme.appleGold : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(width: 24),

          // Center Navigation Tabs
          if (isWide)
            Expanded(
              child: Row(
                children: isBrand
                    ? [
                        _buildNavTabItem("Discover Feed", 0, Icons.explore_outlined),
                        _buildNavTabItem("Unlocked Contacts", 1, Icons.contact_phone_outlined),
                        _buildNavTabItem("Support & FAQs", 2, Icons.help_outline),
                      ]
                    : [
                        _buildNavTabItem("Leads Dashboard", 0, Icons.dashboard_outlined),
                        _buildNavTabItem("Support & FAQs", 1, Icons.help_outline),
                      ],
              ),
            )
          else
            const Spacer(),

          // Right Profile & Quick Actions
          Row(
            children: [
              // Pass or Upgrade Pill
              if (isBrand)
                InkWell(
                  onTap: () {
                    PaywallModal.show(context, state, target: 'brand_unlock');
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: isSubscribed ? AppTheme.appleGreen.withValues(alpha: 0.15) : AppTheme.appleBlue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSubscribed ? Icons.check_circle : Icons.lock_open,
                          size: 14,
                          color: isSubscribed ? AppTheme.appleGreen : Colors.white,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isSubscribed ? "Brand Pass Active" : "Get Brand Pass",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isSubscribed ? AppTheme.appleGreen : Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                InkWell(
                  onTap: () {
                    PaywallModal.show(context, state, target: 'influencer_upgrade');
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppTheme.appleGold.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.appleGold.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.stars, size: 14, color: AppTheme.appleGold),
                        const SizedBox(width: 6),
                        Text(
                          state.activeInfluencer.membershipTier.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.appleGold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(width: 12),

              // Switch Persona Button
              InkWell(
                onTap: () {
                  state.switchRole(isBrand ? 'influencer' : 'brand');
                  setState(() => _selectedTabIndex = 0);
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceElevated,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.borderSubtle),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.swap_horiz, size: 16, color: isBrand ? AppTheme.appleBlue : AppTheme.appleGold),
                      const SizedBox(width: 6),
                      Text(
                        isBrand ? "Switch to Creator" : "Switch to Brand",
                        style: const TextStyle(fontSize: 12, color: AppTheme.textPrimary, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // User Profile & Settings Button
              InkWell(
                onTap: () {
                  ProfileSettingsModal.show(context, state);
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceElevated,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.borderSubtle),
                  ),
                  child: Row(
                    children: [
                      if (state.userPhotoUrl.isNotEmpty)
                        CircleAvatar(
                          radius: 9,
                          backgroundImage: NetworkImage(state.userPhotoUrl),
                        )
                      else
                        Container(
                          width: 18,
                          height: 18,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Text(
                              "G",
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.blue),
                            ),
                          ),
                        ),
                      if (isWide && state.userEmail.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Text(
                          state.userEmail,
                          style: const TextStyle(fontSize: 12, color: AppTheme.textPrimary, fontWeight: FontWeight.w500),
                        ),
                      ],
                      const SizedBox(width: 6),
                      const Icon(Icons.settings_outlined, size: 14, color: AppTheme.textSecondary),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavTabItem(String label, int index, IconData icon) {
    final isSelected = _selectedTabIndex == index;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: TextButton.icon(
        onPressed: () => setState(() => _selectedTabIndex = index),
        icon: Icon(
          icon,
          size: 16,
          color: isSelected ? (widget.appState.isBrand ? AppTheme.appleBlue : AppTheme.appleGold) : AppTheme.textSecondary,
        ),
        label: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? Colors.white : AppTheme.textSecondary,
          ),
        ),
        style: TextButton.styleFrom(
          backgroundColor: isSelected ? AppTheme.surfaceElevated : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildCurrentTabContent(AppState state, bool isBrand) {
    // 1. If Brand user is not yet onboarded, show Brand Onboarding view first!
    if (isBrand && !state.isOnboarded) {
      return _buildBrandOnboardingView(state);
    }

    // 2. If Creator user is not yet onboarded, show Creator Onboarding Wizard first!
    if (!isBrand && !state.isOnboarded) {
      return InfluencerOnboardingWizard(
        appState: state,
        onGoToLeads: () => setState(() => _selectedTabIndex = 0),
      );
    }

    // Normal Onboarded Views
    if (isBrand) {
      switch (_selectedTabIndex) {
        case 0:
          return BrandDiscoveryView(
            appState: state,
            onSelectInfluencer: (creator) {
              state.recordProfileClick(creator, state.filteredInfluencers);
              InfluencerDetailModal.show(context, creator, state);
            },
          );
        case 1:
          return _buildUnlockedLeadsView(state);
        case 2:
          return SupportFaqView(appState: state);
        default:
          return BrandDiscoveryView(
            appState: state,
            onSelectInfluencer: (creator) {
              state.recordProfileClick(creator, state.filteredInfluencers);
              InfluencerDetailModal.show(context, creator, state);
            },
          );
      }
    } else {
      // Creator: only Leads Dashboard and Support & FAQs (or Creator Profile if tab index is 99)
      switch (_selectedTabIndex) {
        case 0:
          return NotificationEngineView(appState: state);
        case 1:
          return SupportFaqView(appState: state);
        case 99:
          return InfluencerOnboardingWizard(
            appState: state,
            onGoToLeads: () => setState(() => _selectedTabIndex = 0),
          );
        default:
          return NotificationEngineView(appState: state);
      }
    }
  }

  // Inline Brand Onboarding View for first-time brand log-ins
  Widget _buildBrandOnboardingView(AppState state) {
    final companyController = TextEditingController(text: state.brandUser.companyName != "Brand Enterprise" ? state.brandUser.companyName : "");
    final contactController = TextEditingController(text: state.userName != "Brand Partner" ? state.userName : "");
    final verifiedPhone = state.userPhone.isNotEmpty ? state.userPhone : (state.brandUser.phone.isNotEmpty ? state.brandUser.phone : "+91 98220 81132");
    final areaController = TextEditingController(text: state.brandArea.isNotEmpty ? state.brandArea : "Koregaon Park");
    String industry = "Food & Beverage / Hospitality";
    String city = state.selectedCity;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 580),
          padding: const EdgeInsets.all(36),
          decoration: BoxDecoration(
            color: const Color(0xFF13131A),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.appleBlue.withValues(alpha: 0.4), width: 1.5),
            boxShadow: const [
              BoxShadow(
                color: Colors.black87,
                blurRadius: 40,
                spreadRadius: 8,
              )
            ],
          ),
          child: StatefulBuilder(
            builder: (ctx, setInternal) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const PulseLogoMark(size: 40, isBrand: true),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Welcome! Setup Your Brand Profile",
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
                            ),
                            Text(
                              "Verified Mobile: $verifiedPhone. Complete business setup to access regional creators.",
                              style: const TextStyle(fontSize: 12, color: Color(0xFF8E8E93)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: AppTheme.borderSubtle),
                  const SizedBox(height: 20),

                  // GPS Location Preview
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B1B26),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.appleBlue.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.my_location, color: AppTheme.appleBlue, size: 16),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Location Detected: ${state.detectedCity}, Maharashtra • Geolocation Enabled",
                            style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  TextField(
                    controller: companyController,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: const InputDecoration(
                      labelText: "Brand / Enterprise Business Name",
                      hintText: "e.g. Blue Tokai Coffee Roasters",
                      prefixIcon: Icon(Icons.business_outlined, size: 18),
                    ),
                  ),
                  const SizedBox(height: 14),

                  TextField(
                    controller: areaController,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: const InputDecoration(
                      labelText: "Business Area / Neighborhood",
                      hintText: "e.g. Koregaon Park, Baner, Bandra West",
                      prefixIcon: Icon(Icons.place_outlined, size: 18),
                    ),
                  ),
                  const SizedBox(height: 14),

                  TextField(
                    controller: contactController,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: const InputDecoration(
                      labelText: "Campaign Manager / Contact Person",
                      hintText: "e.g. Vikram Sharma",
                      prefixIcon: Icon(Icons.person_outline, size: 18),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Verified Mobile Field
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B1B26),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.borderSubtle),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.phone_android, size: 18, color: AppTheme.appleBlue),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Official Contact / WhatsApp Phone", style: TextStyle(fontSize: 10, color: Color(0xFF8E8E93))),
                              const SizedBox(height: 2),
                              Text(verifiedPhone, style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.appleGreen.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.check_circle, size: 12, color: AppTheme.appleGreen),
                              SizedBox(width: 4),
                              Text("OTP Verified", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.appleGreen)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  DropdownButtonFormField<String>(
                    value: industry,
                    dropdownColor: const Color(0xFF1D1D28),
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: const InputDecoration(
                      labelText: "Brand Industry",
                      prefixIcon: Icon(Icons.category_outlined, size: 18),
                    ),
                    items: const [
                      DropdownMenuItem(value: "Food & Beverage / Hospitality", child: Text("Food & Beverage / Hospitality")),
                      DropdownMenuItem(value: "Fashion, Apparel & Lifestyle", child: Text("Fashion, Apparel & Lifestyle")),
                      DropdownMenuItem(value: "Tech, Gadgets & Electronics", child: Text("Tech, Gadgets & Electronics")),
                      DropdownMenuItem(value: "Health, Fitness & Nutrition", child: Text("Health, Fitness & Nutrition")),
                      DropdownMenuItem(value: "Marketing / Creative Agency", child: Text("Marketing / Creative Agency")),
                    ],
                    onChanged: (v) {
                      if (v != null) setInternal(() => industry = v);
                    },
                  ),
                  const SizedBox(height: 14),

                  DropdownButtonFormField<String>(
                    value: city,
                    dropdownColor: const Color(0xFF1D1D28),
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: const InputDecoration(
                      labelText: "Primary Campaign City",
                      prefixIcon: Icon(Icons.location_city, size: 18),
                    ),
                    items: const [
                      DropdownMenuItem(value: "Pune", child: Text("Pune, Maharashtra")),
                      DropdownMenuItem(value: "Mumbai", child: Text("Mumbai, Maharashtra")),
                      DropdownMenuItem(value: "Bengaluru", child: Text("Bengaluru, Karnataka")),
                      DropdownMenuItem(value: "Delhi NCR", child: Text("Delhi NCR")),
                    ],
                    onChanged: (v) {
                      if (v != null) setInternal(() => city = v);
                    },
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        final comp = companyController.text.trim().isNotEmpty
                            ? companyController.text.trim()
                            : "Enterprise Brand";
                        final contact = contactController.text.trim().isNotEmpty
                            ? contactController.text.trim()
                            : "Brand Partner";
                        final area = areaController.text.trim().isNotEmpty
                            ? areaController.text.trim()
                            : "Koregaon Park";

                        state.completeBrandOnboarding(
                          companyName: comp,
                          contactPerson: contact,
                          phone: verifiedPhone,
                          industry: industry,
                          city: city,
                          area: area,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.appleBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Complete Onboarding & View Regional Feed",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // Brand Unlocked Leads View
  Widget _buildUnlockedLeadsView(AppState state) {
    final unlocked = state.unlockedInfluencers;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Unlocked Creator Coordinates",
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        state.brandUser.isSubscribed
                            ? "Brand Pass active: You have unblurred direct access to all regional creators."
                            : "Direct phone, email, and social coordinates unlocked for your campaigns.",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  if (!state.brandUser.isSubscribed)
                    ElevatedButton(
                      onPressed: () => PaywallModal.show(context, state, target: 'brand_unlock'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.appleBlue,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("Unlock All with Brand Pass"),
                    ),
                ],
              ),
              const SizedBox(height: 24),

              if (unlocked.isEmpty)
                Container(
                  padding: const EdgeInsets.all(40),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.borderSubtle),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.lock_open, size: 40, color: AppTheme.textTertiary),
                      const SizedBox(height: 14),
                      const Text(
                        "No creator coordinates unlocked yet.",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Browse creators in the Discover Feed and unblur coordinates to start collaborating.",
                        style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                      ),
                      const SizedBox(height: 18),
                      ElevatedButton(
                        onPressed: () => setState(() => _selectedTabIndex = 0),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.appleBlue,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("Explore Creators in Discover Feed"),
                      )
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: unlocked.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (ctx, idx) {
                    final creator = unlocked[idx];
                    return Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.borderSubtle),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              creator.portfolioImages.isNotEmpty
                                  ? creator.portfolioImages[0]
                                  : "https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=200&q=80",
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      creator.name,
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppTheme.surfaceElevated,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        creator.category,
                                        style: const TextStyle(fontSize: 10, color: AppTheme.appleBlue, fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Phone: ${creator.contactPrimary} • Email: ${creator.emailWork} • ${creator.city}",
                                  style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              InfluencerDetailModal.show(context, creator, state);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.surfaceElevated,
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: AppTheme.borderSubtle),
                            ),
                            child: const Text("View Profile", style: TextStyle(fontSize: 12)),
                          )
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
