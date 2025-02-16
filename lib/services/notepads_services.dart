import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:prontin/models/notepads.dart';

class NotepadsServices extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Notepads> _notes = [];
  List<Notepads> get notes => _notes;

  NotepadsServices() {
    loadNotes();
  }

  Future<void> loadNotes() async {
    User? user = _auth.currentUser;
    if (user == null) {
      print("Nenhum usuário autenticado. Não é possível carregar as notas.");
      return;
    }
    try {
      print("Carregando notas para o usuário: ${user.uid}");

      QuerySnapshot snapshot = await _firestore
          .collection('notes')
          .where('userId', isEqualTo: user.uid)
          .get();

      print("Notas encontradas: ${snapshot.docs.length}");

      _notes = snapshot.docs.map((doc) {
        print("Nota carregada: ${doc.data()}"); // Debug para ver os dados
        return Notepads.fromJson(doc);
      }).toList();

      notifyListeners(); // Atualiza a interface
    } catch (e) {
      print("Erro ao carregar notas: $e");
    }
  }

  Future<void> addNote(String title, String content) async {
    User? user = _auth.currentUser;
    if (user == null) return;

    Notepads newNote = Notepads(
      title: title,
      content: content,
      userId: user.uid,
      createdAt: Timestamp.now(),
    );

    DocumentReference docRef =
        await _firestore.collection('notes').add(newNote.toJson());
    newNote.id = docRef.id;

    _notes.insert(0, newNote);
    notifyListeners();
  }

  Future<void> updateNote(String noteId, String title, String content) async {
    await _firestore.collection('notes').doc(noteId).update({
      'title': title,
      'content': content,
    });

    int index = _notes.indexWhere((note) => note.id == noteId);
    if (index != -1) {
      _notes[index] = Notepads(
        id: noteId,
        title: title,
        content: content,
        userId: _notes[index].userId,
        createdAt: _notes[index].createdAt,
      );
    }

    notifyListeners();
  }

  Future<void> deleteNote(String noteId) async {
    await _firestore.collection('notes').doc(noteId).delete();
    _notes.removeWhere((note) => note.id == noteId);
    notifyListeners();
  }
}
