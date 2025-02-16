import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:prontin/models/tasks.dart';
import 'package:provider/provider.dart';
import 'package:prontin/models/boards.dart';
import 'package:prontin/models/lists.dart';
import 'package:prontin/services/lists_services.dart';
import 'package:prontin/services/tasks_services.dart';

class BoardDetailPage extends StatefulWidget {
  final Boards board;

  const BoardDetailPage({super.key, required this.board});

  @override
  _BoardDetailPageState createState() => _BoardDetailPageState();
}

class _BoardDetailPageState extends State<BoardDetailPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final listsServices = Provider.of<ListsServices>(context, listen: false);
      final tasksServices = Provider.of<TasksServices>(context, listen: false);

      await listsServices.loadLists(widget.board.id!);
      await tasksServices
          .loadTasksForLists(listsServices.lists.map((e) => e.id!).toList());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(11, 116, 116, 1.000),
      appBar: AppBar(
        title: Text(widget.board.title,
            style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Consumer2<ListsServices, TasksServices>(
          builder: (context, listsServices, tasksServices, child) {
            if (listsServices.isLoading || tasksServices.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...listsServices.lists.map((list) {
                    return _buildListCard(context, list, tasksServices);
                  }).toList(),
                  _buildAddListButton(
                      context), // Botão para adicionar nova lista
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // Construindo o cartão da lista com as tarefas e o botão de edição
  Widget _buildListCard(
      BuildContext context, Lists list, TasksServices tasksServices) {
    final tasks = tasksServices.tasksByList[list.id!] ?? [];

    return Container(
      width: 250,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            spreadRadius: 2,
          )
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            color: Colors.teal[700],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    list.title,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white, size: 18),
                  onPressed: () => _showEditListDialog(context, list),
                ),
              ],
            ),
          ),
          Expanded(
            child: tasks.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("Nenhuma tarefa",
                        style: TextStyle(color: Colors.grey)),
                  )
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          child: ListTile(
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  task.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                //se tiver prazo mostrar a data
                                if (task.dueDate !=
                                    null) 
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.calendar_today,
                                            size: 16,
                                            color: Color.fromARGB(
                                                255, 157, 157, 157)),
                                        const SizedBox(width: 4),
                                        Text(
                                          "${task.dueDate!.toDate().day}/${task.dueDate!.toDate().month}/${task.dueDate!.toDate().year}",
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Color.fromARGB(
                                                  255, 157, 157, 157)),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            leading: Checkbox(
                              value: task.isCompleted,
                              onChanged: (value) =>
                                  tasksServices.toggleTaskCompletion(
                                      task.id!, list.id!, value!),
                            ),
                            onTap: () => _showEditTaskDialog(context, task),
                          ),
                        );
                      },
                    ),
                  ),
          ),
          TextButton(
            onPressed: () => _showAddTaskDialog(context, list.id!),
            child: const Text("Adicionar Tarefa"),
          ),
        ],
      ),
    );
  }

  // Botão de adicionar lista
  Widget _buildAddListButton(BuildContext context) {
    return Container(
      width: 250,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white, width: 1),
      ),
      child: TextButton(
        onPressed: () => _showAddListDialog(context),
        child: const Text(
          "+ Adicionar Lista",
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  // Método para adicionar nova lista
  void _showAddListDialog(BuildContext context) {
    TextEditingController titleController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Nova Lista",
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
                  Provider.of<ListsServices>(context, listen: false)
                      .addList(widget.board.id!, titleController.text);
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

  // Método para editar ou excluir uma lista
  void _showEditListDialog(BuildContext context, Lists list) {
    TextEditingController titleController =
        TextEditingController(text: list.title);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Editar Lista",
              style: TextStyle(color: Color.fromRGBO(11, 116, 116, 1.000))),
          content: TextField(
              controller: titleController,
              decoration: const InputDecoration(
                  labelText: "Título",
                  labelStyle:
                      TextStyle(color: Color.fromRGBO(11, 116, 116, 1.000))),
              style: const TextStyle(color: Colors.black)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  Provider.of<ListsServices>(context, listen: false)
                      .updateList(list.id!, titleController.text);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 52, 168, 67)),
              child:
                  const Text("Salvar", style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              onPressed: () => _confirmDeleteList(context, list.id!),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Excluir",
                  style: TextStyle(color: Color.fromARGB(255, 255, 255, 255))),
            ),
          ],
        );
      },
    );
  }

  // Método para confirmar a exclusão da lista
  void _confirmDeleteList(BuildContext context, String listId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Excluir Lista",
              style: TextStyle(color: Color.fromRGBO(11, 116, 116, 1.000))),
          content: const Text("Tem certeza que deseja excluir esta lista?",
              style: TextStyle(color: Color.fromARGB(255, 0, 0, 0))),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                Provider.of<ListsServices>(context, listen: false)
                    .deleteList(listId);
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

  // Método para adicionar nova tarefa dentro da lista
  void _showAddTaskDialog(BuildContext context, String listId) {
    TextEditingController titleController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Nova Tarefa",
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
                  Provider.of<TasksServices>(context, listen: false).addTask(
                    listId: listId,
                    title: titleController.text,
                    description: null,
                    dueDate: null,
                    assignedTo: null,
                  );
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

  void _showEditTaskDialog(BuildContext context, Tasks task) {
    TextEditingController titleController =
        TextEditingController(text: task.title);
    TextEditingController descriptionController =
        TextEditingController(text: task.description ?? "");
    TextEditingController assignedToController =
        TextEditingController(text: task.assignedTo ?? "");

    DateTime selectedDueDate =
        task.dueDate?.toDate() ?? DateTime.now().add(const Duration(days: 1));

    int selectedHour = selectedDueDate.hour;
    int selectedMinute = (selectedDueDate.minute ~/ 15) * 15;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Editar Tarefa",
              style: TextStyle(color: Color.fromRGBO(11, 116, 116, 1.000))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Título"),
                style: const TextStyle(color: Colors.black),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: "Descrição"),
                style: const TextStyle(color: Colors.black),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: assignedToController,
                decoration: const InputDecoration(labelText: "Responsável"),
                style: const TextStyle(color: Colors.black),
              ),
              const SizedBox(height: 10),

              // Seletor de Data
              TextFormField(
                readOnly: true,
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(
                  labelText: "Prazo",
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                controller: TextEditingController(
                  text:
                      "${selectedDueDate.day}/${selectedDueDate.month}/${selectedDueDate.year}",
                ),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: selectedDueDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2101),
                  );

                  if (pickedDate != null) {
                    setState(() {
                      selectedDueDate = DateTime(
                        pickedDate.year,
                        pickedDate.month,
                        pickedDate.day,
                        selectedHour,
                        selectedMinute,
                      );
                    });
                  }
                },
              ),
              const SizedBox(height: 10),

              // Seletor de Hora e Minuto
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: selectedHour,
                      decoration: const InputDecoration(labelText: "Hora"),
                      items: List.generate(24, (index) {
                        return DropdownMenuItem(
                          value: index,
                          child: Text(index.toString().padLeft(2, '0')),
                        );
                      }),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedHour = value;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: selectedMinute,
                      decoration: const InputDecoration(labelText: "Minutos"),
                      items: [0, 15, 30, 45].map((minute) {
                        return DropdownMenuItem(
                          value: minute,
                          child: Text(minute.toString().padLeft(2, '0')),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedMinute = value;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                // Atualizando os valores de data e hora
                selectedDueDate = DateTime(
                  selectedDueDate.year,
                  selectedDueDate.month,
                  selectedDueDate.day,
                  selectedHour,
                  selectedMinute,
                );

                // ✅ Atualizando a tarefa no Firestore
                Provider.of<TasksServices>(context, listen: false).updateTask(
                  task.id!,
                  listId: task.listId!,
                  title: titleController.text,
                  description: descriptionController.text,
                  assignedTo: assignedToController.text,
                  dueDate: Timestamp.fromDate(selectedDueDate),
                );

                Navigator.pop(context); // Fecha o diálogo após salvar
              },
              child: const Text("Salvar"),
            ),
          ],
        );
      },
    );
  }
}
