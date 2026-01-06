
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mfd_app/core/router/app_router.dart';
import 'package:mfd_app/features/forecasting/domain/services/export_service.dart';
import 'package:url_launcher/url_launcher_string.dart';

// 1. Subscription Tier Enum
enum SubscriptionTier {
  free,
  sprint,   // Weekly ($19)
  monthly,  // Monthly ($49)
  yearly,   // Yearly ($390)
  lifetime, // LTD ($499)
}

// 2. Subscription State
class SubscriptionState {
  final SubscriptionTier tier;
  final bool isPro;
  final DateTime? expiry;

  const SubscriptionState({
    required this.tier,
    required this.isPro,
    this.expiry,
  });

  factory SubscriptionState.free() => 
    const SubscriptionState(tier: SubscriptionTier.free, isPro: false);
}

// 3. Service Controller
class SubscriptionController extends StateNotifier<SubscriptionState> {
  SubscriptionController() : super(SubscriptionState.free());

  // Mock: Upgrade Function (Simulates successful payment)
  void mockUpgrade(SubscriptionTier newTier) {
    state = SubscriptionState(
      tier: newTier,
      isPro: true,
      expiry: newTier == SubscriptionTier.sprint 
          ? DateTime.now().add(const Duration(days: 7)) 
          : DateTime.now().add(const Duration(days: 30)),
    );
  }

  // Real: Launch Stripe Checkout
  Future<void> launchCheckout(String productId) async {
    // In production, this would call Supabase Function 'create-checkout-session'
    // which returns a URL.
    // For MVP, we link to payment links directly if using Stripe Payment Links.
    
    // MOCK URLS (Replace with real Stripe Links)
    String url = 'https://buy.stripe.com/test_mock_link';
    if (productId == 'sprint') url = 'https://buy.stripe.com/test_sprint';
    
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else {
      throw 'Could not launch payment page';
    }
  }
}

final subscriptionProvider = StateNotifierProvider<SubscriptionController, SubscriptionState>((ref) {
  return SubscriptionController();
});
