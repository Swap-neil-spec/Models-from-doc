
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mfd_app/core/router/app_router.dart';
import 'package:mfd_app/features/forecasting/domain/services/export_service.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  SubscriptionController() : super(SubscriptionState.free()) {
    _loadState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final isPro = prefs.getBool('isPro') ?? false;
    final tierIndex = prefs.getInt('tier') ?? 0;
    final expiryStr = prefs.getString('expiry');

    if (isPro) {
      state = SubscriptionState(
        tier: SubscriptionTier.values[tierIndex],
        isPro: true,
        expiry: expiryStr != null ? DateTime.parse(expiryStr) : null,
      );
    }
  }

  Future<void> upgrade(SubscriptionTier newTier) async {
    final prefs = await SharedPreferences.getInstance();
    final expiryDate = newTier == SubscriptionTier.sprint 
          ? DateTime.now().add(const Duration(days: 7)) 
          : DateTime.now().add(const Duration(days: 30));

    await prefs.setBool('isPro', true);
    await prefs.setInt('tier', newTier.index);
    await prefs.setString('expiry', expiryDate.toIso8601String());

    state = SubscriptionState(
      tier: newTier,
      isPro: true,
      expiry: expiryDate,
    );
  }

  Future<void> clearSubscription() async {
     final prefs = await SharedPreferences.getInstance();
     await prefs.clear();
     state = SubscriptionState.free();
  }

  Future<void> launchCheckout(String productId) async {
    // START_PRODUCTION_CONFIG
    // Replace these URLs with your actual Stripe Payment Links from the Dashboard
    String url = 'https://buy.stripe.com/test_GeneralLink'; 
    if (productId == 'sprint') url = 'https://buy.stripe.com/test_sprint_link';
    if (productId == 'monthly') url = 'https://buy.stripe.com/test_monthly_link';
    if (productId == 'lifetime') url = 'https://buy.stripe.com/test_ltd_link';
    // END_PRODUCTION_CONFIG
    
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
      // Note: In real webhooks, the state updates asynchronously. 
      // For immediate user feedback in this MVP, you might optimistically unlock logic here if desired,
      // but strictly speaking, we wait for the user to return.
    } else {
      throw 'Could not launch payment page';
    }
  }
}

final subscriptionProvider = StateNotifierProvider<SubscriptionController, SubscriptionState>((ref) {
  return SubscriptionController();
});
