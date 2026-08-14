import '../../products/models/product_model.dart';

/// Lightweight compatibility checks for the in-memory product catalog.
///
/// The current product model does not yet contain structured specifications
/// (socket, memory standard, or wattage), so these checks use only explicit
/// terms already present in product names and descriptions. Unknown details
/// produce no warning rather than an unsupported compatibility claim.
class CompatibilityService {
  const CompatibilityService._();

  static List<String> validate({
    ProductModel? cpu,
    ProductModel? motherboard,
    ProductModel? ram,
    ProductModel? gpu,
    ProductModel? psu,
  }) {
    final warnings = <String>[];

    _validateCpuMotherboard(cpu, motherboard, warnings);
    _validateMemory(motherboard, ram, warnings);
    _validatePowerSupply(gpu, psu, warnings);

    return warnings;
  }

  static void _validateCpuMotherboard(
    ProductModel? cpu,
    ProductModel? motherboard,
    List<String> warnings,
  ) {
    if (cpu == null || motherboard == null) {
      return;
    }

    final cpuPlatform = _platform(cpu);
    final motherboardPlatform = _platform(motherboard);
    if (cpuPlatform != null &&
        motherboardPlatform != null &&
        cpuPlatform != motherboardPlatform) {
      warnings.add(
        '${cpu.name} is not compatible with ${motherboard.name}.',
      );
    }
  }

  static void _validateMemory(
    ProductModel? motherboard,
    ProductModel? ram,
    List<String> warnings,
  ) {
    if (motherboard == null || ram == null) {
      return;
    }

    final motherboardMemory = _memoryStandard(motherboard);
    final ramMemory = _memoryStandard(ram);
    if (motherboardMemory != null &&
        ramMemory != null &&
        motherboardMemory != ramMemory) {
      warnings.add(
        '${ram.name} ($ramMemory) is not compatible with '
        '${motherboard.name} ($motherboardMemory).',
      );
    }
  }

  static void _validatePowerSupply(
    ProductModel? gpu,
    ProductModel? psu,
    List<String> warnings,
  ) {
    if (gpu == null || psu == null) {
      return;
    }

    final wattage = _wattage(psu);
    if (wattage != null && wattage < 550) {
      warnings.add(
        '${psu.name} may not provide enough power for a build with ${gpu.name}. '
        'Use a 550W or higher PSU.',
      );
    }
  }

  static String? _platform(ProductModel product) {
    final text = _searchableText(product);
    if (text.contains('am5') || text.contains('ryzen') || text.contains('amd')) {
      return 'AMD';
    }
    if (text.contains('lga') || text.contains('intel')) {
      return 'Intel';
    }
    return null;
  }

  static String? _memoryStandard(ProductModel product) {
    final text = _searchableText(product);
    if (text.contains('ddr5')) {
      return 'DDR5';
    }
    if (text.contains('ddr4')) {
      return 'DDR4';
    }
    return null;
  }

  static int? _wattage(ProductModel product) {
    final match = RegExp(r'\b(\d{3,4})\s*w\b', caseSensitive: false)
        .firstMatch(_searchableText(product));
    return match == null ? null : int.tryParse(match.group(1)!);
  }

  static String _searchableText(ProductModel product) {
    return '${product.name} ${product.brand} ${product.description}'
        .toLowerCase();
  }
}
