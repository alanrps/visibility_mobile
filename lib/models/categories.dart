import 'package:json_annotation/json_annotation.dart';

part 'categories.g.dart';

@JsonSerializable()
class Categories {
  int? travel;
  int? transport;
  int? supermarket;
  int? services;
  int? leisure;
  int? education;
  int? food;
  int? hospital;
  int? accommodation;
  int? finance;

  Categories({
    required this.travel,
    required this.transport,
    required this.supermarket,
    required this.services,
    required this.leisure,
    required this.education,
    required this.food,
    required this.hospital,
    required this.accommodation,
    required this.finance,
    });

  factory Categories.fromJson(Map<String, dynamic> json) =>
      _$CategoriesFromJson(json);

  Map<String, dynamic> toJson() => _$CategoriesToJson(this);
}