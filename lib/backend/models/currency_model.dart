class Currency {
  final int id;
  final String code;
  final String name;

  Currency({required this.id, required this.code, required this.name});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'name': name,
    };
  }

  factory Currency.fromMap(Map<String, dynamic> map) {
    return Currency(
      id: map['id'] as int,
      code: map['code'] as String,
      name: map['name'] as String,
    );
  }

  @override
  String toString() {
    return "Devise : $name ($code)";
  }
}
