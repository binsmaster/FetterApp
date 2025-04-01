import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<UserModel?> signIn(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        return UserModel(
          id: response.user!.id,
          email: response.user!.email!,
          name: response.user!.userMetadata?['name'] as String?,
          photoUrl: response.user!.userMetadata?['photo_url'] as String?,
        );
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel?> signUp(String email, String password, String name) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
          'photo_url': null,
        },
      );

      if (response.user != null) {
        return UserModel(
          id: response.user!.id,
          email: response.user!.email!,
          name: name,
        );
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  Future<UserModel?> updateProfile(String name, String? photoUrl) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('Usuário não autenticado');

      final response = await _supabase.auth.updateUser(
        UserAttributes(
          data: {
            'name': name,
            'photo_url': photoUrl,
          },
        ),
      );

      if (response.user != null) {
        return UserModel(
          id: response.user!.id,
          email: response.user!.email!,
          name: name,
          photoUrl: photoUrl,
        );
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      await _supabase.auth.updateUser(
        UserAttributes(
          password: newPassword,
        ),
      );
    } catch (e) {
      rethrow;
    }
  }

  UserModel? getCurrentUser() {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      return UserModel(
        id: user.id,
        email: user.email!,
        name: user.userMetadata?['name'] as String?,
        photoUrl: user.userMetadata?['photo_url'] as String?,
      );
    }
    return null;
  }

  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: 'fetterapp://reset-password',
      );
    } catch (e) {
      rethrow;
    }
  }
}
