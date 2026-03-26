import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/Models/notes_model.dart';
import 'package:todo_app/Service/local_status.dart';
import 'package:todo_app/provider/notes_provider.dart';
import 'package:uuid/uuid.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  final localStorageService = LocalStorageService();
  String? userId;

  @override
  void initState() {
    super.initState();
    getUserId();
  }

  void getUserId() async {
    final id = await localStorageService.getUserId();
    setState(() {
      userId = id;
    });
  }

  void _addNoteDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Note"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(hintText: "Title"),
              ),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(hintText: "Content"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final noteProvider = Provider.of<NoteProvider>(
                  context,
                  listen: false,
                );

                final note = Note(
                  title: titleController.text,
                  content: contentController.text,
                  createdAt: DateTime.now(),
                  id: const Uuid().v4().toString(),
                );
                if (userId == null) return;
                await noteProvider.addNote(note, userId!);
                titleController.clear();
                contentController.clear();
                Navigator.pop(context);
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final noteProvider = Provider.of<NoteProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("My Notes")),

      body: userId == null
    ? const Center(child: CircularProgressIndicator())
    : StreamBuilder<QuerySnapshot>( // ✅ correct type
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(userId)
            .collection("user_notes")
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) { // ✅ .docs.isEmpty
            return const Center(child: Text("No Notes Yet"));
          }

          // ✅ map Firestore docs to Note objects
          final notes = snapshot.data!.docs.map((doc) {
            return Note.fromMap(doc.data() as Map<String, dynamic>);
          }).toList();

          return ListView.builder( 
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              return Card(color: Theme.of(context).cardColor,
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(note.title,style: Theme.of(context).textTheme.bodyMedium,),
                  subtitle: Text(note.content),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      noteProvider.deleteNote( userId!,note.id,);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNoteDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
