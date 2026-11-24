import 'package:flutter/material.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/pulse_logo.dart';

class BrandOnboardingModal extends StatefulWidget {
  final AppState appState;
  final VoidCallback onCompleted;

  const BrandOnboardingModal({
    super.key,
    required this.appState,
    required this.onCompleted,
  });

  static void show(BuildContext context, AppState appState, {required VoidCallback onCompleted}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: BrandOnboardingModal(appState: appState, onCompleted: onCompleted),
      ),
    );
  }

  @override
  State<BrandOnboardingModal> createState() => _BrandOnboardingModalState();
}

class _BrandOnboardingModalState extends State<BrandOnboardingModal> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _companyController;
  late TextEditingController _contactPersonController;
  late TextEditingController _phoneController;
  late String _selectedIndustry;
  late String _selectedCity;

  final List<String> _industries = [
    "Food & Beverage / Restaurants",
    "Fashion & Apparel",
    "Tech & Consumer Electronics",
    "Health, Fitness & Wellness",
    "Travel & Hospitality",
    "Beauty & Personal Care",
    "Marketing / Advertising Agency",
    "Retail & Local Business",
  ];

  @override
  void initState() {
    super.initState();
    final user = widget.appState.brandUser;
    _companyController = TextEditingController(text: user.companyName.isNotEmpty ? user.companyName : "Brand Enterprise");
    _contactPersonController = TextEditingController(text: widget.appState.userName);
    _phoneController = TextEditingController(text: "+91 98000 00000");
    _selectedIndustry = _industries[0];
    _selectedCity = widget.appState.selectedCity;
  }

  @override
  void dispose() {
    _companyController.dispose();
    _contactPersonController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submitOnboarding() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.appState.completeBrandOnboarding(
        companyName: _companyController.text.trim(),
        contactPerson: _contactPersonController.text.trim(),
        phone: _phoneController.text.trim(),
        industry: _selectedIndustry,
        city: _selectedCity,
      );
      Navigator.of(context).pop();
      widget.onCompleted();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.appState;

    return Container(
      constraints: const BoxConstraints(maxWidth: 520, maxHeight: 680),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFF111116),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.appleBlue.withValues(alpha: 0.4), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Colors.black87,
            blurRadius: 40,
            spreadRadius: 8,
          )
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Row(
              children: [
                const PulseLogoMark(size: 36, isBrand: true),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Brand Onboarding",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                      Text(
                        "Step 1 of 1: Setup your brand profile to discover regional micro-creators.",
                        style: const TextStyle(fontSize: 12, color: Color(0xFF8E8E93)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: AppTheme.borderSubtle, height: 1),
            const SizedBox(height: 18),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Location Banner
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF181822),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.borderSubtle),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.my_location, color: AppTheme.appleBlue, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Detected GPS: ${state.coordinatesText} (${state.detectedCity})",
                              style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _companyController,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: const InputDecoration(
                        labelText: "Brand / Company Name",
                        prefixIcon: Icon(Icons.business, size: 18),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? "Required" : null,
                    ),
                    const SizedBox(height: 14),

                    TextFormField(
                      controller: _contactPersonController,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: const InputDecoration(
                        labelText: "Marketing Lead / Account Manager",
                        prefixIcon: Icon(Icons.person_outline, size: 18),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? "Required" : null,
                    ),
                    const SizedBox(height: 14),

                    TextFormField(
                      controller: _phoneController,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: const InputDecoration(
                        labelText: "Business Phone / WhatsApp",
                        prefixIcon: Icon(Icons.phone_android, size: 18),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? "Required" : null,
                    ),
                    const SizedBox(height: 14),

                    DropdownButtonFormField<String>(
                      value: _selectedIndustry,
                      dropdownColor: const Color(0xFF1C1C26),
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: const InputDecoration(
                        labelText: "Brand Industry / Niche",
                        prefixIcon: Icon(Icons.category_outlined, size: 18),
                      ),
                      items: _industries.map((ind) {
                        return DropdownMenuItem(value: ind, child: Text(ind));
                      }).toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _selectedIndustry = v);
                      },
                    ),
                    const SizedBox(height: 14),

                    DropdownButtonFormField<String>(
                      value: _selectedCity,
                      dropdownColor: const Color(0xFF1C1C26),
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: const InputDecoration(
                        labelText: "Primary Target City",
                        prefixIcon: Icon(Icons.location_city, size: 18),
                      ),
                      items: const [
                        DropdownMenuItem(value: "Pune", child: Text("Pune, Maharashtra")),
                        DropdownMenuItem(value: "Mumbai", child: Text("Mumbai, Maharashtra")),
                        DropdownMenuItem(value: "Bengaluru", child: Text("Bengaluru, Karnataka")),
                        DropdownMenuItem(value: "Delhi NCR", child: Text("Delhi NCR")),
                      ],
                      onChanged: (v) {
                        if (v != null) setState(() => _selectedCity = v);
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: _submitOnboarding,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.appleBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text(
                  "Complete Brand Onboarding & Enter Feed",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
