import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/app_state.dart';
import '../widgets/pulse_logo.dart';

class PaywallModal extends StatefulWidget {
  final AppState appState;
  final String initialTarget; // 'brand_unlock' or 'influencer_upgrade'

  const PaywallModal({
    super.key,
    required this.appState,
    this.initialTarget = 'brand_unlock',
  });

  static void show(BuildContext context, AppState appState, {String target = 'brand_unlock'}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PaywallModal(appState: appState, initialTarget: target),
    );
  }

  @override
  State<PaywallModal> createState() => _PaywallModalState();
}

class _PaywallModalState extends State<PaywallModal> {
  late String _activeTab;
  bool _isProcessing = false;
  String? _paymentSuccessMessage;

  @override
  void initState() {
    super.initState();
    _activeTab = widget.initialTarget;
  }

  void _processRazorpayPayment({
    required String title,
    required double amount,
    required VoidCallback onSuccess,
  }) async {
    setState(() {
      _isProcessing = true;
    });

    // Simulate high-speed Razorpay checkout processing
    await Future.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;

    onSuccess();
    setState(() {
      _isProcessing = false;
      _paymentSuccessMessage = "Payment of ₹${amount.toInt()} confirmed via Razorpay!\nTransaction ID: pay_rzp_${DateTime.now().millisecondsSinceEpoch}";
    });

    await Future.delayed(const Duration(milliseconds: 1400));
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBrand = _activeTab == 'brand_unlock';

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
        maxWidth: 680,
      ),
      margin: EdgeInsets.only(
        top: 40,
        left: MediaQuery.of(context).size.width > 720 ? (MediaQuery.of(context).size.width - 680) / 2 : 0,
        right: MediaQuery.of(context).size.width > 720 ? (MediaQuery.of(context).size.width - 680) / 2 : 0,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.textTertiary.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    PulseLogoMark(size: 32, isBrand: isBrand),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isBrand ? "Razorpay Brand Access Pass" : "Creator Membership Pass",
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          "Direct access. Zero intermediary commissions.",
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppTheme.textSecondary, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                )
              ],
            ),
          ),

          const Divider(color: AppTheme.borderFaint, height: 1),

          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _paymentSuccessMessage != null
                  ? _buildSuccessView()
                  : isBrand
                      ? _buildBrandPaywallView()
                      : _buildInfluencerMembershipView(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.appleGreen.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle, color: AppTheme.appleGreen, size: 48),
          ),
          const SizedBox(height: 20),
          Text(
            "Access Unlocked!",
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          Text(
            _paymentSuccessMessage!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandPaywallView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Headline
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.surfaceElevated,
                AppTheme.appleBlue.withValues(alpha: 0.08),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.appleBlue.withValues(alpha: 0.25)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.appleBlue,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      "RECOMMENDED FOR BRANDS",
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.5),
                    ),
                  ),
                  const Text(
                    "₹49 / month",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                "Unblur Verified Creator Contacts Across India",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                "Cut out agencies taking 30-50% margins. Speak directly with regional micro-influencers on WhatsApp, Phone, and Email.",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),
        Text(
          "WHAT'S INCLUDED",
          style: Theme.of(context).textTheme.labelSmall?.copyWith(letterSpacing: 1.2, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 14),

        _buildFeatureRow(Icons.phone_iphone, "Direct Phone Numbers & WhatsApp", "Immediate reachout for instant campaign confirmations"),
        _buildFeatureRow(Icons.alternate_email, "Work & Personal Email IDs", "Pre-verified inbox addresses with high response rates"),
        _buildFeatureRow(Icons.camera_alt, "Direct Instagram & Telegram Handles", "Review raw engagement metrics, story views & community chats"),
        _buildFeatureRow(Icons.all_inclusive, "Unlimited Creator Unlocks", "No per-creator credit limits or hidden micro-transactions"),

        const SizedBox(height: 28),

        // Razorpay Checkout Button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _isProcessing
                ? null
                : () => _processRazorpayPayment(
                      title: "Brand Contact Pass",
                      amount: 49,
                      onSuccess: () => widget.appState.unlockBrandSubscription(),
                    ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.appleBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            child: _isProcessing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.lock_open, size: 18),
                      const SizedBox(width: 8),
                      const Text("Unlock All Contacts • ", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                      Text(
                        "₹49",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.lineThrough,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text("₹0 FREE", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppTheme.appleGold)),
                    ],
                  ),
          ),
        ),

        const SizedBox(height: 12),
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.security, size: 13, color: AppTheme.textTertiary),
              const SizedBox(width: 6),
              Text(
                "Secured by Razorpay API • Test & Live Sandbox Active",
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildInfluencerMembershipView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "SELECT YOUR CREATOR TIER",
          style: Theme.of(context).textTheme.labelSmall?.copyWith(letterSpacing: 1.2, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),

        // Gold Tier Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.surfaceElevated,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.appleGold.withValues(alpha: 0.5), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.appleGold.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      "GOLD MEMBERSHIP",
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.appleGold, letterSpacing: 0.5),
                    ),
                  ),
                  const Text(
                    "₹149 / 3 months",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.appleGold),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                "Full Lead Visibility & Brand View Notifications",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
              ),
              const SizedBox(height: 6),
              const Text(
                "Unlocks exact company names, marketing managers, and direct emails of brands who view your profile.",
                style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton(
                  onPressed: _isProcessing
                      ? null
                      : () => _processRazorpayPayment(
                            title: "Gold Creator Membership",
                            amount: 149,
                            onSuccess: () => widget.appState.upgradeInfluencerTier("gold", days: 90),
                          ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.appleGold),
                    foregroundColor: AppTheme.appleGold,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("Subscribe to Gold • ₹149 via Razorpay", style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // Burgundy Tier Card (BRD Module 3: Priority Ranking)
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.surfaceElevated,
                AppTheme.royalBurgundy.withValues(alpha: 0.15),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.royalBurgundy.withValues(alpha: 0.6), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.royalBurgundy,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      "BURGUNDY VIP TIER",
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.5),
                    ),
                  ),
                  const Text(
                    "₹399 / 6 months",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                "Priority Search Ranking + Gold Visibility",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
              ),
              const SizedBox(height: 6),
              const Text(
                "Pin your portfolio at the very top of brand category searches in your city. Receive 4.2x more profile impressions and direct leads.",
                style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: _isProcessing
                      ? null
                      : () => _processRazorpayPayment(
                            title: "Burgundy VIP Membership",
                            amount: 399,
                            onSuccess: () => widget.appState.upgradeInfluencerTier("burgundy", days: 180),
                          ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.royalBurgundy,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("Unlock Burgundy VIP • ₹399 via Razorpay", style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureRow(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppTheme.surfaceElevated,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: AppTheme.appleBlue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.textTertiary)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
