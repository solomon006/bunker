import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'catastrophe_model.g.dart';

@JsonSerializable()
class CatastropheModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final int rating;

  const CatastropheModel({
    required this.id,
    required this.title,
    required this.description,
    required this.rating,
  });

  // Копирование с изменениями
  CatastropheModel copyWith({
    String? id,
    String? title,
    String? description,
    int? rating,
  }) {
    return CatastropheModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      rating: rating ?? this.rating,
    );
  }

  // Фабричный метод для JSON
  factory CatastropheModel.fromJson(Map<String, dynamic> json) => _$CatastropheModelFromJson(json);

  // Сериализация в JSON
  Map<String, dynamic> toJson() => _$CatastropheModelToJson(this);

  @override
  List<Object?> get props => [id, title, description, rating];
}