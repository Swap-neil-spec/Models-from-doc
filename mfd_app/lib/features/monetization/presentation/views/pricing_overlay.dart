import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mfd_app/core/theme/app_theme.dart';
import 'package:mfd_app/features/monetization/domain/services/subscription_service.dart';

class PricingOverlay extends ConsumerWidget {
  final VoidCallback onClose;

  const PricingOverlay({super.key, required this.onClose});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: Colors.black.withOpacity(0.85), // Dimmed background
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1000, maxHeight: 700),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppTheme.voidBlack,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.borderGrey),
            boxShadow: [
              BoxShadow(color: AppTheme.signalGreen.withOpacity(0.1), blurRadius: 40, spreadRadius: 5),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Access the Financial OS', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Choose the plan that fits your runway.', style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: onClose,
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Pricing Tiers (Horizontal List)
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _PricingCard(
                      title: 'The Sprint',
                      price: '\$19',
                      period: '/ week',
                      description: 'Instant relief for your investor deck.',
                      features: const ['7 Days Full Access', 'Export to PDF/CSV', '3 Scenarios'],
                      buttonColor: AppTheme.commandGrey,
                      textColor: Colors.white,
                      tier: SubscriptionTier.sprint,
                    ),
                    const SizedBox(width: 16),
                    _PricingCard(
                      title: 'Monthly',
                      price: '\$49',
                      period: '/ mo',
                      description: 'Standard access for growth monitoring.',
                      features: const ['30 Days Access', 'Monthly Board Prep', 'Unlimited Scenarios'],
                      isPopular: true,
                      buttonColor: AppTheme.signalGreen,
                      textColor: AppTheme.voidBlack,
                      tier: SubscriptionTier.monthly,
                    ),
                    const SizedBox(width: 16),
                    _PricingCard(
                      title: 'Yearly',
                      price: '\$390',
                      period: '/ year',
                      description: 'Commit to your growth. Save 33%.',
                      features: const ['Priority Support', 'Advanced Benchmarks', 'Team Access (Soon)'],
                      buttonColor: AppTheme.commandGrey,
                      textColor: Colors.white,
                      tier: SubscriptionTier.yearly,
                    ),
                    const SizedBox(width: 16),
                    _PricingCard(
                      title: 'The Exit (LTD)',
                      price: '\$499',
                      period: ' once',
                      description: 'Forecast forever. Never pay again.',
                      features: const ['Lifetime Access', 'All Future Updates', 'Founders Circle'],
                      isSpecial: true,
                      buttonColor: AppTheme.electricBlue,
                      textColor: Colors.white,
                      tier: SubscriptionTier.lifetime,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PricingCard extends ConsumerWidget {
  final String title;
  final String price;
  final String period;
  final String description;
  final List<String> features;
  final bool isPopular;
  final bool isSpecial;
  final Color buttonColor;
  final Color textColor;
  final SubscriptionTier tier;

  const _PricingCard({
    required this.title,
    required this.price,
    required this.period,
    required this.description,
    required this.features,
    this.isPopular = false,
    this.isSpecial = false,
    required this.buttonColor,
    required this.textColor,
    required this.tier,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Expanded(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isSpecial ? AppTheme.electricBlue.withOpacity(0.05) : AppTheme.commandGrey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isPopular ? AppTheme.signalGreen : (isSpecial ? AppTheme.electricBlue : AppTheme.borderGrey),
                width: isPopular || isSpecial ? 2 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.getFont('JetBrains Mono', fontSize: 14, fontWeight: FontWeight.bold, color: isSpecial ? AppTheme.electricBlue : AppTheme.textMedium)),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(price, style: GoogleFonts.getFont('Inter', fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text(period, style: GoogleFonts.getFont('Inter', fontSize: 14, color: AppTheme.textMedium)),
                  ],
                ),
                const SizedBox(height: 16),
                Text(description, style: GoogleFonts.getFont('Inter', fontSize: 13, color: AppTheme.textMedium)),
                const SizedBox(height: 24),
                const Divider(color: AppTheme.borderGrey),
                const SizedBox(height: 24),
                ...features.map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Icon(Icons.check, size: 16, color: isPopular || isSpecial ? AppTheme.signalGreen : AppTheme.textMedium),
                      const SizedBox(width: 8),
                      Expanded(child: Text(f, style: GoogleFonts.getFont('Inter', fontSize: 13, color: Colors.white))),
                    ],
                  ),
                )),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      // Mock Upgrade Action
                      ref.read(subscriptionProvider.notifier).mockUpgrade(tier);
                      // Navigator.pop(context); // Optional: close immediately
                    },
                    child: Text(
                      'Select Plan',
                      style: GoogleFonts.getFont('Inter', fontWeight: FontWeight.bold, color: textColor),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isPopular)
            Positioned(
              top: -12,
              right: 24,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: AppTheme.signalGreen, borderRadius: BorderRadius.circular(20)),
                child: Text('RECOMMENDED', style: GoogleFonts.getFont('JetBrains Mono', fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.voidBlack)),
              ),
            ),
             if (isSpecial)
            Positioned(
              top: -12,
              right: 24,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: AppTheme.electricBlue, borderRadius: BorderRadius.circular(20)),
                child: Text('LIMITED TIME', style: GoogleFonts.getFont('JetBrains Mono', fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
        ],
      ),
    );
  }
}
