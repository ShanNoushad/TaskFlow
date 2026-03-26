import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todo_app/Models/notes_model.dart';

class NoteService {
  final _db = FirebaseFirestore.instance.collection("users");
   Future<void> addNote(Note note, String userId) async {
    await _db
        .doc(userId)
        .collection("user_notes")
        .doc(note.id)
        .set(note.toMap());
  }

  Stream<List<Note>> getNotes(String userId) {
  return _db
      .doc(userId)
      .collection("user_notes")
      .snapshots()
      .map((snapshot) {
    return snapshot.docs
        .map((doc) => Note.fromMap(doc.data()))
        .toList();
  });
}

  Future<void> deleteNote(String userId, String noteId) async {
  await _db
      .doc(userId)
      .collection("user_notes")
      .doc(noteId)
      .delete();
}
}