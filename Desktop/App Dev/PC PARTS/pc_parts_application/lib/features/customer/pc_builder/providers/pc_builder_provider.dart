import 'package:flutter/material.dart';

import '../../products/models/product_model.dart';
import '../services/compatibility_service.dart';

class PcBuilderProvider extends ChangeNotifier {
  ProductModel? cpu;
  ProductModel? gpu;
  ProductModel? motherboard;
  ProductModel? ram;
  ProductModel? storage;
  ProductModel? psu;
  ProductModel? pcCase;

  void selectCpu(ProductModel product) => _select(() => cpu = product);
  void selectGpu(ProductModel product) => _select(() => gpu = product);
  void selectMotherboard(ProductModel product) =>
      _select(() => motherboard = product);
  void selectRam(ProductModel product) => _select(() => ram = product);
  void selectStorage(ProductModel product) => _select(() => storage = product);
  void selectPsu(ProductModel product) => _select(() => psu = product);
  void selectCase(ProductModel product) => _select(() => pcCase = product);

  void removeCpu() => _select(() => cpu = null);
  void removeGpu() => _select(() => gpu = null);
  void removeMotherboard() => _select(() => motherboard = null);
  void removeRam() => _select(() => ram = null);
  void removeStorage() => _select(() => storage = null);
  void removePsu() => _select(() => psu = null);
  void removeCase() => _select(() => pcCase = null);

  double get totalPrice => selectedProducts.fold(
        0,
        (total, product) => total + product.price,
      );

  bool get isBuildComplete =>
      cpu != null &&
      gpu != null &&
      motherboard != null &&
      ram != null &&
      storage != null &&
      psu != null &&
      pcCase != null;

  List<String> get compatibilityWarnings => CompatibilityService.validate(
        cpu: cpu,
        motherboard: motherboard,
        ram: ram,
        gpu: gpu,
        psu: psu,
      );

  bool get isBuildCompatible => compatibilityWarnings.isEmpty;

  List<ProductModel> get selectedProducts => [
        ?cpu,
        ?gpu,
        ?motherboard,
        ?ram,
        ?storage,
        ?psu,
        ?pcCase,
      ];

  void loadBuild({
    ProductModel? cpu,
    ProductModel? gpu,
    ProductModel? motherboard,
    ProductModel? ram,
    ProductModel? storage,
    ProductModel? psu,
    ProductModel? pcCase,
  }) {
    this.cpu = cpu;
    this.gpu = gpu;
    this.motherboard = motherboard;
    this.ram = ram;
    this.storage = storage;
    this.psu = psu;
    this.pcCase = pcCase;
    notifyListeners();
  }

  void clearBuild() {
    loadBuild();
  }

  void _select(void Function() update) {
    update();
    notifyListeners();
  }
}
