import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/user.dart';

class UserService {
  static const String _baseUrl = 'https://reqres.in/api';

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'x-api-key': dotenv.env['API_KEY'] ?? '',
      };

  Future<UsersResponse> getUsers({int page = 1}) async {
    try {
      final url = Uri.parse('$_baseUrl/users?page=$page');
      final response = await http.get(url, headers: _headers);
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        return UsersResponse.fromJson(jsonData);
      } else {
        throw Exception(
            'Error al obtener usuarios: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión al obtener usuarios: $e');
    }
  }

  Future<User> getUserById(int id) async {
    try {
      final url = Uri.parse('$_baseUrl/users/$id');
      final response = await http.get(url, headers: _headers);
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final userData = jsonData['data'] as Map<String, dynamic>;
        return User.fromJson(userData);
      } else if (response.statusCode == 404) {
        throw Exception('Usuario no encontrado');
      } else {
        throw Exception(
            'Error al obtener usuario: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión al obtener usuario: $e');
    }
  }

  Future<User> createUser(User user) async {
    try {
      final url = Uri.parse('$_baseUrl/users');
      final body = json.encode(user.toJson());
      final response =
          await http.post(url, headers: _headers, body: body);
      if (response.statusCode == 201) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        return user.copyWith(
          id: int.tryParse(jsonData['id']?.toString() ?? '') ??
              DateTime.now().millisecondsSinceEpoch,
        );
      } else {
        throw Exception(
            'Error al crear usuario: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión al crear usuario: $e');
    }
  }

  Future<User> updateUser(User user) async {
    if (user.id == null) {
      throw Exception('El usuario debe tener un ID para ser actualizado');
    }
    try {
      final url = Uri.parse('$_baseUrl/users/${user.id}');
      final body = json.encode(user.toJson());
      final response =
          await http.put(url, headers: _headers, body: body);
      if (response.statusCode == 200) {
        return user;
      } else {
        throw Exception(
            'Error al actualizar usuario: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión al actualizar usuario: $e');
    }
  }

  Future<bool> deleteUser(int id) async {
    try {
      final url = Uri.parse('$_baseUrl/users/$id');
      final response = await http.delete(url, headers: _headers);
      if (response.statusCode == 204) {
        return true;
      } else {
        throw Exception(
            'Error al eliminar usuario: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión al eliminar usuario: $e');
    }
  }

  Future<List<User>> searchUsers(String query) async {
    try {
      if (query.trim().isEmpty) {
        return [];
      }
      final firstPage = await getUsers(page: 1);
      List<User> allUsers = List.from(firstPage.data);
      for (int page = 2; page <= firstPage.totalPages; page++) {
        final pageResponse = await getUsers(page: page);
        allUsers.addAll(pageResponse.data);
      }
      return allUsers
          .where((user) =>
              user.fullName.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } catch (e) {
      throw Exception('Error al buscar usuarios: $e');
    }
  }
}
