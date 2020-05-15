// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dynamic_screen_textfield.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DynamicScreenTextfieldModel _$DynamicScreenTextfieldModelFromJson(
    Map<String, dynamic> json) {
  return DynamicScreenTextfieldModel(
    required: json['required'] as bool,
    controlsNavigationIfRequired:
        json['controls_navigation_if_required'] as bool ?? false,
    label: json['label'] == null
        ? null
        : DynamicScreenTextModel.fromJson(
            json['label'] as Map<String, dynamic>),
    placeholder: json['placeholder'] == null
        ? null
        : DynamicScreenTextModel.fromJson(
            json['placeholder'] as Map<String, dynamic>),
    padding: (json['padding'] as List)
            ?.map((e) => (e as num)?.toDouble())
            ?.toList() ??
        [0, 0, 0, 0],
  );
}

Map<String, dynamic> _$DynamicScreenTextfieldModelToJson(
        DynamicScreenTextfieldModel instance) =>
    <String, dynamic>{
      'required': instance.required,
      'controls_navigation_if_required': instance.controlsNavigationIfRequired,
      'label': instance.label,
      'placeholder': instance.placeholder,
      'padding': instance.padding,
    };
