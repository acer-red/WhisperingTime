//
//  Generated code. Do not modify.
//  source: whisperingtime.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

class BasicResponse extends $pb.GeneratedMessage {
  factory BasicResponse({
    $core.int? err,
    $core.String? msg,
  }) {
    final $result = create();
    if (err != null) {
      $result.err = err;
    }
    if (msg != null) {
      $result.msg = msg;
    }
    return $result;
  }
  BasicResponse._() : super();
  factory BasicResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory BasicResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BasicResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'whisperingtime'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'err', $pb.PbFieldType.O3)
    ..aOS(2, _omitFieldNames ? '' : 'msg')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  BasicResponse clone() => BasicResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  BasicResponse copyWith(void Function(BasicResponse) updates) => super.copyWith((message) => updates(message as BasicResponse)) as BasicResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BasicResponse create() => BasicResponse._();
  BasicResponse createEmptyInstance() => create();
  static $pb.PbList<BasicResponse> createRepeated() => $pb.PbList<BasicResponse>();
  @$core.pragma('dart2js:noInline')
  static BasicResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BasicResponse>(create);
  static BasicResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get err => $_getIZ(0);
  @$pb.TagNumber(1)
  set err($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasErr() => $_has(0);
  @$pb.TagNumber(1)
  void clearErr() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get msg => $_getSZ(1);
  @$pb.TagNumber(2)
  set msg($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMsg() => $_has(1);
  @$pb.TagNumber(2)
  void clearMsg() => clearField(2);
}

class Empty extends $pb.GeneratedMessage {
  factory Empty() => create();
  Empty._() : super();
  factory Empty.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Empty.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Empty', package: const $pb.PackageName(_omitMessageNames ? '' : 'whisperingtime'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Empty clone() => Empty()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Empty copyWith(void Function(Empty) updates) => super.copyWith((message) => updates(message as Empty)) as Empty;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Empty create() => Empty._();
  Empty createEmptyInstance() => create();
  static $pb.PbList<Empty> createRepeated() => $pb.PbList<Empty>();
  @$core.pragma('dart2js:noInline')
  static Empty getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Empty>(create);
  static Empty? _defaultInstance;
}

/// Theme models
class ThemeSummary extends $pb.GeneratedMessage {
  factory ThemeSummary({
    $core.String? id,
    $core.List<$core.int>? name,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (name != null) {
      $result.name = name;
    }
    return $result;
  }
  ThemeSummary._() : super();
  factory ThemeSummary.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ThemeSummary.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ThemeSummary', package: const $pb.PackageName(_omitMessageNames ? '' : 'whisperingtime'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..a<$core.List<$core.int>>(2, _omitFieldNames ? '' : 'name', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ThemeSummary clone() => ThemeSummary()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ThemeSummary copyWith(void Function(ThemeSummary) updates) => super.copyWith((message) => updates(message as ThemeSummary)) as ThemeSummary;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ThemeSummary create() => ThemeSummary._();
  ThemeSummary createEmptyInstance() => create();
  static $pb.PbList<ThemeSummary> createRepeated() => $pb.PbList<ThemeSummary>();
  @$core.pragma('dart2js:noInline')
  static ThemeSummary getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ThemeSummary>(create);
  static ThemeSummary? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get name => $_getN(1);
  @$pb.TagNumber(2)
  set name($core.List<$core.int> v) { $_setBytes(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => clearField(2);
}

class PermissionEnvelope extends $pb.GeneratedMessage {
  factory PermissionEnvelope({
    $core.List<$core.int>? encryptedKey,
    $core.String? role,
  }) {
    final $result = create();
    if (encryptedKey != null) {
      $result.encryptedKey = encryptedKey;
    }
    if (role != null) {
      $result.role = role;
    }
    return $result;
  }
  PermissionEnvelope._() : super();
  factory PermissionEnvelope.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PermissionEnvelope.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PermissionEnvelope', package: const $pb.PackageName(_omitMessageNames ? '' : 'whisperingtime'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, _omitFieldNames ? '' : 'encryptedKey', $pb.PbFieldType.OY)
    ..aOS(2, _omitFieldNames ? '' : 'role')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PermissionEnvelope clone() => PermissionEnvelope()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PermissionEnvelope copyWith(void Function(PermissionEnvelope) updates) => super.copyWith((message) => updates(message as PermissionEnvelope)) as PermissionEnvelope;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PermissionEnvelope create() => PermissionEnvelope._();
  PermissionEnvelope createEmptyInstance() => create();
  static $pb.PbList<PermissionEnvelope> createRepeated() => $pb.PbList<PermissionEnvelope>();
  @$core.pragma('dart2js:noInline')
  static PermissionEnvelope getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PermissionEnvelope>(create);
  static PermissionEnvelope? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get encryptedKey => $_getN(0);
  @$pb.TagNumber(1)
  set encryptedKey($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasEncryptedKey() => $_has(0);
  @$pb.TagNumber(1)
  void clearEncryptedKey() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get role => $_getSZ(1);
  @$pb.TagNumber(2)
  set role($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasRole() => $_has(1);
  @$pb.TagNumber(2)
  void clearRole() => clearField(2);
}

class GroupConfig extends $pb.GeneratedMessage {
  factory GroupConfig({
    $core.Iterable<$core.bool>? levels,
    $core.int? viewType,
    $core.int? sortType,
    $core.int? autoFreezeDays,
  }) {
    final $result = create();
    if (levels != null) {
      $result.levels.addAll(levels);
    }
    if (viewType != null) {
      $result.viewType = viewType;
    }
    if (sortType != null) {
      $result.sortType = sortType;
    }
    if (autoFreezeDays != null) {
      $result.autoFreezeDays = autoFreezeDays;
    }
    return $result;
  }
  GroupConfig._() : super();
  factory GroupConfig.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GroupConfig.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GroupConfig', package: const $pb.PackageName(_omitMessageNames ? '' : 'whisperingtime'), createEmptyInstance: create)
    ..p<$core.bool>(3, _omitFieldNames ? '' : 'levels', $pb.PbFieldType.KB)
    ..a<$core.int>(4, _omitFieldNames ? '' : 'viewType', $pb.PbFieldType.O3)
    ..a<$core.int>(5, _omitFieldNames ? '' : 'sortType', $pb.PbFieldType.O3)
    ..a<$core.int>(6, _omitFieldNames ? '' : 'autoFreezeDays', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GroupConfig clone() => GroupConfig()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GroupConfig copyWith(void Function(GroupConfig) updates) => super.copyWith((message) => updates(message as GroupConfig)) as GroupConfig;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GroupConfig create() => GroupConfig._();
  GroupConfig createEmptyInstance() => create();
  static $pb.PbList<GroupConfig> createRepeated() => $pb.PbList<GroupConfig>();
  @$core.pragma('dart2js:noInline')
  static GroupConfig getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GroupConfig>(create);
  static GroupConfig? _defaultInstance;

  @$pb.TagNumber(3)
  $core.List<$core.bool> get levels => $_getList(0);

  @$pb.TagNumber(4)
  $core.int get viewType => $_getIZ(1);
  @$pb.TagNumber(4)
  set viewType($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(4)
  $core.bool hasViewType() => $_has(1);
  @$pb.TagNumber(4)
  void clearViewType() => clearField(4);

  @$pb.TagNumber(5)
  $core.int get sortType => $_getIZ(2);
  @$pb.TagNumber(5)
  set sortType($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(5)
  $core.bool hasSortType() => $_has(2);
  @$pb.TagNumber(5)
  void clearSortType() => clearField(5);

  @$pb.TagNumber(6)
  $core.int get autoFreezeDays => $_getIZ(3);
  @$pb.TagNumber(6)
  set autoFreezeDays($core.int v) { $_setSignedInt32(3, v); }
  @$pb.TagNumber(6)
  $core.bool hasAutoFreezeDays() => $_has(3);
  @$pb.TagNumber(6)
  void clearAutoFreezeDays() => clearField(6);
}

class DocConfig extends $pb.GeneratedMessage {
  factory DocConfig({
    $core.bool? isShowTool,
    $core.int? displayPriority,
  }) {
    final $result = create();
    if (isShowTool != null) {
      $result.isShowTool = isShowTool;
    }
    if (displayPriority != null) {
      $result.displayPriority = displayPriority;
    }
    return $result;
  }
  DocConfig._() : super();
  factory DocConfig.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DocConfig.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DocConfig', package: const $pb.PackageName(_omitMessageNames ? '' : 'whisperingtime'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'isShowTool')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'displayPriority', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DocConfig clone() => DocConfig()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DocConfig copyWith(void Function(DocConfig) updates) => super.copyWith((message) => updates(message as DocConfig)) as DocConfig;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DocConfig create() => DocConfig._();
  DocConfig createEmptyInstance() => create();
  static $pb.PbList<DocConfig> createRepeated() => $pb.PbList<DocConfig>();
  @$core.pragma('dart2js:noInline')
  static DocConfig getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DocConfig>(create);
  static DocConfig? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get isShowTool => $_getBF(0);
  @$pb.TagNumber(1)
  set isShowTool($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasIsShowTool() => $_has(0);
  @$pb.TagNumber(1)
  void clearIsShowTool() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get displayPriority => $_getIZ(1);
  @$pb.TagNumber(2)
  set displayPriority($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasDisplayPriority() => $_has(1);
  @$pb.TagNumber(2)
  void clearDisplayPriority() => clearField(2);
}

class GroupSummary extends $pb.GeneratedMessage {
  factory GroupSummary({
    $core.String? id,
    $core.List<$core.int>? name,
    $fixnum.Int64? createAt,
    $fixnum.Int64? updateAt,
    $fixnum.Int64? overAt,
    GroupConfig? config,
    PermissionEnvelope? permission,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (name != null) {
      $result.name = name;
    }
    if (createAt != null) {
      $result.createAt = createAt;
    }
    if (updateAt != null) {
      $result.updateAt = updateAt;
    }
    if (overAt != null) {
      $result.overAt = overAt;
    }
    if (config != null) {
      $result.config = config;
    }
    if (permission != null) {
      $result.permission = permission;
    }
    return $result;
  }
  GroupSummary._() : super();
  factory GroupSummary.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GroupSummary.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GroupSummary', package: const $pb.PackageName(_omitMessageNames ? '' : 'whisperingtime'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..a<$core.List<$core.int>>(2, _omitFieldNames ? '' : 'name', $pb.PbFieldType.OY)
    ..aInt64(3, _omitFieldNames ? '' : 'createAt')
    ..aInt64(4, _omitFieldNames ? '' : 'updateAt')
    ..aInt64(5, _omitFieldNames ? '' : 'overAt')
    ..aOM<GroupConfig>(6, _omitFieldNames ? '' : 'config', subBuilder: GroupConfig.create)
    ..aOM<PermissionEnvelope>(7, _omitFieldNames ? '' : 'permission', subBuilder: PermissionEnvelope.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GroupSummary clone() => GroupSummary()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GroupSummary copyWith(void Function(GroupSummary) updates) => super.copyWith((message) => updates(message as GroupSummary)) as GroupSummary;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GroupSummary create() => GroupSummary._();
  GroupSummary createEmptyInstance() => create();
  static $pb.PbList<GroupSummary> createRepeated() => $pb.PbList<GroupSummary>();
  @$core.pragma('dart2js:noInline')
  static GroupSummary getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GroupSummary>(create);
  static GroupSummary? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get name => $_getN(1);
  @$pb.TagNumber(2)
  set name($core.List<$core.int> v) { $_setBytes(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get createAt => $_getI64(2);
  @$pb.TagNumber(3)
  set createAt($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasCreateAt() => $_has(2);
  @$pb.TagNumber(3)
  void clearCreateAt() => clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get updateAt => $_getI64(3);
  @$pb.TagNumber(4)
  set updateAt($fixnum.Int64 v) { $_setInt64(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasUpdateAt() => $_has(3);
  @$pb.TagNumber(4)
  void clearUpdateAt() => clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get overAt => $_getI64(4);
  @$pb.TagNumber(5)
  set overAt($fixnum.Int64 v) { $_setInt64(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasOverAt() => $_has(4);
  @$pb.TagNumber(5)
  void clearOverAt() => clearField(5);

  @$pb.TagNumber(6)
  GroupConfig get config => $_getN(5);
  @$pb.TagNumber(6)
  set config(GroupConfig v) { setField(6, v); }
  @$pb.TagNumber(6)
  $core.bool hasConfig() => $_has(5);
  @$pb.TagNumber(6)
  void clearConfig() => clearField(6);
  @$pb.TagNumber(6)
  GroupConfig ensureConfig() => $_ensure(5);

  @$pb.TagNumber(7)
  PermissionEnvelope get permission => $_getN(6);
  @$pb.TagNumber(7)
  set permission(PermissionEnvelope v) { setField(7, v); }
  @$pb.TagNumber(7)
  $core.bool hasPermission() => $_has(6);
  @$pb.TagNumber(7)
  void clearPermission() => clearField(7);
  @$pb.TagNumber(7)
  PermissionEnvelope ensurePermission() => $_ensure(6);
}

class DocSummary extends $pb.GeneratedMessage {
  factory DocSummary({
    $core.String? id,
    Content? content,
    $fixnum.Int64? createAt,
    $fixnum.Int64? updateAt,
    PermissionEnvelope? permission,
    DocConfig? config,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (content != null) {
      $result.content = content;
    }
    if (createAt != null) {
      $result.createAt = createAt;
    }
    if (updateAt != null) {
      $result.updateAt = updateAt;
    }
    if (permission != null) {
      $result.permission = permission;
    }
    if (config != null) {
      $result.config = config;
    }
    return $result;
  }
  DocSummary._() : super();
  factory DocSummary.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DocSummary.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DocSummary', package: const $pb.PackageName(_omitMessageNames ? '' : 'whisperingtime'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOM<Content>(2, _omitFieldNames ? '' : 'content', subBuilder: Content.create)
    ..aInt64(5, _omitFieldNames ? '' : 'createAt')
    ..aInt64(6, _omitFieldNames ? '' : 'updateAt')
    ..aOM<PermissionEnvelope>(7, _omitFieldNames ? '' : 'permission', subBuilder: PermissionEnvelope.create)
    ..aOM<DocConfig>(8, _omitFieldNames ? '' : 'config', subBuilder: DocConfig.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DocSummary clone() => DocSummary()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DocSummary copyWith(void Function(DocSummary) updates) => super.copyWith((message) => updates(message as DocSummary)) as DocSummary;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DocSummary create() => DocSummary._();
  DocSummary createEmptyInstance() => create();
  static $pb.PbList<DocSummary> createRepeated() => $pb.PbList<DocSummary>();
  @$core.pragma('dart2js:noInline')
  static DocSummary getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DocSummary>(create);
  static DocSummary? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  Content get content => $_getN(1);
  @$pb.TagNumber(2)
  set content(Content v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasContent() => $_has(1);
  @$pb.TagNumber(2)
  void clearContent() => clearField(2);
  @$pb.TagNumber(2)
  Content ensureContent() => $_ensure(1);

  @$pb.TagNumber(5)
  $fixnum.Int64 get createAt => $_getI64(2);
  @$pb.TagNumber(5)
  set createAt($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(5)
  $core.bool hasCreateAt() => $_has(2);
  @$pb.TagNumber(5)
  void clearCreateAt() => clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get updateAt => $_getI64(3);
  @$pb.TagNumber(6)
  set updateAt($fixnum.Int64 v) { $_setInt64(3, v); }
  @$pb.TagNumber(6)
  $core.bool hasUpdateAt() => $_has(3);
  @$pb.TagNumber(6)
  void clearUpdateAt() => clearField(6);

  @$pb.TagNumber(7)
  PermissionEnvelope get permission => $_getN(4);
  @$pb.TagNumber(7)
  set permission(PermissionEnvelope v) { setField(7, v); }
  @$pb.TagNumber(7)
  $core.bool hasPermission() => $_has(4);
  @$pb.TagNumber(7)
  void clearPermission() => clearField(7);
  @$pb.TagNumber(7)
  PermissionEnvelope ensurePermission() => $_ensure(4);

  @$pb.TagNumber(8)
  DocConfig get config => $_getN(5);
  @$pb.TagNumber(8)
  set config(DocConfig v) { setField(8, v); }
  @$pb.TagNumber(8)
  $core.bool hasConfig() => $_has(5);
  @$pb.TagNumber(8)
  void clearConfig() => clearField(8);
  @$pb.TagNumber(8)
  DocConfig ensureConfig() => $_ensure(5);
}

class Content extends $pb.GeneratedMessage {
  factory Content({
    $core.List<$core.int>? title,
    $core.List<$core.int>? rich,
    $core.List<$core.int>? level,
    $core.List<$core.int>? scales,
  }) {
    final $result = create();
    if (title != null) {
      $result.title = title;
    }
    if (rich != null) {
      $result.rich = rich;
    }
    if (level != null) {
      $result.level = level;
    }
    if (scales != null) {
      $result.scales = scales;
    }
    return $result;
  }
  Content._() : super();
  factory Content.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Content.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Content', package: const $pb.PackageName(_omitMessageNames ? '' : 'whisperingtime'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, _omitFieldNames ? '' : 'title', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(2, _omitFieldNames ? '' : 'rich', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(3, _omitFieldNames ? '' : 'level', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(4, _omitFieldNames ? '' : 'scales', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Content clone() => Content()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Content copyWith(void Function(Content) updates) => super.copyWith((message) => updates(message as Content)) as Content;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Content create() => Content._();
  Content createEmptyInstance() => create();
  static $pb.PbList<Content> createRepeated() => $pb.PbList<Content>();
  @$core.pragma('dart2js:noInline')
  static Content getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Content>(create);
  static Content? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get title => $_getN(0);
  @$pb.TagNumber(1)
  set title($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTitle() => $_has(0);
  @$pb.TagNumber(1)
  void clearTitle() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get rich => $_getN(1);
  @$pb.TagNumber(2)
  set rich($core.List<$core.int> v) { $_setBytes(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasRich() => $_has(1);
  @$pb.TagNumber(2)
  void clearRich() => clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get level => $_getN(2);
  @$pb.TagNumber(3)
  set level($core.List<$core.int> v) { $_setBytes(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasLevel() => $_has(2);
  @$pb.TagNumber(3)
  void clearLevel() => clearField(3);

  @$pb.TagNumber(4)
  $core.List<$core.int> get scales => $_getN(3);
  @$pb.TagNumber(4)
  set scales($core.List<$core.int> v) { $_setBytes(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasScales() => $_has(3);
  @$pb.TagNumber(4)
  void clearScales() => clearField(4);
}

class DocDetail extends $pb.GeneratedMessage {
  factory DocDetail({
    $core.String? id,
    Content? content,
    $fixnum.Int64? createAt,
    $fixnum.Int64? updateAt,
    PermissionEnvelope? permission,
    DocConfig? config,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (content != null) {
      $result.content = content;
    }
    if (createAt != null) {
      $result.createAt = createAt;
    }
    if (updateAt != null) {
      $result.updateAt = updateAt;
    }
    if (permission != null) {
      $result.permission = permission;
    }
    if (config != null) {
      $result.config = config;
    }
    return $result;
  }
  DocDetail._() : super();
  factory DocDetail.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DocDetail.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DocDetail', package: const $pb.PackageName(_omitMessageNames ? '' : 'whisperingtime'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOM<Content>(2, _omitFieldNames ? '' : 'content', subBuilder: Content.create)
    ..aInt64(6, _omitFieldNames ? '' : 'createAt')
    ..aInt64(7, _omitFieldNames ? '' : 'updateAt')
    ..aOM<PermissionEnvelope>(8, _omitFieldNames ? '' : 'permission', subBuilder: PermissionEnvelope.create)
    ..aOM<DocConfig>(9, _omitFieldNames ? '' : 'config', subBuilder: DocConfig.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DocDetail clone() => DocDetail()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DocDetail copyWith(void Function(DocDetail) updates) => super.copyWith((message) => updates(message as DocDetail)) as DocDetail;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DocDetail create() => DocDetail._();
  DocDetail createEmptyInstance() => create();
  static $pb.PbList<DocDetail> createRepeated() => $pb.PbList<DocDetail>();
  @$core.pragma('dart2js:noInline')
  static DocDetail getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DocDetail>(create);
  static DocDetail? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  Content get content => $_getN(1);
  @$pb.TagNumber(2)
  set content(Content v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasContent() => $_has(1);
  @$pb.TagNumber(2)
  void clearContent() => clearField(2);
  @$pb.TagNumber(2)
  Content ensureContent() => $_ensure(1);

  @$pb.TagNumber(6)
  $fixnum.Int64 get createAt => $_getI64(2);
  @$pb.TagNumber(6)
  set createAt($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(6)
  $core.bool hasCreateAt() => $_has(2);
  @$pb.TagNumber(6)
  void clearCreateAt() => clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get updateAt => $_getI64(3);
  @$pb.TagNumber(7)
  set updateAt($fixnum.Int64 v) { $_setInt64(3, v); }
  @$pb.TagNumber(7)
  $core.bool hasUpdateAt() => $_has(3);
  @$pb.TagNumber(7)
  void clearUpdateAt() => clearField(7);

  @$pb.TagNumber(8)
  PermissionEnvelope get permission => $_getN(4);
  @$pb.TagNumber(8)
  set permission(PermissionEnvelope v) { setField(8, v); }
  @$pb.TagNumber(8)
  $core.bool hasPermission() => $_has(4);
  @$pb.TagNumber(8)
  void clearPermission() => clearField(8);
  @$pb.TagNumber(8)
  PermissionEnvelope ensurePermission() => $_ensure(4);

  @$pb.TagNumber(9)
  DocConfig get config => $_getN(5);
  @$pb.TagNumber(9)
  set config(DocConfig v) { setField(9, v); }
  @$pb.TagNumber(9)
  $core.bool hasConfig() => $_has(5);
  @$pb.TagNumber(9)
  void clearConfig() => clearField(9);
  @$pb.TagNumber(9)
  DocConfig ensureConfig() => $_ensure(5);
}

class GroupDetail extends $pb.GeneratedMessage {
  factory GroupDetail({
    $core.String? id,
    $core.List<$core.int>? name,
    GroupConfig? config,
    $core.Iterable<DocDetail>? docs,
    PermissionEnvelope? permission,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (name != null) {
      $result.name = name;
    }
    if (config != null) {
      $result.config = config;
    }
    if (docs != null) {
      $result.docs.addAll(docs);
    }
    if (permission != null) {
      $result.permission = permission;
    }
    return $result;
  }
  GroupDetail._() : super();
  factory GroupDetail.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GroupDetail.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GroupDetail', package: const $pb.PackageName(_omitMessageNames ? '' : 'whisperingtime'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..a<$core.List<$core.int>>(2, _omitFieldNames ? '' : 'name', $pb.PbFieldType.OY)
    ..aOM<GroupConfig>(3, _omitFieldNames ? '' : 'config', subBuilder: GroupConfig.create)
    ..pc<DocDetail>(4, _omitFieldNames ? '' : 'docs', $pb.PbFieldType.PM, subBuilder: DocDetail.create)
    ..aOM<PermissionEnvelope>(5, _omitFieldNames ? '' : 'permission', subBuilder: PermissionEnvelope.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GroupDetail clone() => GroupDetail()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GroupDetail copyWith(void Function(GroupDetail) updates) => super.copyWith((message) => updates(message as GroupDetail)) as GroupDetail;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GroupDetail create() => GroupDetail._();
  GroupDetail createEmptyInstance() => create();
  static $pb.PbList<GroupDetail> createRepeated() => $pb.PbList<GroupDetail>();
  @$core.pragma('dart2js:noInline')
  static GroupDetail getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GroupDetail>(create);
  static GroupDetail? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get name => $_getN(1);
  @$pb.TagNumber(2)
  set name($core.List<$core.int> v) { $_setBytes(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => clearField(2);

  @$pb.TagNumber(3)
  GroupConfig get config => $_getN(2);
  @$pb.TagNumber(3)
  set config(GroupConfig v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasConfig() => $_has(2);
  @$pb.TagNumber(3)
  void clearConfig() => clearField(3);
  @$pb.TagNumber(3)
  GroupConfig ensureConfig() => $_ensure(2);

  @$pb.TagNumber(4)
  $core.List<DocDetail> get docs => $_getList(3);

  @$pb.TagNumber(5)
  PermissionEnvelope get permission => $_getN(4);
  @$pb.TagNumber(5)
  set permission(PermissionEnvelope v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasPermission() => $_has(4);
  @$pb.TagNumber(5)
  void clearPermission() => clearField(5);
  @$pb.TagNumber(5)
  PermissionEnvelope ensurePermission() => $_ensure(4);
}

class ThemeDetail extends $pb.GeneratedMessage {
  factory ThemeDetail({
    $core.String? id,
    $core.List<$core.int>? name,
    $core.Iterable<GroupDetail>? groups,
    PermissionEnvelope? permission,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (name != null) {
      $result.name = name;
    }
    if (groups != null) {
      $result.groups.addAll(groups);
    }
    if (permission != null) {
      $result.permission = permission;
    }
    return $result;
  }
  ThemeDetail._() : super();
  factory ThemeDetail.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ThemeDetail.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ThemeDetail', package: const $pb.PackageName(_omitMessageNames ? '' : 'whisperingtime'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..a<$core.List<$core.int>>(2, _omitFieldNames ? '' : 'name', $pb.PbFieldType.OY)
    ..pc<GroupDetail>(3, _omitFieldNames ? '' : 'groups', $pb.PbFieldType.PM, subBuilder: GroupDetail.create)
    ..aOM<PermissionEnvelope>(4, _omitFieldNames ? '' : 'permission', subBuilder: PermissionEnvelope.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ThemeDetail clone() => ThemeDetail()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ThemeDetail copyWith(void Function(ThemeDetail) updates) => super.copyWith((message) => updates(message as ThemeDetail)) as ThemeDetail;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ThemeDetail create() => ThemeDetail._();
  ThemeDetail createEmptyInstance() => create();
  static $pb.PbList<ThemeDetail> createRepeated() => $pb.PbList<ThemeDetail>();
  @$core.pragma('dart2js:noInline')
  static ThemeDetail getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ThemeDetail>(create);
  static ThemeDetail? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get name => $_getN(1);
  @$pb.TagNumber(2)
  set name($core.List<$core.int> v) { $_setBytes(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => clearField(2);

  @$pb.TagNumber(3)
  $core.List<GroupDetail> get groups => $_getList(2);

  @$pb.TagNumber(4)
  PermissionEnvelope get permission => $_getN(3);
  @$pb.TagNumber(4)
  set permission(PermissionEnvelope v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasPermission() => $_has(3);
  @$pb.TagNumber(4)
  void clearPermission() => clearField(4);
  @$pb.TagNumber(4)
  PermissionEnvelope ensurePermission() => $_ensure(3);
}

/// Theme service
class ListThemesRequest extends $pb.GeneratedMessage {
  factory ListThemesRequest({
    $core.bool? includeDocs,
    $core.bool? includeDetail,
  }) {
    final $result = create();
    if (includeDocs != null) {
      $result.includeDocs = includeDocs;
    }
    if (includeDetail != null) {
      $result.includeDetail = includeDetail;
    }
    return $result;
  }
  ListThemesRequest._() : super();
  factory ListThemesRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListThemesRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListThemesRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'whisperingtime'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'includeDocs')
    ..aOB(2, _omitFieldNames ? '' : 'includeDetail')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListThemesRequest clone() => ListThemesRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListThemesRequest copyWith(void Function(ListThemesRequest) updates) => super.copyWith((message) => updates(message as ListThemesRequest)) as ListThemesRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListThemesRequest create() => ListThemesRequest._();
  ListThemesRequest createEmptyInstance() => create();
  static $pb.PbList<ListThemesRequest> createRepeated() => $pb.PbList<ListThemesRequest>();
  @$core.pragma('dart2js:noInline')
  static ListThemesRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListThemesRequest>(create);
  static ListThemesRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get includeDocs => $_getBF(0);
  @$pb.TagNumber(1)
  set includeDocs($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasIncludeDocs() => $_has(0);
  @$pb.TagNumber(1)
  void clearIncludeDocs() => clearField(1);

  @$pb.TagNumber(2)
  $core.bool get includeDetail => $_getBF(1);
  @$pb.TagNumber(2)
  set includeDetail($core.bool v) { $_setBool(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasIncludeDetail() => $_has(1);
  @$pb.TagNumber(2)
  void clearIncludeDetail() => clearField(2);
}

class ListThemesResponse extends $pb.GeneratedMessage {
  factory ListThemesResponse({
    $core.int? err,
    $core.String? msg,
    $core.Iterable<ThemeDetail>? themes,
  }) {
    final $result = create();
    if (err != null) {
      $result.err = err;
    }
    if (msg != null) {
      $result.msg = msg;
    }
    if (themes != null) {
      $result.themes.addAll(themes);
    }
    return $result;
  }
  ListThemesResponse._() : super();
  factory ListThemesResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListThemesResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListThemesResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'whisperingtime'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'err', $pb.PbFieldType.O3)
    ..aOS(2, _omitFieldNames ? '' : 'msg')
    ..pc<ThemeDetail>(3, _omitFieldNames ? '' : 'themes', $pb.PbFieldType.PM, subBuilder: ThemeDetail.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListThemesResponse clone() => ListThemesResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListThemesResponse copyWith(void Function(ListThemesResponse) updates) => super.copyWith((message) => updates(message as ListThemesResponse)) as ListThemesResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListThemesResponse create() => ListThemesResponse._();
  ListThemesResponse createEmptyInstance() => create();
  static $pb.PbList<ListThemesResponse> createRepeated() => $pb.PbList<ListThemesResponse>();
  @$core.pragma('dart2js:noInline')
  static ListThemesResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListThemesResponse>(create);
  static ListThemesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get err => $_getIZ(0);
  @$pb.TagNumber(1)
  set err($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasErr() => $_has(0);
  @$pb.TagNumber(1)
  void clearErr() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get msg => $_getSZ(1);
  @$pb.TagNumber(2)
  set msg($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMsg() => $_has(1);
  @$pb.TagNumber(2)
  void clearMsg() => clearField(2);

  @$pb.TagNumber(3)
  $core.List<ThemeDetail> get themes => $_getList(2);
}

class CreateThemeRequest extends $pb.GeneratedMessage {
  factory CreateThemeRequest({
    $core.List<$core.int>? name,
    $core.List<$core.int>? defaultGroupName,
    $core.List<$core.int>? encryptedKey,
    $core.List<$core.int>? defaultGroupEncryptedKey,
  }) {
    final $result = create();
    if (name != null) {
      $result.name = name;
    }
    if (defaultGroupName != null) {
      $result.defaultGroupName = defaultGroupName;
    }
    if (encryptedKey != null) {
      $result.encryptedKey = encryptedKey;
    }
    if (defaultGroupEncryptedKey != null) {
      $result.defaultGroupEncryptedKey = defaultGroupEncryptedKey;
    }
    return $result;
  }
  CreateThemeRequest._() : super();
  factory CreateThemeRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreateThemeRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateThemeRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'whisperingtime'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, _omitFieldNames ? '' : 'name', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(2, _omitFieldNames ? '' : 'defaultGroupName', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(3, _omitFieldNames ? '' : 'encryptedKey', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(4, _omitFieldNames ? '' : 'defaultGroupEncryptedKey', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreateThemeRequest clone() => CreateThemeRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreateThemeRequest copyWith(void Function(CreateThemeRequest) updates) => super.copyWith((message) => updates(message as CreateThemeRequest)) as CreateThemeRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateThemeRequest create() => CreateThemeRequest._();
  CreateThemeRequest createEmptyInstance() => create();
  static $pb.PbList<CreateThemeRequest> createRepeated() => $pb.PbList<CreateThemeRequest>();
  @$core.pragma('dart2js:noInline')
  static CreateThemeRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateThemeRequest>(create);
  static CreateThemeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get name => $_getN(0);
  @$pb.TagNumber(1)
  set name($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get defaultGroupName => $_getN(1);
  @$pb.TagNumber(2)
  set defaultGroupName($core.List<$core.int> v) { $_setBytes(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasDefaultGroupName() => $_has(1);
  @$pb.TagNumber(2)
  void clearDefaultGroupName() => clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get encryptedKey => $_getN(2);
  @$pb.TagNumber(3)
  set encryptedKey($core.List<$core.int> v) { $_setBytes(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasEncryptedKey() => $_has(2);
  @$pb.TagNumber(3)
  void clearEncryptedKey() => clearField(3);

  @$pb.TagNumber(4)
  $core.List<$core.int> get defaultGroupEncryptedKey => $_getN(3);
  @$pb.TagNumber(4)
  set defaultGroupEncryptedKey($core.List<$core.int> v) { $_setBytes(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasDefaultGroupEncryptedKey() => $_has(3);
  @$pb.TagNumber(4)
  void clearDefaultGroupEncryptedKey() => clearField(4);
}

class CreateThemeResponse extends $pb.GeneratedMessage {
  factory CreateThemeResponse({
    $core.int? err,
    $core.String? msg,
    $core.String? id,
  }) {
    final $result = create();
    if (err != null) {
      $result.err = err;
    }
    if (msg != null) {
      $result.msg = msg;
    }
    if (id != null) {
      $result.id = id;
    }
    return $result;
  }
  CreateThemeResponse._() : super();
  factory CreateThemeResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreateThemeResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateThemeResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'whisperingtime'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'err', $pb.PbFieldType.O3)
    ..aOS(2, _omitFieldNames ? '' : 'msg')
    ..aOS(3, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreateThemeResponse clone() => CreateThemeResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreateThemeResponse copyWith(void Function(CreateThemeResponse) updates) => super.copyWith((message) => updates(message as CreateThemeResponse)) as CreateThemeResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateThemeResponse create() => CreateThemeResponse._();
  CreateThemeResponse createEmptyInstance() => create();
  static $pb.PbList<CreateThemeResponse> createRepeated() => $pb.PbList<CreateThemeResponse>();
  @$core.pragma('dart2js:noInline')
  static CreateThemeResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateThemeResponse>(create);
  static CreateThemeResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get err => $_getIZ(0);
  @$pb.TagNumber(1)
  set err($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasErr() => $_has(0);
  @$pb.TagNumber(1)
  void clearErr() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get msg => $_getSZ(1);
  @$pb.TagNumber(2)
  set msg($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMsg() => $_has(1);
  @$pb.TagNumber(2)
  void clearMsg() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get id => $_getSZ(2);
  @$pb.TagNumber(3)
  set id($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasId() => $_has(2);
  @$pb.TagNumber(3)
  void clearId() => clearField(3);
}

class UpdateThemeRequest extends $pb.GeneratedMessage {
  factory UpdateThemeRequest({
    $core.String? id,
    $core.List<$core.int>? name,
    $core.List<$core.int>? encryptedKey,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (name != null) {
      $result.name = name;
    }
    if (encryptedKey != null) {
      $result.encryptedKey = encryptedKey;
    }
    return $result;
  }
  UpdateThemeRequest._() : super();
  factory UpdateThemeRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UpdateThemeRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UpdateThemeRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'whisperingtime'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..a<$core.List<$core.int>>(2, _omitFieldNames ? '' : 'name', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(3, _omitFieldNames ? '' : 'encryptedKey', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UpdateThemeRequest clone() => UpdateThemeRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UpdateThemeRequest copyWith(void Function(UpdateThemeRequest) updates) => super.copyWith((message) => updates(message as UpdateThemeRequest)) as UpdateThemeRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateThemeRequest create() => UpdateThemeRequest._();
  UpdateThemeRequest createEmptyInstance() => create();
  static $pb.PbList<UpdateThemeRequest> createRepeated() => $pb.PbList<UpdateThemeRequest>();
  @$core.pragma('dart2js:noInline')
  static UpdateThemeRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UpdateThemeRequest>(create);
  static UpdateThemeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get name => $_getN(1);
  @$pb.TagNumber(2)
  set name($core.List<$core.int> v) { $_setBytes(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get encryptedKey => $_getN(2);
  @$pb.TagNumber(3)
  set encryptedKey($core.List<$core.int> v) { $_setBytes(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasEncryptedKey() => $_has(2);
  @$pb.TagNumber(3)
  void clearEncryptedKey() => clearField(3);
}

class DeleteThemeRequest extends $pb.GeneratedMessage {
  factory DeleteThemeRequest({
    $core.String? id,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    return $result;
  }
  DeleteThemeRequest._() : super();
  factory DeleteThemeRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DeleteThemeRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DeleteThemeRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'whisperingtime'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DeleteThemeRequest clone() => DeleteThemeRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DeleteThemeRequest copyWith(void Function(DeleteThemeRequest) updates) => super.copyWith((message) => updates(message as DeleteThemeRequest)) as DeleteThemeRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteThemeRequest create() => DeleteThemeRequest._();
  DeleteThemeRequest createEmptyInstance() => create();
  static $pb.PbList<DeleteThemeRequest> createRepeated() => $pb.PbList<DeleteThemeRequest>();
  @$core.pragma('dart2js:noInline')
  static DeleteThemeRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DeleteThemeRequest>(create);
  static DeleteThemeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);
}

class ExportAllConfigRequest extends $pb.GeneratedMessage {
  factory ExportAllConfigRequest() => create();
  ExportAllConfigRequest._() : super();
  factory ExportAllConfigRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ExportAllConfigRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ExportAllConfigRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'whisperingtime'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ExportAllConfigRequest clone() => ExportAllConfigRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ExportAllConfigRequest copyWith(void Function(ExportAllConfigRequest) updates) => super.copyWith((message) => updates(message as ExportAllConfigRequest)) as ExportAllConfigRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ExportAllConfigRequest create() => ExportAllConfigRequest._();
  ExportAllConfigRequest createEmptyInstance() => create();
  static $pb.PbList<ExportAllConfigRequest> createRepeated() => $pb.PbList<ExportAllConfigRequest>();
  @$core.pragma('dart2js:noInline')
  static ExportAllConfigRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ExportAllConfigRequest>(create);
  static ExportAllConfigRequest? _defaultInstance;
}

class DeleteUserDataRequest extends $pb.GeneratedMessage {
  factory DeleteUserDataRequest() => create();
  DeleteUserDataRequest._() : super();
  factory DeleteUserDataRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DeleteUserDataRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DeleteUserDataRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'whisperingtime'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DeleteUserDataRequest clone() => DeleteUserDataRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DeleteUserDataRequest copyWith(void Function(DeleteUserDataRequest) updates) => super.copyWith((message) => updates(message as DeleteUserDataRequest)) as DeleteUserDataRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteUserDataRequest create() => DeleteUserDataRequest._();
  DeleteUserDataRequest createEmptyInstance() => create();
  static $pb.PbList<DeleteUserDataRequest> createRepeated() => $pb.PbList<DeleteUserDataRequest>();
  @$core.pragma('dart2js:noInline')
  static DeleteUserDataRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DeleteUserDataRequest>(create);
  static DeleteUserDataRequest? _defaultInstance;
}

/// Group service
class ListGroupsRequest extends $pb.GeneratedMessage {
  factory ListGroupsRequest({
    $core.String? themeId,
  }) {
    final $result = create();
    if (themeId != null) {
      $result.themeId = themeId;
    }
    return $result;
  }
  ListGroupsRequest._() : super();
  factory ListGroupsRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListGroupsRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListGroupsRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'whisperingtime'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'themeId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListGroupsRequest clone() => ListGroupsRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListGroupsRequest copyWith(void Function(ListGroupsRequest) updates) => super.copyWith((message) => updates(message as ListGroupsRequest)) as ListGroupsRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListGroupsRequest create() => ListGroupsRequest._();
  ListGroupsRequest createEmptyInstance() => create();
  static $pb.PbList<ListGroupsRequest> createRepeated() => $pb.PbList<ListGroupsRequest>();
  @$core.pragma('dart2js:noInline')
  static ListGroupsRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListGroupsRequest>(create);
  static ListGroupsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get themeId => $_getSZ(0);
  @$pb.TagNumber(1)
  set themeId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasThemeId() => $_has(0);
  @$pb.TagNumber(1)
  void clearThemeId() => clearField(1);
}

class ListGroupsResponse extends $pb.GeneratedMessage {
  factory ListGroupsResponse({
    $core.int? err,
    $core.String? msg,
    $core.Iterable<GroupSummary>? groups,
  }) {
    final $result = create();
    if (err != null) {
      $result.err = err;
    }
    if (msg != null) {
      $result.msg = msg;
    }
    if (groups != null) {
      $result.groups.addAll(groups);
    }
    return $result;
  }
  ListGroupsResponse._() : super();
  factory ListGroupsResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListGroupsResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListGroupsResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'whisperingtime'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'err', $pb.PbFieldType.O3)
    ..aOS(2, _omitFieldNames ? '' : 'msg')
    ..pc<GroupSummary>(3, _omitFieldNames ? '' : 'groups', $pb.PbFieldType.PM, subBuilder: GroupSummary.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListGroupsResponse clone() => ListGroupsResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListGroupsResponse copyWith(void Function(ListGroupsResponse) updates) => super.copyWith((message) => updates(message as ListGroupsResponse)) as ListGroupsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListGroupsResponse create() => ListGroupsResponse._();
  ListGroupsResponse createEmptyInstance() => create();
  static $pb.PbList<ListGroupsResponse> createRepeated() => $pb.PbList<ListGroupsResponse>();
  @$core.pragma('dart2js:noInline')
  static ListGroupsResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListGroupsResponse>(create);
  static ListGroupsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get err => $_getIZ(0);
  @$pb.TagNumber(1)
  set err($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasErr() => $_has(0);
  @$pb.TagNumber(1)
  void clearErr() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get msg => $_getSZ(1);
  @$pb.TagNumber(2)
  set msg($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMsg() => $_has(1);
  @$pb.TagNumber(2)
  void clearMsg() => clearField(2);

  @$pb.TagNumber(3)
  $core.List<GroupSummary> get groups => $_getList(2);
}

class GetGroupRequest extends $pb.GeneratedMessage {
  factory GetGroupRequest({
    $core.String? themeId,
    $core.String? groupId,
    $core.bool? includeDocs,
    $core.bool? includeDetail,
  }) {
    final $result = create();
    if (themeId != null) {
      $result.themeId = themeId;
    }
    if (groupId != null) {
      $result.groupId = groupId;
    }
    if (includeDocs != null) {
      $result.includeDocs = includeDocs;
    }
    if (includeDetail != null) {
      $result.includeDetail = includeDetail;
    }
    return $result;
  }
  GetGroupRequest._() : super();
  factory GetGroupRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetGroupRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetGroupRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'whisperingtime'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'themeId')
    ..aOS(2, _omitFieldNames ? '' : 'groupId')
    ..aOB(3, _omitFieldNames ? '' : 'includeDocs')
    ..aOB(4, _omitFieldNames ? '' : 'includeDetail')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetGroupRequest clone() => GetGroupRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetGroupRequest copyWith(void Function(GetGroupRequest) updates) => super.copyWith((message) => updates(message as GetGroupRequest)) as GetGroupRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetGroupRequest create() => GetGroupRequest._();
  GetGroupRequest createEmptyInstance() => create();
  static $pb.PbList<GetGroupRequest> createRepeated() => $pb.PbList<GetGroupRequest>();
  @$core.pragma('dart2js:noInline')
  static GetGroupRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetGroupRequest>(create);
  static GetGroupRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get themeId => $_getSZ(0);
  @$pb.TagNumber(1)
  set themeId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasThemeId() => $_has(0);
  @$pb.TagNumber(1)
  void clearThemeId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get groupId => $_getSZ(1);
  @$pb.TagNumber(2)
  set groupId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasGroupId() => $_has(1);
  @$pb.TagNumber(2)
  void clearGroupId() => clearField(2);

  @$pb.TagNumber(3)
  $core.bool get includeDocs => $_getBF(2);
  @$pb.TagNumber(3)
  set includeDocs($core.bool v) { $_setBool(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasIncludeDocs() => $_has(2);
  @$pb.TagNumber(3)
  void clearIncludeDocs() => clearField(3);

  @$pb.TagNumber(4)
  $core.bool get includeDetail => $_getBF(3);
  @$pb.TagNumber(4)
  set includeDetail($core.bool v) { $_setBool(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasIncludeDetail() => $_has(3);
  @$pb.TagNumber(4)
  void clearIncludeDetail() => clearField(4);
}

class GetGroupResponse extends $pb.GeneratedMessage {
  factory GetGroupResponse({
    $core.int? err,
    $core.String? msg,
    GroupDetail? group,
  }) {
    final $result = create();
    if (err != null) {
      $result.err = err;
    }
    if (msg != null) {
      $result.msg = msg;
    }
    if (group != null) {
      $result.group = group;
    }
    return $result;
  }
  GetGroupResponse._() : super();
  factory GetGroupResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetGroupResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetGroupResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'whisperingtime'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'err', $pb.PbFieldType.O3)
    ..aOS(2, _omitFieldNames ? '' : 'msg')
    ..aOM<GroupDetail>(3, _omitFieldNames ? '' : 'group', subBuilder: GroupDetail.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetGroupResponse clone() => GetGroupResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetGroupResponse copyWith(void Function(GetGroupResponse) updates) => super.copyWith((message) => updates(message as GetGroupResponse)) as GetGroupResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetGroupResponse create() => GetGroupResponse._();
  GetGroupResponse createEmptyInstance() => create();
  static $pb.PbList<GetGroupResponse> createRepeated() => $pb.PbList<GetGroupResponse>();
  @$core.pragma('dart2js:noInline')
  static GetGroupResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetGroupResponse>(create);
  static GetGroupResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get err => $_getIZ(0);
  @$pb.TagNumber(1)
  set err($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasErr() => $_has(0);
  @$pb.TagNumber(1)
  void clearErr() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get msg => $_getSZ(1);
  @$pb.TagNumber(2)
  set msg($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMsg() => $_has(1);
  @$pb.TagNumber(2)
  void clearMsg() => clearField(2);

  @$pb.TagNumber(3)
  GroupDetail get group => $_getN(2);
  @$pb.TagNumber(3)
  set group(GroupDetail v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasGroup() => $_has(2);
  @$pb.TagNumber(3)
  void clearGroup() => clearField(3);
  @$pb.TagNumber(3)
  GroupDetail ensureGroup() => $_ensure(2);
}

class CreateGroupRequest extends $pb.GeneratedMessage {
  factory CreateGroupRequest({
    $core.String? themeId,
    $core.List<$core.int>? name,
    $core.int? autoFreezeDays,
    $core.List<$core.int>? encryptedKey,
  }) {
    final $result = create();
    if (themeId != null) {
      $result.themeId = themeId;
    }
    if (name != null) {
      $result.name = name;
    }
    if (autoFreezeDays != null) {
      $result.autoFreezeDays = autoFreezeDays;
    }
    if (encryptedKey != null) {
      $result.encryptedKey = encryptedKey;
    }
    return $result;
  }
  CreateGroupRequest._() : super();
  factory CreateGroupRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreateGroupRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateGroupRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'whisperingtime'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'themeId')
    ..a<$core.List<$core.int>>(2, _omitFieldNames ? '' : 'name', $pb.PbFieldType.OY)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'autoFreezeDays', $pb.PbFieldType.O3)
    ..a<$core.List<$core.int>>(4, _omitFieldNames ? '' : 'encryptedKey', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreateGroupRequest clone() => CreateGroupRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreateGroupRequest copyWith(void Function(CreateGroupRequest) updates) => super.copyWith((message) => updates(message as CreateGroupRequest)) as CreateGroupRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateGroupRequest create() => CreateGroupRequest._();
  CreateGroupRequest createEmptyInstance() => create();
  static $pb.PbList<CreateGroupRequest> createRepeated() => $pb.PbList<CreateGroupRequest>();
  @$core.pragma('dart2js:noInline')
  static CreateGroupRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateGroupRequest>(create);
  static CreateGroupRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get themeId => $_getSZ(0);
  @$pb.TagNumber(1)
  set themeId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasThemeId() => $_has(0);
  @$pb.TagNumber(1)
  void clearThemeId() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get name => $_getN(1);
  @$pb.TagNumber(2)
  set name($core.List<$core.int> v) { $_setBytes(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get autoFreezeDays => $_getIZ(2);
  @$pb.TagNumber(3)
  set autoFreezeDays($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasAutoFreezeDays() => $_has(2);
  @$pb.TagNumber(3)
  void clearAutoFreezeDays() => clearField(3);

  @$pb.TagNumber(4)
  $core.List<$core.int> get encryptedKey => $_getN(3);
  @$pb.TagNumber(4)
  set encryptedKey($core.List<$core.int> v) { $_setBytes(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasEncryptedKey() => $_has(3);
  @$pb.TagNumber(4)
  void clearEncryptedKey() => clearField(4);
}

class CreateGroupResponse extends $pb.GeneratedMessage {
  factory CreateGroupResponse({
    $core.int? err,
    $core.String? msg,
    $core.String? id,
  }) {
    final $result = create();
    if (err != null) {
      $result.err = err;
    }
    if (msg != null) {
      $result.msg = msg;
    }
    if (id != null) {
      $result.id = id;
    }
    return $result;
  }
  CreateGroupResponse._() : super();
  factory CreateGroupResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreateGroupResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateGroupResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'whisperingtime'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'err', $pb.PbFieldType.O3)
    ..aOS(2, _omitFieldNames ? '' : 'msg')
    ..aOS(3, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreateGroupResponse clone() => CreateGroupResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreateGroupResponse copyWith(void Function(CreateGroupResponse) updates) => super.copyWith((message) => updates(message as CreateGroupResponse)) as CreateGroupResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateGroupResponse create() => CreateGroupResponse._();
  CreateGroupResponse createEmptyInstance() => create();
  static $pb.PbList<CreateGroupResponse> createRepeated() => $pb.PbList<CreateGroupResponse>();
  @$core.pragma('dart2js:noInline')
  static CreateGroupResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateGroupResponse>(create);
  static CreateGroupResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get err => $_getIZ(0);
  @$pb.TagNumber(1)
  set err($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasErr() => $_has(0);
  @$pb.TagNumber(1)
  void clearErr() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get msg => $_getSZ(1);
  @$pb.TagNumber(2)
  set msg($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMsg() => $_has(1);
  @$pb.TagNumber(2)
  void clearMsg() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get id => $_getSZ(2);
  @$pb.TagNumber(3)
  set id($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasId() => $_has(2);
  @$pb.TagNumber(3)
  void clearId() => clearField(3);
}

class UpdateGroupRequest extends $pb.GeneratedMessage {
  factory UpdateGroupRequest({
    $core.String? themeId,
    $core.String? groupId,
    $core.List<$core.int>? name,
    GroupConfig? config,
    $fixnum.Int64? overAt,
    $core.List<$core.int>? encryptedKey,
  }) {
    final $result = create();
    if (themeId != null) {
      $result.themeId = themeId;
    }
    if (groupId != null) {
      $result.groupId = groupId;
    }
    if (name != null) {
      $result.name = name;
    }
    if (config != null) {
      $result.config = config;
    }
    if (overAt != null) {
      $result.overAt = overAt;
    }
    if (encryptedKey != null) {
      $result.encryptedKey = encryptedKey;
    }
    return $result;
  }
  UpdateGroupRequest._() : super();
  factory UpdateGroupRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UpdateGroupRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UpdateGroupRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'whisperingtime'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'themeId')
    ..aOS(2, _omitFieldNames ? '' : 'groupId')
    ..a<$core.List<$core.int>>(3, _omitFieldNames ? '' : 'name', $pb.PbFieldType.OY)
    ..aOM<GroupConfig>(4, _omitFieldNames ? '' : 'config', subBuilder: GroupConfig.create)
    ..aInt64(5, _omitFieldNames ? '' : 'overAt')
    ..a<$core.List<$core.int>>(6, _omitFieldNames ? '' : 'encryptedKey', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UpdateGroupRequest clone() => UpdateGroupRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UpdateGroupRequest copyWith(void Function(UpdateGroupRequest) updates) => super.copyWith((message) => updates(message as UpdateGroupRequest)) as UpdateGroupRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateGroupRequest create() => UpdateGroupRequest._();
  UpdateGroupRequest createEmptyInstance() => create();
  static $pb.PbList<UpdateGroupRequest> createRepeated() => $pb.PbList<UpdateGroupRequest>();
  @$core.pragma('dart2js:noInline')
  static UpdateGroupRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UpdateGroupRequest>(create);
  static UpdateGroupRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get themeId => $_getSZ(0);
  @$pb.TagNumber(1)
  set themeId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasThemeId() => $_has(0);
  @$pb.TagNumber(1)
  void clearThemeId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get groupId => $_getSZ(1);
  @$pb.TagNumber(2)
  set groupId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasGroupId() => $_has(1);
  @$pb.TagNumber(2)
  void clearGroupId() => clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get name => $_getN(2);
  @$pb.TagNumber(3)
  set name($core.List<$core.int> v) { $_setBytes(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasName() => $_has(2);
  @$pb.TagNumber(3)
  void clearName() => clearField(3);

  @$pb.TagNumber(4)
  GroupConfig get config => $_getN(3);
  @$pb.TagNumber(4)
  set config(GroupConfig v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasConfig() => $_has(3);
  @$pb.TagNumber(4)
  void clearConfig() => clearField(4);
  @$pb.TagNumber(4)
  GroupConfig ensureConfig() => $_ensure(3);

  @$pb.TagNumber(5)
  $fixnum.Int64 get overAt => $_getI64(4);
  @$pb.TagNumber(5)
  set overAt($fixnum.Int64 v) { $_setInt64(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasOverAt() => $_has(4);
  @$pb.TagNumber(5)
  void clearOverAt() => clearField(5);

  @$pb.TagNumber(6)
  $core.List<$core.int> get encryptedKey => $_getN(5);
  @$pb.TagNumber(6)
  set encryptedKey($core.List<$core.int> v) { $_setBytes(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasEncryptedKey() => $_has(5);
  @$pb.TagNumber(6)
  void clearEncryptedKey() => clearField(6);
}

class DeleteGroupRequest extends $pb.GeneratedMessage {
  factory DeleteGroupRequest({
    $core.String? themeId,
    $core.String? groupId,
  }) {
    final $result = create();
    if (themeId != null) {
      $result.themeId = themeId;
    }
    if (groupId != null) {
      $result.groupId = groupId;
    }
    return $result;
  }
  DeleteGroupRequest._() : super();
  factory DeleteGroupRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DeleteGroupRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DeleteGroupRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'whisperingtime'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'themeId')
    ..aOS(2, _omitFieldNames ? '' : 'groupId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DeleteGroupRequest clone() => DeleteGroupRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DeleteGroupRequest copyWith(void Function(DeleteGroupRequest) updates) => super.copyWith((message) => updates(message as DeleteGroupRequest)) as DeleteGroupRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteGroupRequest create() => DeleteGroupRequest._();
  DeleteGroupRequest createEmptyInstance() => create();
  static $pb.PbList<DeleteGroupRequest> createRepeated() => $pb.PbList<DeleteGroupRequest>();
  @$core.pragma('dart2js:noInline')
  static DeleteGroupRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DeleteGroupRequest>(create);
  static DeleteGroupRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get themeId => $_getSZ(0);
  @$pb.TagNumber(1)
  set themeId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasThemeId() => $_has(0);
  @$pb.TagNumber(1)
  void clearThemeId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get groupId => $_getSZ(1);
  @$pb.TagNumber(2)
  set groupId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasGroupId() => $_has(1);
  @$pb.TagNumber(2)
  void clearGroupId() => clearField(2);
}

class ExportGroupConfigRequest extends $pb.GeneratedMessage {
  factory ExportGroupConfigRequest({
    $core.String? themeId,
    $core.String? groupId,
  }) {
    final $result = create();
    if (themeId != null) {
      $result.themeId = themeId;
    }
    if (groupId != null) {
      $result.groupId = groupId;
    }
    return $result;
  }
  ExportGroupConfigRequest._() : super();
  factory ExportGroupConfigRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ExportGroupConfigRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ExportGroupConfigRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'whisperingtime'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'themeId')
    ..aOS(2, _omitFieldNames ? '' : 'groupId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ExportGroupConfigRequest clone() => ExportGroupConfigRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ExportGroupConfigRequest copyWith(void Function(ExportGroupConfigRequest) updates) => super.copyWith((message) => updates(message as ExportGroupConfigRequest)) as ExportGroupConfigRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ExportGroupConfigRequest create() => ExportGroupConfigRequest._();
  ExportGroupConfigRequest createEmptyInstance() => create();
  static $pb.PbList<ExportGroupConfigRequest> createRepeated() => $pb.PbList<ExportGroupConfigRequest>();
  @$core.pragma('dart2js:noInline')
  static ExportGroupConfigRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ExportGroupConfigRequest>(create);
  static ExportGroupConfigRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get themeId => $_getSZ(0);
  @$pb.TagNumber(1)
  set themeId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasThemeId() => $_has(0);
  @$pb.TagNumber(1)
  void clearThemeId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get groupId => $_getSZ(1);
  @$pb.TagNumber(2)
  set groupId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasGroupId() => $_has(1);
  @$pb.TagNumber(2)
  void clearGroupId() => clearField(2);
}

class ImportGroupConfigResponse extends $pb.GeneratedMessage {
  factory ImportGroupConfigResponse({
    $core.int? err,
    $core.String? msg,
  }) {
    final $result = create();
    if (err != null) {
      $result.err = err;
    }
    if (msg != null) {
      $result.msg = msg;
    }
    return $result;
  }
  ImportGroupConfigResponse._() : super();
  factory ImportGroupConfigResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ImportGroupConfigResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ImportGroupConfigResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'whisperingtime'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'err', $pb.PbFieldType.O3)
    ..aOS(2, _omitFieldNames ? '' : 'msg')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ImportGroupConfigResponse clone() => ImportGroupConfigResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ImportGroupConfigResponse copyWith(void Function(ImportGroupConfigResponse) updates) => super.copyWith((message) => updates(message as ImportGroupConfigResponse)) as ImportGroupConfigResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ImportGroupConfigResponse create() => ImportGroupConfigResponse._();
  ImportGroupConfigResponse createEmptyInstance() => create();
  static $pb.PbList<ImportGroupConfigResponse> createRepeated() => $pb.PbList<ImportGroupConfigResponse>();
  @$core.pragma('dart2js:noInline')
  static ImportGroupConfigResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ImportGroupConfigResponse>(create);
  static ImportGroupConfigResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get err => $_getIZ(0);
  @$pb.TagNumber(1)
  set err($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasErr() => $_has(0);
  @$pb.TagNumber(1)
  void clearErr() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get msg => $_getSZ(1);
  @$pb.TagNumber(2)
  set msg($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMsg() => $_has(1);
  @$pb.TagNumber(2)
  void clearMsg() => clearField(2);
}

/// Doc service
class ListDocsRequest extends $pb.GeneratedMessage {
  factory ListDocsRequest({
    $core.String? groupId,
    $core.int? year,
    $core.int? month,
  }) {
    final $result = create();
    if (groupId != null) {
      $result.groupId = groupId;
    }
    if (year != null) {
      $result.year = year;
    }
    if (month != null) {
      $result.month = month;
    }
    return $result;
  }
  ListDocsRequest._() : super();
  factory ListDocsRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListDocsRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListDocsRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'whisperingtime'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'groupId')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'year', $pb.PbFieldType.O3)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'month', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListDocsRequest clone() => ListDocsRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListDocsRequest copyWith(void Function(ListDocsRequest) updates) => super.copyWith((message) => updates(message as ListDocsRequest)) as ListDocsRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListDocsRequest create() => ListDocsRequest._();
  ListDocsRequest createEmptyInstance() => create();
  static $pb.PbList<ListDocsRequest> createRepeated() => $pb.PbList<ListDocsRequest>();
  @$core.pragma('dart2js:noInline')
  static ListDocsRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListDocsRequest>(create);
  static ListDocsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get groupId => $_getSZ(0);
  @$pb.TagNumber(1)
  set groupId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasGroupId() => $_has(0);
  @$pb.TagNumber(1)
  void clearGroupId() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get year => $_getIZ(1);
  @$pb.TagNumber(2)
  set year($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasYear() => $_has(1);
  @$pb.TagNumber(2)
  void clearYear() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get month => $_getIZ(2);
  @$pb.TagNumber(3)
  set month($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasMonth() => $_has(2);
  @$pb.TagNumber(3)
  void clearMonth() => clearField(3);
}

class ListDocsResponse extends $pb.GeneratedMessage {
  factory ListDocsResponse({
    $core.int? err,
    $core.String? msg,
    $core.Iterable<DocSummary>? docs,
  }) {
    final $result = create();
    if (err != null) {
      $result.err = err;
    }
    if (msg != null) {
      $result.msg = msg;
    }
    if (docs != null) {
      $result.docs.addAll(docs);
    }
    return $result;
  }
  ListDocsResponse._() : super();
  factory ListDocsResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListDocsResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListDocsResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'whisperingtime'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'err', $pb.PbFieldType.O3)
    ..aOS(2, _omitFieldNames ? '' : 'msg')
    ..pc<DocSummary>(3, _omitFieldNames ? '' : 'docs', $pb.PbFieldType.PM, subBuilder: DocSummary.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListDocsResponse clone() => ListDocsResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListDocsResponse copyWith(void Function(ListDocsResponse) updates) => super.copyWith((message) => updates(message as ListDocsResponse)) as ListDocsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListDocsResponse create() => ListDocsResponse._();
  ListDocsResponse createEmptyInstance() => create();
  static $pb.PbList<ListDocsResponse> createRepeated() => $pb.PbList<ListDocsResponse>();
  @$core.pragma('dart2js:noInline')
  static ListDocsResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListDocsResponse>(create);
  static ListDocsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get err => $_getIZ(0);
  @$pb.TagNumber(1)
  set err($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasErr() => $_has(0);
  @$pb.TagNumber(1)
  void clearErr() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get msg => $_getSZ(1);
  @$pb.TagNumber(2)
  set msg($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMsg() => $_has(1);
  @$pb.TagNumber(2)
  void clearMsg() => clearField(2);

  @$pb.TagNumber(3)
  $core.List<DocSummary> get docs => $_getList(2);
}

class CreateDocRequest extends $pb.GeneratedMessage {
  factory CreateDocRequest({
    $core.String? groupId,
    Content? content,
    $fixnum.Int64? createAt,
    $core.List<$core.int>? encryptedKey,
    DocConfig? config,
  }) {
    final $result = create();
    if (groupId != null) {
      $result.groupId = groupId;
    }
    if (content != null) {
      $result.content = content;
    }
    if (createAt != null) {
      $result.createAt = createAt;
    }
    if (encryptedKey != null) {
      $result.encryptedKey = encryptedKey;
    }
    if (config != null) {
      $result.config = config;
    }
    return $result;
  }
  CreateDocRequest._() : super();
  factory CreateDocRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreateDocRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateDocRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'whisperingtime'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'groupId')
    ..aOM<Content>(2, _omitFieldNames ? '' : 'content', subBuilder: Content.create)
    ..aInt64(6, _omitFieldNames ? '' : 'createAt')
    ..a<$core.List<$core.int>>(7, _omitFieldNames ? '' : 'encryptedKey', $pb.PbFieldType.OY)
    ..aOM<DocConfig>(8, _omitFieldNames ? '' : 'config', subBuilder: DocConfig.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreateDocRequest clone() => CreateDocRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreateDocRequest copyWith(void Function(CreateDocRequest) updates) => super.copyWith((message) => updates(message as CreateDocRequest)) as CreateDocRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateDocRequest create() => CreateDocRequest._();
  CreateDocRequest createEmptyInstance() => create();
  static $pb.PbList<CreateDocRequest> createRepeated() => $pb.PbList<CreateDocRequest>();
  @$core.pragma('dart2js:noInline')
  static CreateDocRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateDocRequest>(create);
  static CreateDocRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get groupId => $_getSZ(0);
  @$pb.TagNumber(1)
  set groupId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasGroupId() => $_has(0);
  @$pb.TagNumber(1)
  void clearGroupId() => clearField(1);

  @$pb.TagNumber(2)
  Content get content => $_getN(1);
  @$pb.TagNumber(2)
  set content(Content v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasContent() => $_has(1);
  @$pb.TagNumber(2)
  void clearContent() => clearField(2);
  @$pb.TagNumber(2)
  Content ensureContent() => $_ensure(1);

  @$pb.TagNumber(6)
  $fixnum.Int64 get createAt => $_getI64(2);
  @$pb.TagNumber(6)
  set createAt($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(6)
  $core.bool hasCreateAt() => $_has(2);
  @$pb.TagNumber(6)
  void clearCreateAt() => clearField(6);

  @$pb.TagNumber(7)
  $core.List<$core.int> get encryptedKey => $_getN(3);
  @$pb.TagNumber(7)
  set encryptedKey($core.List<$core.int> v) { $_setBytes(3, v); }
  @$pb.TagNumber(7)
  $core.bool hasEncryptedKey() => $_has(3);
  @$pb.TagNumber(7)
  void clearEncryptedKey() => clearField(7);

  @$pb.TagNumber(8)
  DocConfig get config => $_getN(4);
  @$pb.TagNumber(8)
  set config(DocConfig v) { setField(8, v); }
  @$pb.TagNumber(8)
  $core.bool hasConfig() => $_has(4);
  @$pb.TagNumber(8)
  void clearConfig() => clearField(8);
  @$pb.TagNumber(8)
  DocConfig ensureConfig() => $_ensure(4);
}

class CreateDocResponse extends $pb.GeneratedMessage {
  factory CreateDocResponse({
    $core.int? err,
    $core.String? msg,
    $core.String? id,
  }) {
    final $result = create();
    if (err != null) {
      $result.err = err;
    }
    if (msg != null) {
      $result.msg = msg;
    }
    if (id != null) {
      $result.id = id;
    }
    return $result;
  }
  CreateDocResponse._() : super();
  factory CreateDocResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreateDocResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateDocResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'whisperingtime'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'err', $pb.PbFieldType.O3)
    ..aOS(2, _omitFieldNames ? '' : 'msg')
    ..aOS(3, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreateDocResponse clone() => CreateDocResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreateDocResponse copyWith(void Function(CreateDocResponse) updates) => super.copyWith((message) => updates(message as CreateDocResponse)) as CreateDocResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateDocResponse create() => CreateDocResponse._();
  CreateDocResponse createEmptyInstance() => create();
  static $pb.PbList<CreateDocResponse> createRepeated() => $pb.PbList<CreateDocResponse>();
  @$core.pragma('dart2js:noInline')
  static CreateDocResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateDocResponse>(create);
  static CreateDocResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get err => $_getIZ(0);
  @$pb.TagNumber(1)
  set err($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasErr() => $_has(0);
  @$pb.TagNumber(1)
  void clearErr() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get msg => $_getSZ(1);
  @$pb.TagNumber(2)
  set msg($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMsg() => $_has(1);
  @$pb.TagNumber(2)
  void clearMsg() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get id => $_getSZ(2);
  @$pb.TagNumber(3)
  set id($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasId() => $_has(2);
  @$pb.TagNumber(3)
  void clearId() => clearField(3);
}

class UpdateDocRequest extends $pb.GeneratedMessage {
  factory UpdateDocRequest({
    $core.String? groupId,
    $core.String? docId,
    Content? content,
    $fixnum.Int64? createAt,
    $core.List<$core.int>? encryptedKey,
    DocConfig? config,
  }) {
    final $result = create();
    if (groupId != null) {
      $result.groupId = groupId;
    }
    if (docId != null) {
      $result.docId = docId;
    }
    if (content != null) {
      $result.content = content;
    }
    if (createAt != null) {
      $result.createAt = createAt;
    }
    if (encryptedKey != null) {
      $result.encryptedKey = encryptedKey;
    }
    if (config != null) {
      $result.config = config;
    }
    return $result;
  }
  UpdateDocRequest._() : super();
  factory UpdateDocRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UpdateDocRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UpdateDocRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'whisperingtime'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'groupId')
    ..aOS(2, _omitFieldNames ? '' : 'docId')
    ..aOM<Content>(3, _omitFieldNames ? '' : 'content', subBuilder: Content.create)
    ..aInt64(7, _omitFieldNames ? '' : 'createAt')
    ..a<$core.List<$core.int>>(8, _omitFieldNames ? '' : 'encryptedKey', $pb.PbFieldType.OY)
    ..aOM<DocConfig>(9, _omitFieldNames ? '' : 'config', subBuilder: DocConfig.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UpdateDocRequest clone() => UpdateDocRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UpdateDocRequest copyWith(void Function(UpdateDocRequest) updates) => super.copyWith((message) => updates(message as UpdateDocRequest)) as UpdateDocRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateDocRequest create() => UpdateDocRequest._();
  UpdateDocRequest createEmptyInstance() => create();
  static $pb.PbList<UpdateDocRequest> createRepeated() => $pb.PbList<UpdateDocRequest>();
  @$core.pragma('dart2js:noInline')
  static UpdateDocRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UpdateDocRequest>(create);
  static UpdateDocRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get groupId => $_getSZ(0);
  @$pb.TagNumber(1)
  set groupId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasGroupId() => $_has(0);
  @$pb.TagNumber(1)
  void clearGroupId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get docId => $_getSZ(1);
  @$pb.TagNumber(2)
  set docId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasDocId() => $_has(1);
  @$pb.TagNumber(2)
  void clearDocId() => clearField(2);

  @$pb.TagNumber(3)
  Content get content => $_getN(2);
  @$pb.TagNumber(3)
  set content(Content v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasContent() => $_has(2);
  @$pb.TagNumber(3)
  void clearContent() => clearField(3);
  @$pb.TagNumber(3)
  Content ensureContent() => $_ensure(2);

  @$pb.TagNumber(7)
  $fixnum.Int64 get createAt => $_getI64(3);
  @$pb.TagNumber(7)
  set createAt($fixnum.Int64 v) { $_setInt64(3, v); }
  @$pb.TagNumber(7)
  $core.bool hasCreateAt() => $_has(3);
  @$pb.TagNumber(7)
  void clearCreateAt() => clearField(7);

  @$pb.TagNumber(8)
  $core.List<$core.int> get encryptedKey => $_getN(4);
  @$pb.TagNumber(8)
  set encryptedKey($core.List<$core.int> v) { $_setBytes(4, v); }
  @$pb.TagNumber(8)
  $core.bool hasEncryptedKey() => $_has(4);
  @$pb.TagNumber(8)
  void clearEncryptedKey() => clearField(8);

  @$pb.TagNumber(9)
  DocConfig get config => $_getN(5);
  @$pb.TagNumber(9)
  set config(DocConfig v) { setField(9, v); }
  @$pb.TagNumber(9)
  $core.bool hasConfig() => $_has(5);
  @$pb.TagNumber(9)
  void clearConfig() => clearField(9);
  @$pb.TagNumber(9)
  DocConfig ensureConfig() => $_ensure(5);
}

class DeleteDocRequest extends $pb.GeneratedMessage {
  factory DeleteDocRequest({
    $core.String? groupId,
    $core.String? docId,
  }) {
    final $result = create();
    if (groupId != null) {
      $result.groupId = groupId;
    }
    if (docId != null) {
      $result.docId = docId;
    }
    return $result;
  }
  DeleteDocRequest._() : super();
  factory DeleteDocRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DeleteDocRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DeleteDocRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'whisperingtime'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'groupId')
    ..aOS(2, _omitFieldNames ? '' : 'docId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DeleteDocRequest clone() => DeleteDocRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DeleteDocRequest copyWith(void Function(DeleteDocRequest) updates) => super.copyWith((message) => updates(message as DeleteDocRequest)) as DeleteDocRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteDocRequest create() => DeleteDocRequest._();
  DeleteDocRequest createEmptyInstance() => create();
  static $pb.PbList<DeleteDocRequest> createRepeated() => $pb.PbList<DeleteDocRequest>();
  @$core.pragma('dart2js:noInline')
  static DeleteDocRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DeleteDocRequest>(create);
  static DeleteDocRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get groupId => $_getSZ(0);
  @$pb.TagNumber(1)
  set groupId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasGroupId() => $_has(0);
  @$pb.TagNumber(1)
  void clearGroupId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get docId => $_getSZ(1);
  @$pb.TagNumber(2)
  set docId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasDocId() => $_has(1);
  @$pb.TagNumber(2)
  void clearDocId() => clearField(2);
}

/// Image service
class UploadImageResponse extends $pb.GeneratedMessage {
  factory UploadImageResponse({
    $core.int? err,
    $core.String? msg,
    $core.String? name,
    $core.String? url,
  }) {
    final $result = create();
    if (err != null) {
      $result.err = err;
    }
    if (msg != null) {
      $result.msg = msg;
    }
    if (name != null) {
      $result.name = name;
    }
    if (url != null) {
      $result.url = url;
    }
    return $result;
  }
  UploadImageResponse._() : super();
  factory UploadImageResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UploadImageResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UploadImageResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'whisperingtime'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'err', $pb.PbFieldType.O3)
    ..aOS(2, _omitFieldNames ? '' : 'msg')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..aOS(4, _omitFieldNames ? '' : 'url')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UploadImageResponse clone() => UploadImageResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UploadImageResponse copyWith(void Function(UploadImageResponse) updates) => super.copyWith((message) => updates(message as UploadImageResponse)) as UploadImageResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UploadImageResponse create() => UploadImageResponse._();
  UploadImageResponse createEmptyInstance() => create();
  static $pb.PbList<UploadImageResponse> createRepeated() => $pb.PbList<UploadImageResponse>();
  @$core.pragma('dart2js:noInline')
  static UploadImageResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UploadImageResponse>(create);
  static UploadImageResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get err => $_getIZ(0);
  @$pb.TagNumber(1)
  set err($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasErr() => $_has(0);
  @$pb.TagNumber(1)
  void clearErr() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get msg => $_getSZ(1);
  @$pb.TagNumber(2)
  set msg($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMsg() => $_has(1);
  @$pb.TagNumber(2)
  void clearMsg() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get name => $_getSZ(2);
  @$pb.TagNumber(3)
  set name($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasName() => $_has(2);
  @$pb.TagNumber(3)
  void clearName() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get url => $_getSZ(3);
  @$pb.TagNumber(4)
  set url($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasUrl() => $_has(3);
  @$pb.TagNumber(4)
  void clearUrl() => clearField(4);
}

class DeleteImageRequest extends $pb.GeneratedMessage {
  factory DeleteImageRequest({
    $core.String? name,
  }) {
    final $result = create();
    if (name != null) {
      $result.name = name;
    }
    return $result;
  }
  DeleteImageRequest._() : super();
  factory DeleteImageRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DeleteImageRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DeleteImageRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'whisperingtime'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DeleteImageRequest clone() => DeleteImageRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DeleteImageRequest copyWith(void Function(DeleteImageRequest) updates) => super.copyWith((message) => updates(message as DeleteImageRequest)) as DeleteImageRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteImageRequest create() => DeleteImageRequest._();
  DeleteImageRequest createEmptyInstance() => create();
  static $pb.PbList<DeleteImageRequest> createRepeated() => $pb.PbList<DeleteImageRequest>();
  @$core.pragma('dart2js:noInline')
  static DeleteImageRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DeleteImageRequest>(create);
  static DeleteImageRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => clearField(1);
}

class ImageUploadChunk extends $pb.GeneratedMessage {
  factory ImageUploadChunk({
    $core.String? userId,
    $core.String? mime,
    $core.List<$core.int>? data,
  }) {
    final $result = create();
    if (userId != null) {
      $result.userId = userId;
    }
    if (mime != null) {
      $result.mime = mime;
    }
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  ImageUploadChunk._() : super();
  factory ImageUploadChunk.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ImageUploadChunk.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ImageUploadChunk', package: const $pb.PackageName(_omitMessageNames ? '' : 'whisperingtime'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aOS(2, _omitFieldNames ? '' : 'mime')
    ..a<$core.List<$core.int>>(3, _omitFieldNames ? '' : 'data', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ImageUploadChunk clone() => ImageUploadChunk()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ImageUploadChunk copyWith(void Function(ImageUploadChunk) updates) => super.copyWith((message) => updates(message as ImageUploadChunk)) as ImageUploadChunk;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ImageUploadChunk create() => ImageUploadChunk._();
  ImageUploadChunk createEmptyInstance() => create();
  static $pb.PbList<ImageUploadChunk> createRepeated() => $pb.PbList<ImageUploadChunk>();
  @$core.pragma('dart2js:noInline')
  static ImageUploadChunk getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ImageUploadChunk>(create);
  static ImageUploadChunk? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get mime => $_getSZ(1);
  @$pb.TagNumber(2)
  set mime($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMime() => $_has(1);
  @$pb.TagNumber(2)
  void clearMime() => clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get data => $_getN(2);
  @$pb.TagNumber(3)
  set data($core.List<$core.int> v) { $_setBytes(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasData() => $_has(2);
  @$pb.TagNumber(3)
  void clearData() => clearField(3);
}

/// File service for presigned upload/download
class PresignUploadFileRequest extends $pb.GeneratedMessage {
  factory PresignUploadFileRequest({
    $core.String? themeId,
    $core.String? groupId,
    $core.String? docId,
    $core.String? filename,
    $core.String? mime,
    $fixnum.Int64? size,
    $core.List<$core.int>? encryptedKey,
    $core.List<$core.int>? iv,
    $core.List<$core.int>? encryptedMetadata,
    $fixnum.Int64? expiresInSec,
  }) {
    final $result = create();
    if (themeId != null) {
      $result.themeId = themeId;
    }
    if (groupId != null) {
      $result.groupId = groupId;
    }
    if (docId != null) {
      $result.docId = docId;
    }
    if (filename != null) {
      $result.filename = filename;
    }
    if (mime != null) {
      $result.mime = mime;
    }
    if (size != null) {
      $result.size = size;
    }
    if (encryptedKey != null) {
      $result.encryptedKey = encryptedKey;
    }
    if (iv != null) {
      $result.iv = iv;
    }
    if (encryptedMetadata != null) {
      $result.encryptedMetadata = encryptedMetadata;
    }
    if (expiresInSec != null) {
      $result.expiresInSec = expiresInSec;
    }
    return $result;
  }
  PresignUploadFileRequest._() : super();
  factory PresignUploadFileRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PresignUploadFileRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PresignUploadFileRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'whisperingtime'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'themeId')
    ..aOS(2, _omitFieldNames ? '' : 'groupId')
    ..aOS(3, _omitFieldNames ? '' : 'docId')
    ..aOS(4, _omitFieldNames ? '' : 'filename')
    ..aOS(5, _omitFieldNames ? '' : 'mime')
    ..aInt64(6, _omitFieldNames ? '' : 'size')
    ..a<$core.List<$core.int>>(7, _omitFieldNames ? '' : 'encryptedKey', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(8, _omitFieldNames ? '' : 'iv', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(9, _omitFieldNames ? '' : 'encryptedMetadata', $pb.PbFieldType.OY)
    ..aInt64(10, _omitFieldNames ? '' : 'expiresInSec')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PresignUploadFileRequest clone() => PresignUploadFileRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PresignUploadFileRequest copyWith(void Function(PresignUploadFileRequest) updates) => super.copyWith((message) => updates(message as PresignUploadFileRequest)) as PresignUploadFileRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PresignUploadFileRequest create() => PresignUploadFileRequest._();
  PresignUploadFileRequest createEmptyInstance() => create();
  static $pb.PbList<PresignUploadFileRequest> createRepeated() => $pb.PbList<PresignUploadFileRequest>();
  @$core.pragma('dart2js:noInline')
  static PresignUploadFileRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PresignUploadFileRequest>(create);
  static PresignUploadFileRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get themeId => $_getSZ(0);
  @$pb.TagNumber(1)
  set themeId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasThemeId() => $_has(0);
  @$pb.TagNumber(1)
  void clearThemeId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get groupId => $_getSZ(1);
  @$pb.TagNumber(2)
  set groupId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasGroupId() => $_has(1);
  @$pb.TagNumber(2)
  void clearGroupId() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get docId => $_getSZ(2);
  @$pb.TagNumber(3)
  set docId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasDocId() => $_has(2);
  @$pb.TagNumber(3)
  void clearDocId() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get filename => $_getSZ(3);
  @$pb.TagNumber(4)
  set filename($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasFilename() => $_has(3);
  @$pb.TagNumber(4)
  void clearFilename() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get mime => $_getSZ(4);
  @$pb.TagNumber(5)
  set mime($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasMime() => $_has(4);
  @$pb.TagNumber(5)
  void clearMime() => clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get size => $_getI64(5);
  @$pb.TagNumber(6)
  set size($fixnum.Int64 v) { $_setInt64(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasSize() => $_has(5);
  @$pb.TagNumber(6)
  void clearSize() => clearField(6);

  @$pb.TagNumber(7)
  $core.List<$core.int> get encryptedKey => $_getN(6);
  @$pb.TagNumber(7)
  set encryptedKey($core.List<$core.int> v) { $_setBytes(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasEncryptedKey() => $_has(6);
  @$pb.TagNumber(7)
  void clearEncryptedKey() => clearField(7);

  @$pb.TagNumber(8)
  $core.List<$core.int> get iv => $_getN(7);
  @$pb.TagNumber(8)
  set iv($core.List<$core.int> v) { $_setBytes(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasIv() => $_has(7);
  @$pb.TagNumber(8)
  void clearIv() => clearField(8);

  @$pb.TagNumber(9)
  $core.List<$core.int> get encryptedMetadata => $_getN(8);
  @$pb.TagNumber(9)
  set encryptedMetadata($core.List<$core.int> v) { $_setBytes(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasEncryptedMetadata() => $_has(8);
  @$pb.TagNumber(9)
  void clearEncryptedMetadata() => clearField(9);

  @$pb.TagNumber(10)
  $fixnum.Int64 get expiresInSec => $_getI64(9);
  @$pb.TagNumber(10)
  set expiresInSec($fixnum.Int64 v) { $_setInt64(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasExpiresInSec() => $_has(9);
  @$pb.TagNumber(10)
  void clearExpiresInSec() => clearField(10);
}

class PresignUploadFileResponse extends $pb.GeneratedMessage {
  factory PresignUploadFileResponse({
    $core.int? err,
    $core.String? msg,
    $core.String? fileId,
    $core.String? objectPath,
    $core.String? uploadUrl,
    $fixnum.Int64? expiresAt,
  }) {
    final $result = create();
    if (err != null) {
      $result.err = err;
    }
    if (msg != null) {
      $result.msg = msg;
    }
    if (fileId != null) {
      $result.fileId = fileId;
    }
    if (objectPath != null) {
      $result.objectPath = objectPath;
    }
    if (uploadUrl != null) {
      $result.uploadUrl = uploadUrl;
    }
    if (expiresAt != null) {
      $result.expiresAt = expiresAt;
    }
    return $result;
  }
  PresignUploadFileResponse._() : super();
  factory PresignUploadFileResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PresignUploadFileResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PresignUploadFileResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'whisperingtime'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'err', $pb.PbFieldType.O3)
    ..aOS(2, _omitFieldNames ? '' : 'msg')
    ..aOS(3, _omitFieldNames ? '' : 'fileId')
    ..aOS(4, _omitFieldNames ? '' : 'objectPath')
    ..aOS(5, _omitFieldNames ? '' : 'uploadUrl')
    ..aInt64(6, _omitFieldNames ? '' : 'expiresAt')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PresignUploadFileResponse clone() => PresignUploadFileResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PresignUploadFileResponse copyWith(void Function(PresignUploadFileResponse) updates) => super.copyWith((message) => updates(message as PresignUploadFileResponse)) as PresignUploadFileResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PresignUploadFileResponse create() => PresignUploadFileResponse._();
  PresignUploadFileResponse createEmptyInstance() => create();
  static $pb.PbList<PresignUploadFileResponse> createRepeated() => $pb.PbList<PresignUploadFileResponse>();
  @$core.pragma('dart2js:noInline')
  static PresignUploadFileResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PresignUploadFileResponse>(create);
  static PresignUploadFileResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get err => $_getIZ(0);
  @$pb.TagNumber(1)
  set err($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasErr() => $_has(0);
  @$pb.TagNumber(1)
  void clearErr() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get msg => $_getSZ(1);
  @$pb.TagNumber(2)
  set msg($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMsg() => $_has(1);
  @$pb.TagNumber(2)
  void clearMsg() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get fileId => $_getSZ(2);
  @$pb.TagNumber(3)
  set fileId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasFileId() => $_has(2);
  @$pb.TagNumber(3)
  void clearFileId() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get objectPath => $_getSZ(3);
  @$pb.TagNumber(4)
  set objectPath($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasObjectPath() => $_has(3);
  @$pb.TagNumber(4)
  void clearObjectPath() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get uploadUrl => $_getSZ(4);
  @$pb.TagNumber(5)
  set uploadUrl($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasUploadUrl() => $_has(4);
  @$pb.TagNumber(5)
  void clearUploadUrl() => clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get expiresAt => $_getI64(5);
  @$pb.TagNumber(6)
  set expiresAt($fixnum.Int64 v) { $_setInt64(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasExpiresAt() => $_has(5);
  @$pb.TagNumber(6)
  void clearExpiresAt() => clearField(6);
}

class PresignDownloadFileRequest extends $pb.GeneratedMessage {
  factory PresignDownloadFileRequest({
    $core.String? fileId,
  }) {
    final $result = create();
    if (fileId != null) {
      $result.fileId = fileId;
    }
    return $result;
  }
  PresignDownloadFileRequest._() : super();
  factory PresignDownloadFileRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PresignDownloadFileRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PresignDownloadFileRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'whisperingtime'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'fileId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PresignDownloadFileRequest clone() => PresignDownloadFileRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PresignDownloadFileRequest copyWith(void Function(PresignDownloadFileRequest) updates) => super.copyWith((message) => updates(message as PresignDownloadFileRequest)) as PresignDownloadFileRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PresignDownloadFileRequest create() => PresignDownloadFileRequest._();
  PresignDownloadFileRequest createEmptyInstance() => create();
  static $pb.PbList<PresignDownloadFileRequest> createRepeated() => $pb.PbList<PresignDownloadFileRequest>();
  @$core.pragma('dart2js:noInline')
  static PresignDownloadFileRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PresignDownloadFileRequest>(create);
  static PresignDownloadFileRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get fileId => $_getSZ(0);
  @$pb.TagNumber(1)
  set fileId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasFileId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFileId() => clearField(1);
}

class PresignDownloadFileResponse extends $pb.GeneratedMessage {
  factory PresignDownloadFileResponse({
    $core.int? err,
    $core.String? msg,
    $core.String? fileId,
    $core.String? objectPath,
    $core.String? downloadUrl,
    $fixnum.Int64? expiresAt,
    $core.String? ownerUid,
    $core.String? themeId,
    $core.String? groupId,
    $core.String? docId,
    $core.String? mime,
    $fixnum.Int64? size,
    $core.List<$core.int>? encryptedKey,
    $core.List<$core.int>? iv,
    $core.List<$core.int>? encryptedMetadata,
  }) {
    final $result = create();
    if (err != null) {
      $result.err = err;
    }
    if (msg != null) {
      $result.msg = msg;
    }
    if (fileId != null) {
      $result.fileId = fileId;
    }
    if (objectPath != null) {
      $result.objectPath = objectPath;
    }
    if (downloadUrl != null) {
      $result.downloadUrl = downloadUrl;
    }
    if (expiresAt != null) {
      $result.expiresAt = expiresAt;
    }
    if (ownerUid != null) {
      $result.ownerUid = ownerUid;
    }
    if (themeId != null) {
      $result.themeId = themeId;
    }
    if (groupId != null) {
      $result.groupId = groupId;
    }
    if (docId != null) {
      $result.docId = docId;
    }
    if (mime != null) {
      $result.mime = mime;
    }
    if (size != null) {
      $result.size = size;
    }
    if (encryptedKey != null) {
      $result.encryptedKey = encryptedKey;
    }
    if (iv != null) {
      $result.iv = iv;
    }
    if (encryptedMetadata != null) {
      $result.encryptedMetadata = encryptedMetadata;
    }
    return $result;
  }
  PresignDownloadFileResponse._() : super();
  factory PresignDownloadFileResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PresignDownloadFileResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PresignDownloadFileResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'whisperingtime'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'err', $pb.PbFieldType.O3)
    ..aOS(2, _omitFieldNames ? '' : 'msg')
    ..aOS(3, _omitFieldNames ? '' : 'fileId')
    ..aOS(4, _omitFieldNames ? '' : 'objectPath')
    ..aOS(5, _omitFieldNames ? '' : 'downloadUrl')
    ..aInt64(6, _omitFieldNames ? '' : 'expiresAt')
    ..aOS(7, _omitFieldNames ? '' : 'ownerUid')
    ..aOS(8, _omitFieldNames ? '' : 'themeId')
    ..aOS(9, _omitFieldNames ? '' : 'groupId')
    ..aOS(10, _omitFieldNames ? '' : 'docId')
    ..aOS(11, _omitFieldNames ? '' : 'mime')
    ..aInt64(12, _omitFieldNames ? '' : 'size')
    ..a<$core.List<$core.int>>(13, _omitFieldNames ? '' : 'encryptedKey', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(14, _omitFieldNames ? '' : 'iv', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(15, _omitFieldNames ? '' : 'encryptedMetadata', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PresignDownloadFileResponse clone() => PresignDownloadFileResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PresignDownloadFileResponse copyWith(void Function(PresignDownloadFileResponse) updates) => super.copyWith((message) => updates(message as PresignDownloadFileResponse)) as PresignDownloadFileResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PresignDownloadFileResponse create() => PresignDownloadFileResponse._();
  PresignDownloadFileResponse createEmptyInstance() => create();
  static $pb.PbList<PresignDownloadFileResponse> createRepeated() => $pb.PbList<PresignDownloadFileResponse>();
  @$core.pragma('dart2js:noInline')
  static PresignDownloadFileResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PresignDownloadFileResponse>(create);
  static PresignDownloadFileResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get err => $_getIZ(0);
  @$pb.TagNumber(1)
  set err($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasErr() => $_has(0);
  @$pb.TagNumber(1)
  void clearErr() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get msg => $_getSZ(1);
  @$pb.TagNumber(2)
  set msg($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMsg() => $_has(1);
  @$pb.TagNumber(2)
  void clearMsg() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get fileId => $_getSZ(2);
  @$pb.TagNumber(3)
  set fileId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasFileId() => $_has(2);
  @$pb.TagNumber(3)
  void clearFileId() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get objectPath => $_getSZ(3);
  @$pb.TagNumber(4)
  set objectPath($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasObjectPath() => $_has(3);
  @$pb.TagNumber(4)
  void clearObjectPath() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get downloadUrl => $_getSZ(4);
  @$pb.TagNumber(5)
  set downloadUrl($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasDownloadUrl() => $_has(4);
  @$pb.TagNumber(5)
  void clearDownloadUrl() => clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get expiresAt => $_getI64(5);
  @$pb.TagNumber(6)
  set expiresAt($fixnum.Int64 v) { $_setInt64(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasExpiresAt() => $_has(5);
  @$pb.TagNumber(6)
  void clearExpiresAt() => clearField(6);

  @$pb.TagNumber(7)
  $core.String get ownerUid => $_getSZ(6);
  @$pb.TagNumber(7)
  set ownerUid($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasOwnerUid() => $_has(6);
  @$pb.TagNumber(7)
  void clearOwnerUid() => clearField(7);

  @$pb.TagNumber(8)
  $core.String get themeId => $_getSZ(7);
  @$pb.TagNumber(8)
  set themeId($core.String v) { $_setString(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasThemeId() => $_has(7);
  @$pb.TagNumber(8)
  void clearThemeId() => clearField(8);

  @$pb.TagNumber(9)
  $core.String get groupId => $_getSZ(8);
  @$pb.TagNumber(9)
  set groupId($core.String v) { $_setString(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasGroupId() => $_has(8);
  @$pb.TagNumber(9)
  void clearGroupId() => clearField(9);

  @$pb.TagNumber(10)
  $core.String get docId => $_getSZ(9);
  @$pb.TagNumber(10)
  set docId($core.String v) { $_setString(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasDocId() => $_has(9);
  @$pb.TagNumber(10)
  void clearDocId() => clearField(10);

  @$pb.TagNumber(11)
  $core.String get mime => $_getSZ(10);
  @$pb.TagNumber(11)
  set mime($core.String v) { $_setString(10, v); }
  @$pb.TagNumber(11)
  $core.bool hasMime() => $_has(10);
  @$pb.TagNumber(11)
  void clearMime() => clearField(11);

  @$pb.TagNumber(12)
  $fixnum.Int64 get size => $_getI64(11);
  @$pb.TagNumber(12)
  set size($fixnum.Int64 v) { $_setInt64(11, v); }
  @$pb.TagNumber(12)
  $core.bool hasSize() => $_has(11);
  @$pb.TagNumber(12)
  void clearSize() => clearField(12);

  @$pb.TagNumber(13)
  $core.List<$core.int> get encryptedKey => $_getN(12);
  @$pb.TagNumber(13)
  set encryptedKey($core.List<$core.int> v) { $_setBytes(12, v); }
  @$pb.TagNumber(13)
  $core.bool hasEncryptedKey() => $_has(12);
  @$pb.TagNumber(13)
  void clearEncryptedKey() => clearField(13);

  @$pb.TagNumber(14)
  $core.List<$core.int> get iv => $_getN(13);
  @$pb.TagNumber(14)
  set iv($core.List<$core.int> v) { $_setBytes(13, v); }
  @$pb.TagNumber(14)
  $core.bool hasIv() => $_has(13);
  @$pb.TagNumber(14)
  void clearIv() => clearField(14);

  @$pb.TagNumber(15)
  $core.List<$core.int> get encryptedMetadata => $_getN(14);
  @$pb.TagNumber(15)
  set encryptedMetadata($core.List<$core.int> v) { $_setBytes(14, v); }
  @$pb.TagNumber(15)
  $core.bool hasEncryptedMetadata() => $_has(14);
  @$pb.TagNumber(15)
  void clearEncryptedMetadata() => clearField(15);
}

class DeleteFileRequest extends $pb.GeneratedMessage {
  factory DeleteFileRequest({
    $core.String? fileId,
  }) {
    final $result = create();
    if (fileId != null) {
      $result.fileId = fileId;
    }
    return $result;
  }
  DeleteFileRequest._() : super();
  factory DeleteFileRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DeleteFileRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DeleteFileRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'whisperingtime'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'fileId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DeleteFileRequest clone() => DeleteFileRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DeleteFileRequest copyWith(void Function(DeleteFileRequest) updates) => super.copyWith((message) => updates(message as DeleteFileRequest)) as DeleteFileRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteFileRequest create() => DeleteFileRequest._();
  DeleteFileRequest createEmptyInstance() => create();
  static $pb.PbList<DeleteFileRequest> createRepeated() => $pb.PbList<DeleteFileRequest>();
  @$core.pragma('dart2js:noInline')
  static DeleteFileRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DeleteFileRequest>(create);
  static DeleteFileRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get fileId => $_getSZ(0);
  @$pb.TagNumber(1)
  set fileId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasFileId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFileId() => clearField(1);
}

/// Background job service
class BackgroundJob extends $pb.GeneratedMessage {
  factory BackgroundJob({
    $core.String? id,
    $core.String? name,
    $core.String? jobType,
    $core.String? status,
    $core.String? createdAt,
    $core.String? startedAt,
    $core.String? completedAt,
    $core.int? priority,
    $core.int? retryCount,
    $core.String? resultJson,
    $core.String? errorJson,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (name != null) {
      $result.name = name;
    }
    if (jobType != null) {
      $result.jobType = jobType;
    }
    if (status != null) {
      $result.status = status;
    }
    if (createdAt != null) {
      $result.createdAt = createdAt;
    }
    if (startedAt != null) {
      $result.startedAt = startedAt;
    }
    if (completedAt != null) {
      $result.completedAt = completedAt;
    }
    if (priority != null) {
      $result.priority = priority;
    }
    if (retryCount != null) {
      $result.retryCount = retryCount;
    }
    if (resultJson != null) {
      $result.resultJson = resultJson;
    }
    if (errorJson != null) {
      $result.errorJson = errorJson;
    }
    return $result;
  }
  BackgroundJob._() : super();
  factory BackgroundJob.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory BackgroundJob.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BackgroundJob', package: const $pb.PackageName(_omitMessageNames ? '' : 'whisperingtime'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'jobType')
    ..aOS(4, _omitFieldNames ? '' : 'status')
    ..aOS(5, _omitFieldNames ? '' : 'createdAt')
    ..aOS(6, _omitFieldNames ? '' : 'startedAt')
    ..aOS(7, _omitFieldNames ? '' : 'completedAt')
    ..a<$core.int>(8, _omitFieldNames ? '' : 'priority', $pb.PbFieldType.O3)
    ..a<$core.int>(9, _omitFieldNames ? '' : 'retryCount', $pb.PbFieldType.O3)
    ..aOS(10, _omitFieldNames ? '' : 'resultJson')
    ..aOS(11, _omitFieldNames ? '' : 'errorJson')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  BackgroundJob clone() => BackgroundJob()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  BackgroundJob copyWith(void Function(BackgroundJob) updates) => super.copyWith((message) => updates(message as BackgroundJob)) as BackgroundJob;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BackgroundJob create() => BackgroundJob._();
  BackgroundJob createEmptyInstance() => create();
  static $pb.PbList<BackgroundJob> createRepeated() => $pb.PbList<BackgroundJob>();
  @$core.pragma('dart2js:noInline')
  static BackgroundJob getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BackgroundJob>(create);
  static BackgroundJob? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get jobType => $_getSZ(2);
  @$pb.TagNumber(3)
  set jobType($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasJobType() => $_has(2);
  @$pb.TagNumber(3)
  void clearJobType() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get status => $_getSZ(3);
  @$pb.TagNumber(4)
  set status($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasStatus() => $_has(3);
  @$pb.TagNumber(4)
  void clearStatus() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get createdAt => $_getSZ(4);
  @$pb.TagNumber(5)
  set createdAt($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasCreatedAt() => $_has(4);
  @$pb.TagNumber(5)
  void clearCreatedAt() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get startedAt => $_getSZ(5);
  @$pb.TagNumber(6)
  set startedAt($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasStartedAt() => $_has(5);
  @$pb.TagNumber(6)
  void clearStartedAt() => clearField(6);

  @$pb.TagNumber(7)
  $core.String get completedAt => $_getSZ(6);
  @$pb.TagNumber(7)
  set completedAt($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasCompletedAt() => $_has(6);
  @$pb.TagNumber(7)
  void clearCompletedAt() => clearField(7);

  @$pb.TagNumber(8)
  $core.int get priority => $_getIZ(7);
  @$pb.TagNumber(8)
  set priority($core.int v) { $_setSignedInt32(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasPriority() => $_has(7);
  @$pb.TagNumber(8)
  void clearPriority() => clearField(8);

  @$pb.TagNumber(9)
  $core.int get retryCount => $_getIZ(8);
  @$pb.TagNumber(9)
  set retryCount($core.int v) { $_setSignedInt32(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasRetryCount() => $_has(8);
  @$pb.TagNumber(9)
  void clearRetryCount() => clearField(9);

  @$pb.TagNumber(10)
  $core.String get resultJson => $_getSZ(9);
  @$pb.TagNumber(10)
  set resultJson($core.String v) { $_setString(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasResultJson() => $_has(9);
  @$pb.TagNumber(10)
  void clearResultJson() => clearField(10);

  @$pb.TagNumber(11)
  $core.String get errorJson => $_getSZ(10);
  @$pb.TagNumber(11)
  set errorJson($core.String v) { $_setString(10, v); }
  @$pb.TagNumber(11)
  $core.bool hasErrorJson() => $_has(10);
  @$pb.TagNumber(11)
  void clearErrorJson() => clearField(11);
}

class ListBackgroundJobsRequest extends $pb.GeneratedMessage {
  factory ListBackgroundJobsRequest() => create();
  ListBackgroundJobsRequest._() : super();
  factory ListBackgroundJobsRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListBackgroundJobsRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListBackgroundJobsRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'whisperingtime'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListBackgroundJobsRequest clone() => ListBackgroundJobsRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListBackgroundJobsRequest copyWith(void Function(ListBackgroundJobsRequest) updates) => super.copyWith((message) => updates(message as ListBackgroundJobsRequest)) as ListBackgroundJobsRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListBackgroundJobsRequest create() => ListBackgroundJobsRequest._();
  ListBackgroundJobsRequest createEmptyInstance() => create();
  static $pb.PbList<ListBackgroundJobsRequest> createRepeated() => $pb.PbList<ListBackgroundJobsRequest>();
  @$core.pragma('dart2js:noInline')
  static ListBackgroundJobsRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListBackgroundJobsRequest>(create);
  static ListBackgroundJobsRequest? _defaultInstance;
}

class ListBackgroundJobsResponse extends $pb.GeneratedMessage {
  factory ListBackgroundJobsResponse({
    $core.int? err,
    $core.String? msg,
    $core.Iterable<BackgroundJob>? jobs,
  }) {
    final $result = create();
    if (err != null) {
      $result.err = err;
    }
    if (msg != null) {
      $result.msg = msg;
    }
    if (jobs != null) {
      $result.jobs.addAll(jobs);
    }
    return $result;
  }
  ListBackgroundJobsResponse._() : super();
  factory ListBackgroundJobsResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListBackgroundJobsResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListBackgroundJobsResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'whisperingtime'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'err', $pb.PbFieldType.O3)
    ..aOS(2, _omitFieldNames ? '' : 'msg')
    ..pc<BackgroundJob>(3, _omitFieldNames ? '' : 'jobs', $pb.PbFieldType.PM, subBuilder: BackgroundJob.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListBackgroundJobsResponse clone() => ListBackgroundJobsResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListBackgroundJobsResponse copyWith(void Function(ListBackgroundJobsResponse) updates) => super.copyWith((message) => updates(message as ListBackgroundJobsResponse)) as ListBackgroundJobsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListBackgroundJobsResponse create() => ListBackgroundJobsResponse._();
  ListBackgroundJobsResponse createEmptyInstance() => create();
  static $pb.PbList<ListBackgroundJobsResponse> createRepeated() => $pb.PbList<ListBackgroundJobsResponse>();
  @$core.pragma('dart2js:noInline')
  static ListBackgroundJobsResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListBackgroundJobsResponse>(create);
  static ListBackgroundJobsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get err => $_getIZ(0);
  @$pb.TagNumber(1)
  set err($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasErr() => $_has(0);
  @$pb.TagNumber(1)
  void clearErr() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get msg => $_getSZ(1);
  @$pb.TagNumber(2)
  set msg($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMsg() => $_has(1);
  @$pb.TagNumber(2)
  void clearMsg() => clearField(2);

  @$pb.TagNumber(3)
  $core.List<BackgroundJob> get jobs => $_getList(2);
}

class GetBackgroundJobRequest extends $pb.GeneratedMessage {
  factory GetBackgroundJobRequest({
    $core.String? id,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    return $result;
  }
  GetBackgroundJobRequest._() : super();
  factory GetBackgroundJobRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetBackgroundJobRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBackgroundJobRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'whisperingtime'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetBackgroundJobRequest clone() => GetBackgroundJobRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetBackgroundJobRequest copyWith(void Function(GetBackgroundJobRequest) updates) => super.copyWith((message) => updates(message as GetBackgroundJobRequest)) as GetBackgroundJobRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetBackgroundJobRequest create() => GetBackgroundJobRequest._();
  GetBackgroundJobRequest createEmptyInstance() => create();
  static $pb.PbList<GetBackgroundJobRequest> createRepeated() => $pb.PbList<GetBackgroundJobRequest>();
  @$core.pragma('dart2js:noInline')
  static GetBackgroundJobRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetBackgroundJobRequest>(create);
  static GetBackgroundJobRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);
}

class DeleteBackgroundJobRequest extends $pb.GeneratedMessage {
  factory DeleteBackgroundJobRequest({
    $core.String? id,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    return $result;
  }
  DeleteBackgroundJobRequest._() : super();
  factory DeleteBackgroundJobRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DeleteBackgroundJobRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DeleteBackgroundJobRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'whisperingtime'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DeleteBackgroundJobRequest clone() => DeleteBackgroundJobRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DeleteBackgroundJobRequest copyWith(void Function(DeleteBackgroundJobRequest) updates) => super.copyWith((message) => updates(message as DeleteBackgroundJobRequest)) as DeleteBackgroundJobRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteBackgroundJobRequest create() => DeleteBackgroundJobRequest._();
  DeleteBackgroundJobRequest createEmptyInstance() => create();
  static $pb.PbList<DeleteBackgroundJobRequest> createRepeated() => $pb.PbList<DeleteBackgroundJobRequest>();
  @$core.pragma('dart2js:noInline')
  static DeleteBackgroundJobRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DeleteBackgroundJobRequest>(create);
  static DeleteBackgroundJobRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);
}

class DownloadBackgroundJobFileRequest extends $pb.GeneratedMessage {
  factory DownloadBackgroundJobFileRequest({
    $core.String? id,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    return $result;
  }
  DownloadBackgroundJobFileRequest._() : super();
  factory DownloadBackgroundJobFileRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DownloadBackgroundJobFileRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DownloadBackgroundJobFileRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'whisperingtime'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DownloadBackgroundJobFileRequest clone() => DownloadBackgroundJobFileRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DownloadBackgroundJobFileRequest copyWith(void Function(DownloadBackgroundJobFileRequest) updates) => super.copyWith((message) => updates(message as DownloadBackgroundJobFileRequest)) as DownloadBackgroundJobFileRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DownloadBackgroundJobFileRequest create() => DownloadBackgroundJobFileRequest._();
  DownloadBackgroundJobFileRequest createEmptyInstance() => create();
  static $pb.PbList<DownloadBackgroundJobFileRequest> createRepeated() => $pb.PbList<DownloadBackgroundJobFileRequest>();
  @$core.pragma('dart2js:noInline')
  static DownloadBackgroundJobFileRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DownloadBackgroundJobFileRequest>(create);
  static DownloadBackgroundJobFileRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);
}

class DownloadBackgroundJobFileResponse extends $pb.GeneratedMessage {
  factory DownloadBackgroundJobFileResponse({
    $core.int? err,
    $core.String? msg,
    $core.List<$core.int>? data,
    $core.String? filename,
  }) {
    final $result = create();
    if (err != null) {
      $result.err = err;
    }
    if (msg != null) {
      $result.msg = msg;
    }
    if (data != null) {
      $result.data = data;
    }
    if (filename != null) {
      $result.filename = filename;
    }
    return $result;
  }
  DownloadBackgroundJobFileResponse._() : super();
  factory DownloadBackgroundJobFileResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DownloadBackgroundJobFileResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DownloadBackgroundJobFileResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'whisperingtime'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'err', $pb.PbFieldType.O3)
    ..aOS(2, _omitFieldNames ? '' : 'msg')
    ..a<$core.List<$core.int>>(3, _omitFieldNames ? '' : 'data', $pb.PbFieldType.OY)
    ..aOS(4, _omitFieldNames ? '' : 'filename')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DownloadBackgroundJobFileResponse clone() => DownloadBackgroundJobFileResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DownloadBackgroundJobFileResponse copyWith(void Function(DownloadBackgroundJobFileResponse) updates) => super.copyWith((message) => updates(message as DownloadBackgroundJobFileResponse)) as DownloadBackgroundJobFileResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DownloadBackgroundJobFileResponse create() => DownloadBackgroundJobFileResponse._();
  DownloadBackgroundJobFileResponse createEmptyInstance() => create();
  static $pb.PbList<DownloadBackgroundJobFileResponse> createRepeated() => $pb.PbList<DownloadBackgroundJobFileResponse>();
  @$core.pragma('dart2js:noInline')
  static DownloadBackgroundJobFileResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DownloadBackgroundJobFileResponse>(create);
  static DownloadBackgroundJobFileResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get err => $_getIZ(0);
  @$pb.TagNumber(1)
  set err($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasErr() => $_has(0);
  @$pb.TagNumber(1)
  void clearErr() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get msg => $_getSZ(1);
  @$pb.TagNumber(2)
  set msg($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMsg() => $_has(1);
  @$pb.TagNumber(2)
  void clearMsg() => clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get data => $_getN(2);
  @$pb.TagNumber(3)
  set data($core.List<$core.int> v) { $_setBytes(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasData() => $_has(2);
  @$pb.TagNumber(3)
  void clearData() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get filename => $_getSZ(3);
  @$pb.TagNumber(4)
  set filename($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasFilename() => $_has(3);
  @$pb.TagNumber(4)
  void clearFilename() => clearField(4);
}

/// Shared chunk message for client streaming uploads
class BytesChunk extends $pb.GeneratedMessage {
  factory BytesChunk({
    $core.List<$core.int>? data,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  BytesChunk._() : super();
  factory BytesChunk.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory BytesChunk.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BytesChunk', package: const $pb.PackageName(_omitMessageNames ? '' : 'whisperingtime'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, _omitFieldNames ? '' : 'data', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  BytesChunk clone() => BytesChunk()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  BytesChunk copyWith(void Function(BytesChunk) updates) => super.copyWith((message) => updates(message as BytesChunk)) as BytesChunk;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BytesChunk create() => BytesChunk._();
  BytesChunk createEmptyInstance() => create();
  static $pb.PbList<BytesChunk> createRepeated() => $pb.PbList<BytesChunk>();
  @$core.pragma('dart2js:noInline')
  static BytesChunk getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BytesChunk>(create);
  static BytesChunk? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get data => $_getN(0);
  @$pb.TagNumber(1)
  set data($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
}

/// Stored as encrypted bytes only (server is blind storage).
class ScaleTemplate extends $pb.GeneratedMessage {
  factory ScaleTemplate({
    $core.String? id,
    $core.List<$core.int>? encryptedMetadata,
    $fixnum.Int64? createdAt,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (encryptedMetadata != null) {
      $result.encryptedMetadata = encryptedMetadata;
    }
    if (createdAt != null) {
      $result.createdAt = createdAt;
    }
    return $result;
  }
  ScaleTemplate._() : super();
  factory ScaleTemplate.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ScaleTemplate.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ScaleTemplate', package: const $pb.PackageName(_omitMessageNames ? '' : 'whisperingtime'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..a<$core.List<$core.int>>(2, _omitFieldNames ? '' : 'encryptedMetadata', $pb.PbFieldType.OY)
    ..aInt64(3, _omitFieldNames ? '' : 'createdAt')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ScaleTemplate clone() => ScaleTemplate()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ScaleTemplate copyWith(void Function(ScaleTemplate) updates) => super.copyWith((message) => updates(message as ScaleTemplate)) as ScaleTemplate;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ScaleTemplate create() => ScaleTemplate._();
  ScaleTemplate createEmptyInstance() => create();
  static $pb.PbList<ScaleTemplate> createRepeated() => $pb.PbList<ScaleTemplate>();
  @$core.pragma('dart2js:noInline')
  static ScaleTemplate getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ScaleTemplate>(create);
  static ScaleTemplate? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get encryptedMetadata => $_getN(1);
  @$pb.TagNumber(2)
  set encryptedMetadata($core.List<$core.int> v) { $_setBytes(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasEncryptedMetadata() => $_has(1);
  @$pb.TagNumber(2)
  void clearEncryptedMetadata() => clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get createdAt => $_getI64(2);
  @$pb.TagNumber(3)
  set createdAt($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasCreatedAt() => $_has(2);
  @$pb.TagNumber(3)
  void clearCreatedAt() => clearField(3);
}

class ListScaleTemplatesRequest extends $pb.GeneratedMessage {
  factory ListScaleTemplatesRequest() => create();
  ListScaleTemplatesRequest._() : super();
  factory ListScaleTemplatesRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListScaleTemplatesRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListScaleTemplatesRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'whisperingtime'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListScaleTemplatesRequest clone() => ListScaleTemplatesRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListScaleTemplatesRequest copyWith(void Function(ListScaleTemplatesRequest) updates) => super.copyWith((message) => updates(message as ListScaleTemplatesRequest)) as ListScaleTemplatesRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListScaleTemplatesRequest create() => ListScaleTemplatesRequest._();
  ListScaleTemplatesRequest createEmptyInstance() => create();
  static $pb.PbList<ListScaleTemplatesRequest> createRepeated() => $pb.PbList<ListScaleTemplatesRequest>();
  @$core.pragma('dart2js:noInline')
  static ListScaleTemplatesRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListScaleTemplatesRequest>(create);
  static ListScaleTemplatesRequest? _defaultInstance;
}

class ListScaleTemplatesResponse extends $pb.GeneratedMessage {
  factory ListScaleTemplatesResponse({
    $core.int? err,
    $core.String? msg,
    $core.Iterable<ScaleTemplate>? templates,
  }) {
    final $result = create();
    if (err != null) {
      $result.err = err;
    }
    if (msg != null) {
      $result.msg = msg;
    }
    if (templates != null) {
      $result.templates.addAll(templates);
    }
    return $result;
  }
  ListScaleTemplatesResponse._() : super();
  factory ListScaleTemplatesResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListScaleTemplatesResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListScaleTemplatesResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'whisperingtime'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'err', $pb.PbFieldType.O3)
    ..aOS(2, _omitFieldNames ? '' : 'msg')
    ..pc<ScaleTemplate>(3, _omitFieldNames ? '' : 'templates', $pb.PbFieldType.PM, subBuilder: ScaleTemplate.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListScaleTemplatesResponse clone() => ListScaleTemplatesResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListScaleTemplatesResponse copyWith(void Function(ListScaleTemplatesResponse) updates) => super.copyWith((message) => updates(message as ListScaleTemplatesResponse)) as ListScaleTemplatesResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListScaleTemplatesResponse create() => ListScaleTemplatesResponse._();
  ListScaleTemplatesResponse createEmptyInstance() => create();
  static $pb.PbList<ListScaleTemplatesResponse> createRepeated() => $pb.PbList<ListScaleTemplatesResponse>();
  @$core.pragma('dart2js:noInline')
  static ListScaleTemplatesResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListScaleTemplatesResponse>(create);
  static ListScaleTemplatesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get err => $_getIZ(0);
  @$pb.TagNumber(1)
  set err($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasErr() => $_has(0);
  @$pb.TagNumber(1)
  void clearErr() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get msg => $_getSZ(1);
  @$pb.TagNumber(2)
  set msg($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMsg() => $_has(1);
  @$pb.TagNumber(2)
  void clearMsg() => clearField(2);

  @$pb.TagNumber(3)
  $core.List<ScaleTemplate> get templates => $_getList(2);
}

class CreateScaleTemplateRequest extends $pb.GeneratedMessage {
  factory CreateScaleTemplateRequest({
    $core.List<$core.int>? encryptedMetadata,
  }) {
    final $result = create();
    if (encryptedMetadata != null) {
      $result.encryptedMetadata = encryptedMetadata;
    }
    return $result;
  }
  CreateScaleTemplateRequest._() : super();
  factory CreateScaleTemplateRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreateScaleTemplateRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateScaleTemplateRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'whisperingtime'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, _omitFieldNames ? '' : 'encryptedMetadata', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreateScaleTemplateRequest clone() => CreateScaleTemplateRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreateScaleTemplateRequest copyWith(void Function(CreateScaleTemplateRequest) updates) => super.copyWith((message) => updates(message as CreateScaleTemplateRequest)) as CreateScaleTemplateRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateScaleTemplateRequest create() => CreateScaleTemplateRequest._();
  CreateScaleTemplateRequest createEmptyInstance() => create();
  static $pb.PbList<CreateScaleTemplateRequest> createRepeated() => $pb.PbList<CreateScaleTemplateRequest>();
  @$core.pragma('dart2js:noInline')
  static CreateScaleTemplateRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateScaleTemplateRequest>(create);
  static CreateScaleTemplateRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get encryptedMetadata => $_getN(0);
  @$pb.TagNumber(1)
  set encryptedMetadata($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasEncryptedMetadata() => $_has(0);
  @$pb.TagNumber(1)
  void clearEncryptedMetadata() => clearField(1);
}

class CreateScaleTemplateResponse extends $pb.GeneratedMessage {
  factory CreateScaleTemplateResponse({
    $core.int? err,
    $core.String? msg,
    $core.String? id,
  }) {
    final $result = create();
    if (err != null) {
      $result.err = err;
    }
    if (msg != null) {
      $result.msg = msg;
    }
    if (id != null) {
      $result.id = id;
    }
    return $result;
  }
  CreateScaleTemplateResponse._() : super();
  factory CreateScaleTemplateResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreateScaleTemplateResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateScaleTemplateResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'whisperingtime'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'err', $pb.PbFieldType.O3)
    ..aOS(2, _omitFieldNames ? '' : 'msg')
    ..aOS(3, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreateScaleTemplateResponse clone() => CreateScaleTemplateResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreateScaleTemplateResponse copyWith(void Function(CreateScaleTemplateResponse) updates) => super.copyWith((message) => updates(message as CreateScaleTemplateResponse)) as CreateScaleTemplateResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateScaleTemplateResponse create() => CreateScaleTemplateResponse._();
  CreateScaleTemplateResponse createEmptyInstance() => create();
  static $pb.PbList<CreateScaleTemplateResponse> createRepeated() => $pb.PbList<CreateScaleTemplateResponse>();
  @$core.pragma('dart2js:noInline')
  static CreateScaleTemplateResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateScaleTemplateResponse>(create);
  static CreateScaleTemplateResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get err => $_getIZ(0);
  @$pb.TagNumber(1)
  set err($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasErr() => $_has(0);
  @$pb.TagNumber(1)
  void clearErr() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get msg => $_getSZ(1);
  @$pb.TagNumber(2)
  set msg($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMsg() => $_has(1);
  @$pb.TagNumber(2)
  void clearMsg() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get id => $_getSZ(2);
  @$pb.TagNumber(3)
  set id($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasId() => $_has(2);
  @$pb.TagNumber(3)
  void clearId() => clearField(3);
}

class UpdateScaleTemplateRequest extends $pb.GeneratedMessage {
  factory UpdateScaleTemplateRequest({
    $core.String? id,
    $core.List<$core.int>? encryptedMetadata,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (encryptedMetadata != null) {
      $result.encryptedMetadata = encryptedMetadata;
    }
    return $result;
  }
  UpdateScaleTemplateRequest._() : super();
  factory UpdateScaleTemplateRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UpdateScaleTemplateRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UpdateScaleTemplateRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'whisperingtime'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..a<$core.List<$core.int>>(2, _omitFieldNames ? '' : 'encryptedMetadata', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UpdateScaleTemplateRequest clone() => UpdateScaleTemplateRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UpdateScaleTemplateRequest copyWith(void Function(UpdateScaleTemplateRequest) updates) => super.copyWith((message) => updates(message as UpdateScaleTemplateRequest)) as UpdateScaleTemplateRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateScaleTemplateRequest create() => UpdateScaleTemplateRequest._();
  UpdateScaleTemplateRequest createEmptyInstance() => create();
  static $pb.PbList<UpdateScaleTemplateRequest> createRepeated() => $pb.PbList<UpdateScaleTemplateRequest>();
  @$core.pragma('dart2js:noInline')
  static UpdateScaleTemplateRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UpdateScaleTemplateRequest>(create);
  static UpdateScaleTemplateRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get encryptedMetadata => $_getN(1);
  @$pb.TagNumber(2)
  set encryptedMetadata($core.List<$core.int> v) { $_setBytes(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasEncryptedMetadata() => $_has(1);
  @$pb.TagNumber(2)
  void clearEncryptedMetadata() => clearField(2);
}

class DeleteScaleTemplateRequest extends $pb.GeneratedMessage {
  factory DeleteScaleTemplateRequest({
    $core.String? id,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    return $result;
  }
  DeleteScaleTemplateRequest._() : super();
  factory DeleteScaleTemplateRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DeleteScaleTemplateRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DeleteScaleTemplateRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'whisperingtime'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DeleteScaleTemplateRequest clone() => DeleteScaleTemplateRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DeleteScaleTemplateRequest copyWith(void Function(DeleteScaleTemplateRequest) updates) => super.copyWith((message) => updates(message as DeleteScaleTemplateRequest)) as DeleteScaleTemplateRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteScaleTemplateRequest create() => DeleteScaleTemplateRequest._();
  DeleteScaleTemplateRequest createEmptyInstance() => create();
  static $pb.PbList<DeleteScaleTemplateRequest> createRepeated() => $pb.PbList<DeleteScaleTemplateRequest>();
  @$core.pragma('dart2js:noInline')
  static DeleteScaleTemplateRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DeleteScaleTemplateRequest>(create);
  static DeleteScaleTemplateRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);
}

/// DocContent is defined explicitly for ZKA data-flow documentation.
/// In practice it is carried as Content.scales.
class DocContent extends $pb.GeneratedMessage {
  factory DocContent({
    $core.List<$core.int>? scales,
  }) {
    final $result = create();
    if (scales != null) {
      $result.scales = scales;
    }
    return $result;
  }
  DocContent._() : super();
  factory DocContent.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DocContent.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DocContent', package: const $pb.PackageName(_omitMessageNames ? '' : 'whisperingtime'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, _omitFieldNames ? '' : 'scales', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DocContent clone() => DocContent()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DocContent copyWith(void Function(DocContent) updates) => super.copyWith((message) => updates(message as DocContent)) as DocContent;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DocContent create() => DocContent._();
  DocContent createEmptyInstance() => create();
  static $pb.PbList<DocContent> createRepeated() => $pb.PbList<DocContent>();
  @$core.pragma('dart2js:noInline')
  static DocContent getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DocContent>(create);
  static DocContent? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get scales => $_getN(0);
  @$pb.TagNumber(1)
  set scales($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasScales() => $_has(0);
  @$pb.TagNumber(1)
  void clearScales() => clearField(1);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
