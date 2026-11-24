import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/influencer.dart';
import '../services/app_state.dart';
import '../services/mock_data.dart';
import '../services/web_auth_bridge.dart';
import '../theme/app_theme.dart';
import 'paywall_modal.dart';

class BrandDiscoveryView extends StatefulWidget {
  final AppState appState;
  final Function(Influencer) onSelectInfluencer;

  const BrandDiscoveryView({
    super.key,
    required this.appState,
    required this.onSelectInfluencer,
  });

  @override
  State<BrandDiscoveryView> createState() => _BrandDiscoveryViewState();
}

class _BrandDiscoveryViewState extends State<BrandDiscoveryView> {
  final TextEditingController _searchController = TextEditingController();
  bool _showGeoLocationBanner = true;

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.appState.searchQuery;
    // Auto-detect real browser coordinates on mount
    _detectRealLocation();
  }

  void _detectRealLocation() async {
    try {
      final res = await WebAuthBridge.getCurrentCoordinates();
      if (res.isSuccess) {
        widget.appState.setCoordinates(res.latitude, res.longitude);
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.appState;
    final filtered = state.filteredInfluencers;
    final isSubscribed = state.brandUser.isSubscribed;
    final isWide = MediaQuery.of(context).size.width > 900;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 40 : 16,
        vertical: 24,
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Geo-Location Banner
              if (_showGeoLocationBanner) _buildGeoLocationBanner(),

              // Hero Search Header (Apple Minimalist style)
              _buildDiscoveryHero(),

              const SizedBox(height: 28),

              // Filter Controls Bar
              _buildFilterControls(),

              const SizedBox(height: 24),

              // Results Count & Clean Pass Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        "${filtered.length} Regional Creators Found",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceElevated,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppTheme.borderSubtle),
                        ),
                        child: Text(
                          state.selectedCity,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.appleBlue),
                        ),
                      )
                    ],
                  ),
                  InkWell(
                    onTap: () {
                      PaywallModal.show(context, state, target: 'brand_unlock');
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSubscribed
                            ? AppTheme.appleGreen.withValues(alpha: 0.15)
                            : AppTheme.surfaceElevated,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSubscribed ? AppTheme.appleGreen : AppTheme.borderSubtle,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isSubscribed ? Icons.check_circle : Icons.key_outlined,
                            size: 14,
                            color: isSubscribed ? AppTheme.appleGreen : AppTheme.appleBlue,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isSubscribed ? "Brand Pass Active (Coordinates Unblurred)" : "Brand Access Pass",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isSubscribed ? AppTheme.appleGreen : AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Creators Grid
              if (filtered.isEmpty)
                _buildEmptyState()
              else
                _buildCreatorsGrid(filtered, state),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGeoLocationBanner() {
    final state = widget.appState;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: AppTheme.appleBlue.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.location_on, color: AppTheme.appleBlue, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              children: [
                Text(
                  "${state.selectedCity}, Maharashtra",
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.appleGreen.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    "Geolocation Enabled",
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.appleGreen),
                  ),
                ),
                const SizedBox(width: 8),
                const Flexible(
                  child: Text(
                    "• Auto-filtering creators in your regional market",
                    style: TextStyle(fontSize: 12, color: Color(0xFF8E8E93)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 16, color: AppTheme.textTertiary),
            onPressed: () => setState(() => _showGeoLocationBanner = false),
          )
        ],
      ),
    );
  }

  Widget _buildDiscoveryHero() {
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
              Icon(Icons.bolt, color: AppTheme.appleBlue, size: 13),
              SizedBox(width: 6),
              Text(
                "REGIONAL MICRO-INFLUENCER DIRECTORY",
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.textSecondary, letterSpacing: 0.8),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "Regional Creators.\nDirect Collaboration.",
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: MediaQuery.of(context).size.width > 700 ? 46 : 32,
              ),
        ),
        const SizedBox(height: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Text(
            "Discover verified creators across Pune, Mumbai, Bangalore, and all major regional hubs. Connect directly with zero middleman commissions.",
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterControls() {
    final state = widget.appState;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search row + City selector
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => state.setSearchQuery(val),
                  decoration: InputDecoration(
                    hintText: "Search by creator name, niche, brand collaboration (e.g. Zomato, Tech)...",
                    prefixIcon: const Icon(Icons.search, size: 18),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 16),
                            onPressed: () {
                              _searchController.clear();
                              state.setSearchQuery("");
                            },
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                flex: 1,
                child: DropdownButtonFormField<String>(
                  value: state.selectedCity,
                  dropdownColor: AppTheme.surfaceElevated,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.location_city, size: 18),
                  ),
                  items: MockData.cities.map((city) {
                    return DropdownMenuItem(value: city, child: Text(city));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) state.setCity(val);
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Category Chips (Horizontal scrollable)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: MockData.categories.map((cat) {
                final isSelected = state.selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (_) => state.setCategory(cat),
                    selectedColor: AppTheme.appleBlue,
                    backgroundColor: AppTheme.surfaceElevated,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? Colors.white : AppTheme.textSecondary,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: isSelected ? AppTheme.appleBlue : AppTheme.borderSubtle,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 18),

          // Price Range Slider
          Row(
            children: [
              Text(
                "Price per Reel:",
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "₹${state.priceRange.start.toInt()} – ₹${state.priceRange.end.toInt()}",
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.appleGold),
                ),
              ),
              Expanded(
                child: RangeSlider(
                  values: state.priceRange,
                  min: 500,
                  max: 20000,
                  divisions: 39,
                  activeColor: AppTheme.appleBlue,
                  inactiveColor: AppTheme.surfaceHigh,
                  onChanged: (newRange) => state.setPriceRange(newRange),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCreatorsGrid(List<Influencer> influencers, AppState state) {
    final screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = 3;
    if (screenWidth < 650) {
      crossAxisCount = 1;
    } else if (screenWidth < 1000) {
      crossAxisCount = 2;
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 18,
        mainAxisSpacing: 18,
        childAspectRatio: 0.68,
      ),
      itemCount: influencers.length,
      itemBuilder: (ctx, idx) {
        final creator = influencers[idx];
        final isUnlocked = state.isCreatorUnlocked(creator.id);
        return _buildCreatorTeaserCard(creator, isUnlocked, influencers);
      },
    );
  }

  Widget _buildCreatorTeaserCard(Influencer creator, bool isUnlocked, List<Influencer> currentFeed) {
    final isBurgundy = creator.isBurgundy;
    final isGold = creator.isGold;

    return InkWell(
      onTap: () {
        widget.appState.recordProfileClick(creator, currentFeed);
        widget.onSelectInfluencer(creator);
      },
      borderRadius: BorderRadius.circular(22),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isBurgundy
                ? AppTheme.royalBurgundy.withValues(alpha: 0.5)
                : (isGold ? AppTheme.appleGold.withValues(alpha: 0.4) : AppTheme.borderSubtle),
            width: (isBurgundy || isGold) ? 1.5 : 1,
          ),
          boxShadow: [
            if (isBurgundy)
              BoxShadow(
                color: AppTheme.royalBurgundy.withValues(alpha: 0.12),
                blurRadius: 18,
                spreadRadius: 2,
              )
            else if (isGold)
              BoxShadow(
                color: AppTheme.appleGold.withValues(alpha: 0.1),
                blurRadius: 16,
                spreadRadius: 1,
              )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Image Carousel / Hero Image
            Stack(
              children: [
                SizedBox(
                  height: 190,
                  width: double.infinity,
                  child: Image.network(
                    creator.portfolioImages.isNotEmpty
                        ? creator.portfolioImages[0]
                        : "https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=800&q=80",
                    fit: BoxFit.cover,
                    loadingBuilder: (c, child, progress) {
                      if (progress == null) return child;
                      return Container(color: AppTheme.surfaceElevated);
                    },
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.85),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                // Tier Badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: Row(
                    children: [
                      if (isBurgundy)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.royalBurgundy,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.diamond, color: Colors.white, size: 11),
                              SizedBox(width: 4),
                              Text("BURGUNDY VIP", style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white)),
                            ],
                          ),
                        )
                      else if (isGold)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.appleGold,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.stars, color: Colors.black, size: 11),
                              SizedBox(width: 4),
                              Text("GOLD CREATOR", style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.black)),
                            ],
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text("VERIFIED", style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white70)),
                        ),
                    ],
                  ),
                ),
                // Price Tag
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.borderSubtle),
                    ),
                    child: Text(
                      "₹${creator.pricePerReel.toInt()} / reel",
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ),
                ),
                // Creator Name + Location
                Positioned(
                  bottom: 12,
                  left: 14,
                  right: 14,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        creator.name,
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 12, color: AppTheme.appleBlue),
                          const SizedBox(width: 4),
                          Text(
                            "${creator.city}, ${creator.state}",
                            style: const TextStyle(fontSize: 11, color: Colors.white70),
                          ),
                          const Spacer(),
                          const Icon(Icons.star, size: 12, color: AppTheme.appleGold),
                          const SizedBox(width: 3),
                          Text(
                            "${creator.rating}",
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),

            // Card Body Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category & Followers
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceElevated,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            creator.category,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.appleBlue),
                          ),
                        ),
                        Text(
                          "${creator.followersCount} Reach",
                          style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Past Collaborations chips
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: creator.collabs.take(3).map((collab) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceElevated,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppTheme.borderFaint),
                          ),
                          child: Text(
                            collab,
                            style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
                          ),
                        );
                      }).toList(),
                    ),

                    const Spacer(),

                    // Clean Contact Information Preview (Blurred if not unlocked, clean if unlocked)
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceElevated,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isUnlocked
                              ? AppTheme.appleGreen.withValues(alpha: 0.3)
                              : AppTheme.borderSubtle,
                        ),
                      ),
                      child: isUnlocked
                          ? _buildUnlockedContactDetails(creator)
                          : _buildBlurredContactPreview(),
                    ),

                    const SizedBox(height: 10),

                    // Clean action button
                    SizedBox(
                      width: double.infinity,
                      height: 38,
                      child: ElevatedButton(
                        onPressed: () {
                          widget.appState.recordProfileClick(creator, currentFeed);
                          widget.onSelectInfluencer(creator);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.surfaceElevated,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                          side: const BorderSide(color: AppTheme.borderSubtle),
                        ),
                        child: const Text("View Profile", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
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

  // Natural blurred contact preview without tacky paywall spam
  Widget _buildBlurredContactPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.contact_mail_outlined, size: 12, color: AppTheme.textTertiary),
            SizedBox(width: 5),
            Text(
              "Direct Coordinates",
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.textTertiary),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Phone: +91 98231 44521", style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                Text("Email: creator.work@gmail.com", style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                Text("Instagram: @official_creator", style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Unlocked contact details
  Widget _buildUnlockedContactDetails(Influencer creator) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.check_circle, size: 12, color: AppTheme.appleGreen),
            SizedBox(width: 5),
            Text(
              "Coordinates Unlocked",
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.appleGreen),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text("Phone: ${creator.contactPrimary}", style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w500)),
        Text("Email: ${creator.emailWork}", style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w500)),
        Text("IG: ${creator.socialLinks['ig'] ?? '@creator'}", style: const TextStyle(fontSize: 11, color: AppTheme.appleBlue, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
      alignment: Alignment.center,
      child: Column(
        children: [
          const Icon(Icons.search_off, size: 48, color: AppTheme.textTertiary),
          const SizedBox(height: 16),
          Text(
            "No regional creators found matching these filters.",
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          const Text(
            "Try expanding your price range slider or switching category.",
            style: TextStyle(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              widget.appState.setCategory("All Categories");
              widget.appState.setCity("Pune");
              widget.appState.setPriceRange(const RangeValues(500, 20000));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.surfaceElevated),
            child: const Text("Reset All Filters"),
          )
        ],
      ),
    );
  }
}
