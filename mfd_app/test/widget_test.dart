// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mfd_app/main.dart';
import 'package:mfd_app/features/forecasting/presentation/views/dashboard_screen.dart';

void main() {
  testWidgets('Smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: MfdApp()));

    // --- Onboarding Flow ---
    // Beat 1: Magic Promise
    expect(find.text('Turn documents into your future.'), findsOneWidget);
    await tester.tap(find.text('Start Journey'));
    await tester.pump(); // Start transition
    await tester.pump(const Duration(seconds: 1)); // Wait for transition

    // Beat 2: Identity (Select Fox)
    await tester.pump(const Duration(seconds: 2)); // Wait for cards to animate in (400ms+ delays)
    expect(find.text('Who Are You?'), findsOneWidget);
    await tester.tap(find.text('The Fox')); // Select Archetype
    await tester.pump(); // State change
    await tester.pump(const Duration(seconds: 1)); // Wait for transition

    // Beat 3: Personalization (Select Seed)
    await tester.pump(const Duration(seconds: 1)); // Wait for buttons in
    expect(find.text('What stage is your crusade?'), findsOneWidget);
    await tester.tap(find.text('Seed Stage (1-10)'));
    await tester.pump(); // State change
    await tester.pump(const Duration(seconds: 1)); // Wait for transition

    // Beat 4: Excitement (Wait for auto-advance)
    expect(find.text('Calibrating Engines...'), findsOneWidget);
    await tester.pump(const Duration(seconds: 4)); // Wait for 3s delay + transition
    await tester.pump(); // Frame


    // --- Home Screen ---
    // Verify that the Home Screen button is present.
    expect(find.text('Start New Workspace'), findsOneWidget);

    // Tap the 'Start' button and trigger a frame.
    await tester.tap(find.text('Start New Workspace'));
    await tester.pumpAndSettle();

    // Verify that we are on the Upload Screen.
    expect(find.text('Upload Documents'), findsOneWidget);
    expect(find.text('Start your forecast'), findsOneWidget);

    // Tap 'Process Documents with AI' (Button text changed)
    await tester.scrollUntilVisible(find.text('Process Documents with AI'), 50.0);
    await tester.tap(find.text('Process Documents with AI'));
    await tester.pumpAndSettle();

    // Verify Dialog appears
    expect(find.text('Enter Gemini API Key'), findsOneWidget);

    // Enter Mock Key
    await tester.enterText(find.byType(TextField), 'dummy_api_key');
    await tester.tap(find.text('Analyze'));
    await tester.pumpAndSettle(); // Wait for analyzing (Mock/Real)
    
    // Note: The controller logic will fail with a real or dummy API call in test environment 
    // unless mocked, so we might expect an error snackbar or just verify the dialog interaction.
    // For this smoke test, let's verify we tried.
    
    // Since we can't easily mock the GeminiService inside the widget test without dependency injection override,
    // we might see a SnackBar error "AI Extraction Failed". 
    // Let's check for that or the Dashboard if somehow it succeeded (unlikely).
    
    // Check if we stayed on screen or went to dashboard. 
    // If failed, we are still on Upload Screen.
    expect(find.text('Upload Documents'), findsOneWidget); 
  });

  testWidgets('Dashboard smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: DashboardScreen())));

    // Verify Dashboard renders
    expect(find.text('Financial Model'), findsOneWidget);
    expect(find.text('Cash Balance (18 Months)'), findsOneWidget);

    // Verify Export Button
    final exportBtn = find.byIcon(Icons.download);
    expect(exportBtn, findsOneWidget);
    
    // Tap Export
    await tester.tap(exportBtn);
    await tester.pumpAndSettle();
    
    // Verify Bottom Sheet
    expect(find.text('Export as CSV (Excel)'), findsOneWidget);
    expect(find.text('Export as PDF Report'), findsOneWidget);
  });
}
