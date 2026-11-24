import 'package:flutter/material.dart';
import '../models/influencer.dart';
import '../services/app_state.dart';
import '../services/mock_data.dart';
import '../theme/app_theme.dart';
import 'paywall_modal.dart';

class InfluencerOnboardingWizard extends StatefulWidget {
  final AppState appState;
  final VoidCallback? onGoToLeads;

  const InfluencerOnboardingWizard({super.key, required this.appState, this.onGoToLeads});

  @override
  State<InfluencerOnboardingWizard> createState() => _InfluencerOnboardingWizardState();
}

class _InfluencerOnboardingWizardState extends State<InfluencerOnboardingWizard> {
  int _activeSection = 0;
  bool _showOnboardedSuccess = false;
  final _formKey = GlobalKey<FormState>();

  // Form Controllers
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _addressController;
  late String _selectedCity;
  late String _selectedState;

  // Contact
  late TextEditingController _phonePrimaryController;
  late TextEditingController _phoneSecondaryController;
  late TextEditingController _emailPersonalController;
  late TextEditingController _emailWorkController;

  // Social Links
  late TextEditingController _igController;
  late TextEditingController _tgController;
  late TextEditingController _snapController;
  late TextEditingController _xController;
  late TextEditingController _ytController;

  // Commercials
  late String _category;
  late TextEditingController _priceController;
  final _collabInputController = TextEditingController();
  late List<String> _collabs;

  // Portfolio Images
  late List<String> _portfolioImages;

  final List<String> _presetImageBank = [
    "https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=800&q=80",
    "https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=800&q=80",
    "https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?auto=format&fit=crop&w=800&q=80",
    "https://images.unsplash.com/photo-1517838277536-f5f99be501cd?auto=format&fit=crop&w=800&q=80",
    "https://images.unsplash.com/photo-1526738549149-8e07eca6c147?auto=format&fit=crop&w=800&q=80",
    "https://images.unsplash.com/photo-1490481651871-ab68de25d43d?auto=format&fit=crop&w=800&q=80",
    "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=800&q=80",
  ];

  @override
  void initState() {
    super.initState();
    final creator = widget.appState.activeInfluencer;

    _nameController = TextEditingController(text: creator.name);
    _ageController = TextEditingController(text: creator.age.toString());
    _addressController = TextEditingController(text: creator.address);
    _selectedCity = creator.city;
    _selectedState = creator.state;

    _phonePrimaryController = TextEditingController(text: creator.contactPrimary);
    _phoneSecondaryController = TextEditingController(text: creator.contactSecondary);
    _emailPersonalController = TextEditingController(text: creator.emailPersonal);
    _emailWorkController = TextEditingController(
      text: widget.appState.userEmail.isNotEmpty ? widget.appState.userEmail : creator.emailWork,
    );

    _igController = TextEditingController(text: creator.socialLinks['ig'] ?? "https://instagram.com/creator");
    _tgController = TextEditingController(text: creator.socialLinks['tg'] ?? "https://t.me/creatorclub");
    _snapController = TextEditingController(text: creator.socialLinks['snap'] ?? "https://snapchat.com/add/creator");
    _xController = TextEditingController(text: creator.socialLinks['x'] ?? "https://x.com/creator");
    _ytController = TextEditingController(text: creator.socialLinks['yt'] ?? "https://youtube.com/@creator");

    _category = creator.category;
    _priceController = TextEditingController(text: creator.pricePerReel.toInt().toString());
    _collabs = List.from(creator.collabs);
    _portfolioImages = List.from(creator.portfolioImages);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _addressController.dispose();
    _phonePrimaryController.dispose();
    _phoneSecondaryController.dispose();
    _emailPersonalController.dispose();
    _emailWorkController.dispose();
    _igController.dispose();
    _tgController.dispose();
    _snapController.dispose();
    _xController.dispose();
    _ytController.dispose();
    _priceController.dispose();
    _collabInputController.dispose();
    super.dispose();
  }

  void _addCollabTag() {
    final text = _collabInputController.text.trim();
    if (text.isNotEmpty && !_collabs.contains(text)) {
      setState(() {
        _collabs.add(text);
        _collabInputController.clear();
      });
    }
  }

  void _removeCollabTag(String tag) {
    setState(() {
      _collabs.remove(tag);
    });
  }

  void _addSampleImage() {
    if (_portfolioImages.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Maximum 5 portfolio photos allowed.")),
      );
      return;
    }
    final nextImg = _presetImageBank[_portfolioImages.length % _presetImageBank.length];
    setState(() {
      _portfolioImages.add(nextImg);
    });
  }

  void _removeImage(int index) {
    if (_portfolioImages.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Keep at least 1 image for your portfolio.")),
      );
      return;
    }
    setState(() {
      _portfolioImages.removeAt(index);
    });
  }

  void _saveAndPublishProfile() async {
    final name = _nameController.text.trim().isEmpty ? "Verified Creator" : _nameController.text.trim();
    final price = double.tryParse(_priceController.text) ?? 2200.0;
    final age = int.tryParse(_ageController.text) ?? 24;

    final updated = widget.appState.activeInfluencer.copyWith(
      name: name,
      age: age,
      address: _addressController.text,
      city: _selectedCity,
      state: _selectedState,
      contactPrimary: _phonePrimaryController.text,
      contactSecondary: _phoneSecondaryController.text,
      emailPersonal: _emailPersonalController.text,
      emailWork: _emailWorkController.text,
      socialLinks: {
        "ig": _igController.text,
        "tg": _tgController.text,
        "snap": _snapController.text,
        "x": _xController.text,
        "yt": _ytController.text,
      },
      collabs: List.from(_collabs),
      category: _category,
      pricePerReel: price,
      portfolioImages: List.from(_portfolioImages),
    );

    await widget.appState.updateActiveInfluencer(updated);
    widget.appState.completeCreatorOnboarding(updated);

    if (!mounted) return;
    setState(() {
      _showOnboardedSuccess = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppTheme.appleGreen,
        content: Text("Portfolio saved to Supabase (users_influencer) & published live!", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final creator = widget.appState.activeInfluencer;
    final isWide = MediaQuery.of(context).size.width > 860;

    if (_showOnboardedSuccess) {
      return Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 620),
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          padding: const EdgeInsets.all(36),
          decoration: BoxDecoration(
            color: const Color(0xFF13131A),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.appleGreen.withValues(alpha: 0.5), width: 1.5),
            boxShadow: const [
              BoxShadow(
                color: Colors.black87,
                blurRadius: 40,
                spreadRadius: 8,
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.appleGreen.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle, color: AppTheme.appleGreen, size: 64),
              ),
              const SizedBox(height: 24),
              const Text(
                "Creator Profile Onboarded & Published!",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                "Your profile '${creator.name}' is actively discoverable by brands across ${creator.city} and India. All portfolio imagery is securely saved in Supabase Storage. You are ready to receive real-time brand inquiry alerts!",
                style: const TextStyle(fontSize: 13, color: Color(0xFF8E8E93), height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (widget.onGoToLeads != null) {
                      widget.onGoToLeads!();
                    } else {
                      setState(() => _showOnboardedSuccess = false);
                    }
                  },
                  icon: const Icon(Icons.dashboard_outlined, size: 18),
                  label: const Text("Go to Leads & Views Dashboard", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.appleGold,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => setState(() => _showOnboardedSuccess = false),
                child: const Text("Edit Portfolio Again", style: TextStyle(color: Color(0xFF8E8E93), fontSize: 13)),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: isWide ? 40 : 16, vertical: 24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 960),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gold Early Access Banner with Burgundy VIP Upgrade Option
              _buildEarlyAccessAndBurgundyBanner(creator),

              const SizedBox(height: 28),

              // Section Navigation Pills
              _buildSectionTabs(),

              const SizedBox(height: 24),

              // Editor Container
              Container(
                padding: EdgeInsets.all(isWide ? 32 : 20),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppTheme.borderSubtle),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_activeSection == 0) _buildSection0Basic(),
                      if (_activeSection == 1) _buildSection1Contact(),
                      if (_activeSection == 2) _buildSection2Social(),
                      if (_activeSection == 3) _buildSection3Commercials(),
                      if (_activeSection == 4) _buildSection4Portfolio(),

                      const SizedBox(height: 32),

                      // Persistent Action Row (Save & Publish button always accessible!)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (_activeSection > 0)
                            OutlinedButton.icon(
                              onPressed: () => setState(() => _activeSection--),
                              icon: const Icon(Icons.arrow_back, size: 16),
                              label: const Text("Previous Section"),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.textSecondary,
                                side: const BorderSide(color: AppTheme.borderSubtle),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            )
                          else
                            const SizedBox(),

                          Row(
                            children: [
                              if (_activeSection < 4)
                                TextButton(
                                  onPressed: () => setState(() => _activeSection++),
                                  child: const Text("Next Section →", style: TextStyle(color: AppTheme.appleBlue, fontSize: 13)),
                                ),
                              const SizedBox(width: 12),
                              ElevatedButton.icon(
                                onPressed: _saveAndPublishProfile,
                                icon: const Icon(Icons.check_circle_outline, size: 18),
                                label: const Text("Save & Publish Portfolio", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.appleGold,
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  elevation: 0,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEarlyAccessAndBurgundyBanner(Influencer creator) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.appleGold.withValues(alpha: 0.4)),
      ),
      child: LayoutBuilder(
        builder: (ctx, constraints) {
          final isNarrow = constraints.maxWidth < 680;

          return Flex(
            direction: isNarrow ? Axis.vertical : Axis.horizontal,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gold Early Access message
              Expanded(
                flex: isNarrow ? 0 : 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.appleGold.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.appleGold.withValues(alpha: 0.5)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.stars, color: AppTheme.appleGold, size: 14),
                              SizedBox(width: 6),
                              Text(
                                "EARLY CREATOR INVITATION",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.appleGold,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text(
                          "Gold Membership: ",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                        Text(
                          "₹149",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.lineThrough,
                            color: AppTheme.textTertiary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "FREE (90 Days)",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.appleGold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Your creator profile is actively verified and discoverable by regional brands across India.",
                      style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),

              if (!isNarrow) const SizedBox(width: 24) else const SizedBox(height: 18),

              // Upgrade to Burgundy VIP Button (User requirement)
              Expanded(
                flex: isNarrow ? 0 : 2,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceElevated,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.royalBurgundy.withValues(alpha: 0.4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.diamond, color: Colors.white, size: 14),
                          SizedBox(width: 6),
                          Text("BURGUNDY VIP TIER", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Priority Top Search Ranking • ₹399 / 6 mo",
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 36,
                        child: ElevatedButton(
                          onPressed: () {
                            PaywallModal.show(context, widget.appState, target: 'influencer_upgrade');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.royalBurgundy,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: EdgeInsets.zero,
                          ),
                          child: const Text("Upgrade to Burgundy VIP", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                        ),
                      ),
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

  Widget _buildSectionTabs() {
    final sections = ["Basic Info", "Contact Details", "Socials", "Commercials", "Portfolio Gallery"];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(sections.length, (idx) {
          final isActive = _activeSection == idx;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(sections[idx]),
              selected: isActive,
              onSelected: (_) => setState(() => _activeSection = idx),
              selectedColor: AppTheme.appleGold,
              backgroundColor: AppTheme.surfaceElevated,
              labelStyle: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                color: isActive ? Colors.black : AppTheme.textSecondary,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: isActive ? AppTheme.appleGold : AppTheme.borderSubtle),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSection0Basic() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Personal & Studio Profile", style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 6),
        const Text("Your professional display name and base operational region.", style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
        const SizedBox(height: 24),
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: "Full Creator / Brand Name",
            prefixIcon: Icon(Icons.person_outline, size: 18),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              flex: 1,
              child: TextFormField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Age",
                  prefixIcon: Icon(Icons.cake_outlined, size: 18),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: DropdownButtonFormField<String>(
                value: _selectedCity,
                dropdownColor: AppTheme.surfaceElevated,
                decoration: const InputDecoration(
                  labelText: "Primary Operating City",
                  prefixIcon: Icon(Icons.location_on_outlined, size: 18),
                ),
                items: MockData.cities.where((c) => c != "All Locations").map((c) {
                  return DropdownMenuItem(value: c, child: Text(c));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCity = val);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _addressController,
          decoration: const InputDecoration(
            labelText: "Studio / Neighborhood Address",
            prefixIcon: Icon(Icons.home_outlined, size: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildSection1Contact() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Contact Coordinates", style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 6),
        const Text("Direct phone, WhatsApp and work email coordinates where verified brands will reach out to you.", style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _phonePrimaryController,
                decoration: const InputDecoration(
                  labelText: "Primary Phone / WhatsApp",
                  prefixIcon: Icon(Icons.phone_iphone, size: 18),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _phoneSecondaryController,
                decoration: const InputDecoration(
                  labelText: "Secondary Phone (Optional)",
                  prefixIcon: Icon(Icons.phone, size: 18),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _emailPersonalController,
                decoration: const InputDecoration(
                  labelText: "Personal Email",
                  prefixIcon: Icon(Icons.email_outlined, size: 18),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _emailWorkController,
                decoration: const InputDecoration(
                  labelText: "Work / Collaboration Email",
                  prefixIcon: Icon(Icons.business_center_outlined, size: 18),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSection2Social() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Social Channels", style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 6),
        const Text("Links to your primary publishing channels.", style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
        const SizedBox(height: 24),
        TextFormField(
          controller: _igController,
          decoration: const InputDecoration(
            labelText: "Instagram Profile URL",
            prefixIcon: Icon(Icons.camera_alt_outlined, size: 18),
          ),
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _ytController,
          decoration: const InputDecoration(
            labelText: "YouTube Channel URL",
            prefixIcon: Icon(Icons.video_library_outlined, size: 18),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _tgController,
                decoration: const InputDecoration(
                  labelText: "Telegram Channel",
                  prefixIcon: Icon(Icons.send_outlined, size: 18),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: TextFormField(
                controller: _xController,
                decoration: const InputDecoration(
                  labelText: "X (Twitter) Profile",
                  prefixIcon: Icon(Icons.tag, size: 18),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSection3Commercials() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Category & Rate Card", style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 6),
        const Text("Set your primary niche and standard rate per reel.", style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
        const SizedBox(height: 24),
        DropdownButtonFormField<String>(
          value: _category,
          dropdownColor: AppTheme.surfaceElevated,
          decoration: const InputDecoration(
            labelText: "Niche Category",
            prefixIcon: Icon(Icons.category_outlined, size: 18),
          ),
          items: MockData.onboardingCategories.map((cat) {
            return DropdownMenuItem(value: cat, child: Text(cat));
          }).toList(),
          onChanged: (val) {
            if (val != null) setState(() => _category = val);
          },
        ),
        const SizedBox(height: 18),
        TextFormField(
          controller: _priceController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: "Average Rate per Reel (₹)",
            prefixIcon: Icon(Icons.currency_rupee, size: 18),
          ),
        ),
        const SizedBox(height: 24),
        const Text("Past Brand Collaborations", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _collabInputController,
                onSubmitted: (_) => _addCollabTag(),
                decoration: const InputDecoration(
                  hintText: "Add brand name (e.g. Zomato, Starbucks, Mamaearth)...",
                ),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: _addCollabTag,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.surfaceElevated,
                foregroundColor: AppTheme.appleBlue,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              ),
              child: const Text("Add"),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _collabs.map((tag) {
            return Chip(
              backgroundColor: AppTheme.surfaceElevated,
              label: Text(tag, style: const TextStyle(fontSize: 12, color: Colors.white)),
              deleteIcon: const Icon(Icons.close, size: 14, color: AppTheme.textSecondary),
              onDeleted: () => _removeCollabTag(tag),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSection4Portfolio() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Portfolio Imagery", style: Theme.of(context).textTheme.headlineMedium),
            Text("${_portfolioImages.length} of 5 photos", style: const TextStyle(fontSize: 12, color: AppTheme.appleGold, fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 6),
        const Text("Showcase past campaign reels, engagement screenshots, and high-res photography.", style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
        const SizedBox(height: 20),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.9,
          ),
          itemCount: _portfolioImages.length + (_portfolioImages.length < 5 ? 1 : 0),
          itemBuilder: (ctx, idx) {
            if (idx == _portfolioImages.length) {
              return InkWell(
                onTap: _addSampleImage,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceElevated,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.appleGold.withValues(alpha: 0.5)),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate_outlined, color: AppTheme.appleGold, size: 28),
                      SizedBox(height: 8),
                      Text("Add Photo", style: TextStyle(fontSize: 12, color: AppTheme.appleGold, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              );
            }

            return Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(_portfolioImages[idx], fit: BoxFit.cover),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: () => _removeImage(idx),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.black87, shape: BoxShape.circle),
                      child: const Icon(Icons.close, size: 14, color: Colors.white),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
