import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/food_journal.dart';

class DatabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  // Get journals for the current user (with optional time range)
  Future<List<FoodJournal>> getJournals({DateTime? start, DateTime? end}) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not logged in');

      var query = _supabase
          .from('food_journals')
          .select()
          .eq('user_id', userId);

      if (start != null) {
        query = query.gte('logged_at', start.toUtc().toIso8601String());
      }
      if (end != null) {
        query = query.lte('logged_at', end.toUtc().toIso8601String());
      }

      final response = await query.order('logged_at', ascending: false);

      return (response as List).map((json) => FoodJournal.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching journals: $e');
      return [];
    }
  }

  // Add a new journal entry
  Future<FoodJournal?> addJournal(FoodJournal journal) async {
    try {
      final response = await _supabase
          .from('food_journals')
          .insert(journal.toJson())
          .select()
          .single();
          
      return FoodJournal.fromJson(response);
    } catch (e) {
      throw Exception('Database Error: $e');
    }
  }

  // Delete a journal entry
  Future<bool> deleteJournal(String id) async {
    try {
      await _supabase.from('food_journals').delete().eq('id', id);
      return true;
    } catch (e) {
      debugPrint('Error deleting journal: $e');
      return false;
    }
  }
}
