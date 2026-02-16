// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard_stats.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

DashboardStats _$DashboardStatsFromJson(Map<String, dynamic> json) {
  return _DashboardStats.fromJson(json);
}

/// @nodoc
mixin _$DashboardStats {
  int get totalTemplates => throw _privateConstructorUsedError;
  int get activeTemplates => throw _privateConstructorUsedError;
  int get premiumTemplates => throw _privateConstructorUsedError;
  int get categoriesCount => throw _privateConstructorUsedError;
  List<Map<String, dynamic>> get recentTemplates =>
      throw _privateConstructorUsedError;

  /// Serializes this DashboardStats to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DashboardStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DashboardStatsCopyWith<DashboardStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DashboardStatsCopyWith<$Res> {
  factory $DashboardStatsCopyWith(
    DashboardStats value,
    $Res Function(DashboardStats) then,
  ) = _$DashboardStatsCopyWithImpl<$Res, DashboardStats>;
  @useResult
  $Res call({
    int totalTemplates,
    int activeTemplates,
    int premiumTemplates,
    int categoriesCount,
    List<Map<String, dynamic>> recentTemplates,
  });
}

/// @nodoc
class _$DashboardStatsCopyWithImpl<$Res, $Val extends DashboardStats>
    implements $DashboardStatsCopyWith<$Res> {
  _$DashboardStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DashboardStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalTemplates = null,
    Object? activeTemplates = null,
    Object? premiumTemplates = null,
    Object? categoriesCount = null,
    Object? recentTemplates = null,
  }) {
    return _then(
      _value.copyWith(
            totalTemplates: null == totalTemplates
                ? _value.totalTemplates
                : totalTemplates // ignore: cast_nullable_to_non_nullable
                      as int,
            activeTemplates: null == activeTemplates
                ? _value.activeTemplates
                : activeTemplates // ignore: cast_nullable_to_non_nullable
                      as int,
            premiumTemplates: null == premiumTemplates
                ? _value.premiumTemplates
                : premiumTemplates // ignore: cast_nullable_to_non_nullable
                      as int,
            categoriesCount: null == categoriesCount
                ? _value.categoriesCount
                : categoriesCount // ignore: cast_nullable_to_non_nullable
                      as int,
            recentTemplates: null == recentTemplates
                ? _value.recentTemplates
                : recentTemplates // ignore: cast_nullable_to_non_nullable
                      as List<Map<String, dynamic>>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DashboardStatsImplCopyWith<$Res>
    implements $DashboardStatsCopyWith<$Res> {
  factory _$$DashboardStatsImplCopyWith(
    _$DashboardStatsImpl value,
    $Res Function(_$DashboardStatsImpl) then,
  ) = __$$DashboardStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int totalTemplates,
    int activeTemplates,
    int premiumTemplates,
    int categoriesCount,
    List<Map<String, dynamic>> recentTemplates,
  });
}

/// @nodoc
class __$$DashboardStatsImplCopyWithImpl<$Res>
    extends _$DashboardStatsCopyWithImpl<$Res, _$DashboardStatsImpl>
    implements _$$DashboardStatsImplCopyWith<$Res> {
  __$$DashboardStatsImplCopyWithImpl(
    _$DashboardStatsImpl _value,
    $Res Function(_$DashboardStatsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DashboardStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalTemplates = null,
    Object? activeTemplates = null,
    Object? premiumTemplates = null,
    Object? categoriesCount = null,
    Object? recentTemplates = null,
  }) {
    return _then(
      _$DashboardStatsImpl(
        totalTemplates: null == totalTemplates
            ? _value.totalTemplates
            : totalTemplates // ignore: cast_nullable_to_non_nullable
                  as int,
        activeTemplates: null == activeTemplates
            ? _value.activeTemplates
            : activeTemplates // ignore: cast_nullable_to_non_nullable
                  as int,
        premiumTemplates: null == premiumTemplates
            ? _value.premiumTemplates
            : premiumTemplates // ignore: cast_nullable_to_non_nullable
                  as int,
        categoriesCount: null == categoriesCount
            ? _value.categoriesCount
            : categoriesCount // ignore: cast_nullable_to_non_nullable
                  as int,
        recentTemplates: null == recentTemplates
            ? _value._recentTemplates
            : recentTemplates // ignore: cast_nullable_to_non_nullable
                  as List<Map<String, dynamic>>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DashboardStatsImpl implements _DashboardStats {
  const _$DashboardStatsImpl({
    this.totalTemplates = 0,
    this.activeTemplates = 0,
    this.premiumTemplates = 0,
    this.categoriesCount = 0,
    final List<Map<String, dynamic>> recentTemplates = const [],
  }) : _recentTemplates = recentTemplates;

  factory _$DashboardStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$DashboardStatsImplFromJson(json);

  @override
  @JsonKey()
  final int totalTemplates;
  @override
  @JsonKey()
  final int activeTemplates;
  @override
  @JsonKey()
  final int premiumTemplates;
  @override
  @JsonKey()
  final int categoriesCount;
  final List<Map<String, dynamic>> _recentTemplates;
  @override
  @JsonKey()
  List<Map<String, dynamic>> get recentTemplates {
    if (_recentTemplates is EqualUnmodifiableListView) return _recentTemplates;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recentTemplates);
  }

  @override
  String toString() {
    return 'DashboardStats(totalTemplates: $totalTemplates, activeTemplates: $activeTemplates, premiumTemplates: $premiumTemplates, categoriesCount: $categoriesCount, recentTemplates: $recentTemplates)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DashboardStatsImpl &&
            (identical(other.totalTemplates, totalTemplates) ||
                other.totalTemplates == totalTemplates) &&
            (identical(other.activeTemplates, activeTemplates) ||
                other.activeTemplates == activeTemplates) &&
            (identical(other.premiumTemplates, premiumTemplates) ||
                other.premiumTemplates == premiumTemplates) &&
            (identical(other.categoriesCount, categoriesCount) ||
                other.categoriesCount == categoriesCount) &&
            const DeepCollectionEquality().equals(
              other._recentTemplates,
              _recentTemplates,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    totalTemplates,
    activeTemplates,
    premiumTemplates,
    categoriesCount,
    const DeepCollectionEquality().hash(_recentTemplates),
  );

  /// Create a copy of DashboardStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DashboardStatsImplCopyWith<_$DashboardStatsImpl> get copyWith =>
      __$$DashboardStatsImplCopyWithImpl<_$DashboardStatsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$DashboardStatsImplToJson(this);
  }
}

abstract class _DashboardStats implements DashboardStats {
  const factory _DashboardStats({
    final int totalTemplates,
    final int activeTemplates,
    final int premiumTemplates,
    final int categoriesCount,
    final List<Map<String, dynamic>> recentTemplates,
  }) = _$DashboardStatsImpl;

  factory _DashboardStats.fromJson(Map<String, dynamic> json) =
      _$DashboardStatsImpl.fromJson;

  @override
  int get totalTemplates;
  @override
  int get activeTemplates;
  @override
  int get premiumTemplates;
  @override
  int get categoriesCount;
  @override
  List<Map<String, dynamic>> get recentTemplates;

  /// Create a copy of DashboardStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DashboardStatsImplCopyWith<_$DashboardStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
