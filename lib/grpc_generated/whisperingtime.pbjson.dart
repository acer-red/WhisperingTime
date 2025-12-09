//
//  Generated code. Do not modify.
//  source: whisperingtime.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use basicResponseDescriptor instead')
const BasicResponse$json = {
  '1': 'BasicResponse',
  '2': [
    {'1': 'err', '3': 1, '4': 1, '5': 5, '10': 'err'},
    {'1': 'msg', '3': 2, '4': 1, '5': 9, '10': 'msg'},
  ],
};

/// Descriptor for `BasicResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List basicResponseDescriptor = $convert.base64Decode(
    'Cg1CYXNpY1Jlc3BvbnNlEhAKA2VychgBIAEoBVIDZXJyEhAKA21zZxgCIAEoCVIDbXNn');

@$core.Deprecated('Use emptyDescriptor instead')
const Empty$json = {
  '1': 'Empty',
};

/// Descriptor for `Empty`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List emptyDescriptor = $convert.base64Decode(
    'CgVFbXB0eQ==');

@$core.Deprecated('Use themeSummaryDescriptor instead')
const ThemeSummary$json = {
  '1': 'ThemeSummary',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 12, '10': 'name'},
  ],
};

/// Descriptor for `ThemeSummary`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List themeSummaryDescriptor = $convert.base64Decode(
    'CgxUaGVtZVN1bW1hcnkSDgoCaWQYASABKAlSAmlkEhIKBG5hbWUYAiABKAxSBG5hbWU=');

@$core.Deprecated('Use permissionEnvelopeDescriptor instead')
const PermissionEnvelope$json = {
  '1': 'PermissionEnvelope',
  '2': [
    {'1': 'encrypted_key', '3': 1, '4': 1, '5': 12, '10': 'encryptedKey'},
    {'1': 'role', '3': 2, '4': 1, '5': 9, '10': 'role'},
  ],
};

/// Descriptor for `PermissionEnvelope`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List permissionEnvelopeDescriptor = $convert.base64Decode(
    'ChJQZXJtaXNzaW9uRW52ZWxvcGUSIwoNZW5jcnlwdGVkX2tleRgBIAEoDFIMZW5jcnlwdGVkS2'
    'V5EhIKBHJvbGUYAiABKAlSBHJvbGU=');

@$core.Deprecated('Use groupConfigDescriptor instead')
const GroupConfig$json = {
  '1': 'GroupConfig',
  '2': [
    {'1': 'levels', '3': 3, '4': 3, '5': 8, '10': 'levels'},
    {'1': 'view_type', '3': 4, '4': 1, '5': 5, '10': 'viewType'},
    {'1': 'sort_type', '3': 5, '4': 1, '5': 5, '10': 'sortType'},
    {'1': 'auto_freeze_days', '3': 6, '4': 1, '5': 5, '10': 'autoFreezeDays'},
  ],
};

/// Descriptor for `GroupConfig`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List groupConfigDescriptor = $convert.base64Decode(
    'CgtHcm91cENvbmZpZxIWCgZsZXZlbHMYAyADKAhSBmxldmVscxIbCgl2aWV3X3R5cGUYBCABKA'
    'VSCHZpZXdUeXBlEhsKCXNvcnRfdHlwZRgFIAEoBVIIc29ydFR5cGUSKAoQYXV0b19mcmVlemVf'
    'ZGF5cxgGIAEoBVIOYXV0b0ZyZWV6ZURheXM=');

@$core.Deprecated('Use groupSummaryDescriptor instead')
const GroupSummary$json = {
  '1': 'GroupSummary',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 12, '10': 'name'},
    {'1': 'create_at', '3': 3, '4': 1, '5': 3, '10': 'createAt'},
    {'1': 'update_at', '3': 4, '4': 1, '5': 3, '10': 'updateAt'},
    {'1': 'over_at', '3': 5, '4': 1, '5': 3, '10': 'overAt'},
    {'1': 'config', '3': 6, '4': 1, '5': 11, '6': '.whisperingtime.GroupConfig', '10': 'config'},
    {'1': 'permission', '3': 7, '4': 1, '5': 11, '6': '.whisperingtime.PermissionEnvelope', '10': 'permission'},
  ],
};

/// Descriptor for `GroupSummary`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List groupSummaryDescriptor = $convert.base64Decode(
    'CgxHcm91cFN1bW1hcnkSDgoCaWQYASABKAlSAmlkEhIKBG5hbWUYAiABKAxSBG5hbWUSGwoJY3'
    'JlYXRlX2F0GAMgASgDUghjcmVhdGVBdBIbCgl1cGRhdGVfYXQYBCABKANSCHVwZGF0ZUF0EhcK'
    'B292ZXJfYXQYBSABKANSBm92ZXJBdBIzCgZjb25maWcYBiABKAsyGy53aGlzcGVyaW5ndGltZS'
    '5Hcm91cENvbmZpZ1IGY29uZmlnEkIKCnBlcm1pc3Npb24YByABKAsyIi53aGlzcGVyaW5ndGlt'
    'ZS5QZXJtaXNzaW9uRW52ZWxvcGVSCnBlcm1pc3Npb24=');

@$core.Deprecated('Use docSummaryDescriptor instead')
const DocSummary$json = {
  '1': 'DocSummary',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'content', '3': 2, '4': 1, '5': 11, '6': '.whisperingtime.Content', '10': 'content'},
    {'1': 'create_at', '3': 5, '4': 1, '5': 3, '10': 'createAt'},
    {'1': 'update_at', '3': 6, '4': 1, '5': 3, '10': 'updateAt'},
    {'1': 'permission', '3': 7, '4': 1, '5': 11, '6': '.whisperingtime.PermissionEnvelope', '10': 'permission'},
  ],
  '9': [
    {'1': 4, '2': 5},
  ],
};

/// Descriptor for `DocSummary`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List docSummaryDescriptor = $convert.base64Decode(
    'CgpEb2NTdW1tYXJ5Eg4KAmlkGAEgASgJUgJpZBIxCgdjb250ZW50GAIgASgLMhcud2hpc3Blcm'
    'luZ3RpbWUuQ29udGVudFIHY29udGVudBIbCgljcmVhdGVfYXQYBSABKANSCGNyZWF0ZUF0EhsK'
    'CXVwZGF0ZV9hdBgGIAEoA1IIdXBkYXRlQXQSQgoKcGVybWlzc2lvbhgHIAEoCzIiLndoaXNwZX'
    'Jpbmd0aW1lLlBlcm1pc3Npb25FbnZlbG9wZVIKcGVybWlzc2lvbkoECAQQBQ==');

@$core.Deprecated('Use contentDescriptor instead')
const Content$json = {
  '1': 'Content',
  '2': [
    {'1': 'title', '3': 1, '4': 1, '5': 12, '9': 0, '10': 'title', '17': true},
    {'1': 'rich', '3': 2, '4': 1, '5': 12, '9': 1, '10': 'rich', '17': true},
    {'1': 'level', '3': 3, '4': 1, '5': 12, '9': 2, '10': 'level', '17': true},
  ],
  '8': [
    {'1': '_title'},
    {'1': '_rich'},
    {'1': '_level'},
  ],
};

/// Descriptor for `Content`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List contentDescriptor = $convert.base64Decode(
    'CgdDb250ZW50EhkKBXRpdGxlGAEgASgMSABSBXRpdGxliAEBEhcKBHJpY2gYAiABKAxIAVIEcm'
    'ljaIgBARIZCgVsZXZlbBgDIAEoDEgCUgVsZXZlbIgBAUIICgZfdGl0bGVCBwoFX3JpY2hCCAoG'
    'X2xldmVs');

@$core.Deprecated('Use docDetailDescriptor instead')
const DocDetail$json = {
  '1': 'DocDetail',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'content', '3': 2, '4': 1, '5': 11, '6': '.whisperingtime.Content', '10': 'content'},
    {'1': 'create_at', '3': 6, '4': 1, '5': 3, '10': 'createAt'},
    {'1': 'update_at', '3': 7, '4': 1, '5': 3, '10': 'updateAt'},
    {'1': 'permission', '3': 8, '4': 1, '5': 11, '6': '.whisperingtime.PermissionEnvelope', '10': 'permission'},
  ],
  '9': [
    {'1': 5, '2': 6},
  ],
};

/// Descriptor for `DocDetail`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List docDetailDescriptor = $convert.base64Decode(
    'CglEb2NEZXRhaWwSDgoCaWQYASABKAlSAmlkEjEKB2NvbnRlbnQYAiABKAsyFy53aGlzcGVyaW'
    '5ndGltZS5Db250ZW50Ugdjb250ZW50EhsKCWNyZWF0ZV9hdBgGIAEoA1IIY3JlYXRlQXQSGwoJ'
    'dXBkYXRlX2F0GAcgASgDUgh1cGRhdGVBdBJCCgpwZXJtaXNzaW9uGAggASgLMiIud2hpc3Blcm'
    'luZ3RpbWUuUGVybWlzc2lvbkVudmVsb3BlUgpwZXJtaXNzaW9uSgQIBRAG');

@$core.Deprecated('Use groupDetailDescriptor instead')
const GroupDetail$json = {
  '1': 'GroupDetail',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 12, '10': 'name'},
    {'1': 'config', '3': 3, '4': 1, '5': 11, '6': '.whisperingtime.GroupConfig', '10': 'config'},
    {'1': 'docs', '3': 4, '4': 3, '5': 11, '6': '.whisperingtime.DocDetail', '10': 'docs'},
    {'1': 'permission', '3': 5, '4': 1, '5': 11, '6': '.whisperingtime.PermissionEnvelope', '10': 'permission'},
  ],
};

/// Descriptor for `GroupDetail`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List groupDetailDescriptor = $convert.base64Decode(
    'CgtHcm91cERldGFpbBIOCgJpZBgBIAEoCVICaWQSEgoEbmFtZRgCIAEoDFIEbmFtZRIzCgZjb2'
    '5maWcYAyABKAsyGy53aGlzcGVyaW5ndGltZS5Hcm91cENvbmZpZ1IGY29uZmlnEi0KBGRvY3MY'
    'BCADKAsyGS53aGlzcGVyaW5ndGltZS5Eb2NEZXRhaWxSBGRvY3MSQgoKcGVybWlzc2lvbhgFIA'
    'EoCzIiLndoaXNwZXJpbmd0aW1lLlBlcm1pc3Npb25FbnZlbG9wZVIKcGVybWlzc2lvbg==');

@$core.Deprecated('Use themeDetailDescriptor instead')
const ThemeDetail$json = {
  '1': 'ThemeDetail',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 12, '10': 'name'},
    {'1': 'groups', '3': 3, '4': 3, '5': 11, '6': '.whisperingtime.GroupDetail', '10': 'groups'},
    {'1': 'permission', '3': 4, '4': 1, '5': 11, '6': '.whisperingtime.PermissionEnvelope', '10': 'permission'},
  ],
};

/// Descriptor for `ThemeDetail`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List themeDetailDescriptor = $convert.base64Decode(
    'CgtUaGVtZURldGFpbBIOCgJpZBgBIAEoCVICaWQSEgoEbmFtZRgCIAEoDFIEbmFtZRIzCgZncm'
    '91cHMYAyADKAsyGy53aGlzcGVyaW5ndGltZS5Hcm91cERldGFpbFIGZ3JvdXBzEkIKCnBlcm1p'
    'c3Npb24YBCABKAsyIi53aGlzcGVyaW5ndGltZS5QZXJtaXNzaW9uRW52ZWxvcGVSCnBlcm1pc3'
    'Npb24=');

@$core.Deprecated('Use listThemesRequestDescriptor instead')
const ListThemesRequest$json = {
  '1': 'ListThemesRequest',
  '2': [
    {'1': 'include_docs', '3': 1, '4': 1, '5': 8, '10': 'includeDocs'},
    {'1': 'include_detail', '3': 2, '4': 1, '5': 8, '10': 'includeDetail'},
  ],
};

/// Descriptor for `ListThemesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listThemesRequestDescriptor = $convert.base64Decode(
    'ChFMaXN0VGhlbWVzUmVxdWVzdBIhCgxpbmNsdWRlX2RvY3MYASABKAhSC2luY2x1ZGVEb2NzEi'
    'UKDmluY2x1ZGVfZGV0YWlsGAIgASgIUg1pbmNsdWRlRGV0YWls');

@$core.Deprecated('Use listThemesResponseDescriptor instead')
const ListThemesResponse$json = {
  '1': 'ListThemesResponse',
  '2': [
    {'1': 'err', '3': 1, '4': 1, '5': 5, '10': 'err'},
    {'1': 'msg', '3': 2, '4': 1, '5': 9, '10': 'msg'},
    {'1': 'themes', '3': 3, '4': 3, '5': 11, '6': '.whisperingtime.ThemeDetail', '10': 'themes'},
  ],
};

/// Descriptor for `ListThemesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listThemesResponseDescriptor = $convert.base64Decode(
    'ChJMaXN0VGhlbWVzUmVzcG9uc2USEAoDZXJyGAEgASgFUgNlcnISEAoDbXNnGAIgASgJUgNtc2'
    'cSMwoGdGhlbWVzGAMgAygLMhsud2hpc3BlcmluZ3RpbWUuVGhlbWVEZXRhaWxSBnRoZW1lcw==');

@$core.Deprecated('Use createThemeRequestDescriptor instead')
const CreateThemeRequest$json = {
  '1': 'CreateThemeRequest',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 12, '10': 'name'},
    {'1': 'default_group_name', '3': 2, '4': 1, '5': 12, '10': 'defaultGroupName'},
    {'1': 'encrypted_key', '3': 3, '4': 1, '5': 12, '10': 'encryptedKey'},
    {'1': 'default_group_encrypted_key', '3': 4, '4': 1, '5': 12, '10': 'defaultGroupEncryptedKey'},
  ],
};

/// Descriptor for `CreateThemeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createThemeRequestDescriptor = $convert.base64Decode(
    'ChJDcmVhdGVUaGVtZVJlcXVlc3QSEgoEbmFtZRgBIAEoDFIEbmFtZRIsChJkZWZhdWx0X2dyb3'
    'VwX25hbWUYAiABKAxSEGRlZmF1bHRHcm91cE5hbWUSIwoNZW5jcnlwdGVkX2tleRgDIAEoDFIM'
    'ZW5jcnlwdGVkS2V5Ej0KG2RlZmF1bHRfZ3JvdXBfZW5jcnlwdGVkX2tleRgEIAEoDFIYZGVmYX'
    'VsdEdyb3VwRW5jcnlwdGVkS2V5');

@$core.Deprecated('Use createThemeResponseDescriptor instead')
const CreateThemeResponse$json = {
  '1': 'CreateThemeResponse',
  '2': [
    {'1': 'err', '3': 1, '4': 1, '5': 5, '10': 'err'},
    {'1': 'msg', '3': 2, '4': 1, '5': 9, '10': 'msg'},
    {'1': 'id', '3': 3, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `CreateThemeResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createThemeResponseDescriptor = $convert.base64Decode(
    'ChNDcmVhdGVUaGVtZVJlc3BvbnNlEhAKA2VychgBIAEoBVIDZXJyEhAKA21zZxgCIAEoCVIDbX'
    'NnEg4KAmlkGAMgASgJUgJpZA==');

@$core.Deprecated('Use updateThemeRequestDescriptor instead')
const UpdateThemeRequest$json = {
  '1': 'UpdateThemeRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 12, '10': 'name'},
    {'1': 'encrypted_key', '3': 3, '4': 1, '5': 12, '10': 'encryptedKey'},
  ],
};

/// Descriptor for `UpdateThemeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateThemeRequestDescriptor = $convert.base64Decode(
    'ChJVcGRhdGVUaGVtZVJlcXVlc3QSDgoCaWQYASABKAlSAmlkEhIKBG5hbWUYAiABKAxSBG5hbW'
    'USIwoNZW5jcnlwdGVkX2tleRgDIAEoDFIMZW5jcnlwdGVkS2V5');

@$core.Deprecated('Use deleteThemeRequestDescriptor instead')
const DeleteThemeRequest$json = {
  '1': 'DeleteThemeRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `DeleteThemeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteThemeRequestDescriptor = $convert.base64Decode(
    'ChJEZWxldGVUaGVtZVJlcXVlc3QSDgoCaWQYASABKAlSAmlk');

@$core.Deprecated('Use exportAllConfigRequestDescriptor instead')
const ExportAllConfigRequest$json = {
  '1': 'ExportAllConfigRequest',
};

/// Descriptor for `ExportAllConfigRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List exportAllConfigRequestDescriptor = $convert.base64Decode(
    'ChZFeHBvcnRBbGxDb25maWdSZXF1ZXN0');

@$core.Deprecated('Use listGroupsRequestDescriptor instead')
const ListGroupsRequest$json = {
  '1': 'ListGroupsRequest',
  '2': [
    {'1': 'theme_id', '3': 1, '4': 1, '5': 9, '10': 'themeId'},
  ],
};

/// Descriptor for `ListGroupsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listGroupsRequestDescriptor = $convert.base64Decode(
    'ChFMaXN0R3JvdXBzUmVxdWVzdBIZCgh0aGVtZV9pZBgBIAEoCVIHdGhlbWVJZA==');

@$core.Deprecated('Use listGroupsResponseDescriptor instead')
const ListGroupsResponse$json = {
  '1': 'ListGroupsResponse',
  '2': [
    {'1': 'err', '3': 1, '4': 1, '5': 5, '10': 'err'},
    {'1': 'msg', '3': 2, '4': 1, '5': 9, '10': 'msg'},
    {'1': 'groups', '3': 3, '4': 3, '5': 11, '6': '.whisperingtime.GroupSummary', '10': 'groups'},
  ],
};

/// Descriptor for `ListGroupsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listGroupsResponseDescriptor = $convert.base64Decode(
    'ChJMaXN0R3JvdXBzUmVzcG9uc2USEAoDZXJyGAEgASgFUgNlcnISEAoDbXNnGAIgASgJUgNtc2'
    'cSNAoGZ3JvdXBzGAMgAygLMhwud2hpc3BlcmluZ3RpbWUuR3JvdXBTdW1tYXJ5UgZncm91cHM=');

@$core.Deprecated('Use getGroupRequestDescriptor instead')
const GetGroupRequest$json = {
  '1': 'GetGroupRequest',
  '2': [
    {'1': 'theme_id', '3': 1, '4': 1, '5': 9, '10': 'themeId'},
    {'1': 'group_id', '3': 2, '4': 1, '5': 9, '10': 'groupId'},
    {'1': 'include_docs', '3': 3, '4': 1, '5': 8, '10': 'includeDocs'},
    {'1': 'include_detail', '3': 4, '4': 1, '5': 8, '10': 'includeDetail'},
  ],
};

/// Descriptor for `GetGroupRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getGroupRequestDescriptor = $convert.base64Decode(
    'Cg9HZXRHcm91cFJlcXVlc3QSGQoIdGhlbWVfaWQYASABKAlSB3RoZW1lSWQSGQoIZ3JvdXBfaW'
    'QYAiABKAlSB2dyb3VwSWQSIQoMaW5jbHVkZV9kb2NzGAMgASgIUgtpbmNsdWRlRG9jcxIlCg5p'
    'bmNsdWRlX2RldGFpbBgEIAEoCFINaW5jbHVkZURldGFpbA==');

@$core.Deprecated('Use getGroupResponseDescriptor instead')
const GetGroupResponse$json = {
  '1': 'GetGroupResponse',
  '2': [
    {'1': 'err', '3': 1, '4': 1, '5': 5, '10': 'err'},
    {'1': 'msg', '3': 2, '4': 1, '5': 9, '10': 'msg'},
    {'1': 'group', '3': 3, '4': 1, '5': 11, '6': '.whisperingtime.GroupDetail', '10': 'group'},
  ],
};

/// Descriptor for `GetGroupResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getGroupResponseDescriptor = $convert.base64Decode(
    'ChBHZXRHcm91cFJlc3BvbnNlEhAKA2VychgBIAEoBVIDZXJyEhAKA21zZxgCIAEoCVIDbXNnEj'
    'EKBWdyb3VwGAMgASgLMhsud2hpc3BlcmluZ3RpbWUuR3JvdXBEZXRhaWxSBWdyb3Vw');

@$core.Deprecated('Use createGroupRequestDescriptor instead')
const CreateGroupRequest$json = {
  '1': 'CreateGroupRequest',
  '2': [
    {'1': 'theme_id', '3': 1, '4': 1, '5': 9, '10': 'themeId'},
    {'1': 'name', '3': 2, '4': 1, '5': 12, '10': 'name'},
    {'1': 'auto_freeze_days', '3': 3, '4': 1, '5': 5, '10': 'autoFreezeDays'},
    {'1': 'encrypted_key', '3': 4, '4': 1, '5': 12, '10': 'encryptedKey'},
  ],
};

/// Descriptor for `CreateGroupRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createGroupRequestDescriptor = $convert.base64Decode(
    'ChJDcmVhdGVHcm91cFJlcXVlc3QSGQoIdGhlbWVfaWQYASABKAlSB3RoZW1lSWQSEgoEbmFtZR'
    'gCIAEoDFIEbmFtZRIoChBhdXRvX2ZyZWV6ZV9kYXlzGAMgASgFUg5hdXRvRnJlZXplRGF5cxIj'
    'Cg1lbmNyeXB0ZWRfa2V5GAQgASgMUgxlbmNyeXB0ZWRLZXk=');

@$core.Deprecated('Use createGroupResponseDescriptor instead')
const CreateGroupResponse$json = {
  '1': 'CreateGroupResponse',
  '2': [
    {'1': 'err', '3': 1, '4': 1, '5': 5, '10': 'err'},
    {'1': 'msg', '3': 2, '4': 1, '5': 9, '10': 'msg'},
    {'1': 'id', '3': 3, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `CreateGroupResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createGroupResponseDescriptor = $convert.base64Decode(
    'ChNDcmVhdGVHcm91cFJlc3BvbnNlEhAKA2VychgBIAEoBVIDZXJyEhAKA21zZxgCIAEoCVIDbX'
    'NnEg4KAmlkGAMgASgJUgJpZA==');

@$core.Deprecated('Use updateGroupRequestDescriptor instead')
const UpdateGroupRequest$json = {
  '1': 'UpdateGroupRequest',
  '2': [
    {'1': 'theme_id', '3': 1, '4': 1, '5': 9, '10': 'themeId'},
    {'1': 'group_id', '3': 2, '4': 1, '5': 9, '10': 'groupId'},
    {'1': 'name', '3': 3, '4': 1, '5': 12, '10': 'name'},
    {'1': 'config', '3': 4, '4': 1, '5': 11, '6': '.whisperingtime.GroupConfig', '10': 'config'},
    {'1': 'over_at', '3': 5, '4': 1, '5': 3, '10': 'overAt'},
    {'1': 'encrypted_key', '3': 6, '4': 1, '5': 12, '10': 'encryptedKey'},
  ],
};

/// Descriptor for `UpdateGroupRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateGroupRequestDescriptor = $convert.base64Decode(
    'ChJVcGRhdGVHcm91cFJlcXVlc3QSGQoIdGhlbWVfaWQYASABKAlSB3RoZW1lSWQSGQoIZ3JvdX'
    'BfaWQYAiABKAlSB2dyb3VwSWQSEgoEbmFtZRgDIAEoDFIEbmFtZRIzCgZjb25maWcYBCABKAsy'
    'Gy53aGlzcGVyaW5ndGltZS5Hcm91cENvbmZpZ1IGY29uZmlnEhcKB292ZXJfYXQYBSABKANSBm'
    '92ZXJBdBIjCg1lbmNyeXB0ZWRfa2V5GAYgASgMUgxlbmNyeXB0ZWRLZXk=');

@$core.Deprecated('Use deleteGroupRequestDescriptor instead')
const DeleteGroupRequest$json = {
  '1': 'DeleteGroupRequest',
  '2': [
    {'1': 'theme_id', '3': 1, '4': 1, '5': 9, '10': 'themeId'},
    {'1': 'group_id', '3': 2, '4': 1, '5': 9, '10': 'groupId'},
  ],
};

/// Descriptor for `DeleteGroupRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteGroupRequestDescriptor = $convert.base64Decode(
    'ChJEZWxldGVHcm91cFJlcXVlc3QSGQoIdGhlbWVfaWQYASABKAlSB3RoZW1lSWQSGQoIZ3JvdX'
    'BfaWQYAiABKAlSB2dyb3VwSWQ=');

@$core.Deprecated('Use exportGroupConfigRequestDescriptor instead')
const ExportGroupConfigRequest$json = {
  '1': 'ExportGroupConfigRequest',
  '2': [
    {'1': 'theme_id', '3': 1, '4': 1, '5': 9, '10': 'themeId'},
    {'1': 'group_id', '3': 2, '4': 1, '5': 9, '10': 'groupId'},
  ],
};

/// Descriptor for `ExportGroupConfigRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List exportGroupConfigRequestDescriptor = $convert.base64Decode(
    'ChhFeHBvcnRHcm91cENvbmZpZ1JlcXVlc3QSGQoIdGhlbWVfaWQYASABKAlSB3RoZW1lSWQSGQ'
    'oIZ3JvdXBfaWQYAiABKAlSB2dyb3VwSWQ=');

@$core.Deprecated('Use importGroupConfigResponseDescriptor instead')
const ImportGroupConfigResponse$json = {
  '1': 'ImportGroupConfigResponse',
  '2': [
    {'1': 'err', '3': 1, '4': 1, '5': 5, '10': 'err'},
    {'1': 'msg', '3': 2, '4': 1, '5': 9, '10': 'msg'},
  ],
};

/// Descriptor for `ImportGroupConfigResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List importGroupConfigResponseDescriptor = $convert.base64Decode(
    'ChlJbXBvcnRHcm91cENvbmZpZ1Jlc3BvbnNlEhAKA2VychgBIAEoBVIDZXJyEhAKA21zZxgCIA'
    'EoCVIDbXNn');

@$core.Deprecated('Use listDocsRequestDescriptor instead')
const ListDocsRequest$json = {
  '1': 'ListDocsRequest',
  '2': [
    {'1': 'group_id', '3': 1, '4': 1, '5': 9, '10': 'groupId'},
    {'1': 'year', '3': 2, '4': 1, '5': 5, '10': 'year'},
    {'1': 'month', '3': 3, '4': 1, '5': 5, '10': 'month'},
  ],
};

/// Descriptor for `ListDocsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listDocsRequestDescriptor = $convert.base64Decode(
    'Cg9MaXN0RG9jc1JlcXVlc3QSGQoIZ3JvdXBfaWQYASABKAlSB2dyb3VwSWQSEgoEeWVhchgCIA'
    'EoBVIEeWVhchIUCgVtb250aBgDIAEoBVIFbW9udGg=');

@$core.Deprecated('Use listDocsResponseDescriptor instead')
const ListDocsResponse$json = {
  '1': 'ListDocsResponse',
  '2': [
    {'1': 'err', '3': 1, '4': 1, '5': 5, '10': 'err'},
    {'1': 'msg', '3': 2, '4': 1, '5': 9, '10': 'msg'},
    {'1': 'docs', '3': 3, '4': 3, '5': 11, '6': '.whisperingtime.DocSummary', '10': 'docs'},
  ],
};

/// Descriptor for `ListDocsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listDocsResponseDescriptor = $convert.base64Decode(
    'ChBMaXN0RG9jc1Jlc3BvbnNlEhAKA2VychgBIAEoBVIDZXJyEhAKA21zZxgCIAEoCVIDbXNnEi'
    '4KBGRvY3MYAyADKAsyGi53aGlzcGVyaW5ndGltZS5Eb2NTdW1tYXJ5UgRkb2Nz');

@$core.Deprecated('Use createDocRequestDescriptor instead')
const CreateDocRequest$json = {
  '1': 'CreateDocRequest',
  '2': [
    {'1': 'group_id', '3': 1, '4': 1, '5': 9, '10': 'groupId'},
    {'1': 'content', '3': 2, '4': 1, '5': 11, '6': '.whisperingtime.Content', '10': 'content'},
    {'1': 'create_at', '3': 6, '4': 1, '5': 3, '10': 'createAt'},
    {'1': 'encrypted_key', '3': 7, '4': 1, '5': 12, '10': 'encryptedKey'},
  ],
  '9': [
    {'1': 5, '2': 6},
  ],
};

/// Descriptor for `CreateDocRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createDocRequestDescriptor = $convert.base64Decode(
    'ChBDcmVhdGVEb2NSZXF1ZXN0EhkKCGdyb3VwX2lkGAEgASgJUgdncm91cElkEjEKB2NvbnRlbn'
    'QYAiABKAsyFy53aGlzcGVyaW5ndGltZS5Db250ZW50Ugdjb250ZW50EhsKCWNyZWF0ZV9hdBgG'
    'IAEoA1IIY3JlYXRlQXQSIwoNZW5jcnlwdGVkX2tleRgHIAEoDFIMZW5jcnlwdGVkS2V5SgQIBR'
    'AG');

@$core.Deprecated('Use createDocResponseDescriptor instead')
const CreateDocResponse$json = {
  '1': 'CreateDocResponse',
  '2': [
    {'1': 'err', '3': 1, '4': 1, '5': 5, '10': 'err'},
    {'1': 'msg', '3': 2, '4': 1, '5': 9, '10': 'msg'},
    {'1': 'id', '3': 3, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `CreateDocResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createDocResponseDescriptor = $convert.base64Decode(
    'ChFDcmVhdGVEb2NSZXNwb25zZRIQCgNlcnIYASABKAVSA2VychIQCgNtc2cYAiABKAlSA21zZx'
    'IOCgJpZBgDIAEoCVICaWQ=');

@$core.Deprecated('Use updateDocRequestDescriptor instead')
const UpdateDocRequest$json = {
  '1': 'UpdateDocRequest',
  '2': [
    {'1': 'group_id', '3': 1, '4': 1, '5': 9, '10': 'groupId'},
    {'1': 'doc_id', '3': 2, '4': 1, '5': 9, '10': 'docId'},
    {'1': 'content', '3': 3, '4': 1, '5': 11, '6': '.whisperingtime.Content', '10': 'content'},
    {'1': 'create_at', '3': 7, '4': 1, '5': 3, '10': 'createAt'},
    {'1': 'encrypted_key', '3': 8, '4': 1, '5': 12, '10': 'encryptedKey'},
  ],
  '9': [
    {'1': 6, '2': 7},
  ],
};

/// Descriptor for `UpdateDocRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateDocRequestDescriptor = $convert.base64Decode(
    'ChBVcGRhdGVEb2NSZXF1ZXN0EhkKCGdyb3VwX2lkGAEgASgJUgdncm91cElkEhUKBmRvY19pZB'
    'gCIAEoCVIFZG9jSWQSMQoHY29udGVudBgDIAEoCzIXLndoaXNwZXJpbmd0aW1lLkNvbnRlbnRS'
    'B2NvbnRlbnQSGwoJY3JlYXRlX2F0GAcgASgDUghjcmVhdGVBdBIjCg1lbmNyeXB0ZWRfa2V5GA'
    'ggASgMUgxlbmNyeXB0ZWRLZXlKBAgGEAc=');

@$core.Deprecated('Use deleteDocRequestDescriptor instead')
const DeleteDocRequest$json = {
  '1': 'DeleteDocRequest',
  '2': [
    {'1': 'group_id', '3': 1, '4': 1, '5': 9, '10': 'groupId'},
    {'1': 'doc_id', '3': 2, '4': 1, '5': 9, '10': 'docId'},
  ],
};

/// Descriptor for `DeleteDocRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteDocRequestDescriptor = $convert.base64Decode(
    'ChBEZWxldGVEb2NSZXF1ZXN0EhkKCGdyb3VwX2lkGAEgASgJUgdncm91cElkEhUKBmRvY19pZB'
    'gCIAEoCVIFZG9jSWQ=');

@$core.Deprecated('Use uploadImageResponseDescriptor instead')
const UploadImageResponse$json = {
  '1': 'UploadImageResponse',
  '2': [
    {'1': 'err', '3': 1, '4': 1, '5': 5, '10': 'err'},
    {'1': 'msg', '3': 2, '4': 1, '5': 9, '10': 'msg'},
    {'1': 'name', '3': 3, '4': 1, '5': 9, '10': 'name'},
    {'1': 'url', '3': 4, '4': 1, '5': 9, '10': 'url'},
  ],
};

/// Descriptor for `UploadImageResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List uploadImageResponseDescriptor = $convert.base64Decode(
    'ChNVcGxvYWRJbWFnZVJlc3BvbnNlEhAKA2VychgBIAEoBVIDZXJyEhAKA21zZxgCIAEoCVIDbX'
    'NnEhIKBG5hbWUYAyABKAlSBG5hbWUSEAoDdXJsGAQgASgJUgN1cmw=');

@$core.Deprecated('Use deleteImageRequestDescriptor instead')
const DeleteImageRequest$json = {
  '1': 'DeleteImageRequest',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
  ],
};

/// Descriptor for `DeleteImageRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteImageRequestDescriptor = $convert.base64Decode(
    'ChJEZWxldGVJbWFnZVJlcXVlc3QSEgoEbmFtZRgBIAEoCVIEbmFtZQ==');

@$core.Deprecated('Use imageUploadChunkDescriptor instead')
const ImageUploadChunk$json = {
  '1': 'ImageUploadChunk',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'mime', '3': 2, '4': 1, '5': 9, '10': 'mime'},
    {'1': 'data', '3': 3, '4': 1, '5': 12, '10': 'data'},
  ],
};

/// Descriptor for `ImageUploadChunk`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List imageUploadChunkDescriptor = $convert.base64Decode(
    'ChBJbWFnZVVwbG9hZENodW5rEhcKB3VzZXJfaWQYASABKAlSBnVzZXJJZBISCgRtaW1lGAIgAS'
    'gJUgRtaW1lEhIKBGRhdGEYAyABKAxSBGRhdGE=');

@$core.Deprecated('Use backgroundJobDescriptor instead')
const BackgroundJob$json = {
  '1': 'BackgroundJob',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'job_type', '3': 3, '4': 1, '5': 9, '10': 'jobType'},
    {'1': 'status', '3': 4, '4': 1, '5': 9, '10': 'status'},
    {'1': 'created_at', '3': 5, '4': 1, '5': 9, '10': 'createdAt'},
    {'1': 'started_at', '3': 6, '4': 1, '5': 9, '10': 'startedAt'},
    {'1': 'completed_at', '3': 7, '4': 1, '5': 9, '10': 'completedAt'},
    {'1': 'priority', '3': 8, '4': 1, '5': 5, '10': 'priority'},
    {'1': 'retry_count', '3': 9, '4': 1, '5': 5, '10': 'retryCount'},
    {'1': 'result_json', '3': 10, '4': 1, '5': 9, '10': 'resultJson'},
    {'1': 'error_json', '3': 11, '4': 1, '5': 9, '10': 'errorJson'},
  ],
};

/// Descriptor for `BackgroundJob`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List backgroundJobDescriptor = $convert.base64Decode(
    'Cg1CYWNrZ3JvdW5kSm9iEg4KAmlkGAEgASgJUgJpZBISCgRuYW1lGAIgASgJUgRuYW1lEhkKCG'
    'pvYl90eXBlGAMgASgJUgdqb2JUeXBlEhYKBnN0YXR1cxgEIAEoCVIGc3RhdHVzEh0KCmNyZWF0'
    'ZWRfYXQYBSABKAlSCWNyZWF0ZWRBdBIdCgpzdGFydGVkX2F0GAYgASgJUglzdGFydGVkQXQSIQ'
    'oMY29tcGxldGVkX2F0GAcgASgJUgtjb21wbGV0ZWRBdBIaCghwcmlvcml0eRgIIAEoBVIIcHJp'
    'b3JpdHkSHwoLcmV0cnlfY291bnQYCSABKAVSCnJldHJ5Q291bnQSHwoLcmVzdWx0X2pzb24YCi'
    'ABKAlSCnJlc3VsdEpzb24SHQoKZXJyb3JfanNvbhgLIAEoCVIJZXJyb3JKc29u');

@$core.Deprecated('Use listBackgroundJobsRequestDescriptor instead')
const ListBackgroundJobsRequest$json = {
  '1': 'ListBackgroundJobsRequest',
};

/// Descriptor for `ListBackgroundJobsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listBackgroundJobsRequestDescriptor = $convert.base64Decode(
    'ChlMaXN0QmFja2dyb3VuZEpvYnNSZXF1ZXN0');

@$core.Deprecated('Use listBackgroundJobsResponseDescriptor instead')
const ListBackgroundJobsResponse$json = {
  '1': 'ListBackgroundJobsResponse',
  '2': [
    {'1': 'err', '3': 1, '4': 1, '5': 5, '10': 'err'},
    {'1': 'msg', '3': 2, '4': 1, '5': 9, '10': 'msg'},
    {'1': 'jobs', '3': 3, '4': 3, '5': 11, '6': '.whisperingtime.BackgroundJob', '10': 'jobs'},
  ],
};

/// Descriptor for `ListBackgroundJobsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listBackgroundJobsResponseDescriptor = $convert.base64Decode(
    'ChpMaXN0QmFja2dyb3VuZEpvYnNSZXNwb25zZRIQCgNlcnIYASABKAVSA2VychIQCgNtc2cYAi'
    'ABKAlSA21zZxIxCgRqb2JzGAMgAygLMh0ud2hpc3BlcmluZ3RpbWUuQmFja2dyb3VuZEpvYlIE'
    'am9icw==');

@$core.Deprecated('Use getBackgroundJobRequestDescriptor instead')
const GetBackgroundJobRequest$json = {
  '1': 'GetBackgroundJobRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `GetBackgroundJobRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBackgroundJobRequestDescriptor = $convert.base64Decode(
    'ChdHZXRCYWNrZ3JvdW5kSm9iUmVxdWVzdBIOCgJpZBgBIAEoCVICaWQ=');

@$core.Deprecated('Use deleteBackgroundJobRequestDescriptor instead')
const DeleteBackgroundJobRequest$json = {
  '1': 'DeleteBackgroundJobRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `DeleteBackgroundJobRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteBackgroundJobRequestDescriptor = $convert.base64Decode(
    'ChpEZWxldGVCYWNrZ3JvdW5kSm9iUmVxdWVzdBIOCgJpZBgBIAEoCVICaWQ=');

@$core.Deprecated('Use downloadBackgroundJobFileRequestDescriptor instead')
const DownloadBackgroundJobFileRequest$json = {
  '1': 'DownloadBackgroundJobFileRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `DownloadBackgroundJobFileRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List downloadBackgroundJobFileRequestDescriptor = $convert.base64Decode(
    'CiBEb3dubG9hZEJhY2tncm91bmRKb2JGaWxlUmVxdWVzdBIOCgJpZBgBIAEoCVICaWQ=');

@$core.Deprecated('Use downloadBackgroundJobFileResponseDescriptor instead')
const DownloadBackgroundJobFileResponse$json = {
  '1': 'DownloadBackgroundJobFileResponse',
  '2': [
    {'1': 'err', '3': 1, '4': 1, '5': 5, '10': 'err'},
    {'1': 'msg', '3': 2, '4': 1, '5': 9, '10': 'msg'},
    {'1': 'data', '3': 3, '4': 1, '5': 12, '10': 'data'},
    {'1': 'filename', '3': 4, '4': 1, '5': 9, '10': 'filename'},
  ],
};

/// Descriptor for `DownloadBackgroundJobFileResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List downloadBackgroundJobFileResponseDescriptor = $convert.base64Decode(
    'CiFEb3dubG9hZEJhY2tncm91bmRKb2JGaWxlUmVzcG9uc2USEAoDZXJyGAEgASgFUgNlcnISEA'
    'oDbXNnGAIgASgJUgNtc2cSEgoEZGF0YRgDIAEoDFIEZGF0YRIaCghmaWxlbmFtZRgEIAEoCVII'
    'ZmlsZW5hbWU=');

@$core.Deprecated('Use bytesChunkDescriptor instead')
const BytesChunk$json = {
  '1': 'BytesChunk',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 12, '10': 'data'},
  ],
};

/// Descriptor for `BytesChunk`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List bytesChunkDescriptor = $convert.base64Decode(
    'CgpCeXRlc0NodW5rEhIKBGRhdGEYASABKAxSBGRhdGE=');

