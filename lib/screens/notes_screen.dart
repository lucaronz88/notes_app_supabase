import 'package:flutter/material.dart';
import 'package:notes_app_supabase/database/note_database.dart';
import 'package:notes_app_supabase/models/note.dart';
import 'package:notes_app_supabase/services/auth_service.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  // get auth service and note database service
  final _authService = AuthService();
  final _noteDatabase = NoteDatabase();

  // get current user id
  final String _userId = AuthService().currentUser!.id;

  // List of notes to show
  List<Note>? _notes;

  // _isLoading for state transition
  bool _isLoading = true;

  // show error message when something wrong
  String? _errorMessage;

  // logout button pressed
  void logout() async {
    await _authService.signOut();
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/login');
  }

  // load notes method
  Future<void> _loadNotes() async {
    setState(() {
      // transition to loading state
      _isLoading = true;
      _errorMessage = null;
    });

    // try to fetch notes from supabase
    try {
      final notes = await _noteDatabase.getNotes(_userId);
      setState(() {
        _notes = notes;
      });
    }
    // catch any errors and show to screen
    catch (e) {
      setState(() {
        _errorMessage = "Failed to load notes: ${e.toString()}";
      });
    }
    // set back _isLoading to false when operation done
    finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // delete note method
  Future<void> _deleteNote(String id) async {
    // try to delete
    try {
      await _noteDatabase.deleteNote(id, _userId);
      _loadNotes();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Note deleted successfully")),
      );
    }
    // catch any errors
    catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete note: ${e.toString()}")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("N O T E"),
        actions: [
          // logout button
          IconButton(onPressed: logout, icon: const Icon(Icons.logout)),
        ],
      ),
      body:
          // check if it's loading
          _isLoading
              ?
              // if yes, show loading icon
              const Center(child: CircularProgressIndicator())
              :
              // if not, check if there's any error
              _errorMessage != null
              ?
              // if any error, show error message
              Center(child: Text(_errorMessage!))
              :
              // if no error, check if notes empty or not
              _notes!.isEmpty
              ?
              // if empty, show no notes message
              const Center(child: Text("No notes yet. Add your first note!"))
              :
              // if not empty, show notes
              RefreshIndicator(
                onRefresh: _loadNotes,
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _notes!.length,
                  itemBuilder: (context, index) {
                    // fetch individual note
                    final note = _notes![index];

                    // return note in Card style
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 4,
                      ),
                      child: ListTile(
                        title: Text(
                          note.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          note.content,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteNote(note.id),
                        ),
                        onTap: () async {
                          // when tapped navigate to edit note page
                          await Navigator.of(
                            context,
                          ).pushNamed('/edit_note', arguments: note.id);
                          _loadNotes();
                        },
                      ),
                    );
                  },
                ),
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).pushNamed('/edit_note');
          _loadNotes();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
