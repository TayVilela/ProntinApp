import 'package:cloud_firestore/cloud_firestore.dart';

class Boards {
  String? id;
  String title;
  String userId;
  bool isFavorite;
  Timestamp createdAt;

  Boards({
    this.id,
    required this.title,
    required this.userId,
    this.isFavorite = false,
    required this.createdAt,
  });

  // Converte para JSON para salvar no Firestore
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'userId': userId,
      'isFavorite': isFavorite,
      'createdAt': createdAt,
    };
  }

  // Construtor para converter um documento Firestore em objeto `Boards`
  Boards.fromJson(DocumentSnapshot doc)
      : id = doc.id,
        title = doc['title'],
        userId = doc['userId'],
        isFavorite = doc['isFavorite'] ?? false,
        createdAt = doc['createdAt'];
}