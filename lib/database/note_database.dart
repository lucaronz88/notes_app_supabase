import 'package:notes_app_supabase/models/note.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NoteDatabase {
  // Get a reference for supabase client
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get list of notes
  Future<List<Note>> getNotes(String userId) async {
    final response = await _supabase
        .from('notes')
        .select()
        .eq('user_id', userId)
        .order('updated_at', ascending: false);

    return (response as List).map((note) => Note.fromJson(note)).toList();
  }

  // Get a single note
  Future<Note> getNote(String id, String userId) async {
    final response =
        await _supabase
            .from('notes')
            .select()
            .eq('id', id)
            .eq('user_id', userId)
            .single();

    return Note.fromJson(response);
  }

  // Create a note
  Future<Note> createNote(String title, String content, String userId) async {
    final response =
        await _supabase
            .from('notes')
            .insert({'title': title, 'content': content, 'user_id': userId})
            .select()
            .single();

    return Note.fromJson(response);
  }

  // Update a note
  Future<Note> updateNote(
    String id,
    String title,
    String content,
    String userId,
  ) async {
    final response =
        await _supabase
            .from('notes')
            .update({
              'title': title,
              'content': content,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', id)
            .eq('user_id', userId)
            .select()
            .single();

    return Note.fromJson(response);
  }

  // Delete a note
  Future<void> deleteNote(String id, String userId) async {
    await _supabase
      .from('notes')
      .delete()
      .eq('id', id)
      .eq('user_id', userId);
  }
}