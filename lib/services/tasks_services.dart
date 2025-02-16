import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:prontin/models/tasks.dart';

class TasksServices extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, List<Tasks>> _tasksByList = {};
  bool isLoading = false;

  Map<String, List<Tasks>> get tasksByList => _tasksByList;

  Future<void> loadTasksForLists(List<String> listIds) async {
    if (listIds.isEmpty) return;

    isLoading = true;
    notifyListeners();

    try {
      print("🔄 Carregando todas as tarefas para listas: $listIds");

      for (String listId in listIds) {
        QuerySnapshot snapshot = await _firestore
            .collection('tasks')
            .where('listId', isEqualTo: listId)
            .orderBy('createdAt', descending: true)
            .get();

        _tasksByList[listId] =
            snapshot.docs.map((doc) => Tasks.fromJson(doc)).toList();
        print(
            "📌 Tarefas carregadas para a lista $listId: ${_tasksByList[listId]!.length}");
      }
    } catch (e) {
      print("❌ Erro ao carregar tarefas: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> addTask({
    required String listId,
    required String title,
    String? description,
    Timestamp? dueDate,
    String? assignedTo,
  }) async {
    try {
      // Criando a tarefa no Firestore com todas as variáveis
      DocumentReference docRef = await _firestore.collection('tasks').add({
        'listId': listId,
        'title': title,
        'isCompleted': false, // Sempre começa como não concluída
        'description': description, // Pode ser null
        'dueDate': dueDate, // Pode ser null
        'assignedTo': assignedTo, // Pode ser null
        'createdAt': Timestamp.now(),
      });

      // Criando a instância local da nova tarefa
      Tasks newTask = Tasks(
        id: docRef.id,
        listId: listId,
        title: title,
        isCompleted: false,
        description: description,
        dueDate: dueDate,
        assignedTo: assignedTo,
        createdAt: Timestamp.now(),
      );

      // Atualizando a lista de tarefas localmente
      _tasksByList[listId] = [..._tasksByList[listId] ?? [], newTask];

      notifyListeners(); // Atualiza a interface
    } catch (e) {
      print("❌ Erro ao adicionar tarefa: $e");
    }
  }

  Future<void> toggleTaskCompletion(
      String taskId, String listId, bool isCompleted) async {
    try {
      await _firestore
          .collection('tasks')
          .doc(taskId)
          .update({'isCompleted': isCompleted});

      int index =
          _tasksByList[listId]?.indexWhere((task) => task.id == taskId) ?? -1;
      if (index != -1) {
        _tasksByList[listId]![index].isCompleted = isCompleted;
      }

      notifyListeners();
    } catch (e) {
      print("❌ Erro ao atualizar tarefa: $e");
    }
  }

  Future<void> deleteTask(String taskId, String listId) async {
    try {
      await _firestore.collection('tasks').doc(taskId).delete();

      _tasksByList[listId]?.removeWhere((task) => task.id == taskId);
      notifyListeners();
    } catch (e) {
      print("❌ Erro ao excluir tarefa: $e");
    }
  }

  Future<void> updateTask(
    String taskId, {
    required String listId,
    required String title,
    String? description,
    String? assignedTo,
    Timestamp? dueDate,
  }) async {
    try {
      await _firestore.collection('tasks').doc(taskId).update({
        'title': title,
        'description': description,
        'assignedTo': assignedTo,
        'dueDate': dueDate,
      });

      int index =
          _tasksByList[listId]?.indexWhere((task) => task.id == taskId) ?? -1;
      if (index != -1) {
        _tasksByList[listId]![index] = Tasks(
          id: taskId,
          listId: listId,
          title: title,
          isCompleted: _tasksByList[listId]![index].isCompleted,
          description: description,
          assignedTo: assignedTo,
          dueDate: dueDate,
          createdAt: _tasksByList[listId]![index].createdAt,
        );
        notifyListeners();
      }
    } catch (e) {
      print("❌ Erro ao atualizar tarefa: $e");
    }
  }
}
