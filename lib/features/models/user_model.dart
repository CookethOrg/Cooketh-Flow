import 'package:supabase_flutter/supabase_flutter.dart';

class CurrentUser {
  final String id;
  final String? name; // Full name (e.g., "Antara Paul")
  final String? username; // Unique username (e.g., "@antara_paul")
  final String email;
  final String? avatarUrl; // URL for the profile picture
  final String provider; // 'email', 'google', 'github'

  CurrentUser({
    required this.id,
    this.name,
    this.username,
    required this.email,
    this.avatarUrl,
    required this.provider,
  });

  factory CurrentUser.fromSupabaseUser(User user) {
    final Map<String, dynamic> userMetadata = user.userMetadata ?? {};
    final Map<String, dynamic> appMetadata = user.appMetadata ?? {};

    String? name;
    String? username;
    String? avatarUrl;
    String provider = appMetadata['provider'] ?? 'email'; // Default to email

    // Extract relevant data based on the provider
    switch (provider) {
      case 'google':
        name = userMetadata['full_name'] ?? userMetadata['name'];
        username = null;
        avatarUrl = userMetadata['avatar_url'] ?? userMetadata['picture'];
        break;
      case 'github':
        name = userMetadata['full_name'] ?? userMetadata['name'];
        username = userMetadata['preferred_username'] ?? userMetadata['user_name'];
        avatarUrl = userMetadata['avatar_url'];
        break;
      case 'email':
      default:
        name = userMetadata['name'] ?? user.email?.split('@').first;
        username = userMetadata['userName'] ?? user.email?.split('@').first;
        avatarUrl = userMetadata['profile_picture_url']; // Custom field for uploaded PFP
        break;
    }

    return CurrentUser(
      id: user.id,
      name: name,
      username: username,
      email: user.email!,
      avatarUrl: avatarUrl,
      provider: provider,
    );
  }

  /// Creates a copy of the [CurrentUser] object with optional new values.
  CurrentUser copyWith({
    String? name,
    String? username,
    String? email,
    String? avatarUrl,
  }) {
    return CurrentUser(
      id: id,
      name: name ?? this.name,
      username: username ?? this.username,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      provider: provider,
    );
  }
}