import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:prontin/models/boards.dart';

class BoardsServices extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Boards> _boards = [];
  List<Boards> get boards => _boards;

  BoardsServices() {
    loadBoards(); // Garante que os quadros são carregados na inicialização
  }

  // Carrega os quadros do usuário autenticado
  Future<void> loadBoards() async {
    User? user = _auth.currentUser;
    if (user == null) {
      print("⚠️ Nenhum usuário autenticado!");
      return;
    }

    try {
      print("🔄 Carregando quadros para o usuário: ${user.uid}");
      QuerySnapshot snapshot = await _firestore
          .collection('boards')
          .where('userId', isEqualTo: user.uid)
          .get();

      print("✅ Quadros encontrados: ${snapshot.docs.length}");

      _boards = snapshot.docs.map((doc) {
        return Boards.fromJson(doc);
      }).toList();

      // 🔥 Ordenando: Favoritos primeiro
      _boards.sort(
          (a, b) => b.isFavorite.toString().compareTo(a.isFavorite.toString()));

      notifyListeners();
    } catch (e) {
      print("❌ Erro ao carregar quadros: $e");
    }
  }

  // ✅ Método para adicionar um novo quadro
  Future<void> addBoard(String title) async {
    User? user = _auth.currentUser;
    if (user == null) return;

    Boards newBoard = Boards(
      title: title,
      userId: user.uid,
      createdAt: Timestamp.now(),
      isFavorite: false,
    );

    DocumentReference docRef =
        await _firestore.collection('boards').add(newBoard.toJson());
    newBoard.id = docRef.id;

    _boards.insert(0, newBoard);

    _boards.sort(
        (a, b) => b.isFavorite.toString().compareTo(a.isFavorite.toString()));

    notifyListeners();
  }

  // Método para ordenar favorito
  Future<void> toggleFavorite(String boardId, bool isFavorite) async {
    try {
      await _firestore.collection('boards').doc(boardId).update({
        'isFavorite': isFavorite,
      });

      int index = _boards.indexWhere((board) => board.id == boardId);
      if (index != -1) {
        _boards[index].isFavorite = isFavorite;

        // 🔥 Reordena a lista sempre que um favorito for atualizado
        _boards.sort((a, b) =>
            b.isFavorite.toString().compareTo(a.isFavorite.toString()));

        notifyListeners();
      }
    } catch (e) {
      debugPrint("❌ Erro ao alternar favorito: $e");
    }
  }

  Future<void> deleteBoard(String boardId) async {
    try {
      // 🔹 Excluir todas as listas associadas ao quadro
      QuerySnapshot listsSnapshot = await _firestore
          .collection('lists')
          .where('boardId', isEqualTo: boardId)
          .get();

      for (var listDoc in listsSnapshot.docs) {
        String listId = listDoc.id;

        // 🔴 Excluir todas as tarefas associadas a essa lista
        QuerySnapshot tasksSnapshot = await _firestore
            .collection('tasks')
            .where('listId', isEqualTo: listId)
            .get();

        for (var taskDoc in tasksSnapshot.docs) {
          await taskDoc.reference.delete(); // Exclui cada tarefa
        }

        await listDoc.reference
            .delete(); // Exclui a lista após remover as tarefas
      }

      // 🔴 Agora, excluir o próprio quadro
      await _firestore.collection('boards').doc(boardId).delete();

      // Remover localmente da lista de quadros
      _boards.removeWhere((board) => board.id == boardId);
      notifyListeners();

      print("✅ Quadro e todos os seus dados foram excluídos!");
    } catch (e) {
      print("❌ Erro ao excluir quadro e suas dependências: $e");
    }
  }

  Future<void> updateBoard(String boardId, String newTitle) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('boards').doc(boardId).get();

      if (!doc.exists) {
        print("❌ Erro: Quadro não encontrado!");
        return;
      }

      Map<String, dynamic>? boardData = doc.data() as Map<String, dynamic>?;

      if (boardData != null) {
        await _firestore.collection('boards').doc(boardId).update({
          'title': newTitle,
        });

        // Atualiza o cache local
        int index = _boards.indexWhere((board) => board.id == boardId);
        if (index != -1) {
          _boards[index] = Boards(
            id: boardId,
            title: newTitle,
            userId: boardData['userId'], // Mantemos o userId original
            createdAt: boardData['createdAt'], // Mantemos a data original
            isFavorite:
                boardData['isFavorite'] ?? false, // Caso não esteja definido
          );
          notifyListeners();
        }
      }
    } catch (e) {
      print("❌ Erro ao atualizar quadro: $e");
    }
  }
}
