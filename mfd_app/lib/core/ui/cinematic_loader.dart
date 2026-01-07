
import 'package:flutter/material.dart';
import 'dart:ui' as android_ui; // Use prefix to avoid conflicts
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mfd_app/core/theme/app_theme.dart';

class CinematicLoader extends StatefulWidget {
  const CinematicLoader({super.key});

  @override
  State<CinematicLoader> createState() => _CinematicLoaderState();
}

class _CinematicLoaderState extends State<CinematicLoader> {
  int _index = 0;
  final List<String> _messages = [
    "Reading Documents...",
    "Analyzing Burn Rate...",
    "Forecasting Runway...",
    "Finalizing Model...",
    "Applying Growth Logic...",
  ];

  @override
  void initState() {
    super.initState();
    _cycleMessages();
  }

  void _cycleMessages() async {
    while (mounted) {
      await Future.delayed(const Duration(milliseconds: 2500));
      if (mounted) {
        setState(() {
          _index = (_index + 1) % _messages.length;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Glass Blur Effect
          ClipRect(
            child: BackdropFilter(
              filter: android_ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ).animate().fadeIn(),

          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated Pulse
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.emeraldGreen.withValues(alpha: 0.2),
                ),
            child: Center(
              child: Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.emeraldGreen,
                ),
                child: const Icon(Icons.auto_awesome, color: Colors.white, size: 28),
              ).animate(onPlay: (c) => c.repeat(reverse: true))
               .scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2), duration: 1000.ms),
            ),
          ).animate().fadeIn(),

          const SizedBox(height: 32),

          // Cycling Text with Slide Transition
          SizedBox(
            height: 40,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(begin: const Offset(0.0, 0.5), end: Offset.zero)
                        .animate(animation),
                    child: child,
                  ),
                );
              },
              child: Text(
                _messages[_index],
                key: ValueKey<int>(_index),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          const Text(
            "AI Agent Active",
            style: TextStyle(fontSize: 12, color: Colors.white54, letterSpacing: 1.5),
          ),
        ],
      ),
        ],
      ),
    );
  }
}
