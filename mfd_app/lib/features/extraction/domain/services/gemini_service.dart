import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mfd_app/features/forecasting/domain/entities/assumption.dart';
import 'package:mfd_app/features/extraction/domain/entities/document.dart'; // Import Document

import 'package:mfd_app/core/secrets/app_secrets.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

class GeminiService {
  const GeminiService();

  Future<List<Assumption>> extractData(List<Document> docs) async {
    // SECURITY UPDATE: Using Supabase Edge Function (Server-Side Proxy)
    try {
      final parts = <Map<String, dynamic>>[
        {
          'text': 'You are a financial analyst. Analyze these documents (P&L, Decks, Bank Statements). '
          'Extract the following 3 key metrics for a SaaS forecast:\n'
          '1. "revenue_growth_rate": The projected monthly revenue growth rate as a percentage (e.g., 10 for 10%). If unknown, estimate based on stage (Seed=10, Series A=5).\n'
          '2. "monthly_opex": The current monthly operating expenses (burn rate) in USD.\n'
          '3. "starting_cash": The current cash balance in USD.\n\n'
          'Return ONLY a raw JSON object (no markdown, no backticks) with keys: "revenue_growth_rate", "monthly_opex", "starting_cash". '
          'Example: {"revenue_growth_rate": 5.5, "monthly_opex": 45000, "starting_cash": 1200000}'
        }
      ];

      for (var doc in docs) {
         if (doc.bytes == null) continue; // Skip if no content
         
         final base64Data = base64Encode(doc.bytes!);
         final mimeType = _getMimeType(doc.name);
         
         parts.add({
           'inline_data': {
             'mime_type': mimeType,
             'data': base64Data
           }
         });
      }

      print('Supabase Edge Function: Invoking analyze-doc...');
      print('Supabase Edge Function: Invoking analyze-doc...');
      final response = await Supabase.instance.client.functions.invoke(
        'analyze-doc',
        body: {'parts': parts},
      );
      
      print('Supabase Response Status: ${response.status}');

      if (response.status == 200) {
        // The edge function returns the raw Gemini response
        // e.g. { "candidates": [ ... ] }
        final data = response.data; // invoke parses JSON auto if content-type is json
        
        // Handle type safety: response.data is dynamic
        final Map<String, dynamic> jsonResponse = (data is String) ? jsonDecode(data) : data;

        // Check for Upstream API Error (Google Gemini)
        if (jsonResponse.containsKey('error')) {
           final errorMsg = jsonResponse['error']['message'] ?? 'Unknown API Error';
           throw Exception('AI Provider Error: $errorMsg');
        }

        final candidates = jsonResponse['candidates'] as List?;
        if (candidates == null || candidates.isEmpty) {
           // Debug: Print full response
           print('Gemini RAW Response: $jsonResponse');
           throw Exception('AI returned no candidates. Raw: $jsonResponse');
        }

        final candidate = candidates[0];
        if (candidate.containsKey('finishReason')) {
           final reason = candidate['finishReason'];
           if (reason != 'STOP') {
             print('Gemini Finish Reason: $reason');
             if (reason == 'SAFETY') throw Exception('AI blocked content due to SAFETY/Privacy settings.');
             if (reason == 'RECITATION') throw Exception('AI blocked due to Copyright/Recitation.');
           }
        }

        final content = candidate['content'];
        if (content == null) throw Exception('AI returned candidates but no content (FinishReason: ${candidate['finishReason']})');
        
        final parts = content['parts'] as List?;
        final text = parts?[0]['text'];
        
        return _parseRawText(text);
      } else {
         throw Exception('Proxy Function failed: ${response.status} - ${response.data}');
      }

    } catch (e) {
      print('Gemini Proxy Error: $e');
      throw Exception('Security/Proxy Failure: $e');
    }
  }

  Future<String> generateInsights(Map<String, dynamic> forecastSummary) async {
    try {
        final prompt = "Analyze this financial forecast summary (Assumptions & Hires) and provide 3 brief, high-impact bullet points of executive insights (Focus on risks, runway, and growth potential). Keep it professional. Data: $forecastSummary";
        return await _callGenericTextPrompt(prompt);
    } catch (e) {
        print('Insights Error: $e');
        return "AI Insights temporarily unavailable. Please check your connection.";
    }
  }

  Future<String> _callGenericTextPrompt(String prompt) async {
      try {
        print('Supabase Edge Function: Generative Text Request...');
        final response = await Supabase.instance.client.functions.invoke(
          'analyze-doc',
          body: {'parts': [{'text': prompt}]},
        );

        if (response.status == 200) {
          final data = response.data;
          final Map<String, dynamic> jsonResponse = (data is String) ? jsonDecode(data) : data;
          
          if (jsonResponse.containsKey('error')) throw Exception(jsonResponse['error']['message']);
          
          final candidates = jsonResponse['candidates'] as List?;
          if (candidates != null && candidates.isNotEmpty) {
             final text = candidates[0]['content']?['parts']?[0]['text'];
             if (text != null) return text;
          }
        }
        throw Exception('No valid text response from AI');
      } catch (e) {
        throw Exception('AI Text Error: $e');
      }
  }

  List<Assumption> _parseRawText(String? text) {
      if (text == null) throw Exception('No content in Gemini response');

      // Robust JSON Extraction
      String cleanJson = text;
      if (text.contains('```json')) {
        cleanJson = text.split('```json')[1].split('```')[0].trim();
      } else if (text.contains('```')) {
        cleanJson = text.split('```')[1].split('```')[0].trim();
      }
      
      Map<String, dynamic> jsonMap;
      try {
        jsonMap = jsonDecode(cleanJson) as Map<String, dynamic>;
      } catch (e) {
        print('JSON Parse Error: $e');
         // Fallback: minimal clean
        jsonMap = jsonDecode(cleanJson.replaceAll(RegExp(r'[^\{]*\{'), '{').replaceAll(RegExp(r'\}[^\}]*$'), '}')) as Map<String, dynamic>;
      }
      
      return [
        Assumption(
          key: 'revenue_growth_rate', 
          label: 'Revenue Growth Rate', 
          value: (jsonMap['revenue_growth_rate'] as num?)?.toDouble() ?? 0.0, 
          unit: '%',
          sourceSnippet: 'AI Extracted from documents'
        ),
        Assumption(
          key: 'monthly_opex', 
          label: 'Monthly Burn (Opex)', 
          value: (jsonMap['monthly_opex'] as num?)?.toDouble() ?? 0.0, 
          unit: '\$',
          sourceSnippet: 'AI Extracted from documents'
        ),
        Assumption(
          key: 'starting_cash', 
          label: 'Starting Cash Balance', 
          value: (jsonMap['starting_cash'] as num?)?.toDouble() ?? 0.0, 
          unit: '\$',
          sourceSnippet: 'AI Extracted from documents'
        ),
      ];
  }

  String _getMimeType(String path) {
    if (path.endsWith('.pdf')) return 'application/pdf';
    if (path.endsWith('.png')) return 'image/png';
    if (path.endsWith('.jpg') || path.endsWith('.jpeg')) return 'image/jpeg';
    return 'application/pdf'; // Default fallback
  }
}
