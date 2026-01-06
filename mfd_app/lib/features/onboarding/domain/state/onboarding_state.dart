enum OnboardingBeat {
  magicPromise, // Beat 1
  identity, // Beat 2
  personalization, // Beat 3
  excitement, // Beat 4
  complete // Beat 5 (Nav to Dashboard)
}

enum FounderArchetype {
  fox, // Efficiency
  tiger, // Growth
  falcon, // Vision
  undecided
}

class OnboardingState {
  final OnboardingBeat currentBeat;
  final FounderArchetype archetype;
  final String stage;

  const OnboardingState({
    this.currentBeat = OnboardingBeat.magicPromise,
    this.archetype = FounderArchetype.undecided,
    this.stage = '',
  });

  OnboardingState copyWith({
    OnboardingBeat? currentBeat,
    FounderArchetype? archetype,
    String? stage,
  }) {
    return OnboardingState(
      currentBeat: currentBeat ?? this.currentBeat,
      archetype: archetype ?? this.archetype,
      stage: stage ?? this.stage,
    );
  }
}
