import 'package:freezed_annotation/freezed_annotation.dart';

part 'generation_options_model.freezed.dart';
part 'generation_options_model.g.dart';

@freezed
class GenerationOptionsModel with _$GenerationOptionsModel {
  const factory GenerationOptionsModel({
    @Default('1:1') String aspectRatio,
    @Default(1) int imageCount,
    @Default('jpg') String outputFormat,
    @Default('google/imagen4') String modelId,
    @Default('') String otherIdeas,
  }) = _GenerationOptionsModel;

  factory GenerationOptionsModel.fromJson(Map<String, dynamic> json) =>
      _$GenerationOptionsModelFromJson(json);
}
