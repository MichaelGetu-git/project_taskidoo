class UserProfile {
  String id;
  String name;
  String email;
  String avatarUrl; // Optional
  String role; // 'Individual' or 'Team Member'

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl = '',
    this.role = 'Individual',
  });
}
