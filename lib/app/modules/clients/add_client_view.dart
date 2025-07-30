import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/client_model.dart';

class AddClientView extends StatefulWidget {
  final ClientModel? existingClient;

  AddClientView({super.key}) : existingClient = Get.arguments;

  @override
  State<AddClientView> createState() => _AddClientViewState();
}


class _AddClientViewState extends State<AddClientView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _emailController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();

  @override
void initState() {
  super.initState();
  if (widget.existingClient != null) {
    _nameController.text = widget.existingClient!.name;
    _contactController.text = widget.existingClient!.contactNumber;
    _emailController.text = widget.existingClient!.email;
    _cityController.text = widget.existingClient!.city;
    _stateController.text = widget.existingClient!.state;
  }
}


  void _saveClient() async {
    if (_formKey.currentState!.validate()) {
      
      if (widget.existingClient != null) {
        // Update existing client
        widget.existingClient!
          ..name = _nameController.text.trim()
          ..contactNumber = _contactController.text.trim()
          ..email = _emailController.text.trim()
          ..city = _cityController.text.trim()
          ..state = _stateController.text.trim();
        await widget.existingClient!.save();
        Get.back();
        Get.snackbar('Updated', 'Client updated successfully');
      } else {
        // Add new client
        final newClient = ClientModel(
          id: const Uuid().v4(),
          name: _nameController.text.trim(),
          contactNumber: _contactController.text.trim(),
          email: _emailController.text.trim(),
          city: _cityController.text.trim(),
          state: _stateController.text.trim(),
        );
        final box = Hive.box<ClientModel>('clients');
        await box.add(newClient);
        Get.back();
        Get.snackbar('Success', 'Client added successfully');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingClient != null;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Client' : 'Add Client'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _contactController,
                decoration: const InputDecoration(labelText: 'Contact Number'),
                keyboardType: TextInputType.numberWithOptions(),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(labelText: 'City'),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _stateController,
                decoration: const InputDecoration(labelText: 'State'),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _saveClient,
                icon: Icon(Icons.save, color: Theme.of(context).colorScheme.onPrimary, size: 24, ),
                label: Text(isEditing ? 'Update Client' : 'Save Client'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
