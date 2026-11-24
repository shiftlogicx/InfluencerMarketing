import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/influencer.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';

class InfluencerDetailModal extends StatefulWidget {
  final Influencer influencer;
  final AppState appState;

  const InfluencerDetailModal({
    super.key,
    required this.influencer,
    required this.appState,
  });

  static void show(BuildContext context, Influencer influencer, AppState appState) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: InfluencerDetailModal(influencer: influencer, appState: appState),
      ),
    );
  }

  @override
  State<InfluencerDetailModal> createState() => _InfluencerDetailModalState();
}

class _InfluencerDetailModalState extends State<InfluencerDetailModal> {
  int _selectedPhotoIdx = 0;

  @override
  Widget build(BuildContext context) {
    final creator = widget.influencer;
    final isUnlocked = widget.appState.isCreatorUnlocked(creator.id);
    final isBurgundy = creator.isBurgundy;
    final isGold = creator.isGold;

    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      constraints: BoxConstraints(
        maxHeight: screenHeight * 0.92,
        maxWidth: 520, // Clean Apple sheet proportions, never horizontally stretched!
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF111116),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isBurgundy
              ? AppTheme.royalBurgundy.withValues(alpha: 0.6)
              : (isGold ? AppTheme.appleGold.withValues(alpha: 0.5) : AppTheme.borderSubtle),
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black87,
            blurRadius: 40,
            spreadRadius: 8,
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            // Header Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: const BoxDecoration(
                color: Color(0xFF16161E),
                border: Border(bottom: BorderSide(color: AppTheme.borderSubtle)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                creator.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: -0.3,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (isBurgundy)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.royalBurgundy,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text("BURGUNDY VIP", style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white)),
                              )
                            else if (isGold)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.appleGold,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text("GOLD", style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.black)),
                              ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "${creator.category} • ${creator.city}, ${creator.state}",
                          style: const TextStyle(fontSize: 12, color: AppTheme.appleBlue, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Portfolio Showcase
                    _buildPortfolioSection(creator),

                    const SizedBox(height: 18),

                    // Quick Stats 2x2 Grid
                    _buildStatsGrid(creator),

                    const SizedBox(height: 18),

                    // Creator Overview & Bio
                    const Text(
                      "About the Creator",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      creator.bio.isNotEmpty
                          ? creator.bio
                          : "Professional regional content creator specializing in engaging reels, authentic stories, and audience conversions.",
                      style: const TextStyle(fontSize: 13, color: Color(0xFFD1D1D6), height: 1.45),
                    ),

                    const SizedBox(height: 18),

                    // Past Brand Collaborations
                    if (creator.collabs.isNotEmpty) ...[
                      const Text(
                        "Verified Past Collaborations",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: creator.collabs.map((collab) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1D1D26),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppTheme.borderSubtle),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.check_circle_outline, size: 12, color: AppTheme.appleGreen),
                                const SizedBox(width: 5),
                                Text(collab, style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500)),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Direct Contact Coordinates Box
                    _buildCoordinatesCard(context, creator, isUnlocked),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPortfolioSection(Influencer creator) {
    final images = creator.portfolioImages;
    if (images.isEmpty) return const SizedBox();

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: 16 / 10, // Natural cinematic aspect ratio, never stretched!
            child: Image.network(
              images[_selectedPhotoIdx.clamp(0, images.length - 1)],
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: const Color(0xFF1D1D26),
                child: const Center(child: Icon(Icons.broken_image, color: Colors.white38)),
              ),
            ),
          ),
        ),
        if (images.length > 1) ...[
          const SizedBox(height: 10),
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (ctx, idx) {
                final isSelected = _selectedPhotoIdx == idx;
                return GestureDetector(
                  onTap: () => setState(() => _selectedPhotoIdx = idx),
                  child: Container(
                    width: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? AppTheme.appleBlue : AppTheme.borderSubtle,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(images[idx], fit: BoxFit.cover),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatsGrid(Influencer creator) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF181822),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCell("Rate per Reel", "₹${creator.pricePerReel.toInt()}", Icons.payments_outlined, AppTheme.appleGold),
          ),
          Container(width: 1, height: 36, color: AppTheme.borderSubtle),
          Expanded(
            child: _buildStatCell("Audience Reach", creator.followersCount, Icons.people_outline, AppTheme.appleBlue),
          ),
          Container(width: 1, height: 36, color: AppTheme.borderSubtle),
          Expanded(
            child: _buildStatCell("Rating", "${creator.rating} ★", Icons.star_border, Colors.amber),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCell(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Color(0xFF8E8E93), fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildCoordinatesCard(BuildContext context, Influencer creator, bool isUnlocked) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161620),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnlocked ? AppTheme.appleGreen.withValues(alpha: 0.5) : AppTheme.appleBlue.withValues(alpha: 0.4),
          width: 1.2,
        ),
      ),
      child: isUnlocked
          ? _buildUnlockedDetails(context, creator)
          : _buildLockedPreview(context, creator),
    );
  }

  Widget _buildLockedPreview(BuildContext context, Influencer creator) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.lock_outline, color: AppTheme.appleBlue, size: 18),
            SizedBox(width: 8),
            Text(
              "Direct Creator Contact Coordinates",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          "Direct WhatsApp, mobile numbers, and agency work emails are available to verified brand subscribers.",
          style: TextStyle(fontSize: 12, color: Color(0xFFA1A1A6), height: 1.35),
        ),
        const SizedBox(height: 12),

        // Masked coordinates preview (Readable, not broken blur!)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF1F1F2C),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMaskedRow(Icons.phone_android, "WhatsApp / Mobile", "+91 98231 ••••••"),
              const SizedBox(height: 6),
              _buildMaskedRow(Icons.email_outlined, "Work Email", "collab.creator••••@gmail.com"),
              const SizedBox(height: 6),
              _buildMaskedRow(Icons.camera_alt_outlined, "Direct Handle", "@${creator.name.toLowerCase().replaceAll(' ', '')}_••••"),
            ],
          ),
        ),

        const SizedBox(height: 16),

        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () {
              widget.appState.unlockDirectContact(creator.id);
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppTheme.appleGreen,
                  content: Text(
                    "Inquiry Sent to ${creator.name} (~₹49~ ₹0 FREE)! Added to Unlocked Contacts.",
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.appleBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.send_rounded, size: 16, color: Colors.white),
                const SizedBox(width: 8),
                const Text(
                  "Send Inquiry • ",
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Colors.white),
                ),
                Text(
                  "₹49",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.lineThrough,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  "₹0 FREE",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.appleGold),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMaskedRow(IconData icon, String label, String maskedVal) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppTheme.appleBlue),
        const SizedBox(width: 8),
        Text("$label: ", style: const TextStyle(fontSize: 12, color: Color(0xFF8E8E93))),
        Text(maskedVal, style: const TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
      ],
    );
  }

  Widget _buildUnlockedDetails(BuildContext context, Influencer creator) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(Icons.check_circle, color: AppTheme.appleGreen, size: 18),
                SizedBox(width: 8),
                Text(
                  "Verified Direct Coordinates",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.appleGreen.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text("INQUIRY SENT", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.appleGreen)),
            ),
          ],
        ),
        const SizedBox(height: 12),

        _buildDirectContactItem(context, "Primary Phone / WhatsApp", creator.contactPrimary, Icons.phone_android),
        if (creator.contactSecondary.isNotEmpty)
          _buildDirectContactItem(context, "Secondary Phone", creator.contactSecondary, Icons.phone),
        _buildDirectContactItem(context, "Work / Agency Email", creator.emailWork, Icons.business_center_outlined),
        _buildDirectContactItem(context, "Personal Email", creator.emailPersonal, Icons.email_outlined),

        if (creator.socialLinks.isNotEmpty) ...[
          const SizedBox(height: 8),
          const Divider(color: AppTheme.borderSubtle, height: 1),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: creator.socialLinks.entries.map((entry) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF22222E),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.borderSubtle),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("${entry.key.toUpperCase()}: ", style: const TextStyle(fontSize: 11, color: AppTheme.appleBlue, fontWeight: FontWeight.w700)),
                    SelectableText(entry.value, style: const TextStyle(fontSize: 11, color: Colors.white)),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildDirectContactItem(BuildContext context, String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 15, color: AppTheme.appleGreen),
          const SizedBox(width: 8),
          Text("$label: ", style: const TextStyle(fontSize: 12, color: Color(0xFF8E8E93))),
          Expanded(
            child: SelectableText(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy, size: 14, color: Colors.white54),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: "Copy $label",
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppTheme.appleGreen,
                  content: Text("Copied $label: $value", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
