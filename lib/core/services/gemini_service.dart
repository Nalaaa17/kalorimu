import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../constants/env.dart';

class GeminiService {
  late final GenerativeModel _model;

  GeminiService() {
    final apiKey = Env.geminiApiKey;
    if (apiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY not found in env file');
    }

    // We use gemini-2.5-flash as requested by user
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.1, // Low temperature for consistent output
      ),
    );
  }

  Future<Map<String, dynamic>?> analyzeFoodImage(File imageFile) async {
    try {
      final imageBytes = await imageFile.readAsBytes();

      final prompt = TextPart('''
You are a professional nutritionist. Analyze this food image and provide nutritional information broken down into its individual components.
Respond ONLY with a valid JSON object matching this exact structure, with no markdown formatting or extra text:
{
  "foodName": "Name of the overall dish (Indonesian preferred)",
  "calories": 450,
  "protein": 20,
  "carbs": 50,
  "fat": 15,
  "description": "Brief description of the dish (1-2 sentences)",
  "components": [
    {
      "name": "Nasi Putih",
      "amount": 1,
      "unit": "centong"
    },
    {
      "name": "Ayam Goreng",
      "amount": 1,
      "unit": "potong"
    }
  ]
}
If there are multiple items, list them as separate components. Make realistic estimates. If the image is not food, return a JSON with foodName "Bukan Makanan", 0 for macros, and an empty components array.
''');

      final imagePart = DataPart('image/jpeg', imageBytes);

      final response = await _model.generateContent([
        Content.multi([prompt, imagePart]),
      ]);

      final text = response.text;
      if (text != null) {
        // Clean up the response in case it contains markdown code blocks
        String cleanText = text;
        if (cleanText.startsWith('```json')) {
          cleanText = cleanText.replaceAll('```json', '');
        }
        if (cleanText.startsWith('```')) {
          cleanText = cleanText.replaceAll('```', '');
        }
        cleanText = cleanText.trim();
        if (cleanText.endsWith('```')) {
          cleanText = cleanText.substring(0, cleanText.length - 3).trim();
        }

        return jsonDecode(cleanText) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('Error analyzing image with Gemini: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> recalculateCalories(
    String foodName,
    List<Map<String, dynamic>> components,
  ) async {
    try {
      final prompt = TextPart('''
You are a professional nutritionist. I have a dish named "$foodName".
The user has manually edited its individual components to be:
${jsonEncode(components)}

Based ONLY on these updated components and their amounts/units, calculate the NEW total estimated nutritional value for the entire meal.
Respond ONLY with a valid JSON object matching this exact structure:
{
  "calories": 500,
  "protein": 25,
  "carbs": 60,
  "fat": 18
}
Do not use markdown formatting.
''');

      final response = await _model.generateContent([
        Content.text(prompt.text),
      ]);

      final text = response.text;
      if (text != null) {
        String cleanText = text;
        if (cleanText.startsWith('```json')) {
          cleanText = cleanText.replaceAll('```json', '');
        }
        if (cleanText.startsWith('```')) {
          cleanText = cleanText.replaceAll('```', '');
        }
        cleanText = cleanText.trim();
        if (cleanText.endsWith('```')) {
          cleanText = cleanText.substring(0, cleanText.length - 3).trim();
        }

        return jsonDecode(cleanText) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('Error recalculating with Gemini: $e');
      return null;
    }
  }
}
