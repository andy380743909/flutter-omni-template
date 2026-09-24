/// Domain entity representing a user's profile.
///
/// Entities are plain, framework-agnostic value objects. This feature exercises
/// the network + cache layers (unlike the local-only [Counter]), demonstrating
/// how a remote data source and a local cache cooperate behind one repository.
class UserProfile {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
  });

  /// Returns a copy with the given fields replaced.
  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? Function()? avatarUrl,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl != null ? avatarUrl() : this.avatarUrl,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfile &&
          other.id == id &&
          other.name == name &&
          other.email == email &&
          other.avatarUrl == avatarUrl;

  @override
  int get hashCode => Object.hash(id, name, email, avatarUrl);

  @override
  String toString() =>
      'UserProfile(id: $id, name: $name, email: $email, avatarUrl: $avatarUrl)';
}
