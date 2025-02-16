import 'package:cloud_firestore/cloud_firestore.dart';

class Tasks {
  String? id;
  String title;
  bool isCompleted;
  String? description;
  Timestamp? dueDate;
  String? assignedTo;
  String listId; // Relacionado a uma lista
  Timestamp createdAt;

  Tasks({
    this.id,
    required this.title,
    required this.isCompleted,
    this.description,
    this.dueDate,
    this.assignedTo,
    required this.listId,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'isCompleted': isCompleted,
      'description': description,
      'dueDate': dueDate,
      'assignedTo': assignedTo,
      'listId': listId,
      'createdAt': createdAt,
    };
  }

  Tasks.fromJson(DocumentSnapshot doc)
      : id = doc.id,
        title = doc['title'],
        isCompleted = doc['isCompleted'],
        description = doc['description'],
        dueDate = doc['dueDate'],
        assignedTo = doc['assignedTo'],
        listId = doc['listId'],
        createdAt = doc['createdAt'];
}
