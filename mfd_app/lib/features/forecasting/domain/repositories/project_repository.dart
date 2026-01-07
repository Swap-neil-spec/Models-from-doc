
import 'dart:convert';
import 'package:mfd_app/features/forecasting/domain/entities/assumption.dart';
import 'package:mfd_app/features/forecasting/domain/entities/staff.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProjectRepository {
  static const String _keyAssumptions = 'project_assumptions';
  static const String _keyStaff = 'project_staff';
  static const String _keyScenario = 'project_scenario';
  static const String _keyActuals = 'project_actuals';

  Future<void> saveProject({
    required List<Assumption> baseAssumptions,
    required List<Staff> baseStaff,
    required String currentScenario,
    List<Assumption>? actuals,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Save Assumptions
    final assumptionsJson = jsonEncode(baseAssumptions.map((e) => e.toJson()).toList());
    await prefs.setString(_keyAssumptions, assumptionsJson);

    // Save Staff
    final staffJson = jsonEncode(baseStaff.map((e) => e.toJson()).toList());
    await prefs.setString(_keyStaff, staffJson);

    // Save Scenario Intent
    await prefs.setString(_keyScenario, currentScenario);

    // Save Actuals (if any)
    if (actuals != null) {
      final actualsJson = jsonEncode(actuals.map((e) => e.toJson()).toList());
      await prefs.setString(_keyActuals, actualsJson);
    }
  }

  Future<({
    List<Assumption>? assumptions, 
    List<Staff>? staff, 
    String? scenario,
    List<Assumption>? actuals
  })> loadProject() async {
    final prefs = await SharedPreferences.getInstance();

    final assumptionsString = prefs.getString(_keyAssumptions);
    final staffString = prefs.getString(_keyStaff);
    final scenarioString = prefs.getString(_keyScenario);
    final actualsString = prefs.getString(_keyActuals);

    List<Assumption>? loadedAssumptions;
    if (assumptionsString != null) {
      try {
        final List decoded = jsonDecode(assumptionsString);
        loadedAssumptions = decoded.map((e) => Assumption.fromJson(e)).toList();
      } catch (e) {
        print('Error loading assumptions: $e');
      }
    }

    List<Staff>? loadedStaff;
    if (staffString != null) {
      try {
        final List decoded = jsonDecode(staffString);
        loadedStaff = decoded.map((e) => Staff.fromJson(e)).toList();
      } catch (e) {
        print('Error loading staff: $e');
      }
    }

    List<Assumption>? loadedActuals;
    if (actualsString != null) {
      try {
        final List decoded = jsonDecode(actualsString);
        loadedActuals = decoded.map((e) => Assumption.fromJson(e)).toList();
      } catch (e) {
        print('Error loading actuals: $e');
      }
    }

    return (
      assumptions: loadedAssumptions,
      staff: loadedStaff,
      scenario: scenarioString,
      actuals: loadedActuals,
    );
  }

  Future<void> clearProject() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAssumptions);
    await prefs.remove(_keyStaff);
    await prefs.remove(_keyScenario);
    await prefs.remove(_keyActuals);
  }
}
