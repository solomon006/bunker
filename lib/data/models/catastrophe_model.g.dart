// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catastrophe_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CatastropheModel _$CatastropheModelFromJson(Map<String, dynamic> json) =>
    CatastropheModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      rating: (json['rating'] as num).toInt(),
    );

Map<String, dynamic> _$CatastropheModelToJson(CatastropheModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'rating': instance.rating,
    };
