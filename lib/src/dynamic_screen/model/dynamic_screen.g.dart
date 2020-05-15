// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dynamic_screen.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DynamicScreenModel _$DynamicScreenModelFromJson(Map<String, dynamic> json) {
  return DynamicScreenModel(
    showNavigation: json['show_navigation'] as bool ?? false,
    appBar: json['appbar'] == null
        ? null
        : DynamicScreenAppBarModel.fromJson(
            json['appbar'] as Map<String, dynamic>),
    pages: DynamicScreenModel._pagesFromJson(json['pages'] as List),
  );
}

Map<String, dynamic> _$DynamicScreenModelToJson(DynamicScreenModel instance) =>
    <String, dynamic>{
      'show_navigation': instance.showNavigation,
      'appbar': instance.appBar,
      'pages': instance.pages,
    };
