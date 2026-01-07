
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';

class AgentService {
  final SupabaseClient _client;

  AgentService(this._client);

  /// Converts natural language [query] into a structured Action.
  /// Returns a Map identifying the action and parameters.
  /// e.g. {'action': 'update_assumption', 'key': 'revenue_growth_rate', 'value': 20.0}
  Future<Map<String, dynamic>> parseIntent(String query) async {
    try {
      final prompt = """
      You are an AI Controller for a Financial Forecasting App.
      Map the user's natural language request to one of the following JSON actions.
      
      ACTIONS:
      1. UPDATE ASSUMPTION:
         { "action": "update_assumption", "key": "<key_name>", "value": <number> }
         Valid Keys: "revenue_growth_rate", "monthly_opex", "current_revenue", "gross_margin", "opening_cash"
      
      2. ADD HIRE:
         { "action": "add_hire", "role": "<role_name>", "salary": <monthly_cost>, "start_month": <month_int_1_to_12> }
      
      3. SWITCH SCENARIO:
         { "action": "switch_scenario", "scenario": "base" | "bull" | "bear" }

      4. UNKNOWN:
         { "action": "unknown", "message": "I didn't understand that." }

      USER REQUEST: "$query"

      Return ONLY the raw JSON object. Use defaults if needed (Salary=5000, StartMonth=1).
      """;


      final response = await _client.functions.invoke(
        'analyze-doc', // Re-using existing function for text-to-text
        body: {'parts': [{'text': prompt}]},
      );

      if (response.status == 200) {
          final data = response.data;
          final Map<String, dynamic> jsonResponse = (data is String) ? jsonDecode(data) : data;
          
          if (jsonResponse.containsKey('error')) throw Exception(jsonResponse['error']);
          
          final candidates = jsonResponse['candidates'] as List?;
          if (candidates != null && candidates.isNotEmpty) {
             String text = candidates[0]['content']?['parts']?[0]['text'] ?? '{}';
             
             // Clean code blocks
             text = text.replaceAll('```json', '').replaceAll('```', '').trim();
             
             return jsonDecode(text) as Map<String, dynamic>;
          }
      }
      return {'action': 'unknown', 'message': 'AI currently offline.'};

    } catch (e) {
      print('Agent Error: $e');
      return {'action': 'unknown', 'message': 'Failed to process command.'};
    }
  }
}
