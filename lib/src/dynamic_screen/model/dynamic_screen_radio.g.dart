// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dynamic_screen_radio.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DynamicScreenRadioModel _$DynamicScreenRadioModelFromJson(
    Map<String, dynamic> json) {
  return DynamicScreenRadioModel(
    title:
        DynamicScreenTextModel.fromJson(json['title'] as Map<String, dynamic>),
    value: json['value'],
  );
}

Map<String, dynamic> _$DynamicScreenRadioModelToJson(
        DynamicScreenRadioModel instance) =>
    <String, dynamic>{
      'title': instance.title,
      'value': instance.value,
    };
