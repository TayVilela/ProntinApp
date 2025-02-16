import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:prontin/models/lists.dart';

class ListsServices extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Lists> _lists = [];
  List<Lists> get lists => _lists;

  bool isLoading = false;

  // Carregar listas para um quadro específico
  Future<void> loadLists(String boardId) async {
    try {
      isLoading = true;
      notifyListeners();

      QuerySnapshot snapshot = await _firestore
          .collection('lists')
          .where('boardId', isEqualTo: boardId)
          .orderBy('createdAt', descending: false)
          .get();

      _lists = snapshot.docs
          .map((doc) => Lists.fromJson(doc as DocumentSnapshot<Map<String, dynamic>>))
          .toList();

      notifyListeners();
    } catch (e) {
      print("❌ Erro ao carregar listas: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Adicionar uma nova lista
  Future<void> addList(String boardId, String title) async {
    try {
      DocumentReference docRef = await _firestore.collection('lists').add({
        'boardId': boardId,
        'title': title,
        'createdAt': Timestamp.now(),
      });

      Lists newList = Lists(
        id: docRef.id,
        boardId: boardId,
        title: title,
        createdAt: Timestamp.now(),
      );

      _lists.add(newList);
      notifyListeners();
    } catch (e) {
      print("❌ Erro ao adicionar lista: $e");
    }
  }

  // **🔹 Atualizar o nome de uma lista**
  Future<void> updateList(String listId, String newTitle) async {
    try {
      await _firestore.collection('lists').doc(listId).update({
        'title': newTitle,
      });

      int index = _lists.indexWhere((list) => list.id == listId);
      if (index != -1) {
        _lists[index] = Lists(
          id: _lists[index].id,
          boardId: _lists[index].boardId,
          title: newTitle,
          createdAt: _lists[index].createdAt,
        );
      }

      notifyListeners();
    } catch (e) {
      print("❌ Erro ao atualizar lista: $e");
    }
  }

  // **🔴 Excluir uma lista e suas tarefas associadas**
  Future<void> deleteList(String listId) async {
    try {
      // Primeiro, excluir todas as tarefas associadas à lista
      QuerySnapshot tasksSnapshot = await _firestore
          .collection('tasks')
          .where('listId', isEqualTo: listId)
          .get();

      for (var doc in tasksSnapshot.docs) {
        await doc.reference.delete();
      }

      // Agora, excluir a própria lista
      await _firestore.collection('lists').doc(listId).delete();

      _lists.removeWhere((list) => list.id == listId);
      notifyListeners();
    } catch (e) {
      print("❌ Erro ao excluir lista: $e");
    }
  }
}
