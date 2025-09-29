import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../providers/user_provider.dart';

class UserFormScreen extends StatefulWidget {
  final User? user;
  const UserFormScreen({super.key, this.user});
  bool get isEditing => user != null;
  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _avatarController = TextEditingController();
  final _firstNameFocus = FocusNode();
  final _lastNameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _avatarFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.isEditing && widget.user != null) {
      _firstNameController.text = widget.user!.firstName;
      _lastNameController.text = widget.user!.lastName;
      _emailController.text = widget.user!.email;
      _avatarController.text = widget.user!.avatar;
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _avatarController.dispose();
    _firstNameFocus.dispose();
    _lastNameFocus.dispose();
    _emailFocus.dispose();
    _avatarFocus.dispose();
    super.dispose();
  }

  Future<void> _saveUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final user = User(
      id: widget.user?.id,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      avatar: _avatarController.text.trim(),
    );
    final provider = context.read<UserProvider>();
    bool success;
    if (widget.isEditing) {
      success = await provider.updateUser(user);
    } else {
      success = await provider.createUser(user);
    }
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEditing
                  ? 'Usuario actualizado exitosamente'
                  : 'Usuario creado exitosamente',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${provider.errorMessage}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es obligatorio';
    }
    if (value.trim().length < 2) {
      return 'Debe tener al menos 2 caracteres';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El email es obligatorio';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Ingresa un email válido';
    }
    return null;
  }

  String? _validateAvatar(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    final urlRegex = RegExp(r'^https?://');
    if (!urlRegex.hasMatch(value.trim())) {
      return 'Debe ser una URL válida (http:// o https://)';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Editar Usuario' : 'Crear Usuario'),
        centerTitle: true,
        elevation: 2,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Consumer<UserProvider>(
        builder: (context, provider, child) {
          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildAvatarPreview(),
                  const SizedBox(height: 20),
                  _buildFormFields(),
                  const SizedBox(height: 32),
                  _buildSaveButton(provider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAvatarPreview() {
    final avatarUrl = _avatarController.text.trim();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Vista Previa',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 12),
            CircleAvatar(
              radius: 40,
              backgroundImage: avatarUrl.isNotEmpty && avatarUrl.startsWith('http')
                  ? NetworkImage(avatarUrl)
                  : null,
              onBackgroundImageError: avatarUrl.isNotEmpty
                  ? (exception, stackTrace) {}
                  : null,
              child: avatarUrl.isEmpty || !avatarUrl.startsWith('http')
                  ? const Icon(Icons.person, size: 40)
                  : null,
            ),
            const SizedBox(height: 8),
            Text(
              '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (_emailController.text.trim().isNotEmpty)
              Text(
                _emailController.text.trim(),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        TextFormField(
          controller: _firstNameController,
          focusNode: _firstNameFocus,
          decoration: InputDecoration(
            labelText: 'Nombre *',
            hintText: 'Ingresa el nombre',
            prefixIcon: const Icon(Icons.person),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
            ),
          ),
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => _lastNameFocus.requestFocus(),
          validator: _validateName,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _lastNameController,
          focusNode: _lastNameFocus,
          decoration: InputDecoration(
            labelText: 'Apellido *',
            hintText: 'Ingresa el apellido',
            prefixIcon: const Icon(Icons.person_outline),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
            ),
          ),
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => _emailFocus.requestFocus(),
          validator: _validateName,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _emailController,
          focusNode: _emailFocus,
          decoration: InputDecoration(
            labelText: 'Email *',
            hintText: 'ejemplo@email.com',
            prefixIcon: const Icon(Icons.email),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
            ),
          ),
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => _avatarFocus.requestFocus(),
          validator: _validateEmail,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _avatarController,
          focusNode: _avatarFocus,
          decoration: InputDecoration(
            labelText: 'Avatar URL (opcional)',
            hintText: 'https://ejemplo.com/imagen.jpg',
            prefixIcon: const Icon(Icons.image),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
            ),
            helperText: 'URL de la imagen de perfil',
          ),
          keyboardType: TextInputType.url,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _saveUser(),
          validator: _validateAvatar,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 8),
        Text(
          '* Campos obligatorios',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(UserProvider provider) {
    final isLoading = provider.createUpdateState == LoadingState.loading;
    return ElevatedButton(
      onPressed: isLoading ? null : _saveUser,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      child: isLoading
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Text(widget.isEditing ? 'Actualizando...' : 'Creando...'),
              ],
            )
          : Text(
              widget.isEditing ? 'Actualizar Usuario' : 'Crear Usuario',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }
}