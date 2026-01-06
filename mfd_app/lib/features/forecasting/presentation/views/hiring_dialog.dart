import 'package:flutter/material.dart';
import 'package:mfd_app/core/theme/app_theme.dart';
import 'package:mfd_app/features/forecasting/domain/entities/staff.dart';
import 'package:uuid/uuid.dart';

class HiringDialog extends StatefulWidget {
  final Function(Staff) onHire;

  const HiringDialog({super.key, required this.onHire});

  @override
  State<HiringDialog> createState() => _HiringDialogState();
}

class _HiringDialogState extends State<HiringDialog> {
  final _roleController = TextEditingController();
  final _salaryController = TextEditingController();
  int _startMonth = 1;

  // Presets
  final List<Map<String, dynamic>> _presets = [
    {'role': 'Junior Dev', 'salary': 8000},
    {'role': 'Senior Dev', 'salary': 14000},
    {'role': 'Sales Rep', 'salary': 6000},
    {'role': 'Marketing Lead', 'salary': 10000},
    {'role': 'CS Rep', 'salary': 5000},
  ];

  void _applyPreset(Map<String, dynamic> preset) {
    setState(() {
      _roleController.text = preset['role'];
      _salaryController.text = preset['salary'].toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.commandGrey,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppTheme.borderGrey)),
      title: const Text('Add New Hire', style: TextStyle(color: Colors.white)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Presets
            const Text('Quick Select:', style: TextStyle(color: AppTheme.textMedium, fontSize: 12)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _presets.map((p) => ActionChip(
                backgroundColor: AppTheme.voidBlack,
                side: const BorderSide(color: AppTheme.electricBlue),
                label: Text(p['role'], style: const TextStyle(color: AppTheme.electricBlue, fontSize: 11)),
                onPressed: () => _applyPreset(p),
              )).toList(),
            ),
            const SizedBox(height: 24),
            
            // Form
            TextField(
              controller: _roleController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Role Title',
                labelStyle: TextStyle(color: AppTheme.textMedium),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.borderGrey)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _salaryController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Monthly Cost (\$)',
                labelStyle: TextStyle(color: AppTheme.textMedium),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.borderGrey)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Start Month:', style: TextStyle(color: AppTheme.textMedium)),
                DropdownButton<int>(
                  value: _startMonth,
                  dropdownColor: AppTheme.commandGrey,
                  style: const TextStyle(color: Colors.white),
                  items: List.generate(18, (index) => index + 1)
                      .map((i) => DropdownMenuItem(value: i, child: Text('Month $i')))
                      .toList(),
                  onChanged: (val) => setState(() => _startMonth = val!),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: AppTheme.textLow)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.signalGreen),
          onPressed: () {
            if (_roleController.text.isNotEmpty && _salaryController.text.isNotEmpty) {
              final salary = double.tryParse(_salaryController.text) ?? 0.0;
              final staff = Staff(
                id: const Uuid().v4(),
                role: _roleController.text,
                monthlySalary: salary,
                startMonth: _startMonth,
              );
              widget.onHire(staff);
              Navigator.pop(context);
            }
          },
          child: const Text('Hire', style: TextStyle(color: AppTheme.voidBlack, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
