import 'package:flutter_test/flutter_test.dart';
import 'package:pc_parts_application/features/customer/pc_builder/services/compatibility_service.dart';
import 'package:pc_parts_application/features/customer/products/models/product_model.dart';

ProductModel product({
  required String name,
  required String category,
  required String description,
}) {
  return ProductModel(
    id: name,
    name: name,
    category: category,
    brand: 'Test',
    price: 1,
    image: '',
    stock: 1,
    description: description,
  );
}

void main() {
  test('detects platform, memory, and PSU compatibility warnings', () {
    final warnings = CompatibilityService.validate(
      cpu: product(
        name: 'Intel Core Test',
        category: 'CPU',
        description: 'Intel processor.',
      ),
      motherboard: product(
        name: 'AM5 Board',
        category: 'Motherboard',
        description: 'AM5 motherboard supporting DDR5 memory.',
      ),
      ram: product(
        name: 'DDR4 RAM',
        category: 'RAM',
        description: 'DDR4 memory module.',
      ),
      gpu: product(
        name: 'GPU',
        category: 'GPU',
        description: 'Graphics card.',
      ),
      psu: product(
        name: '450W PSU',
        category: 'PSU',
        description: '450W power supply.',
      ),
    );

    expect(warnings, hasLength(3));
  });

  test('accepts the current AMD AM5 DDR5 650W sample build', () {
    final warnings = CompatibilityService.validate(
      cpu: product(
        name: 'Ryzen CPU',
        category: 'CPU',
        description: 'AMD Ryzen processor.',
      ),
      motherboard: product(
        name: 'B650 Board',
        category: 'Motherboard',
        description: 'AM5 motherboard supporting DDR5 memory.',
      ),
      ram: product(
        name: 'DDR5 RAM',
        category: 'RAM',
        description: 'DDR5 memory module.',
      ),
      gpu: product(name: 'GPU', category: 'GPU', description: 'Graphics card.'),
      psu: product(
        name: '650W PSU',
        category: 'PSU',
        description: '650W power supply.',
      ),
    );

    expect(warnings, isEmpty);
  });
}
