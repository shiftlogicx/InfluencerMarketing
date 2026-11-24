import 'package:flutter/material.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import 'paywall_modal.dart';

class ProfileSettingsModal extends StatefulWidget {
  final AppState appState;

  const ProfileSettingsModal({super.key, required this.appState});

  static void show(BuildContext context, AppState appState) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: ProfileSettingsModal(appState: appState),
      ),
    );
  }

  @override
  State<ProfileSettingsModal> createState() => _ProfileSettingsModalState();
}

class _ProfileSettingsModalState extends State<ProfileSettingsModal> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _companyController;
  late String _selectedCity;
  late String _selectedTheme;
  String _avatarUrl = "https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80";

  final List<String> _sampleAvatars = [
    "https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80",
    "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80",
    "https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=200&q=80",
    "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=200&q=80",
  ];

  @override
  void initState() {
    super.initState();
    final state = widget.appState;
    _nameController = TextEditingController(text: state.userName.isNotEmpty ? state.userName : "Amit Thakur");
    _emailController = TextEditingController(text: state.userEmail.isNotEmpty ? state.userEmail : "shiftlogiciq@gmail.com");
    _companyController = TextEditingController(
      text: state.isBrand ? state.brandUser.companyName : "Independent Creator Studio",
    );
    _selectedCity = state.selectedCity;
    _selectedTheme = "Space Black";
    if (state.userPhotoUrl.isNotEmpty) {
      _avatarUrl = state.userPhotoUrl;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  void _saveSettings() {
    final state = widget.appState;
    state.updateUserProfile(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      photoUrl: _avatarUrl,
      companyName: _companyController.text.trim(),
    );
    state.setCity(_selectedCity);
    state.setTheme(_selectedTheme);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppTheme.appleGreen,
        content: Text("Profile settings & preferences saved to Supabase!", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.appState;
    final isBrand = state.isBrand;

    return Container(
      constraints: const BoxConstraints(maxWidth: 540, maxHeight: 720),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppTheme.borderSubtle, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Colors.black87,
            blurRadius: 40,
            spreadRadius: 10,
          )
        ],
      ),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (isBrand ? AppTheme.appleBlue : AppTheme.appleGold).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.settings_outlined,
                      size: 20,
                      color: isBrand ? AppTheme.appleBlue : AppTheme.appleGold,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isBrand ? "Brand Profile & Settings" : "Creator Profile & Settings",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        "Manage your profile picture, preferences, and billing.",
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20, color: AppTheme.textSecondary),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(color: AppTheme.borderFaint, height: 1),
          const SizedBox(height: 20),

          // Scrollable Settings Form
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Picture Section
                  Center(
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundImage: NetworkImage(_avatarUrl),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: AppTheme.appleBlue,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Select Profile Picture",
                          style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: _sampleAvatars.map((url) {
                            final isSel = _avatarUrl == url;
                            return GestureDetector(
                              onTap: () => setState(() => _avatarUrl = url),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSel ? AppTheme.appleBlue : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 16,
                                  backgroundImage: NetworkImage(url),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Fields
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: isBrand ? "Account Manager Name" : "Creator Display Name",
                      prefixIcon: const Icon(Icons.person_outline, size: 18),
                    ),
                  ),
                  const SizedBox(height: 14),

                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: "Google SSO Connected Email",
                      prefixIcon: Icon(Icons.email_outlined, size: 18),
                    ),
                  ),
                  const SizedBox(height: 14),

                  TextFormField(
                    controller: _companyController,
                    decoration: InputDecoration(
                      labelText: isBrand ? "Brand / Company Name" : "Studio / Channel Name",
                      prefixIcon: const Icon(Icons.business_outlined, size: 18),
                    ),
                  ),
                  const SizedBox(height: 14),

                  DropdownButtonFormField<String>(
                    value: _selectedCity,
                    decoration: const InputDecoration(
                      labelText: "Primary Operating City",
                      prefixIcon: Icon(Icons.location_on_outlined, size: 18),
                    ),
                    dropdownColor: AppTheme.surfaceElevated,
                    items: const [
                      DropdownMenuItem(value: "Pune", child: Text("Pune, Maharashtra")),
                      DropdownMenuItem(value: "Mumbai", child: Text("Mumbai, Maharashtra")),
                      DropdownMenuItem(value: "Bengaluru", child: Text("Bengaluru, Karnataka")),
                      DropdownMenuItem(value: "Delhi NCR", child: Text("Delhi NCR")),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedCity = val);
                    },
                  ),

                  const SizedBox(height: 20),

                  // Theme Selection (Apple Studio Themes)
                  const Text("Visual Theme", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildThemeChip("Space Black", Icons.dark_mode_outlined),
                      const SizedBox(width: 8),
                      _buildThemeChip("Deep Obsidian", Icons.lens_blur_outlined),
                      const SizedBox(width: 8),
                      _buildThemeChip("Midnight", Icons.nights_stay_outlined),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Plan & Billing
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceElevated,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.borderSubtle),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isBrand ? "Brand Access Pass" : "Creator Tier Status",
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isBrand
                                  ? (state.brandUser.isSubscribed ? "Active Subscription • ₹49/mo" : "Inactive (Coordinates Blurred)")
                                  : "${state.activeInfluencer.membershipTier.toUpperCase()} Member (Free Early Access)",
                              style: TextStyle(
                                fontSize: 11,
                                color: (isBrand && state.brandUser.isSubscribed) || (!isBrand && state.activeInfluencer.isPremium)
                                    ? AppTheme.appleGreen
                                    : AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            PaywallModal.show(context, state, target: isBrand ? 'brand_unlock' : 'influencer_upgrade');
                          },
                          child: Text(
                            isBrand ? "Manage Pass" : "Upgrade VIP",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isBrand ? AppTheme.appleBlue : AppTheme.appleGold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 18),

          // Save Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _saveSettings,
              style: ElevatedButton.styleFrom(
                backgroundColor: isBrand ? AppTheme.appleBlue : AppTheme.appleGold,
                foregroundColor: isBrand ? Colors.white : Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text("Save Preferences", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeChip(String name, IconData icon) {
    final isSelected = _selectedTheme == name;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedTheme = name),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.appleBlue.withValues(alpha: 0.15) : AppTheme.surfaceElevated,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppTheme.appleBlue : AppTheme.borderSubtle,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: isSelected ? AppTheme.appleBlue : AppTheme.textSecondary),
              const SizedBox(width: 6),
              Text(
                name,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
