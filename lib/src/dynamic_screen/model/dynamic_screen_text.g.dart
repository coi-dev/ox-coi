// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dynamic_screen_text.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DynamicScreenTextModel _$DynamicScreenTextModelFromJson(
    Map<String, dynamic> json) {
  return DynamicScreenTextModel(
    textStyle: _$enumDecodeNullable(
            _$DynamicScreenTextStyleEnumMap, json['text_style']) ??
        DynamicScreenTextStyle.body1,
    padding: (json['padding'] as List)
            ?.map((e) => (e as num)?.toDouble())
            ?.toList() ??
        [0.0, 0.0, 0.0, 0.0],
    localizable: DynamicScreenLocalizableModel.fromJson(
        json['localizable'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$DynamicScreenTextModelToJson(
        DynamicScreenTextModel instance) =>
    <String, dynamic>{
      'text_style': _$DynamicScreenTextStyleEnumMap[instance.textStyle],
      'padding': instance.padding,
      'localizable': instance.localizable,
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

const _$DynamicScreenTextStyleEnumMap = {
  DynamicScreenTextStyle.display4: 'display4',
  DynamicScreenTextStyle.display3: 'display3',
  DynamicScreenTextStyle.display2: 'display2',
  DynamicScreenTextStyle.display1: 'display1',
  DynamicScreenTextStyle.headline: 'headline',
  DynamicScreenTextStyle.title: 'title',
  DynamicScreenTextStyle.subhead: 'subhead',
  DynamicScreenTextStyle.body2: 'body2',
  DynamicScreenTextStyle.body1: 'body1',
  DynamicScreenTextStyle.caption: 'caption',
  DynamicScreenTextStyle.button: 'button',
  DynamicScreenTextStyle.subtitle: 'subtitle',
  DynamicScreenTextStyle.overline: 'overline',
};
