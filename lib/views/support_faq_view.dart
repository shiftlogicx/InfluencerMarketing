import 'package:flutter/material.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';

class SupportFaqView extends StatefulWidget {
  final AppState appState;

  const SupportFaqView({super.key, required this.appState});

  @override
  State<SupportFaqView> createState() => _SupportFaqViewState();
}

class _SupportFaqViewState extends State<SupportFaqView> {
  final Set<int> _expandedFaqIndices = {0}; // First one open by default

  void _toggleFaq(int index) {
    setState(() {
      if (_expandedFaqIndices.contains(index)) {
        _expandedFaqIndices.remove(index);
      } else {
        _expandedFaqIndices.add(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.appState;
    final isBrand = state.isBrand;
    final isWide = MediaQuery.of(context).size.width > 860;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 40 : 16,
        vertical: 28,
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.borderSubtle),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isBrand ? Icons.business_center : Icons.star,
                      color: isBrand ? AppTheme.appleBlue : AppTheme.appleGold,
                      size: 13,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isBrand ? "BRAND & CUSTOMER RESOURCE CENTER" : "CREATOR & INFLUENCER CARE DESK",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: isBrand ? AppTheme.appleBlue : AppTheme.appleGold,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                isBrand ? "Support & Brand Guide" : "Support & Creator Growth",
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Text(
                  isBrand
                      ? "Everything you need to know about discovering regional creators, unblurring direct coordinates, and running high-ROI campaigns."
                      : "Answers on profile discovery, early access Gold membership, lead alert notifications, and keeping 100% of your earnings.",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),

              const SizedBox(height: 32),

              // Contact Assistance Cards
              _buildSupportContactGrid(isBrand),

              const SizedBox(height: 36),

              // FAQs Section
              Text(
                "Frequently Asked Questions",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),

              _buildFaqList(isBrand),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSupportContactGrid(bool isBrand) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final isNarrow = constraints.maxWidth < 650;

        return GridView.count(
          crossAxisCount: isNarrow ? 1 : 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: isNarrow ? 2.8 : 1.35,
          children: isBrand
              ? [
                  _buildHelpCard(
                    icon: Icons.support_agent,
                    title: "Brand Concierge",
                    subtitle: "Direct assistance with hiring creators, custom regional lists & invoicing.",
                    actionLabel: "shiftlogiciq@gmail.com",
                    accentColor: AppTheme.appleBlue,
                  ),
                  _buildHelpCard(
                    icon: Icons.campaign_outlined,
                    title: "Bulk Campaign Curation",
                    subtitle: "Launching a store or restaurant in Pune or Mumbai? We assist with 10+ creators.",
                    actionLabel: "Request Campaign Scout",
                    accentColor: AppTheme.appleGreen,
                  ),
                  _buildHelpCard(
                    icon: Icons.receipt_long_outlined,
                    title: "Razorpay Billing Support",
                    subtitle: "GST invoices, corporate receipts & subscription management.",
                    actionLabel: "Instant Helpdesk",
                    accentColor: AppTheme.appleGold,
                  ),
                ]
              : [
                  _buildHelpCard(
                    icon: Icons.verified_user_outlined,
                    title: "Creator Verification",
                    subtitle: "Fast-track your profile verification and showcase past brand analytics.",
                    actionLabel: "shiftlogiciq@gmail.com",
                    accentColor: AppTheme.appleGold,
                  ),
                  _buildHelpCard(
                    icon: Icons.insights_outlined,
                    title: "Lead Notification Support",
                    subtitle: "Ensure your work email receives real-time brand interest dispatches.",
                    actionLabel: "Check Email Status",
                    accentColor: AppTheme.appleBlue,
                  ),
                  _buildHelpCard(
                    icon: Icons.handshake_outlined,
                    title: "Collaboration Rights",
                    subtitle: "Tips on standard rate cards, contract terms, and client communication.",
                    actionLabel: "Creator Knowledge Base",
                    accentColor: AppTheme.royalBurgundy,
                  ),
                ],
        );
      },
    );
  }

  Widget _buildHelpCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String actionLabel,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: accentColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                actionLabel,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: accentColor),
              ),
              const SizedBox(width: 4),
              Icon(Icons.arrow_forward_ios, size: 10, color: accentColor),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildFaqList(bool isBrand) {
    final List<Map<String, String>> faqs = isBrand
        ? [
            {
              "q": "How does connecting with creators work on Influencer Pulse?",
              "a": "Influencer Pulse is a zero-commission marketplace. Once you unblur a creator's contact coordinates, you reach out to them directly via Phone, WhatsApp, personal email, and Instagram. There are no middleman agency fees or escrow deductions."
            },
            {
              "q": "Why are contact coordinates initially blurred on the discover feed?",
              "a": "Creators on our platform are vetted regional micro-influencers. Contact details are kept private to shield them from scrapers and telemarketing spam, ensuring only genuine brands initiate communication."
            },
            {
              "q": "What is the ₹49/month Brand Access Pass?",
              "a": "The Brand Access Pass allows you to unblur contact coordinates across all regional creators across India. It is billed directly through Razorpay, carries zero setup fees, and can be cancelled anytime with a single click."
            },
            {
              "q": "How is the creator pricing per reel determined?",
              "a": "Pricing listed on creator cards is self-set by the influencer based on their production quality, follower engagement, and regional reach. You negotiate directly with the creator based on your deliverables."
            },
            {
              "q": "Can I search for creators in cities other than Pune?",
              "a": "Yes! While our geo-location engine initially surfaces creators near your current region (e.g. Pune), you can switch the location dropdown anytime to Mumbai, Bengaluru, Delhi NCR, Hyderabad, Chennai, and more."
            },
            {
              "q": "How can I request support for a large-scale campaign launch?",
              "a": "For multi-creator rosters (10+ creators for product launches, restaurant tastings, or retail store inaugurations), email our concierge team directly at shiftlogiciq@gmail.com."
            },
          ]
        : [
            {
              "q": "What is the 'Gold Membership: FREE for early access' offer?",
              "a": "As an early creator joining Influencer Pulse, you receive full Gold Tier privileges at no cost for 90 days. This unlocks full visibility into which brands look at your portfolio, including their company name and marketing manager email."
            },
            {
              "q": "How do Brand View and Lead Alert notifications work?",
              "a": "Whenever a verified brand searches your niche and views your profile, our notification engine logs the inquiry and dispatches a real-time lead alert to your dashboard and work email, allowing you to connect directly with the hiring manager."
            },
            {
              "q": "Do I have to pay any commission on deals I close with brands?",
              "a": "None! You keep 100% of your earnings. Influencer Pulse never takes a percentage cut of your reel fee or campaign budget."
            },
            {
              "q": "Are my personal phone number and personal email visible to the public?",
              "a": "No. All contact coordinates are strictly blurred on the public marketplace. Only verified brands with an active pass can view your coordinates."
            },
            {
              "q": "What is the Burgundy VIP Membership?",
              "a": "Burgundy VIP pins your portfolio to the very top of category and city search feeds. Brands searching for creators in your niche will see your card first, resulting in over 4x more profile views and direct bookings."
            },
            {
              "q": "How do I update my reel pricing or add new past brand collabs?",
              "a": "You can update your rates, past collaboration tags, and portfolio imagery anytime through the Creator Profile & Onboarding tab."
            },
          ];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: faqs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (ctx, idx) {
        final item = faqs[idx];
        final isOpen = _expandedFaqIndices.contains(idx);

        return Container(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isOpen ? AppTheme.appleBlue.withValues(alpha: 0.3) : AppTheme.borderSubtle,
            ),
          ),
          child: Column(
            children: [
              InkWell(
                onTap: () => _toggleFaq(idx),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item["q"]!,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                      ),
                      Icon(
                        isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: isOpen ? AppTheme.appleBlue : AppTheme.textSecondary,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              if (isOpen)
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, bottom: 18),
                  child: Text(
                    item["a"]!,
                    style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.5),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
