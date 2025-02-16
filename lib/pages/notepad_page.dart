import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:prontin/services/notepads_services.dart';
import 'package:provider/provider.dart';

class NotepadPage extends StatefulWidget {
  const NotepadPage({super.key});

  @override
  State<NotepadPage> createState() => _NotepadPageState();
}

class _NotepadPageState extends State<NotepadPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotepadsServices>(context, listen: false).loadNotes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(11, 116, 116, 1.000),
      appBar: AppBar(
        title: const Text(
          "Bloco de Notas",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Consumer<NotepadsServices>(
          builder: (context, notepadsServices, child) {
            return notepadsServices.notes.isEmpty
                ? const Center(child: Text("Nenhuma nota encontrada"))
                : ListView.builder(
                    itemCount: notepadsServices.notes.length,
                    itemBuilder: (context, index) {
                      final note = notepadsServices.notes[index];
                      return Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          title: Text(
                            note.title ?? "Sem título",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            note.content ?? "Sem conteúdo",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () =>
                                _confirmDeleteNote(context, note.id!),
                          ),
                          onTap: () {
                            _showNoteDialog(context, notepadsServices, note);
                          },
                        ),
                      );
                    },
                  );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNoteDialog(context,
            Provider.of<NotepadsServices>(context, listen: false), null),
        backgroundColor: Colors.teal[700],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showNoteDialog(
      BuildContext context, NotepadsServices notepadsServices, note) {
    TextEditingController titleController =
        TextEditingController(text: note?.title ?? "");
    quill.QuillController contentController = quill.QuillController.basic();

    if (note != null) {
      final document = quill.Document()..insert(0, note.content ?? "");
      contentController = quill.QuillController(
          document: document,
          selection: const TextSelection.collapsed(offset: 0));
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(note == null ? "Nova Nota" : "Editar Nota",
              style:
                  const TextStyle(color: Color.fromRGBO(11, 116, 116, 1.000))),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                        labelText: "Título",
                        labelStyle: TextStyle(
                            color: Color.fromRGBO(11, 116, 116, 1.000))),
                    style: const TextStyle(color: Colors.black)),
                const SizedBox(height: 10),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Descrição",
                    style: TextStyle(
                      color: Color.fromRGBO(11, 116, 116, 1.000),
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                DefaultTextStyle(
                  style: const TextStyle(color: Colors.black),
                  child: SizedBox(
                    height: 200,
                    child: quill.QuillEditor.basic(
                      controller: contentController,
                      focusNode: FocusNode(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                final content = contentController.document.toPlainText();
                if (note == null) {
                  notepadsServices.addNote(titleController.text, content);
                } else {
                  notepadsServices.updateNote(
                      note.id!, titleController.text, content);
                }
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 52, 168, 67)),
              child:
                  const Text("Salvar", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // Método para confirmar a exclusão da nota
  void _confirmDeleteNote(BuildContext context, String note) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Excluir Nota",
              style: TextStyle(color: Color.fromRGBO(11, 116, 116, 1.000))),
          content: const Text("Tem certeza que deseja excluir esta nota?",
              style: TextStyle(color: Color.fromARGB(255, 0, 0, 0))),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                Provider.of<NotepadsServices>(context, listen: false)
                    .deleteNote(note);
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
}
