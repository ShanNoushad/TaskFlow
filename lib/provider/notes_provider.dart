import 'package:flutter/material.dart';
import 'package:todo_app/Models/notes_model.dart';
import 'package:todo_app/Service/notes_service.dart';


class NoteProvider extends ChangeNotifier {
  final NoteService _service = NoteService();

  List<Note> _notes = [];
  List<Note> get notes => _notes;

  // Listen to notes (real-time)
   fetchNotes(String userId) {
    _service.getNotes(userId).listen((data) {
      _notes = data;
      notifyListeners();
    });
  }

  // Add note
  Future<void> addNote(Note note, String userId) async {
    await _service.addNote(note,userId);
  }

  // Delete note
  Future<void> deleteNote(String userId, String noteId) async {
    await _service.deleteNote(userId,noteId);
  }
}