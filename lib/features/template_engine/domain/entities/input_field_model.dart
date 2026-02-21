// ignore_for_file: invalid_annotation_target — @JsonKey on Freezed constructor params is the recommended pattern
import 'package:freezed_annotation/freezed_annotation.dart';

part 'input_field_model.freezed.dart';
part 'input_field_model.g.dart';

@freezed
class InputFieldModel with _$InputFieldModel {
  const factory InputFieldModel({
    required String name,
    required String label,
    required String type, // text, select, slider, toggle
    String? placeholder,
    @JsonKey(name: 'default_value') String? defaultValue,
    List<String>? options,
    double? min,
    double? max,
    @Default(false) bool required,
  }) = _InputFieldModel;

  factory InputFieldModel.fromJson(Map<String, dynamic> json) =>
      _$InputFieldModelFromJson(json);
}
