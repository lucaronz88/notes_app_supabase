import 'package:flutter/material.dart';
import 'package:notes_app_supabase/database/note_database.dart';
import 'package:notes_app_supabase/services/auth_service.dart';

class EditNoteScreen extends StatefulWidget {
  const EditNoteScreen({super.key});

  @override
  State<EditNoteScreen> createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  // get auth service and note database service
  final _noteDatabase = NoteDatabase();

  // get current user id
  final String _userId = AuthService().currentUser!.id;

  // text controllers
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  // _isLoading for state transition
  bool _isLoading = false;

  // _isNewNote to tell if it's to create a new note or update note
  bool _isNewNote = true;

  // for note id
  String? _noteId;

  // show error message when something wrong
  String? _errorMessage;

  // method to fetch note data by note id
  Future<void> _loadNote(String id) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // try to fetch data from database
    try {
      final note = await _noteDatabase.getNote(id, _userId);
      setState(() {
        _titleController.text = note.title;
        _contentController.text = note.content;
      });
    }
    // catch any errors
    catch (e) {
      setState(() {
        _errorMessage = "Failed to load note: ${e.toString()}";
      });
    }
    // set back _isLoading to false when operation done
    finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // method to update note
  Future<void> _saveNote() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // try to insert/update database
      try {
        // create a new note
        if (_isNewNote) {
          await _noteDatabase.createNote(
            _titleController.text.trim(),
            _contentController.text.trim(),
            _userId,
          );
        }
        // update a note
        else {
          await _noteDatabase.updateNote(
            _noteId!,
            _titleController.text.trim(),
            _contentController.text.trim(),
            _userId,
          );
        }

        // navigate back to previous screen
        if (!mounted) return;
        Navigator.pop(context);
      }
      // catch any errors..
      catch (e) {
        setState(() {
          _errorMessage = "Failed to save note: ${e.toString()}";
        });
      }
      // set back _isLoading to false when operation done
      finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // get note id from note screen
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // get note id
    _noteId = ModalRoute.of(context)?.settings.arguments as String?;
    // check if we received a note id (meaning we're editing an existing note)
    // AND checks if _isNewNote is true (meaning we haven't already loaded the note)
    if (_noteId != null && _isNewNote) {
      // to mark that we're editing an existing note
      _isNewNote = false;
      // fetch note data
      _loadNote(_noteId!);
    }
  }

  // dispose text controllers when it's done
  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(_isNewNote ? "New Note" : "Edit Note"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _saveNote,
          ),
        ],
      ),
      body:
          // check if it's loading
          _isLoading && !_isNewNote
              ?
              // show progress indicator
              const Center(child: CircularProgressIndicator())
              :
              // check if any error message
              _errorMessage != null
              ?
              // show error message
              Center(child: Text(_errorMessage!))
              :
              // show text form
              Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // title field
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: "Title",
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter a title";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // content field
                      Expanded(
                        child: TextFormField(
                          controller: _contentController,
                          decoration: const InputDecoration(
                            labelText: "Content",
                            border: OutlineInputBorder(),
                            alignLabelWithHint: true,
                          ),
                          maxLines: null,
                          expands: true,
                          textAlignVertical: TextAlignVertical.top,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter some content";
                            }
                            return null;
                          },
                        ),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
    );
  }
}
