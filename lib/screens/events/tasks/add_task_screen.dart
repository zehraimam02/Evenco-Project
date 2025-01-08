import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:evenco_app/blocs/events/guest_bloc.dart'; 
import 'package:evenco_app/blocs/events/task_bloc.dart';
import 'package:evenco_app/models/task_model.dart';
import 'package:evenco_app/models/event_model.dart';
import 'package:evenco_app/models/guest_model.dart'; 

class AddTaskScreen extends StatefulWidget {
  final EventModel event;

  const AddTaskScreen({
    super.key,
    required this.event,
  });

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _dueDate;
  GuestModel? _assignedTo; 

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Task'),
      ),
      body: BlocBuilder<GuestsBloc, GuestsState>(
        builder: (context, state) {
          if (state is GuestsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is GuestsLoaded) {
            final guests = state.guests
                .where((guest) => guest.eventId == widget.event.id)
                .toList();

            return Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Task Title',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter task title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter task description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text('Due Date'),
                    subtitle: Text(_dueDate == null
                        ? 'Select due date'
                        : _dueDate.toString().split(' ')[0]),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _dueDate ?? widget.event.date,
                        firstDate: DateTime.now(),
                        lastDate: widget.event.date,
                      );
                      if (date != null) {
                        setState(() => _dueDate = date);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<GuestModel>(
                    decoration: const InputDecoration(
                      labelText: 'Assign To',
                      border: OutlineInputBorder(),
                    ),
                    value: _assignedTo,
                    items: guests.map((guest) {
                      return DropdownMenuItem(
                        value: guest,
                        child: Text(guest.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _assignedTo = value);
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please assign the task to someone';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: const Text('Add Task'),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: Text('Failed to load guests'));
          }
        },
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate() && _dueDate != null) {
      final task = TaskModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        eventId: widget.event.id,
        title: _titleController.text,
        description: _descriptionController.text,
        dueDate: _dueDate!,
        assignedTo: _assignedTo!.name, 
      );

      context.read<TasksBloc>().add(AddTask(task));
      Navigator.pop(context);
    } else if (_dueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a due date')),
      );
    }
  }
}
