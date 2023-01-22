import 'dart:convert';
import 'package:api_study_day_2/components/todo_item.dart';
import 'package:api_study_day_2/main.dart';
import 'package:api_study_day_2/models/todo_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Todo> _todoList = [];
  List<Todo> _filteredData = [];

  bool isLoading = true;

  final _searchController = TextEditingController();
  final _titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadTodo();
    isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'api',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.grey.shade100,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            searchItem(),
            const SizedBox(height: 20),
            const Text(
              'Todos as tarefas',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w500,
              ),
            ),
            Expanded(
              child: Container(
                height: 500,
                child: RefreshIndicator(
                  onRefresh: loadTodo,
                  child: ListView.builder(
                    itemCount: _filteredData.length,
                    itemBuilder: (context, index) {
                      final todo =
                          _filteredData[_filteredData.length - index - 1];
                      return Container(
                        padding: const EdgeInsets.only(top: 20),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 5,
                            horizontal: 20,
                          ),
                          onTap: () {
                            if (todo.isDone) {
                              notDone(todo.id);
                            } else {
                              done(todo.id);
                            }
                          },
                          onLongPress: () {
                            _showForm(id: todo.id, title: todo.title);
                          },
                          tileColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          leading: todo.isDone
                              ? const Icon(
                                  Icons.check_box,
                                  color: Colors.blue,
                                )
                              : const Icon(
                                  Icons.check_box_outline_blank,
                                ),
                          title: Text(
                            todo.title,
                            style: TextStyle(
                              decoration: todo.isDone
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          trailing: Container(
                            width: 35,
                            height: 35,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.delete),
                              iconSize: 18,
                              color: Colors.white,
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text('Apagar Tarefa'),
                                      content: const Text(
                                          'Deseja mesmo apagar esta tarefa?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('Não'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            delete(todo.id).then(
                                              (value) =>
                                                  Navigator.of(context).pop(),
                                            );
                                          },
                                          child: const Text('Sim'),
                                        )
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: SizedBox(
        width: 100,
        child: FloatingActionButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          onPressed: () {
            _showForm();
          },
          child: const Text('adicionar'),
        ),
      ),
    );
  }

  Future<dynamic> _showForm({String? title, String? id}) {
    if (title != null) {
      _titleController.text = title;
    }

    return showModalBottomSheet(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), hintText: 'Titulo aqui'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (title == null) {
                        add(_titleController.text);
                      } else {
                        update(id: id, title: _titleController.text);
                      }
                      _titleController.clear();
                      Navigator.of(context).pop();
                    },
                    child: Text(title == null ? 'Adicionar' : "Atualizar"),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Container searchItem() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: TextField(
        controller: _searchController,
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Pesquise',
          prefixIcon: Icon(
            Icons.search,
            size: 20,
          ),
        ),
        onChanged: (value) {
          setState(() {
            _filteredData = _todoList
                .where((element) => element.title.toLowerCase().contains(value))
                .toList();
          });
        },
      ),
    );
  }

  Future<void> loadTodo() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:8080/api/todo'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      setState(() {
        _todoList = (data as List).map((e) => Todo.fromJson(e)).toList();
        _filteredData = _todoList;
      });
    } else {
      print('error to load todo list');
    }
  }

  Future<void> done(String id) async {
    final response = await http.patch(Uri.parse(
      'http://10.0.2.2:8080/api/todo/$id/completed',
    ));

    if (response.statusCode == 201) {
      setState(() {
        _todoList.firstWhere((element) => element.id == id).toggle();
        _filteredData = _todoList;
      });
    } else {
      print("error to complete the todo");
    }
  }

  Future<void> notDone(String id) async {
    final response = await http.patch(Uri.parse(
      'http://10.0.2.2:8080/api/todo/$id/not-completed',
    ));

    if (response.statusCode == 201) {
      setState(() {
        _todoList.firstWhere((element) => element.id == id).toggle();
        _filteredData = _todoList;
      });
    } else {
      print("error to complete the todo");
    }
  }

  Future<void> delete(String id) async {
    final response = await http.delete(
      Uri.parse("http://10.0.2.2:8080/api/todo/$id"),
    );

    if (response.statusCode == 200) {
      setState(() {
        _todoList.removeWhere((element) => element.id == id);
        _filteredData = _todoList;
      });
    }
  }

  Future<void> add(String title) async {
    final response = await http.post(
      Uri.parse("http://10.0.2.2:8080/api/todo"),
      body: {'title': title},
    );

    if (response.statusCode == 201) {
      setState(() {
        _todoList.add(Todo.fromJson(jsonDecode(response.body)));
        _filteredData = _todoList;
      });
    } else {
      print('error to add todo');
    }
  }

  Future<void> update({String? id, required String title}) async {
    final response = await http.put(
      Uri.parse("http://10.0.2.2:8080/api/todo/$id"),
      body: {"title": title},
    );

    if (response.statusCode == 200) {
      setState(() {
        loadTodo();
      });
    } else {
      print('error to update todo');
    }
  }
}
