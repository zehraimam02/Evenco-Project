import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/guest_model.dart';
import '../../../blocs/events/guest_bloc.dart';

class UpdateGuestScreen extends StatefulWidget {
  final GuestModel guest;

  const UpdateGuestScreen({Key? key, required this.guest}) : super(key: key);

  @override
  _UpdateGuestScreenState createState() => _UpdateGuestScreenState();
}

class _UpdateGuestScreenState extends State<UpdateGuestScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _notesController;
  int _plusOnes = 0;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.guest.name);
    _emailController = TextEditingController(text: widget.guest.email);
    _phoneController = TextEditingController(text: widget.guest.phone ?? '');
    _notesController = TextEditingController(text: widget.guest.notes ?? '');
    _plusOnes = widget.guest.plusOnes ?? 0;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _updateGuest() {
    if (_formKey.currentState!.validate()) {
      final updatedGuest = widget.guest.copyWith(
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text.isEmpty ? null : _phoneController.text,
        plusOnes: _plusOnes,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      context.read<GuestsBloc>().add(UpdateGuestEvent(updatedGuest));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Guest'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter an email';
                  } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone (optional)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Plus Ones:'),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: _plusOnes > 0
                        ? () => setState(() => _plusOnes--)
                        : null,
                  ),
                  Text('$_plusOnes'),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => setState(() => _plusOnes++),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              BlocConsumer<GuestsBloc, GuestsState>(
                listener: (context, state) {
                  if (state is GuestsError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message)),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is GuestsLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  return ElevatedButton(
                    onPressed: _updateGuest,
                    child: const Text('Update Guest'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
