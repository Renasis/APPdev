class AddressModel {
  final String id;
  String fullName;
  String phoneNumber;
  String address;
  bool isDefault;

  AddressModel({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.address,
    this.isDefault = false,
  });
}

