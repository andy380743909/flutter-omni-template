import 'package:app_template/features/profile/domain/entities/profile.dart';

/// Data-layer model for [UserProfile].
///
/// Handles (de)serialization for the network and cache layers. It is a thin
/// mapping wrapper over the domain [UserProfile] entity.
class ProfileModel {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;

  const ProfileModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
  });

  /// Builds a model from a JSON map (e.g. a network response or cached record).
  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawId = json['id'];
    final dynamic rawName = json['name'];
    final dynamic rawEmail = json['email'];
    if (rawId is! String) {
      throw const FormatException('ProfileModel requires a String "id".');
    }
    if (rawName is! String) {
      throw const FormatException('ProfileModel requires a String "name".');
    }
    if (rawEmail is! String) {
      throw const FormatException('ProfileModel requires a String "email".');
    }
    final dynamic rawAvatar = json['avatarUrl'];
    return ProfileModel(
      id: rawId,
      name: rawName,
      email: rawEmail,
      avatarUrl: rawAvatar is String ? rawAvatar : null,
    );
  }

  /// Builds a model from a domain [UserProfile] entity.
  factory ProfileModel.fromEntity(UserProfile entity) => ProfileModel(
        id: entity.id,
        name: entity.name,
        email: entity.email,
        avatarUrl: entity.avatarUrl,
      );

  /// Serializes this model to a JSON map.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'email': email,
        'avatarUrl': avatarUrl,
      };

  /// Converts this model back to a domain [UserProfile] entity.
  UserProfile toEntity() => UserProfile(
        id: id,
        name: name,
        email: email,
        avatarUrl: avatarUrl,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProfileModel &&
          other.id == id &&
          other.name == name &&
          other.email == email &&
          other.avatarUrl == avatarUrl;

  @override
  int get hashCode => Object.hash(id, name, email, avatarUrl);

  @override
  String toString() =>
      'ProfileModel(id: $id, name: $name, email: $email, avatarUrl: $avatarUrl)';
}
