class Todo {
  final String id;
  String title;
  bool isDone;

  Todo({
    required this.id,
    required this.title,
    required this.isDone,
  });

  toggle() => isDone = !isDone;

  factory Todo.fromJson(Map<String, dynamic> json) => Todo(
        id: json['_id'],
        title: json['title'],
        isDone: json['done'],
      );
}
