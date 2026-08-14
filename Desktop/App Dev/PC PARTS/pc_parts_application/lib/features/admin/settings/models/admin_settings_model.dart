class AdminSettings {
  String storeName;
  String email;
  String phone;
  String address;
  String currency;
  bool notificationsEnabled;

  AdminSettings({
    required this.storeName,
    required this.email,
    required this.phone,
    required this.address,
    required this.currency,
    required this.notificationsEnabled,
  });
}