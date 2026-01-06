import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mfd_app/core/theme/app_theme.dart';
import 'package:mfd_app/features/forecasting/presentation/controllers/forecast_controller.dart';
import 'package:mfd_app/core/ui/glass_container.dart';

class DriverTreeWidget extends ConsumerWidget {
  const DriverTreeWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(forecastControllerProvider);
    final controller = ref.read(forecastControllerProvider.notifier);
    final model = state.model;
    
    // Derived Data
    final runway = model.runwayMonths;
    final revGrowth = state.assumptions.firstWhere((a) => a.key == 'revenue_growth_rate').value;
    final opex = state.assumptions.firstWhere((a) => a.key == 'monthly_opex').value;
    final startRev = state.assumptions.firstWhere((a) => a.key == 'current_revenue').value;
    
    // Calculate total staff cost (simple approximation for M1)
    final staffCost = state.staff.fold(0.0, (sum, s) => sum + s.monthlySalary);

    return Column(
      children: [
        // Title
        Row(
          children: const [
            Icon(Icons.account_tree_outlined, color: AppTheme.signalGreen),
            SizedBox(width: 12),
            Text('Driver Tree (Living Model)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textHigh)),
          ],
        ),
        const SizedBox(height: 24),

        // Tree Layout: Root -> Branches -> Leafs
        // We use a simplified vertical Layout for V1
        
        // LEVEL 1: OUTCOME
        _TreeNode(
          label: 'RUNWAY',
          value: '$runway Months',
          color: runway > 18 ? AppTheme.signalGreen : AppTheme.alertRed,
          isRoot: true,
        ),
        
        _TreeConnector(height: 24),

        // LEVEL 2: COMPOSITES (Net Burn / Growth)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Branch: Revenue
            Column(
              children: [
                 _TreeNode(
                  label: 'REVENUE',
                  value: _formatMoney(startRev),
                  color: AppTheme.electricBlue,
                ),
                _TreeConnector(height: 24),
                // Inputs
                _InputNode(
                  label: 'Growth Rate',
                  value: '${revGrowth.toStringAsFixed(1)}%',
                  onTap: () => _editAssumption(context, controller, 'revenue_growth_rate', revGrowth),
                ),
                const SizedBox(height: 8),
                _InputNode(
                  label: 'Base MRR',
                  value: _formatMoney(startRev),
                  onTap: () => _editAssumption(context, controller, 'current_revenue', startRev),
                ),
              ],
            ),
            
            // Right Branch: Burn
            Column(
              children: [
                _TreeNode(
                  label: 'NET BURN',
                  value: _formatMoney(opex + staffCost),
                  color: AppTheme.alertRed,
                ),
                _TreeConnector(height: 24),
                // Inputs
                _InputNode(
                  label: 'Fixed Opex',
                  value: _formatMoney(opex),
                  onTap: () => _editAssumption(context, controller, 'monthly_opex', opex),
                ),
                const SizedBox(height: 8),
                _InputNode(
                  label: 'Staff Cost',
                  value: _formatMoney(staffCost),
                  isReadOnly: true,
                  subtext: '${state.staff.length} Hires',
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  void _editAssumption(BuildContext context, ForecastController controller, String key, double currentValue) {
    // Simple Dialog for Number Input
    final textCtrl = TextEditingController(text: currentValue.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.commandGrey,
        title: Text('Edit Driver', style: TextStyle(color: AppTheme.textHigh)),
        content: TextField(
          controller: textCtrl,
          keyboardType: TextInputType.number,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'New Value',
            labelStyle: TextStyle(color: AppTheme.textMedium),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.electricBlue)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.electricBlue),
            onPressed: () {
               final val = double.tryParse(textCtrl.text);
               if (val != null) {
                 controller.updateAssumption(key, val);
                 Navigator.pop(ctx);
               }
            }, 
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _formatMoney(double val) {
    if (val >= 1000) return '\$${(val / 1000).toStringAsFixed(1)}k';
    return '\$${val.toStringAsFixed(0)}';
  }
}

class _TreeNode extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isRoot;

  const _TreeNode({required this.label, required this.value, required this.color, this.isRoot = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      width: 140,
      decoration: BoxDecoration(
        color: AppTheme.voidBlack,
        border: Border.all(color: color, width: isRoot ? 2 : 1),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.2), blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(color: AppTheme.textMedium, fontSize: 10, letterSpacing: 1.2)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'JetBrains Mono')),
        ],
      ),
    );
  }
}

class _InputNode extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onTap;
  final bool isReadOnly;
  final String? subtext;

  const _InputNode({required this.label, required this.value, this.onTap, this.isReadOnly = false, this.subtext});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isReadOnly ? null : onTap,
      child: Container(
        width: 140,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.commandGrey,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: isReadOnly ? Colors.transparent : AppTheme.borderGrey),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: AppTheme.textMedium, fontSize: 10)),
                Text(value, style: const TextStyle(color: AppTheme.signalGreen, fontFamily: 'JetBrains Mono', fontSize: 12)),
              ],
            ),
            if (!isReadOnly)
              Icon(Icons.edit, size: 12, color: AppTheme.textLow),
            if (subtext != null)
              Text(subtext!, style: TextStyle(fontSize: 9, color: AppTheme.textLow)),
          ],
        ),
      ),
    );
  }
}

class _TreeConnector extends StatelessWidget {
  final double height;
  const _TreeConnector({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: height,
      color: AppTheme.borderGrey,
    );
  }
}
