import 'package:flutter/material.dart';
import '../models/friend.dart';
import '../repositories/friend_repository.dart';
import '../viewmodels/friend_viewmodel.dart';
import '../services/api_service.dart'; // Necesario para crear el repositorio si no se pasa

class AddFriendScreen extends StatefulWidget {
  const AddFriendScreen({
    super.key,
    this.friendRepository, // Hacemos el repositorio opcional
  });

  final FriendRepository? friendRepository;

  @override
  State<AddFriendScreen> createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  
  late final FriendViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    // Usamos el repositorio pasado o creamos uno nuevo si es necesario
    final repo = widget.friendRepository ?? FriendRepository(service: ApiService());
    _viewModel = FriendViewModel(friendRepository: repo);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Amigo'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Ingresa un nombre';
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
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Ingresa un email';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return 'Ingresa un email válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            ListenableBuilder(
              listenable: _viewModel.addFriend,
              builder: (context, child) {
                return FilledButton(
                  onPressed: _viewModel.addFriend.running ? null : _saveFriend,
                  child: _viewModel.addFriend.running
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Guardar'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveFriend() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Ejecutar el comando del ViewModel
    // Nota: El método _addFriend en el ViewModel actual solo toma el nombre (String),
    // si quisieras pasar email deberías actualizar el ViewModel. 
    // Por ahora usamos solo el nombre para que compile con tu ViewModel actual.
    await _viewModel.addFriend.execute(_nameController.text.trim());

    if (mounted) {
      if (_viewModel.addFriend.completed) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Amigo agregado')),
        );
        Navigator.pop(context);
      } else if (_viewModel.addFriend.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_viewModel.errorMessage ?? 'Error al agregar')),
        );
      }
    }
  }
}