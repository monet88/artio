// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'admin_template_model.freezed.dart';
part 'admin_template_model.g.dart';

@freezed
class AdminTemplateModel with _$AdminTemplateModel {
  const factory AdminTemplateModel({
    required String id,
    required String name,
    required String description,
    required String category,
    @JsonKey(name: 'prompt_template') required String promptTemplate,
    @JsonKey(name: 'order') required int order,
    @JsonKey(name: 'is_premium') @Default(false) bool isPremium,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'thumbnail_url') String? thumbnailUrl,
    @JsonKey(name: 'default_aspect_ratio')
    @Default('1:1')
    String defaultAspectRatio,
    @JsonKey(name: 'input_fields')
    @Default([])
    List<Map<String, dynamic>> inputFields,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _AdminTemplateModel;

  factory AdminTemplateModel.fromJson(Map<String, dynamic> json) =>
      _$AdminTemplateModelFromJson(json);
}
