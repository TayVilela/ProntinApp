import 'package:cloud_firestore/cloud_firestore.dart';

class Lists {
  String? id;
  String title;
  String boardId; //vincula a um quadro
  Timestamp createdAt;

  Lists({
    this.id,
    required this.title,
    required this.boardId,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'boardId': boardId,
      'createdAt': createdAt,
    };
  }

  Lists.fromJson(DocumentSnapshot doc)
      : id = doc.id,
        title = doc['title'],
        boardId = doc['boardId'],
        createdAt = doc['createdAt'];
}
