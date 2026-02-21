// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'input_field_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$InputFieldModelImpl _$$InputFieldModelImplFromJson(
  Map<String, dynamic> json,
) => _$InputFieldModelImpl(
  name: json['name'] as String,
  label: json['label'] as String,
  type: json['type'] as String,
  placeholder: json['placeholder'] as String?,
  defaultValue: json['default_value'] as String?,
  options: (json['options'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  min: (json['min'] as num?)?.toDouble(),
  max: (json['max'] as num?)?.toDouble(),
  required: json['required'] as bool? ?? false,
);

Map<String, dynamic> _$$InputFieldModelImplToJson(
  _$InputFieldModelImpl instance,
) => <String, dynamic>{
  'name': instance.name,
  'label': instance.label,
  'type': instance.type,
  'placeholder': instance.placeholder,
  'default_value': instance.defaultValue,
  'options': instance.options,
  'min': instance.min,
  'max': instance.max,
  'required': instance.required,
};
