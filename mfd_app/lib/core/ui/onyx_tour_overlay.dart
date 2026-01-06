import 'package:flutter/material.dart';
import 'package:mfd_app/core/theme/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';

class OnyxTourOverlay extends StatefulWidget {
  final Widget child;
  final bool showTour;
  final VoidCallback onComplete;

  const OnyxTourOverlay({super.key, required this.child, required this.showTour, required this.onComplete});

  @override
  State<OnyxTourOverlay> createState() => _OnyxTourOverlayState();
}

class _OnyxTourOverlayState extends State<OnyxTourOverlay> {
  int _step = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        
        if (widget.showTour)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.7),
            ).animate().fadeIn(),
          ),
          
        if (widget.showTour)
          _buildStep(),
      ],
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0: // Sidebar
        return Positioned(
          left: 100,
          top: 100,
          child: _buildTooltip(
            title: 'MISSION CONTROL',
            content: 'Your main navigation hub. Switch between Cockpit, Upload, and System Settings.',
            onNext: () => setState(() => _step++),
          ),
        );
      case 1: // Command Palette
        return Positioned(
          top: 80,
          right: 350,
          child: _buildTooltip(
            title: 'COMMAND LINK',
            content: 'Press Cmd+K to access global actions instantly. Switch scenarios, add hires, or navigate.',
            onNext: () => setState(() => _step++),
          ),
        );
      case 2: // Driver Tree
        return Positioned(
          bottom: 200,
          left: 300,
          child: _buildTooltip(
            title: 'LIVING MODEL',
            content: 'This isn\'t just a chart. It\'s a circuit. Click any node to adjust inputs and watch the Runway update in real-time.',
            onNext: widget.onComplete,
            isLast: true,
          ),
        );
      default:
        return const SizedBox();
    }
  }

  Widget _buildTooltip({required String title, required String content, required VoidCallback onNext, bool isLast = false}) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.commandGrey,
        border: Border.all(color: AppTheme.signalGreen),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
           BoxShadow(color: AppTheme.signalGreen.withOpacity(0.2), blurRadius: 24, spreadRadius: 0),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: AppTheme.signalGreen, size: 16),
              const SizedBox(width: 8),
              Text(
                title, 
                style: const TextStyle(
                  color: AppTheme.signalGreen, 
                  fontWeight: FontWeight.bold, 
                  fontSize: 12, 
                  letterSpacing: 1.5
                )
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(content, style: const TextStyle(color: Colors.white, height: 1.5)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: widget.onComplete,
                child: const Text('Skip', style: TextStyle(color: AppTheme.textLow)),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.signalGreen, foregroundColor: AppTheme.voidBlack),
                onPressed: onNext, 
                child: Text(isLast ? 'ENGAGE' : 'NEXT'),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().scale();
  }
}
