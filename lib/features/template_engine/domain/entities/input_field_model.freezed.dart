// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'input_field_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

InputFieldModel _$InputFieldModelFromJson(Map<String, dynamic> json) {
  return _InputFieldModel.fromJson(json);
}

/// @nodoc
mixin _$InputFieldModel {
  String get name => throw _privateConstructorUsedError;
  String get label => throw _privateConstructorUsedError;
  String get type =>
      throw _privateConstructorUsedError; // text, select, slider, toggle
  String? get placeholder => throw _privateConstructorUsedError;
  String? get defaultValue => throw _privateConstructorUsedError;
  List<String>? get options => throw _privateConstructorUsedError;
  double? get min => throw _privateConstructorUsedError;
  double? get max => throw _privateConstructorUsedError;
  bool get required => throw _privateConstructorUsedError;

  /// Serializes this InputFieldModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of InputFieldModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $InputFieldModelCopyWith<InputFieldModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InputFieldModelCopyWith<$Res> {
  factory $InputFieldModelCopyWith(
    InputFieldModel value,
    $Res Function(InputFieldModel) then,
  ) = _$InputFieldModelCopyWithImpl<$Res, InputFieldModel>;
  @useResult
  $Res call({
    String name,
    String label,
    String type,
    String? placeholder,
    String? defaultValue,
    List<String>? options,
    double? min,
    double? max,
    bool required,
  });
}

/// @nodoc
class _$InputFieldModelCopyWithImpl<$Res, $Val extends InputFieldModel>
    implements $InputFieldModelCopyWith<$Res> {
  _$InputFieldModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of InputFieldModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? label = null,
    Object? type = null,
    Object? placeholder = freezed,
    Object? defaultValue = freezed,
    Object? options = freezed,
    Object? min = freezed,
    Object? max = freezed,
    Object? required = null,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            label: null == label
                ? _value.label
                : label // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            placeholder: freezed == placeholder
                ? _value.placeholder
                : placeholder // ignore: cast_nullable_to_non_nullable
                      as String?,
            defaultValue: freezed == defaultValue
                ? _value.defaultValue
                : defaultValue // ignore: cast_nullable_to_non_nullable
                      as String?,
            options: freezed == options
                ? _value.options
                : options // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            min: freezed == min
                ? _value.min
                : min // ignore: cast_nullable_to_non_nullable
                      as double?,
            max: freezed == max
                ? _value.max
                : max // ignore: cast_nullable_to_non_nullable
                      as double?,
            required: null == required
                ? _value.required
                : required // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$InputFieldModelImplCopyWith<$Res>
    implements $InputFieldModelCopyWith<$Res> {
  factory _$$InputFieldModelImplCopyWith(
    _$InputFieldModelImpl value,
    $Res Function(_$InputFieldModelImpl) then,
  ) = __$$InputFieldModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String name,
    String label,
    String type,
    String? placeholder,
    String? defaultValue,
    List<String>? options,
    double? min,
    double? max,
    bool required,
  });
}

/// @nodoc
class __$$InputFieldModelImplCopyWithImpl<$Res>
    extends _$InputFieldModelCopyWithImpl<$Res, _$InputFieldModelImpl>
    implements _$$InputFieldModelImplCopyWith<$Res> {
  __$$InputFieldModelImplCopyWithImpl(
    _$InputFieldModelImpl _value,
    $Res Function(_$InputFieldModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of InputFieldModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? label = null,
    Object? type = null,
    Object? placeholder = freezed,
    Object? defaultValue = freezed,
    Object? options = freezed,
    Object? min = freezed,
    Object? max = freezed,
    Object? required = null,
  }) {
    return _then(
      _$InputFieldModelImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        label: null == label
            ? _value.label
            : label // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        placeholder: freezed == placeholder
            ? _value.placeholder
            : placeholder // ignore: cast_nullable_to_non_nullable
                  as String?,
        defaultValue: freezed == defaultValue
            ? _value.defaultValue
            : defaultValue // ignore: cast_nullable_to_non_nullable
                  as String?,
        options: freezed == options
            ? _value._options
            : options // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        min: freezed == min
            ? _value.min
            : min // ignore: cast_nullable_to_non_nullable
                  as double?,
        max: freezed == max
            ? _value.max
            : max // ignore: cast_nullable_to_non_nullable
                  as double?,
        required: null == required
            ? _value.required
            : required // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$InputFieldModelImpl implements _InputFieldModel {
  const _$InputFieldModelImpl({
    required this.name,
    required this.label,
    required this.type,
    this.placeholder,
    this.defaultValue,
    final List<String>? options,
    this.min,
    this.max,
    this.required = false,
  }) : _options = options;

  factory _$InputFieldModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$InputFieldModelImplFromJson(json);

  @override
  final String name;
  @override
  final String label;
  @override
  final String type;
  // text, select, slider, toggle
  @override
  final String? placeholder;
  @override
  final String? defaultValue;
  final List<String>? _options;
  @override
  List<String>? get options {
    final value = _options;
    if (value == null) return null;
    if (_options is EqualUnmodifiableListView) return _options;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final double? min;
  @override
  final double? max;
  @override
  @JsonKey()
  final bool required;

  @override
  String toString() {
    return 'InputFieldModel(name: $name, label: $label, type: $type, placeholder: $placeholder, defaultValue: $defaultValue, options: $options, min: $min, max: $max, required: $required)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InputFieldModelImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.placeholder, placeholder) ||
                other.placeholder == placeholder) &&
            (identical(other.defaultValue, defaultValue) ||
                other.defaultValue == defaultValue) &&
            const DeepCollectionEquality().equals(other._options, _options) &&
            (identical(other.min, min) || other.min == min) &&
            (identical(other.max, max) || other.max == max) &&
            (identical(other.required, required) ||
                other.required == required));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    label,
    type,
    placeholder,
    defaultValue,
    const DeepCollectionEquality().hash(_options),
    min,
    max,
    required,
  );

  /// Create a copy of InputFieldModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InputFieldModelImplCopyWith<_$InputFieldModelImpl> get copyWith =>
      __$$InputFieldModelImplCopyWithImpl<_$InputFieldModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$InputFieldModelImplToJson(this);
  }
}

abstract class _InputFieldModel implements InputFieldModel {
  const factory _InputFieldModel({
    required final String name,
    required final String label,
    required final String type,
    final String? placeholder,
    final String? defaultValue,
    final List<String>? options,
    final double? min,
    final double? max,
    final bool required,
  }) = _$InputFieldModelImpl;

  factory _InputFieldModel.fromJson(Map<String, dynamic> json) =
      _$InputFieldModelImpl.fromJson;

  @override
  String get name;
  @override
  String get label;
  @override
  String get type; // text, select, slider, toggle
  @override
  String? get placeholder;
  @override
  String? get defaultValue;
  @override
  List<String>? get options;
  @override
  double? get min;
  @override
  double? get max;
  @override
  bool get required;

  /// Create a copy of InputFieldModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InputFieldModelImplCopyWith<_$InputFieldModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
