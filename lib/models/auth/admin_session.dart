import 'package:equatable/equatable.dart';

import 'auth_tokens.dart';

class AdminSession extends Equatable {
  const AdminSession({
    required this.email,
    required this.role,
    required this.tokens,
  });

  final String email;
  final String role;
  final AuthTokens tokens;

  AdminSession copyWith({
    String? email,
    String? role,
    AuthTokens? tokens,
  }) {
    return AdminSession(
      email: email ?? this.email,
      role: role ?? this.role,
      tokens: tokens ?? this.tokens,
    );
  }

  @override
  List<Object?> get props => [email, role, tokens];
}
