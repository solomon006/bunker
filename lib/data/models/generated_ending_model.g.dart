// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'generated_ending_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GeneratedEndingModel _$GeneratedEndingModelFromJson(
        Map<String, dynamic> json) =>
    GeneratedEndingModel(
      id: json['id'] as String,
      gameId: json['gameId'] as String,
      title: json['title'] as String,
      storyText: json['storyText'] as String,
      isSuccess: json['isSuccess'] as bool,
      generatedAt: DateTime.parse(json['generatedAt'] as String),
      acquisitionMethod: json['acquisitionMethod'] as String,
      generatorVersion: (json['generatorVersion'] as num).toInt(),
    );

Map<String, dynamic> _$GeneratedEndingModelToJson(
        GeneratedEndingModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'gameId': instance.gameId,
      'title': instance.title,
      'storyText': instance.storyText,
      'isSuccess': instance.isSuccess,
      'generatedAt': instance.generatedAt.toIso8601String(),
      'acquisitionMethod': instance.acquisitionMethod,
      'generatorVersion': instance.generatorVersion,
    };
