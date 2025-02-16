import 'package:flutter/material.dart';
import 'package:prontin/models/boards.dart';
import 'package:provider/provider.dart';
import 'package:prontin/services/boards_services.dart';
import 'package:prontin/pages/boarddetail_page.dart';

class BoardPage extends StatelessWidget {
  const BoardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(11, 116, 116, 1.000),
      appBar: AppBar(
        title:
            const Text("Meus Quadros", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Consumer<BoardsServices>(
          builder: (context, boardsServices, child) {
            if (boardsServices.boards.isEmpty) {
              return const Center(
                  child: Text("Nenhum quadro encontrado",
                      style: TextStyle(color: Colors.white)));
            }
            return ListView.builder(
              itemCount: boardsServices.boards.length,
              itemBuilder: (context, index) {
                final board = boardsServices.boards[index];
                return Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    title: Text(
                      board.title,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.grey),
                          onPressed: () => _showEditBoardDialog(context, board),
                        ),
                        IconButton(
                          icon: Icon(
                            board.isFavorite ? Icons.star : Icons.star_border,
                            color:
                                board.isFavorite ? Colors.yellow : Colors.grey,
                          ),
                          onPressed: () {
                            Provider.of<BoardsServices>(context, listen: false)
                                .toggleFavorite(board.id!, !board.isFavorite);
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BoardDetailPage(board: board),
                        ),
                      );
                    },
                    onLongPress: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text("Excluir Quadro"),
                            content: const Text(
                                "Deseja realmente excluir este quadro?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("Cancelar"),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Provider.of<BoardsServices>(context,
                                          listen: false)
                                      .deleteBoard(board.id!);
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red),
                                child: const Text("Excluir"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showBoardDialog(context),
        backgroundColor: Colors.teal[700],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showEditBoardDialog(BuildContext context, Boards board) {
    TextEditingController titleController =
        TextEditingController(text: board.title);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Editar Quadro",
              style: TextStyle(color: Color.fromRGBO(11, 116, 116, 1.000))),
          content: TextField(
            controller: titleController,
            decoration: const InputDecoration(
                labelText: "Título",
                labelStyle:
                    TextStyle(color: Color.fromRGBO(11, 116, 116, 1.000))),
            style: const TextStyle(color: Colors.black),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Fecha apenas a edição
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  Provider.of<BoardsServices>(context, listen: false)
                      .updateBoard(board.id!, titleController.text);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 52, 168, 67)),
              child:
                  const Text("Salvar", style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () => _confirmDeleteBoard(context, board.id!),
              style: TextButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Excluir Quadro",
                  style: TextStyle(color: Color.fromARGB(255, 255, 255, 255))),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteBoard(BuildContext context, String boardId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Excluir Quadro",
              style: TextStyle(color: Color.fromRGBO(11, 116, 116, 1.000))),
          content: const Text(
              "Tem certeza que deseja excluir este quadro? Essa ação não pode ser desfeita.",
              style: TextStyle(color: Color.fromARGB(255, 0, 0, 0))),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                Provider.of<BoardsServices>(context, listen: false)
                    .deleteBoard(boardId);
                Navigator.pop(context);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child:
                  const Text("Excluir", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showBoardDialog(BuildContext context) {
    TextEditingController titleController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Novo Quadro",
              style: TextStyle(color: Color.fromRGBO(11, 116, 116, 1.000))),
          content: TextField(
            controller: titleController,
            decoration: const InputDecoration(
                labelText: "Título",
                labelStyle:
                    TextStyle(color: Color.fromRGBO(11, 116, 116, 1.000))),
            style: const TextStyle(color: Colors.black),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  Provider.of<BoardsServices>(context, listen: false)
                      .addBoard(titleController.text);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 52, 168, 67)),
              child: const Text("Criar", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
