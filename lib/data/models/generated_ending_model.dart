import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'generated_ending_model.g.dart';

@JsonSerializable()
class GeneratedEndingModel extends Equatable {
  final String id;
  final String gameId;
  final String title;
  final String storyText;
  final bool isSuccess;
  final DateTime generatedAt;
  final String acquisitionMethod;
  final int generatorVersion;

  const GeneratedEndingModel({
    required this.id,
    required this.gameId,
    required this.title,
    required this.storyText,
    required this.isSuccess,
    required this.generatedAt,
    required this.acquisitionMethod,
    required this.generatorVersion,
  });

  // Копирование с изменениями
  GeneratedEndingModel copyWith({
    String? id,
    String? gameId,
    String? title,
    String? storyText,
    bool? isSuccess,
    DateTime? generatedAt,
    String? acquisitionMethod,
    int? generatorVersion,
  }) {
    return GeneratedEndingModel(
      id: id ?? this.id,
      gameId: gameId ?? this.gameId,
      title: title ?? this.title,
      storyText: storyText ?? this.storyText,
      isSuccess: isSuccess ?? this.isSuccess,
      generatedAt: generatedAt ?? this.generatedAt,
      acquisitionMethod: acquisitionMethod ?? this.acquisitionMethod,
      generatorVersion: generatorVersion ?? this.generatorVersion,
    );
  }

  // Фабричный метод для JSON
  factory GeneratedEndingModel.fromJson(Map<String, dynamic> json) => _$GeneratedEndingModelFromJson(json);

  // Сериализация в JSON
  Map<String, dynamic> toJson() => _$GeneratedEndingModelToJson(this);

  @override
  List<Object?> get props => [
    id, gameId, title, storyText, isSuccess,
    generatedAt, acquisitionMethod, generatorVersion
  ];
}
