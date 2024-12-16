import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/plan_model.dart';
import '../models/todo_model.dart';
import '../providers/app_provider.dart';

class AddItemScreen extends StatefulWidget {
  @override
  _AddItemScreenState createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  DateTime _date = DateTime.now();  // Default to the current date
  String _startTime = '';
  String _endTime = '';
  String _location = '';
  String _description = '';
  String _priority = 'Medium';
  String _itemType = 'Plan';  // Set the initial type to Plan

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Item")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Replaced the SwitchListTile with ChoiceChip for Plan or Todo
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ChoiceChip(
                    label: Text("Plan"),
                    selected: _itemType == 'Plan',
                    onSelected: (selected) {
                      setState(() {
                        _itemType = 'Plan';
                      });
                    },
                  ),
                  SizedBox(width: 16),
                  ChoiceChip(
                    label: Text("ToDo"),
                    selected: _itemType == 'ToDo',
                    onSelected: (selected) {
                      setState(() {
                        _itemType = 'ToDo';
                      });
                    },
                  ),
                ],
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Name"),
                onSaved: (value) => _name = value!,
              ),
              // Date Picker
              ListTile(
                title: Text("Date: ${_date.toLocal()}".split(' ')[0]), // Display date
                trailing: Icon(Icons.calendar_today),
                onTap: _selectDate,
              ),
              // Start Time Picker
              ListTile(
                title: Text("Start Time: $_startTime"),
                trailing: Icon(Icons.access_time),
                onTap: _selectStartTime,
              ),
              // End Time Picker
              ListTile(
                title: Text("End Time: $_endTime"),
                trailing: Icon(Icons.access_time),
                onTap: _selectEndTime,
              ),
              // Location Input
              if (_itemType == 'Plan') ...[
                TextFormField(
                  decoration: InputDecoration(labelText: "Location"),
                  onSaved: (value) => _location = value!,
                ),
              ],
              // Description Field
              TextFormField(
                decoration: InputDecoration(labelText: "Description"),
                onSaved: (value) => _description = value!,
              ),
              if (_itemType == 'ToDo') // Show priority for Todo only
                DropdownButtonFormField(
                  value: _priority,
                  items: ["High", "Medium", "Low"]
                      .map((priority) => DropdownMenuItem(
                            value: priority,
                            child: Text(priority),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() => _priority = value!),
                ),
              ElevatedButton(
                onPressed: _saveItem,
                child: Text("Save"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to open Date Picker with restriction on past dates
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(), // Restrict to today and future dates
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _date)
      setState(() {
        _date = picked; // Update the selected date
      });
  }

  // Function to open Start Time Picker
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

  // Function to open End Time Picker
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

  void _saveItem() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final provider = Provider.of<AppProvider>(context, listen: false);
      if (_itemType == 'Plan') {
        provider.addPlan(
          Plan(
            name: _name,
            date: _date,
            startTime: _startTime,
            endTime: _endTime,
            location: _location,
            priority: _priority,
          ),
        );
      } else {
        provider.addToDo(
          ToDo(
            name: _name,
            description: _description,
            priority: _priority,
            date: _date,
          ),
        );
      }
      Navigator.pop(context);
    }
  }
}
