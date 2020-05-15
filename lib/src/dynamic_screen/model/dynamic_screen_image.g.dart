// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dynamic_screen_image.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DynamicScreenImageModel _$DynamicScreenImageModelFromJson(
    Map<String, dynamic> json) {
  return DynamicScreenImageModel(
    name: json['name'] as String,
    padding: (json['padding'] as List)
            ?.map((e) => (e as num)?.toDouble())
            ?.toList() ??
        [0.0, 0.0, 0.0, 0.0],
  );
}

Map<String, dynamic> _$DynamicScreenImageModelToJson(
        DynamicScreenImageModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'padding': instance.padding,
    };
