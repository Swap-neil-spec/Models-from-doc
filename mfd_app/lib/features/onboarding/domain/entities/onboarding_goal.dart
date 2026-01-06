enum OnboardingDocumentType {
  pnl,
  bankStatement,
  stripeCsv,
  payrollCsv,
  capTable,
}

enum OnboardingGoal {
  survival,
  fundraising,
  hiring;

  String get label {
    switch (this) {
      case OnboardingGoal.survival: return 'Survival Mode';
      case OnboardingGoal.fundraising: return 'Fundraise Ready';
      case OnboardingGoal.hiring: return 'Hiring Plan';
    }
  }

  String get description {
    switch (this) {
      case OnboardingGoal.survival: return 'I need to know my runway and burn rate immediately.';
      case OnboardingGoal.fundraising: return 'I need investor-grade metrics (LTV, CAC, Retention).';
      case OnboardingGoal.hiring: return 'Can I afford to hire more people right now?';
    }
  }

  List<OnboardingDocumentType> get recommendedDocuments {
    switch (this) {
      case OnboardingGoal.survival:
        return [OnboardingDocumentType.pnl, OnboardingDocumentType.bankStatement];
      case OnboardingGoal.fundraising:
        return [OnboardingDocumentType.pnl, OnboardingDocumentType.stripeCsv, OnboardingDocumentType.capTable];
      case OnboardingGoal.hiring:
        return [OnboardingDocumentType.pnl, OnboardingDocumentType.payrollCsv];
    }
  }
}

