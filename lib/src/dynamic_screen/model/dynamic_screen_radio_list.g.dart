// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dynamic_screen_radio_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DynamicScreenRadioListModel _$DynamicScreenRadioListModelFromJson(
    Map<String, dynamic> json) {
  return DynamicScreenRadioListModel(
    items:
        DynamicScreenRadioListModel._componentsFromJson(json['items'] as List),
    padding: (json['padding'] as List)
            ?.map((e) => (e as num)?.toDouble())
            ?.toList() ??
        [0.0, 0.0, 0.0, 0.0],
    groupValue: json['group_value'],
  )..groupKey = json['group_key'];
}

Map<String, dynamic> _$DynamicScreenRadioListModelToJson(
        DynamicScreenRadioListModel instance) =>
    <String, dynamic>{
      'items': instance.items,
      'padding': instance.padding,
      'group_value': instance.groupValue,
      'group_key': instance.groupKey,
    };
