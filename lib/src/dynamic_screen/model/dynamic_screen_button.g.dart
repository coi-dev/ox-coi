// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dynamic_screen_button.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DynamicScreenButtonModel _$DynamicScreenButtonModelFromJson(
    Map<String, dynamic> json) {
  return DynamicScreenButtonModel(
    importance: _$enumDecodeNullable(
            _$ButtonImportanceTypeEnumMap, json['importance']) ??
        ButtonImportanceType.high,
    onPressed: json['on_pressed'] as String,
    title:
        DynamicScreenTextModel.fromJson(json['title'] as Map<String, dynamic>),
    padding: (json['padding'] as List)
            ?.map((e) => (e as num)?.toDouble())
            ?.toList() ??
        [0.0, 0.0, 0.0, 0.0],
  );
}

Map<String, dynamic> _$DynamicScreenButtonModelToJson(
        DynamicScreenButtonModel instance) =>
    <String, dynamic>{
      'importance': _$ButtonImportanceTypeEnumMap[instance.importance],
      'on_pressed': instance.onPressed,
      'title': instance.title,
      'padding': instance.padding,
    };

T _$enumDecode<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    throw ArgumentError('A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}');
  }

  final value = enumValues.entries
      .singleWhere((e) => e.value == source, orElse: () => null)
      ?.key;

  if (value == null && unknownValue == null) {
    throw ArgumentError('`$source` is not one of the supported values: '
        '${enumValues.values.join(', ')}');
  }
  return value ?? unknownValue;
}

T _$enumDecodeNullable<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<T>(enumValues, source, unknownValue: unknownValue);
}

const _$ButtonImportanceTypeEnumMap = {
  ButtonImportanceType.high: 'high',
  ButtonImportanceType.medium: 'medium',
  ButtonImportanceType.low: 'low',
  ButtonImportanceType.none: 'none',
};
