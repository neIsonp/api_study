import 'package:flutter/material.dart';

class Todoitem extends StatelessWidget {
  const Todoitem({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
        onTap: () {},
        tileColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        leading: const Icon(
          Icons.check_box,
          color: Colors.blue,
        ),
        title: Text(
          'programar um app',
          style: TextStyle(decoration: TextDecoration.lineThrough),
        ),
        trailing: Container(
          width: 35,
          height: 35,
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(5),
          ),
          child: IconButton(
            icon: Icon(Icons.delete),
            iconSize: 18,
            color: Colors.white,
            onPressed: () {},
          ),
        ),
      ),
    );
  }
}
