// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dynamic_screen_page.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DynamicScreenPageModel _$DynamicScreenPageModelFromJson(
    Map<String, dynamic> json) {
  return DynamicScreenPageModel(
    json['skipable'] as bool ?? true,
    (json['availabilities'] as List)
            ?.map((e) => (e as Map<String, dynamic>)?.map(
                  (k, e) => MapEntry(k, e as bool),
                ))
            ?.toList() ??
        [{}],
    DynamicScreenPageModel._componentsFromJson(json['components'] as List),
    (json['padding'] as List)?.map((e) => (e as num)?.toDouble())?.toList() ??
        [32.0, 0, 32.0, 0],
  );
}

Map<String, dynamic> _$DynamicScreenPageModelToJson(
        DynamicScreenPageModel instance) =>
    <String, dynamic>{
      'skipable': instance.skipable,
      'availabilities': instance.availabilities,
      'padding': instance.padding,
      'components': instance.components,
    };
