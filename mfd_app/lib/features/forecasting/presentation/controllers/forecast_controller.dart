import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mfd_app/features/forecasting/domain/entities/assumption.dart';
import 'package:mfd_app/features/forecasting/domain/entities/financial_model.dart';
import 'package:mfd_app/features/forecasting/domain/logic/forecast_engine.dart';
import 'package:mfd_app/features/forecasting/domain/entities/staff.dart';
import 'package:mfd_app/features/extraction/domain/services/csv_parsing_service.dart';
import 'package:mfd_app/features/forecasting/domain/entities/actuals_series.dart';
import 'package:file_picker/file_picker.dart';

enum Scenario { base, bull, bear }

class ForecastState {
  final Scenario currentScenario;
  
  // Assumptions
  final List<Assumption> baseAssumptions;
  final List<Assumption> bullAssumptions;
  final List<Assumption> bearAssumptions;

  // Staffing
  final List<Staff> baseStaff;
  final List<Staff> bullStaff;
  final List<Staff> bearStaff;

  // Models
  final FinancialModel baseModel;
  final FinancialModel bullModel;
  final FinancialModel bearModel;
  final FinancialModel? actualsModel; // New: Actuals Overlay
  final List<ActualsSeries> rawActuals; // New: Raw Data for Pacing

  const ForecastState({
    required this.currentScenario,
    required this.baseAssumptions,
    required this.bullAssumptions,
    required this.bearAssumptions,
    required this.baseStaff,
    required this.bullStaff,
    required this.bearStaff,
    required this.baseModel,
    required this.bullModel,
    required this.bearModel,
    this.actualsModel,
    this.rawActuals = const [],
  });

  List<Assumption> get assumptions => _getForScenario(currentScenario).assumptions;
  List<Staff> get staff => _getForScenario(currentScenario).staff;
  FinancialModel get model => _getForScenario(currentScenario).model;

  ({List<Assumption> assumptions, List<Staff> staff, FinancialModel model}) _getForScenario(Scenario s) {
    switch (s) {
      case Scenario.bull: return (assumptions: bullAssumptions, staff: bullStaff, model: bullModel);
      case Scenario.bear: return (assumptions: bearAssumptions, staff: bearStaff, model: bearModel);
      case Scenario.base: default: return (assumptions: baseAssumptions, staff: baseStaff, model: baseModel);
    }
  }
}

final forecastControllerProvider = StateNotifierProvider<ForecastController, ForecastState>((ref) {
  return ForecastController();
});

class ForecastController extends StateNotifier<ForecastState> {
  final _engine = ForecastEngine();

  ForecastController() : super(_initialState());

  static ForecastState _initialState() {
     final engine = ForecastEngine();
     final baseAssumptions = [
      const Assumption(key: 'opening_cash', label: 'Starting Cash', value: 100000, unit: '\$'),
      const Assumption(key: 'revenue_growth_rate', label: 'Rev Growth', value: 5, unit: '%'),
      const Assumption(key: 'monthly_opex', label: 'Monthly Burn', value: 15000, unit: '\$'),
      const Assumption(key: 'current_revenue', label: 'Current MRR', value: 5000, unit: '\$'),
      const Assumption(key: 'gross_margin', label: 'Gross Margin', value: 90, unit: '%'),
    ];

    final bullAssumptions = baseAssumptions.map((a) => a.key == 'revenue_growth_rate' ? a.copyWith(value: 15) : a).toList();
    final bearAssumptions = baseAssumptions.map((a) {
      if (a.key == 'revenue_growth_rate') return a.copyWith(value: 0);
      if (a.key == 'monthly_opex') return a.copyWith(value: 20000);
      return a;
    }).toList();

    return ForecastState(
      currentScenario: Scenario.base,
      baseAssumptions: baseAssumptions,
      bullAssumptions: bullAssumptions,
      bearAssumptions: bearAssumptions,
      baseStaff: [],
      bullStaff: [],
      bearStaff: [],
      baseModel: engine.generateModel(baseAssumptions, staffList: []),
      bullModel: engine.generateModel(bullAssumptions, staffList: []),
      bearModel: engine.generateModel(bearAssumptions, staffList: []),
    );
  }

  void switchScenario(Scenario scenario) => state = _copyWith(currentScenario: scenario);

  void updateAssumption(String key, double newValue) {
    final current = state._getForScenario(state.currentScenario);
    final updatedAssumptions = current.assumptions.map((a) => a.key == key ? a.copyWith(value: newValue) : a).toList();
    _updateActiveScenario(updatedAssumptions, current.staff);
  }

  void addHire(Staff staff) {
    final current = state._getForScenario(state.currentScenario);
    final updatedStaff = [...current.staff, staff];
    _updateActiveScenario(current.assumptions, updatedStaff);
  }

  void removeHire(String staffId) {
    final current = state._getForScenario(state.currentScenario);
    final updatedStaff = current.staff.where((s) => s.id != staffId).toList();
    _updateActiveScenario(current.assumptions, updatedStaff);
  }

  void _updateActiveScenario(List<Assumption> assumptions, List<Staff> staff) {
    final newModel = _engine.generateModel(assumptions, staffList: staff);

    switch (state.currentScenario) {
      case Scenario.base:
        state = _copyWith(baseAssumptions: assumptions, baseStaff: staff, baseModel: newModel);
        break;
      case Scenario.bull:
        state = _copyWith(bullAssumptions: assumptions, bullStaff: staff, bullModel: newModel);
        break;
      case Scenario.bear:
        state = _copyWith(bearAssumptions: assumptions, bearStaff: staff, bearModel: newModel);
        break;
    }
  }

  void setAssumptions(List<Assumption> newAssumptions) {
    final baseModel = _engine.generateModel(newAssumptions, staffList: []);
    final bullAssumptions = newAssumptions.map((a) => a.key == 'revenue_growth_rate' ? a.copyWith(value: a.value + 5) : a).toList();
    final bearAssumptions = newAssumptions.map((a) => a.key == 'revenue_growth_rate' ? a.copyWith(value: (a.value - 5).clamp(0, 100).toDouble()) : a).toList();
    
    // Reset staff on new upload
    state = ForecastState(
        currentScenario: Scenario.base,
        baseAssumptions: newAssumptions,
        bullAssumptions: bullAssumptions,
        bearAssumptions: bearAssumptions,
        baseStaff: [],
        bullStaff: [],
        bearStaff: [],
        baseModel: baseModel,
        bullModel: _engine.generateModel(bullAssumptions, staffList: []),
        bearModel: _engine.generateModel(bearAssumptions, staffList: []),
        actualsModel: null, // Reset actuals
    );
  }

  // New: Load Actuals
  void setActuals(List<Assumption> actuals) {
    // Generate a model solely from actuals logic (simplified for now as same engine)
    final actualsModel = _engine.generateModel(actuals, staffList: []);
    // We update with actualsModel but NOT rawActuals because this method is the old path?
    // Let's assume this method is internal primarily.
    state = _copyWith(actualsModel: actualsModel);
  }

  Future<void> processAndLoadActuals(PlatformFile file) async {
    try {
      final service = CsvParsingService();
      
      // Handle Bytes (Web/Desktop withData:true)
      List<int> bytes = file.bytes ?? [];
      
      // Fallback for Desktop if bytes missing (shouldn't happen with withData:true, but safety first)
      if (bytes.isEmpty && file.path != null) {
         // We can't use dart:io here if we removed the import.
         // But we assume withData:true worked.
         // If we really need fallback, we'd need universal_io or conditional import.
         // Let's trust withData:true for now.
         throw Exception('File content not loaded. Ensure withData:true is used.');
      }

      final seriesList = await service.parseFinancialCsv(bytes, filename: file.name);
      
      if (seriesList.isEmpty) return;

      // 1. Store Raw Data for Pacing Engine
      // We need to pass this to state.
      
      // 2. Aggregate for Chart Visualization
      final Map<String, double> monthlySums = {};
      
      for (final item in seriesList) {
         final key = "${item.date.year}-${item.date.month.toString().padLeft(2, '0')}";
         monthlySums[key] = (monthlySums[key] ?? 0) + item.value;
      }
      
      if (monthlySums.isEmpty) return;
      
      final firstVal = monthlySums.values.first; 
      
      final newAssumptions = state.baseAssumptions.map((a) {
        if (a.key == 'current_revenue') return a.copyWith(value: firstVal);
        return a;
      }).toList();
      
      final actualsModel = _engine.generateModel(newAssumptions, staffList: []);
      
      state = _copyWith(
        actualsModel: actualsModel, 
        rawActuals: seriesList,
      );
      
    } catch (e) {
      print('CSV Parse Error: $e');
      rethrow;
    }
  }

  ForecastState _copyWith({
    Scenario? currentScenario,
    List<Assumption>? baseAssumptions,
    List<Assumption>? bullAssumptions,
    List<Assumption>? bearAssumptions,
    List<Staff>? baseStaff,
    List<Staff>? bullStaff,
    List<Staff>? bearStaff,
    FinancialModel? baseModel,
    FinancialModel? bullModel,
    FinancialModel? bearModel,
    FinancialModel? actualsModel,
    List<ActualsSeries>? rawActuals,
  }) {
    return ForecastState(
      currentScenario: currentScenario ?? state.currentScenario,
      baseAssumptions: baseAssumptions ?? state.baseAssumptions,
      bullAssumptions: bullAssumptions ?? state.bullAssumptions,
      bearAssumptions: bearAssumptions ?? state.bearAssumptions,
      baseStaff: baseStaff ?? state.baseStaff,
      bullStaff: bullStaff ?? state.bullStaff,
      bearStaff: bearStaff ?? state.bearStaff,
      baseModel: baseModel ?? state.baseModel,
      bullModel: bullModel ?? state.bullModel,
      bearModel: bearModel ?? state.bearModel,
      actualsModel: actualsModel ?? state.actualsModel,
      rawActuals: rawActuals ?? state.rawActuals,
    );
  }
}
