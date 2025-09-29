
class User {
  final int? id;
  final String email;
  final String firstName;
  final String lastName;
  final String avatar;

  User({
    this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.avatar,
  });

  String get fullName => '$firstName $lastName';

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int?,
      email: json['email'] as String? ?? '',
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      avatar: json['avatar'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'avatar': avatar,
    };
  }

  User copyWith({
    int? id,
    String? email,
    String? firstName,
    String? lastName,
    String? avatar,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      avatar: avatar ?? this.avatar,
    );
  }

  @override
  String toString() {
    return 'User{id: $id, email: $email, firstName: $firstName, lastName: $lastName, avatar: $avatar}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.id == id &&
        other.email == email &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.avatar == avatar;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        email.hashCode ^
        firstName.hashCode ^
        lastName.hashCode ^
        avatar.hashCode;
  }
}

class UsersResponse {
  final int page;
  final int perPage;
  final int total;
  final int totalPages;
  final List<User> data;

  UsersResponse({
    required this.page,
    required this.perPage,
    required this.total,
    required this.totalPages,
    required this.data,
  });

  factory UsersResponse.fromJson(Map<String, dynamic> json) {
    return UsersResponse(
      page: json['page'] as int? ?? 1,
      perPage: json['per_page'] as int? ?? 6,
      total: json['total'] as int? ?? 0,
      totalPages: json['total_pages'] as int? ?? 0,
      data: (json['data'] as List<dynamic>? ?? [])
          .map((userJson) => User.fromJson(userJson as Map<String, dynamic>))
          .toList(),
    );
  }

  bool get hasMorePages => page < totalPages;

  @override
  String toString() {
    return 'UsersResponse{page: $page, perPage: $perPage, total: $total, totalPages: $totalPages, dataLength: ${data.length}}';
  }
}