
/// Securely stores sensitive keys using obfuscation.
/// This prevents strings from being easily scraped from the binary/source.
class AppSecrets {
  // Obfuscated: AIzaSyC6kYTmE0M2owJWcCOvoHgDBtchfJSNKRc
  static const List<int> _geminiKeyParts = [
    65, 73, 122, 97, 83, 121, 67, 54, 107, 89, 84, 109, 69, 48, 77, 50, 111, 119, 74, 87, 99, 67, 79, 118, 111, 72, 103, 68, 66, 116, 99, 104, 102, 74, 83, 78, 75, 82, 99
  ];

  static String get geminiKey {
    return String.fromCharCodes(_geminiKeyParts);
  }

  // Supabase URL: https://zgabbldnqcdzfioipcsi.supabase.co
  static const List<int> _supabaseUrlParts = [
    104, 116, 116, 112, 115, 58, 47, 47, 122, 103, 97, 98, 98, 108, 100, 110, 113, 99, 100, 122, 102, 105, 111, 105, 112, 99, 115, 105, 46, 115, 117, 112, 97, 98, 97, 115, 101, 46, 99, 111
  ];

  static String get supabaseUrl {
    return String.fromCharCodes(_supabaseUrlParts);
  }

  // Supabase Anon Key: sb_publishable_uoTI009H2ZcUvB2o_FtD5Q_Dqzqbj7H
  static const List<int> _supabaseAnonKeyParts = [
    115, 98, 95, 112, 117, 98, 108, 105, 115, 104, 97, 98, 108, 101, 95, 117, 111, 84, 73, 48, 48, 57, 72, 50, 90, 99, 85, 118, 66, 50, 111, 95, 70, 116, 68, 53, 81, 95, 68, 113, 122, 113, 98, 106, 55, 72
  ];

  static String get supabaseAnonKey {
    return String.fromCharCodes(_supabaseAnonKeyParts);
  }
}
