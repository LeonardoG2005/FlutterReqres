import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../providers/user_provider.dart';
import 'user_form_screen.dart';

class UserDetailScreen extends StatelessWidget {
  final User user;

  const UserDetailScreen({
    super.key,
    required this.user,
  });

  void _navigateToEdit(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserFormScreen(user: user),
      ),
    );
  }

  Future<void> _showDeleteDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Usuario'),
        content: Text('¿Estás seguro de que quieres eliminar a ${user.fullName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (result == true && context.mounted) {
      await _deleteUser(context);
    }
  }

  Future<void> _deleteUser(BuildContext context) async {
    if (user.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se puede eliminar un usuario sin ID'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    final provider = context.read<UserProvider>();
    final success = await provider.deleteUser(user.id!);
    
    if (context.mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${user.fullName} eliminado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Volver a la lista
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar usuario: ${provider.errorMessage}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(user.fullName),
        centerTitle: true,
        elevation: 2,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          // Botón de editar en el AppBar
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _navigateToEdit(context),
            tooltip: 'Editar Usuario',
          ),
          // Botón de eliminar en el AppBar
          if (user.id != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _showDeleteDialog(context),
              tooltip: 'Eliminar Usuario',
            ),
        ],
      ),
      body: Consumer<UserProvider>(
        builder: (context, provider, child) {
          // Mostrar loading si se está eliminando
          if (provider.deleteState == LoadingState.loading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Eliminando usuario...'),
                ],
              ),
            );
          }
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Tarjeta principal con avatar y información básica
                _buildMainCard(),
                
                const SizedBox(height: 20),
                
                // Tarjeta con información detallada
                _buildDetailCard(),
                
                const SizedBox(height: 20),
                
                // Botones de acción
                _buildActionButtons(context),
              ],
            ),
          );
        },
      ),
    );
  }
  
  /// Construye la tarjeta principal con avatar y nombre
  Widget _buildMainCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Avatar grande
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 60,
                backgroundImage: user.avatar.isNotEmpty 
                    ? NetworkImage(user.avatar)
                    : null,
                onBackgroundImageError: user.avatar.isNotEmpty 
                    ? (exception, stackTrace) {
                        // Error al cargar imagen, se mostrará el icono por defecto
                      }
                    : null,
                child: user.avatar.isEmpty 
                    ? const Icon(Icons.person, size: 60)
                    : null,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Nombre completo
            Text(
              user.fullName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 8),
            
            // Email
            Text(
              user.email,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            
            // ID (si existe)
            if (user.id != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'ID: ${user.id}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  /// Construye la tarjeta con información detallada
  Widget _buildDetailCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Información Detallada',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Información en formato de lista
            _buildDetailItem(
              icon: Icons.badge,
              label: 'ID',
              value: user.id?.toString() ?? 'N/A',
            ),
            
            _buildDetailItem(
              icon: Icons.person,
              label: 'Nombre',
              value: user.firstName,
            ),
            
            _buildDetailItem(
              icon: Icons.person_outline,
              label: 'Apellido',
              value: user.lastName,
            ),
            
            _buildDetailItem(
              icon: Icons.email,
              label: 'Email',
              value: user.email,
            ),
            
            _buildDetailItem(
              icon: Icons.image,
              label: 'Avatar URL',
              value: user.avatar.isNotEmpty ? user.avatar : 'Sin imagen',
              isUrl: user.avatar.isNotEmpty,
            ),
          ],
        ),
      ),
    );
  }
  
  /// Construye un elemento de detalle individual
  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    bool isUrl = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                SelectableText(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: isUrl ? Colors.blue : Colors.grey.shade800,
                    decoration: isUrl ? TextDecoration.underline : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  /// Construye los botones de acción
  Widget _buildActionButtons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Botón de editar
        ElevatedButton.icon(
          onPressed: () => _navigateToEdit(context),
          icon: const Icon(Icons.edit),
          label: const Text('Editar Usuario'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Botón de eliminar (solo si tiene ID)
        if (user.id != null)
          ElevatedButton.icon(
            onPressed: () => _showDeleteDialog(context),
            icon: const Icon(Icons.delete),
            label: const Text('Eliminar Usuario'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
      ],
    );
  }
}