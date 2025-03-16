// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shelter_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShelterModel _$ShelterModelFromJson(Map<String, dynamic> json) => ShelterModel(
      id: json['id'] as String,
      name: json['name'] as String,
      area: (json['area'] as num).toInt(),
      duration: (json['duration'] as num).toInt(),
      capacity: (json['capacity'] as num).toInt(),
      description: json['description'] as String,
    );

Map<String, dynamic> _$ShelterModelToJson(ShelterModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'area': instance.area,
      'duration': instance.duration,
      'capacity': instance.capacity,
      'description': instance.description,
    };
