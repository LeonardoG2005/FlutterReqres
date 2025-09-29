import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/user_service.dart';

enum LoadingState { idle, loading, success, error }

class UserProvider extends ChangeNotifier {
  final UserService _userService = UserService();
  List<User> _users = [];
  List<User> get users => List.unmodifiable(_users);
  List<User> _filteredUsers = [];
  List<User> get filteredUsers => List.unmodifiable(_filteredUsers);
  User? _selectedUser;
  User? get selectedUser => _selectedUser;
  LoadingState _loadingState = LoadingState.idle;
  LoadingState get loadingState => _loadingState;
  LoadingState _createUpdateState = LoadingState.idle;
  LoadingState get createUpdateState => _createUpdateState;
  LoadingState _deleteState = LoadingState.idle;
  LoadingState get deleteState => _deleteState;
  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  int _currentPage = 1;
  int get currentPage => _currentPage;
  bool _hasMorePages = true;
  bool get hasMorePages => _hasMorePages;
  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;
  String _searchQuery = '';
  String get searchQuery => _searchQuery;
  bool _isSearching = false;
  bool get isSearching => _isSearching;
  List<User> get displayUsers => _isSearching ? _filteredUsers : _users;
  bool get hasUsers => displayUsers.isNotEmpty;
  
  
  bool get isLoadingFirstPage => _loadingState == LoadingState.loading && _users.isEmpty;
  
  
  Future<void> loadUsers({bool refresh = false}) async {
    try {
      if (refresh) {
        _users.clear();
        _currentPage = 1;
        _hasMorePages = true;
        _clearSearch();
      }
      
      _setLoadingState(LoadingState.loading);
      _clearError();
      
      
      final response = await _userService.getUsers(page: _currentPage);
      
      _users.addAll(response.data);
      _hasMorePages = response.hasMorePages;
      
      _setLoadingState(LoadingState.success);
      
    } catch (e) {
      _setError('Error al cargar usuarios: $e');
      _setLoadingState(LoadingState.error);
    }
  }
  
  
  Future<void> loadMoreUsers() async {
    if (_isLoadingMore || !_hasMorePages || _isSearching) {
      return;
    }
    
    try {
      _isLoadingMore = true;
      notifyListeners();
      
      _currentPage++;
      
      final response = await _userService.getUsers(page: _currentPage);
      
      _users.addAll(response.data);
      _hasMorePages = response.hasMorePages;
      
      
    } catch (e) {
      _currentPage--; // Revertir el incremento si hay error
      // No mostramos error aquí para no interrumpir el scroll
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }
  
  
  Future<void> searchUsers(String query) async {
    _searchQuery = query.trim();
    
    if (_searchQuery.isEmpty) {
      _clearSearch();
      return;
    }
    
    try {
      _isSearching = true;
      _setLoadingState(LoadingState.loading);
      _clearError();
      
      
      final results = await _userService.searchUsers(_searchQuery);
      _filteredUsers = results;
      
      _setLoadingState(LoadingState.success);
      
    } catch (e) {
      _setError('Error al buscar usuarios: $e');
      _setLoadingState(LoadingState.error);
    }
  }
  
  
  void clearSearch() {
    _clearSearch();
  }
  
  
  void selectUser(User user) {
    _selectedUser = user;
    notifyListeners();
  }
  
  
  Future<void> loadUserById(int id) async {
    try {
      _setLoadingState(LoadingState.loading);
      _clearError();
      
      final user = await _userService.getUserById(id);
      _selectedUser = user;
      
      _setLoadingState(LoadingState.success);
      
    } catch (e) {
      _setError('Error al cargar usuario: $e');
      _setLoadingState(LoadingState.error);
    }
  }
  
  
  Future<bool> createUser(User user) async {
    try {
      _setCreateUpdateState(LoadingState.loading);
      _clearError();
      
      
      final createdUser = await _userService.createUser(user);
      
      // Agregamos el usuario al inicio de la lista
      _users.insert(0, createdUser);
      
      _setCreateUpdateState(LoadingState.success);
      
      return true;
    } catch (e) {
      _setError('Error al crear usuario: $e');
      _setCreateUpdateState(LoadingState.error);
      return false;
    }
  }
  
  
  Future<bool> updateUser(User user) async {
    try {
      _setCreateUpdateState(LoadingState.loading);
      _clearError();
      
      
      final updatedUser = await _userService.updateUser(user);
      
      // Actualizamos el usuario en la lista
      final index = _users.indexWhere((u) => u.id == updatedUser.id);
      if (index != -1) {
        _users[index] = updatedUser;
      }
      
      // Actualizamos también el usuario seleccionado si es el mismo
      if (_selectedUser?.id == updatedUser.id) {
        _selectedUser = updatedUser;
      }
      
      _setCreateUpdateState(LoadingState.success);
      
      return true;
    } catch (e) {
      _setError('Error al actualizar usuario: $e');
      _setCreateUpdateState(LoadingState.error);
      return false;
    }
  }
  
  
  Future<bool> deleteUser(int id) async {
    try {
      _setDeleteState(LoadingState.loading);
      _clearError();
      
      
      final success = await _userService.deleteUser(id);
      
      if (success) {
        // Removemos el usuario de la lista
        _users.removeWhere((user) => user.id == id);
        
        // Si era el usuario seleccionado, lo limpiamos
        if (_selectedUser?.id == id) {
          _selectedUser = null;
        }
        
        _setDeleteState(LoadingState.success);
      }
      
      return success;
    } catch (e) {
      _setError('Error al eliminar usuario: $e');
      _setDeleteState(LoadingState.error);
      return false;
    }
  }
  
  
  Future<void> refresh() async {
    await loadUsers(refresh: true);
  }
  
  
  void clearError() {
    _clearError();
  }
  
  
  
  void _setLoadingState(LoadingState state) {
    _loadingState = state;
    notifyListeners();
  }
  
  void _setCreateUpdateState(LoadingState state) {
    _createUpdateState = state;
    notifyListeners();
  }
  
  void _setDeleteState(LoadingState state) {
    _deleteState = state;
    notifyListeners();
  }
  
  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }
  
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
  
  void _clearSearch() {
    _searchQuery = '';
    _isSearching = false;
    _filteredUsers.clear();
    notifyListeners();
  }
  
  
  @override
  void dispose() {
    _users.clear();
    _filteredUsers.clear();
    _selectedUser = null;
    super.dispose();
  }
}