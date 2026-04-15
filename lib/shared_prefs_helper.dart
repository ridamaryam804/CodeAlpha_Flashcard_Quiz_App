import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SharedPrefsHelper {
  static const String _flashcardsKey = 'saved_flashcards';
  static const String _statsKey = 'quiz_statistics';

  // Save flashcards for specific category and difficulty
  static Future<void> saveFlashcards(String category, String difficulty, List<Map<String, String>> flashcards) async {
    final prefs = await SharedPreferences.getInstance();
    String key = '${_flashcardsKey}_${category}_$difficulty';
    List<String> jsonList = flashcards.map((card) => jsonEncode(card)).toList();
    await prefs.setStringList(key, jsonList);
  }

  // Load flashcards for specific category and difficulty
  static Future<List<Map<String, String>>> loadFlashcards(String category, String difficulty) async {
    final prefs = await SharedPreferences.getInstance();
    String key = '${_flashcardsKey}_${category}_$difficulty';
    List<String>? jsonList = prefs.getStringList(key);

    if (jsonList == null || jsonList.isEmpty) {
      return [];
    }

    List<Map<String, String>> result = [];
    for (String json in jsonList) {
      Map<String, dynamic> map = jsonDecode(json);
      result.add({
        'question': map['question'] as String,
        'answer': map['answer'] as String,
      });
    }
    return result;
  }

  // Add a new flashcard
  static Future<void> addFlashcard(String category, String difficulty, Map<String, String> newCard) async {
    List<Map<String, String>> existingCards = await loadFlashcards(category, difficulty);
    existingCards.add(newCard);
    await saveFlashcards(category, difficulty, existingCards);
  }

  // Save quiz statistics
  static Future<void> saveQuizStats(String category, String difficulty, int score, int total, int flips) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> stats = prefs.getStringList(_statsKey) ?? [];

    Map<String, dynamic> stat = {
      'category': category,
      'difficulty': difficulty,
      'score': score,
      'total': total,
      'flips': flips,
      'date': DateTime.now().toIso8601String(),
    };

    stats.add(jsonEncode(stat));
    await prefs.setStringList(_statsKey, stats);
  }

  // Load all quiz statistics
  static Future<List<Map<String, dynamic>>> loadQuizStats() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? stats = prefs.getStringList(_statsKey);

    if (stats == null || stats.isEmpty) {
      return [];
    }

    List<Map<String, dynamic>> result = [];
    for (String json in stats) {
      result.add(jsonDecode(json) as Map<String, dynamic>);
    }
    return result;
  }

  // Clear all saved flashcards (for testing)
  static Future<void> clearAllFlashcards() async {
    final prefs = await SharedPreferences.getInstance();
    Set<String> keys = prefs.getKeys();
    for (String key in keys) {
      if (key.startsWith(_flashcardsKey)) {
        await prefs.remove(key);
      }
    }
  }
}