import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/plan_model.dart';
import '../models/todo_model.dart';
import '../providers/app_provider.dart';

class EditItemScreen extends StatefulWidget {
  final dynamic item; // Can be either a Plan or a ToDo

  EditItemScreen({required this.item});

  @override
  _EditItemScreenState createState() => _EditItemScreenState();
}

class _EditItemScreenState extends State<EditItemScreen> {
  late TextEditingController _titleController;
  late TextEditingController _locationController; // Added for location input
  late DateTime _selectedDate;
  late String _priority; // For ToDo only
  late String _startTime;
  late String _endTime;
  bool isPlan = false;

  @override
  void initState() {
    super.initState();

    isPlan = widget.item is Plan;
    _titleController = TextEditingController(text: widget.item.name);

    if (isPlan) {
      // Initialize fields for Plan
      _selectedDate = widget.item.date;
      _locationController = TextEditingController(text: widget.item.location);
      _startTime = widget.item.startTime ?? '';
      _endTime = widget.item.endTime ?? '';
      _priority = ''; // Priority is not used for Plan
    } else {
      // Initialize fields for ToDo
      _selectedDate = widget.item.date ?? DateTime.now();
      _priority = widget.item.priority;
      _locationController = TextEditingController(); // Not applicable for ToDo
      _startTime = '';
      _endTime = '';
    }

    // Add a listener to preserve cursor position for location
    _locationController.addListener(() {
      final cursorPos = _locationController.selection.baseOffset;
      final newText = _locationController.text;
      _locationController.value = _locationController.value.copyWith(
        text: newText,
        selection: TextSelection.collapsed(offset: cursorPos),
      );
    });
  }

  @override
  void dispose() {
    // Dispose of controllers to avoid memory leaks
    _titleController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  // Select start time using TimePicker
  Future<void> _selectStartTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(DateTime.now()),
    );
    if (picked != null) {
      setState(() {
        _startTime = picked.format(context);
      });
    }
  }

  // Select end time using TimePicker
  Future<void> _selectEndTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(DateTime.now()),
    );
    if (picked != null) {
      setState(() {
        _endTime = picked.format(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(isPlan ? 'Edit Plan' : 'Edit To-Do'),
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

              // Priority dropdown (only for ToDo)
              if (!isPlan) ...[
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
              ],

              // Location input (only for Plan)
              if (isPlan) ...[
                Text('Location:', style: TextStyle(fontSize: 16)),
                TextField(
                  controller: _locationController,
                  decoration: InputDecoration(labelText: 'Location'),
                ),
                SizedBox(height: 16),
              ],

              // Start Time input (only for Plan)
              if (isPlan) ...[
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: _selectStartTime,
                      child: Text('Select Start Time'),
                    ),
                    SizedBox(width: 10),
                    Text(
                      _startTime.isEmpty ? 'No time selected' : _startTime,
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                SizedBox(height: 16),
              ],

              // End Time input (only for Plan)
              if (isPlan) ...[
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: _selectEndTime,
                      child: Text('Select End Time'),
                    ),
                    SizedBox(width: 10),
                    Text(
                      _endTime.isEmpty ? 'No time selected' : _endTime,
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                SizedBox(height: 16),
              ],

              // Save Button
              ElevatedButton(
                onPressed: () {
                  if (isPlan) {
                    // Update Plan
                    Plan updatedPlan = Plan(
                      name: _titleController.text,
                      date: _selectedDate,
                      startTime: _startTime,
                      endTime: _endTime,
                      location: _locationController.text,
                      priority: '',
                    );
                    provider.editPlan(widget.item as Plan, updatedPlan);
                  } else {
                    // Update ToDo
                    ToDo updatedToDo = ToDo(
                      name: _titleController.text,
                      description: (widget.item as ToDo).description,
                      priority: _priority,
                      date: _selectedDate,
                      isCompleted: (widget.item as ToDo).isCompleted,
                      startTime: _startTime,
                      endTime: _endTime,
                    );
                    provider.editToDo(widget.item as ToDo, updatedToDo);
                  }
                  Navigator.pop(context);
                },
                child: Text('Save'),
              ),
              SizedBox(height: 16),

              // Delete Button
              ElevatedButton(
                onPressed: () {
                  if (isPlan) {
                    provider.deletePlan(widget.item as Plan);
                  } else {
                    provider.deleteToDo(widget.item as ToDo);
                  }
                  Navigator.pop(context);
                },
                child: Text('Delete'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
