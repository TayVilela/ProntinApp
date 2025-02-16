import 'package:cloud_firestore/cloud_firestore.dart';

class Notepads {
  String? id;
  String? title;
  String? content;
  String? userId;
  Timestamp? createdAt;

  Notepads({
    this.id,
    required this.title,
    required this.content,
    required this.userId,
    required this.createdAt,
  });

  // Converte para JSON para salvar no Firestore
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'userId': userId,
      'createdAt': createdAt,
    };
  }

  // Construtor para converter um documento Firestore em objeto `Notepads`
  Notepads.fromJson(DocumentSnapshot doc) {
    id = doc.id;
    title = doc.get('title');
    content = doc.get('content');
    userId = doc.get('userId');
    createdAt = doc.get('createdAt');
  }
}
