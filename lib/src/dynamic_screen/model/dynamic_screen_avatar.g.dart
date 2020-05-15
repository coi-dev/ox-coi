// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dynamic_screen_avatar.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DynamicScreenAvatarModel _$DynamicScreenAvatarModelFromJson(
    Map<String, dynamic> json) {
  return DynamicScreenAvatarModel(
    avatarPressed: json['avatar_pressed'] as String,
    padding: (json['padding'] as List)
            ?.map((e) => (e as num)?.toDouble())
            ?.toList() ??
        [0.0, 0.0, 0.0, 0.0],
  );
}

Map<String, dynamic> _$DynamicScreenAvatarModelToJson(
        DynamicScreenAvatarModel instance) =>
    <String, dynamic>{
      'avatar_pressed': instance.avatarPressed,
      'padding': instance.padding,
    };
