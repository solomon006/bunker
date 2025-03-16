import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'shelter_model.g.dart';

@JsonSerializable()
class ShelterModel extends Equatable {
  final String id;
  final String name;
  final int area;
  final int duration;
  final int capacity;
  final String description;

  const ShelterModel({
    required this.id,
    required this.name,
    required this.area,
    required this.duration,
    required this.capacity,
    required this.description,
  });

  // Копирование с изменениями
  ShelterModel copyWith({
    String? id,
    String? name,
    int? area,
    int? duration,
    int? capacity,
    String? description,
  }) {
    return ShelterModel(
      id: id ?? this.id,
      name: name ?? this.name,
      area: area ?? this.area,
      duration: duration ?? this.duration,
      capacity: capacity ?? this.capacity,
      description: description ?? this.description,
    );
  }

  // Фабричный метод для JSON
  factory ShelterModel.fromJson(Map<String, dynamic> json) => _$ShelterModelFromJson(json);

  // Сериализация в JSON
  Map<String, dynamic> toJson() => _$ShelterModelToJson(this);

  @override
  List<Object?> get props => [id, name, area, duration, capacity, description];
}
