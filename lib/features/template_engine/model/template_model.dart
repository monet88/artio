import 'package:freezed_annotation/freezed_annotation.dart';
import 'input_field_model.dart';

part 'template_model.freezed.dart';
part 'template_model.g.dart';

@freezed
class TemplateModel with _$TemplateModel {
  const factory TemplateModel({
    required String id,
    required String name,
    required String description,
    required String thumbnailUrl,
    required String category,
    required String promptTemplate,
    required List<InputFieldModel> inputFields,
    @Default('1:1') String defaultAspectRatio,
    @Default(false) bool isPremium,
    @Default(0) int order,
  }) = _TemplateModel;

  factory TemplateModel.fromJson(Map<String, dynamic> json) =>
      _$TemplateModelFromJson(json);
}
