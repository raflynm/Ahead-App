import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/todo_model.dart';
import '../providers/app_provider.dart';
import '../screens/edit_item_screen.dart'; // Import the edit screen

class ToDoItem extends StatelessWidget {
  final ToDo todo;

  ToDoItem({required this.todo});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      title: Text(todo.name),
      subtitle: Text("Priority: ${todo.priority}"),
      trailing: Checkbox(
        value: todo.isCompleted,
        onChanged: (value) {
          // Only toggle completion status when the checkbox is clicked
          final provider = Provider.of<AppProvider>(context, listen: false);
          provider.toggleToDoStatus(todo);
        },
      ),
      onTap: () {
        // Navigate to Edit Screen for ToDo when tapping the list item
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                EditItemScreen(item: todo), // Pass ToDo item here
          ),
        );
      },
    );
  }
}
