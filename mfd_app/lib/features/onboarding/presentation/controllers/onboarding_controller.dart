import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mfd_app/features/onboarding/domain/state/onboarding_state.dart';

final onboardingControllerProvider = StateNotifierProvider<OnboardingController, OnboardingState>((ref) {
  return OnboardingController();
});

class OnboardingController extends StateNotifier<OnboardingState> {
  OnboardingController() : super(const OnboardingState());

  Future<void> setArchetype(FounderArchetype archetype) async {
    state = state.copyWith(archetype: archetype, currentBeat: OnboardingBeat.personalization);
    // Persist archetype for future sessions (e.g., adapt dashboard)
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('founder_archetype', archetype.name);
  }

  void setStage(String stage) {
     // Trigger transition to excitement beat
     state = state.copyWith(stage: stage, currentBeat: OnboardingBeat.excitement);
  }

  void completeExcitement() {
    state = state.copyWith(currentBeat: OnboardingBeat.complete);
  }

  void startJourney() {
    state = state.copyWith(currentBeat: OnboardingBeat.identity);
  }
}
