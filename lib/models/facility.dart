class Facility {
  final int id;
  final String code;
  final String name;
  final String category;
  final String location;
  final String description;
  final int totalQty;
  final int availableQty;

  const Facility({
    required this.id,
    required this.code,
    required this.name,
    required this.category,
    required this.location,
    required this.description,
    required this.totalQty,
    required this.availableQty,
  });

  factory Facility.fromMap(Map<String, Object?> map) => Facility(
        id: map['id'] as int,
        code: map['code'] as String,
        name: map['name'] as String,
        category: map['category'] as String,
        location: map['location'] as String,
        description: map['description'] as String,
        totalQty: map['total_qty'] as int,
        availableQty: map['available_qty'] as int,
      );
}
