// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dynamic_screen_appbar.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DynamicScreenAppBarModel _$DynamicScreenAppBarModelFromJson(
    Map<String, dynamic> json) {
  return DynamicScreenAppBarModel(
    showDivider: json['showDivider'] as bool ?? false,
    title: json['title'] == null
        ? null
        : DynamicScreenTextModel.fromJson(
            json['title'] as Map<String, dynamic>),
    actions: DynamicScreenAppBarModel._actionsFromJson(json['actions'] as List),
  );
}

Map<String, dynamic> _$DynamicScreenAppBarModelToJson(
        DynamicScreenAppBarModel instance) =>
    <String, dynamic>{
      'showDivider': instance.showDivider,
      'title': instance.title,
      'actions': instance.actions,
    };
