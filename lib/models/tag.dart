import 'package:isar/isar.dart';
import 'package:flutter/material.dart';

part 'tag.g.dart';

@collection
class Tag {
  Id id = Isar.autoIncrement;

  late String uuid;
  late String name;       // e.g. 'Exercise'
  late String colorHex;   // e.g. 'FF4CAF50' — ARGB hex colour
  late int order;         // Display order in filter bar

  Tag();

  // Convenience getter: converts hex string to Flutter Color
  @ignore // @ignore means Isar will not try to store this computed value
  Color get color => Color(int.parse(colorHex, radix: 16));
}
