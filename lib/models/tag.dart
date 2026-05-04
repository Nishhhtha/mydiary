import 'package:flutter/material.dart';

class Tag {
  final String uuid;
  final String name;
  final String colorHex;
  final int order;

  Tag({required this.uuid, required this.name,
       required this.colorHex, this.order = 0});

  // Identical getter to your current code — no @ignore needed
  Color get color => Color(int.parse(colorHex, radix: 16));

  Map<String, dynamic> toMap() => {
    'uuid': uuid, 'name': name,
    'colorHex': colorHex, 'order': order,
  };

  factory Tag.fromMap(Map<dynamic, dynamic> m) => Tag(
    uuid:     m['uuid'] as String,
    name:     m['name'] as String,
    colorHex: m['colorHex'] as String,
    order:    (m['order'] as num?)?.toInt() ?? 0,
  );
}
