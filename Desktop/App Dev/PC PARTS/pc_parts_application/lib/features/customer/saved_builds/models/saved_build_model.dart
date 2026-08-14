import '../../products/models/product_model.dart';

class SavedBuildModel {
  final String id;
  final String buildName;
  final double totalPrice;
  final DateTime createdAt;

  final ProductModel? cpu;
  final ProductModel? gpu;
  final ProductModel? motherboard;
  final ProductModel? ram;
  final ProductModel? storage;
  final ProductModel? psu;
  final ProductModel? pcCase;

  const SavedBuildModel({
    required this.id,
    required this.buildName,
    required this.totalPrice,
    required this.createdAt,
    this.cpu,
    this.gpu,
    this.motherboard,
    this.ram,
    this.storage,
    this.psu,
    this.pcCase,
  });
}
