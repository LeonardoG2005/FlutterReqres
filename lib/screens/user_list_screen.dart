import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../providers/user_provider.dart';
import 'user_detail_screen.dart';
import 'user_form_screen.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});
  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadInitialData() {
    final provider = context.read<UserProvider>();
    if (provider.users.isEmpty) {
      provider.loadUsers();
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<UserProvider>().loadMoreUsers();
    }
  }
  
  void _onSearchChanged(String query) {
    final provider = context.read<UserProvider>();
    
    if (query.trim().isEmpty) {
      provider.clearSearch();
    } else {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (_searchController.text == query) {
          provider.searchUsers(query);
        }
      });
    }
  }
  void _navigateToDetail(User user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserDetailScreen(user: user),
      ),
    );
  }
  void _navigateToCreate() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const UserFormScreen(),
      ),
    );
  }
  Future<void> _showDeleteDialog(User user) async {
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
    
    if (result == true && mounted) {
      _deleteUser(user);
    }
  }
  Future<void> _deleteUser(User user) async {
    final provider = context.read<UserProvider>();
    final success = await provider.deleteUser(user.id!);
    
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${user.fullName} eliminado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
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
        title: const Text('Usuarios'),
        centerTitle: true,
        elevation: 2,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: Consumer<UserProvider>(
              builder: (context, provider, child) {
                return _buildContent(provider);
              },
            ),
          ),
        ],
      ),
      
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreate,
        tooltip: 'Agregar Usuario',
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar por nombre...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged('');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Theme.of(context).primaryColor),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
        onChanged: _onSearchChanged,
      ),
    );
  }
  
  Widget _buildContent(UserProvider provider) {
    // Estado de carga inicial
    if (provider.isLoadingFirstPage) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Cargando usuarios...'),
          ],
        ),
      );
    }
    
    // Estado de error
    if (provider.loadingState == LoadingState.error && !provider.hasUsers) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Error al cargar usuarios',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              provider.errorMessage ?? 'Error desconocido',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => provider.refresh(),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }
    
    // Lista vacía (búsqueda sin resultados o no hay usuarios)
    if (!provider.hasUsers) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              provider.isSearching ? Icons.search_off : Icons.people_outline,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              provider.isSearching 
                  ? 'No se encontraron usuarios'
                  : 'No hay usuarios disponibles',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              provider.isSearching
                  ? 'Intenta con otros términos de búsqueda'
                  : 'Agrega el primer usuario',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }
    
    // Lista de usuarios con RefreshIndicator
    return RefreshIndicator(
      onRefresh: provider.refresh,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: provider.displayUsers.length + (provider.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          // Mostrar indicador de carga al final si se están cargando más usuarios
          if (index == provider.displayUsers.length) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          
          final user = provider.displayUsers[index];
          return _buildUserCard(user, provider);
        },
      ),
    );
  }
  
  Widget _buildUserCard(User user, UserProvider provider) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        leading: CircleAvatar(
          radius: 30,
          backgroundImage: NetworkImage(user.avatar),
          onBackgroundImageError: (exception, stackTrace) {
          },
          child: user.avatar.isEmpty 
              ? const Icon(Icons.person, size: 30)
              : null,
        ),
        title: Text(
          user.fullName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              user.email,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'ID: ${user.id}',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'detail':
                _navigateToDetail(user);
                break;
              case 'edit':
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserFormScreen(user: user),
                  ),
                );
                break;
              case 'delete':
                if (user.id != null) {
                  _showDeleteDialog(user);
                }
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'detail',
              child: ListTile(
                leading: Icon(Icons.visibility),
                title: Text('Ver Detalle'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'edit',
              child: ListTile(
                leading: Icon(Icons.edit),
                title: Text('Editar'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            if (user.id != null)
              const PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete, color: Colors.red),
                  title: Text('Eliminar', style: TextStyle(color: Colors.red)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
          ],
        ),
        onTap: () => _navigateToDetail(user),
      ),
    );
  }
}