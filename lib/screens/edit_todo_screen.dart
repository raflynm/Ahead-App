import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/todo_model.dart';
import '../providers/app_provider.dart';

class EditToDoScreen extends StatefulWidget {
  final ToDo todo;

  EditToDoScreen({required this.todo});

  @override
  _EditToDoScreenState createState() => _EditToDoScreenState();
}

class _EditToDoScreenState extends State<EditToDoScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;
  late String _priority;
  bool isCompleted = false;
  late String _startTime;
  late String _endTime;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.todo.name);
    _descriptionController = TextEditingController(text: widget.todo.description);
    _selectedDate = widget.todo.date ?? DateTime.now();
    _priority = widget.todo.priority; // Ensure this is non-null
    isCompleted = widget.todo.isCompleted;
    _startTime = widget.todo.startTime ?? '';
    _endTime = widget.todo.endTime ?? '';
  }

  // Time Picker for Start Time
  Future<void> _selectStartTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(DateTime.now()),
    );
    if (picked != null) {
      setState(() {
        _startTime = picked.format(context); // Update start time
      });
    }
  }

  // Time Picker for End Time
  Future<void> _selectEndTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(DateTime.now()),
    );
    if (picked != null) {
      setState(() {
        _endTime = picked.format(context); // Update end time
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit To-Do'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title input
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              SizedBox(height: 16),

              // Description input
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              SizedBox(height: 16),

              // Date Picker
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      ).then((date) {
                        if (date != null) {
                          setState(() {
                            _selectedDate = date;
                          });
                        }
                      });
                    },
                    child: Text('Select Date'),
                  ),
                  SizedBox(width: 10),
                  Text(
                    _selectedDate.toLocal().toString().split(' ')[0],
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Priority dropdown
              Text('Priority:', style: TextStyle(fontSize: 16)),
              DropdownButton<String>(
                value: _priority,
                onChanged: (String? newValue) {
                  setState(() {
                    _priority = newValue!;
                  });
                },
                items: <String>['Low', 'Medium', 'High']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              SizedBox(height: 16),

              // Completed checkbox
              Row(
                children: [
                  Checkbox(
                    value: isCompleted,
                    onChanged: (bool? newValue) {
                      setState(() {
                        isCompleted = newValue!;
                      });
                    },
                  ),
                  Text("Completed", style: TextStyle(fontSize: 16)),
                ],
              ),
              SizedBox(height: 16),

              // Start Time input
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _selectStartTime,
                    child: Text('Select Start Time'),
                  ),
                  SizedBox(width: 10),
                  Text(_startTime.isEmpty ? 'No time selected' : _startTime),
                ],
              ),
              SizedBox(height: 16),

              // End Time input
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _selectEndTime,
                    child: Text('Select End Time'),
                  ),
                  SizedBox(width: 10),
                  Text(_endTime.isEmpty ? 'No time selected' : _endTime),
                ],
              ),
              SizedBox(height: 16),

              // Save Button
              ElevatedButton(
                onPressed: () {
                  ToDo updatedToDo = ToDo(
                    name: _titleController.text,
                    description: _descriptionController.text,
                    priority: _priority,
                    date: _selectedDate,
                    isCompleted: isCompleted,
                    startTime: _startTime,
                    endTime: _endTime,
                  );

                  provider.editToDo(widget.todo, updatedToDo);
                  Navigator.pop(context); // Return to the previous screen
                },
                child: Text('Save'),
              ),
              SizedBox(height: 16),

              // Delete Button
              ElevatedButton(
                onPressed: () {
                  provider.deleteToDo(widget.todo); // Delete the ToDo item
                  Navigator.pop(context); // Go back after deletion
                },
                child: Text('Delete', style: TextStyle(color: Colors.red)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.red,
                  side: BorderSide(color: Colors.red),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
