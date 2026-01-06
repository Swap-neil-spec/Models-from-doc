import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:mfd_app/core/theme/app_theme.dart';
import 'package:mfd_app/features/extraction/presentation/controllers/upload_controller.dart';
import 'package:mfd_app/features/extraction/domain/entities/document.dart';
import 'package:mfd_app/core/ui/cinematic_loader.dart';

import 'package:mfd_app/features/onboarding/domain/entities/onboarding_goal.dart';

class UploadScreen extends ConsumerWidget {
  final OnboardingGoal? goal;
  const UploadScreen({super.key, this.goal});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uploadState = ref.watch(uploadControllerProvider);
    final controller = ref.read(uploadControllerProvider.notifier);
    final theme = Theme.of(context);
    final documents = uploadState.files;
    final isAnalyzing = uploadState.status == UploadStatus.analyzing;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Documents'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
               if (goal != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C63FF).withOpacity(0.1),
                      border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.lightbulb, color: Color(0xFF6C63FF), size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Goal: ${goal!.label}',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6C63FF)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                         const Text('For the best results, please upload:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: goal!.recommendedDocuments.map((doc) {
                            return Chip(
                              label: Text(doc.name, style: const TextStyle(fontSize: 10)),
                              backgroundColor: const Color(0xFF6C63FF).withOpacity(0.2),
                              visualDensity: VisualDensity.compact,
                              side: BorderSide.none,
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),

                const Text(
                  'Start your forecast',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Upload your P&L, Investor Deck, or Bank Statements.',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                
                // Drop Zone
                InkWell(
                  onTap: isAnalyzing ? null : () => controller.pickFiles(),
                  child: DottedBorder(
                    color: theme.primaryColor.withValues(alpha: 0.5),
                    strokeWidth: 2,
                    dashPattern: const [8, 4],
                    borderType: BorderType.RRect,
                    radius: const Radius.circular(12),
                    child: Container(
                      height: 180,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cloud_upload_outlined, size: 48, color: theme.primaryColor),
                          const SizedBox(height: 12),
                          const Text(
                            'Click to Upload Documents',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          const Text(
                            'PDF, CSV, XLSX supported',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // File List
                if (documents.isNotEmpty) ...[
                  const Text(
                    'Uploaded Files',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.separated(
                      itemCount: documents.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final doc = documents[index];
                        return _DocumentListTile(doc: doc, onDelete: () => controller.removeFile(doc.id));
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: isAnalyzing 
                        ? null 
                        : () => _handleProcess(context, controller, ref),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: isAnalyzing 
                          ? const SizedBox(
                              height: 20, 
                              width: 20, 
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                            )
                          : const Text('Process Documents with AI'),
                    ),
                  ),
                ],
              ],
            ),
          ),
          

          if (isAnalyzing)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.8), // Darker overlay for focus
                child: const CinematicLoader(), 
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _handleProcess(BuildContext context, UploadController controller, WidgetRef ref) async {
    final success = await controller.processDocuments();
    if (!context.mounted) return;

    if (success) {
      GoRouter.of(context).go('/dashboard');
    } else {
      // Re-read the state to get the error message
      final errorMsg = ref.read(uploadControllerProvider).errorMessage ?? 'AI Extraction Failed. Check File Content.';
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

class _DocumentListTile extends StatelessWidget {
  final Document doc;
  final VoidCallback onDelete;

  const _DocumentListTile({required this.doc, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;

    switch (doc.type) {
      case DocumentType.pdf:
        icon = Icons.picture_as_pdf;
        color = Colors.red;
        break;
      case DocumentType.spreadsheet:
        icon = Icons.table_chart;
        color = Colors.green;
        break;
      case DocumentType.presentation:
        icon = Icons.slideshow;
        color = Colors.orange;
        break;
      default:
        icon = Icons.insert_drive_file;
        color = Colors.grey;
    }

    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(doc.name, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Row(
          children: [
            if (doc.tag != DocumentTag.other)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.deepBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  doc.tag.name.toUpperCase(),
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.deepBlue),
                ),
              ),
            if (doc.status == ProcessingStatus.analyzing)
              const Padding(
                padding: EdgeInsets.only(left: 8.0, top: 4),
                child: Text('Analyzing...', style: TextStyle(fontSize: 12, color: Colors.orange)),
              ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.close),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
