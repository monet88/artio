// ignore_for_file: invalid_annotation_target — @JsonKey on Freezed constructor params is the recommended pattern
import 'package:artio/features/template_engine/domain/entities/input_field_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'template_model.freezed.dart';
part 'template_model.g.dart';

@freezed
class TemplateModel with _$TemplateModel {
  const factory TemplateModel({
    required String id,
    required String name,
    required String description,
    @JsonKey(name: 'thumbnail_url') required String thumbnailUrl,
    required String category,
    @JsonKey(name: 'prompt_template') required String promptTemplate,
    @JsonKey(name: 'input_fields') required List<InputFieldModel> inputFields,
    @JsonKey(name: 'default_aspect_ratio') @Default('1:1') String defaultAspectRatio,
    @JsonKey(name: 'is_premium') @Default(false) bool isPremium,
    @Default(0) int order,
  }) = _TemplateModel;

  factory TemplateModel.fromJson(Map<String, dynamic> json) =>
      _$TemplateModelFromJson(json);
}
