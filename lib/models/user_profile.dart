class UserProfile {
  String name;
  String username;
  String email;
  String? profileImageUrl;

  UserProfile({
    required this.name,
    required this.username,
    required this.email,
    this.profileImageUrl,
  });
}

class NotificationSettings {
  bool email;
  bool push;
  bool sms;

  NotificationSettings({
    required this.email,
    required this.push,
    required this.sms,
  });
}

class PrivacySettings {
  bool profilePublic;
  bool showEmail;
  bool showPhone;

  PrivacySettings({
    required this.profilePublic,
    required this.showEmail,
    required this.showPhone,
  });
}

class PromoPreferences {
  String category;
  String budget;
  bool alertsEnabled;

  PromoPreferences({
    required this.category,
    required this.budget,
    required this.alertsEnabled,
  });
}
