//
//  Generated code. Do not modify.
//  source: whisperingtime.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'whisperingtime.pb.dart' as $0;

export 'whisperingtime.pb.dart';

@$pb.GrpcServiceName('whisperingtime.ThemeService')
class ThemeServiceClient extends $grpc.Client {
  static final _$listThemes = $grpc.ClientMethod<$0.ListThemesRequest, $0.ListThemesResponse>(
      '/whisperingtime.ThemeService/ListThemes',
      ($0.ListThemesRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.ListThemesResponse.fromBuffer(value));
  static final _$createTheme = $grpc.ClientMethod<$0.CreateThemeRequest, $0.CreateThemeResponse>(
      '/whisperingtime.ThemeService/CreateTheme',
      ($0.CreateThemeRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.CreateThemeResponse.fromBuffer(value));
  static final _$updateTheme = $grpc.ClientMethod<$0.UpdateThemeRequest, $0.BasicResponse>(
      '/whisperingtime.ThemeService/UpdateTheme',
      ($0.UpdateThemeRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.BasicResponse.fromBuffer(value));
  static final _$deleteTheme = $grpc.ClientMethod<$0.DeleteThemeRequest, $0.BasicResponse>(
      '/whisperingtime.ThemeService/DeleteTheme',
      ($0.DeleteThemeRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.BasicResponse.fromBuffer(value));
  static final _$exportAllConfig = $grpc.ClientMethod<$0.ExportAllConfigRequest, $0.BasicResponse>(
      '/whisperingtime.ThemeService/ExportAllConfig',
      ($0.ExportAllConfigRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.BasicResponse.fromBuffer(value));
  static final _$deleteUserData = $grpc.ClientMethod<$0.DeleteUserDataRequest, $0.BasicResponse>(
      '/whisperingtime.ThemeService/DeleteUserData',
      ($0.DeleteUserDataRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.BasicResponse.fromBuffer(value));

  ThemeServiceClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options,
        interceptors: interceptors);

  $grpc.ResponseFuture<$0.ListThemesResponse> listThemes($0.ListThemesRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$listThemes, request, options: options);
  }

  $grpc.ResponseFuture<$0.CreateThemeResponse> createTheme($0.CreateThemeRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$createTheme, request, options: options);
  }

  $grpc.ResponseFuture<$0.BasicResponse> updateTheme($0.UpdateThemeRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$updateTheme, request, options: options);
  }

  $grpc.ResponseFuture<$0.BasicResponse> deleteTheme($0.DeleteThemeRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$deleteTheme, request, options: options);
  }

  $grpc.ResponseFuture<$0.BasicResponse> exportAllConfig($0.ExportAllConfigRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$exportAllConfig, request, options: options);
  }

  $grpc.ResponseFuture<$0.BasicResponse> deleteUserData($0.DeleteUserDataRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$deleteUserData, request, options: options);
  }
}

@$pb.GrpcServiceName('whisperingtime.ThemeService')
abstract class ThemeServiceBase extends $grpc.Service {
  $core.String get $name => 'whisperingtime.ThemeService';

  ThemeServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.ListThemesRequest, $0.ListThemesResponse>(
        'ListThemes',
        listThemes_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ListThemesRequest.fromBuffer(value),
        ($0.ListThemesResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.CreateThemeRequest, $0.CreateThemeResponse>(
        'CreateTheme',
        createTheme_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.CreateThemeRequest.fromBuffer(value),
        ($0.CreateThemeResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.UpdateThemeRequest, $0.BasicResponse>(
        'UpdateTheme',
        updateTheme_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.UpdateThemeRequest.fromBuffer(value),
        ($0.BasicResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DeleteThemeRequest, $0.BasicResponse>(
        'DeleteTheme',
        deleteTheme_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.DeleteThemeRequest.fromBuffer(value),
        ($0.BasicResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ExportAllConfigRequest, $0.BasicResponse>(
        'ExportAllConfig',
        exportAllConfig_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ExportAllConfigRequest.fromBuffer(value),
        ($0.BasicResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DeleteUserDataRequest, $0.BasicResponse>(
        'DeleteUserData',
        deleteUserData_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.DeleteUserDataRequest.fromBuffer(value),
        ($0.BasicResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.ListThemesResponse> listThemes_Pre($grpc.ServiceCall call, $async.Future<$0.ListThemesRequest> request) async {
    return listThemes(call, await request);
  }

  $async.Future<$0.CreateThemeResponse> createTheme_Pre($grpc.ServiceCall call, $async.Future<$0.CreateThemeRequest> request) async {
    return createTheme(call, await request);
  }

  $async.Future<$0.BasicResponse> updateTheme_Pre($grpc.ServiceCall call, $async.Future<$0.UpdateThemeRequest> request) async {
    return updateTheme(call, await request);
  }

  $async.Future<$0.BasicResponse> deleteTheme_Pre($grpc.ServiceCall call, $async.Future<$0.DeleteThemeRequest> request) async {
    return deleteTheme(call, await request);
  }

  $async.Future<$0.BasicResponse> exportAllConfig_Pre($grpc.ServiceCall call, $async.Future<$0.ExportAllConfigRequest> request) async {
    return exportAllConfig(call, await request);
  }

  $async.Future<$0.BasicResponse> deleteUserData_Pre($grpc.ServiceCall call, $async.Future<$0.DeleteUserDataRequest> request) async {
    return deleteUserData(call, await request);
  }

  $async.Future<$0.ListThemesResponse> listThemes($grpc.ServiceCall call, $0.ListThemesRequest request);
  $async.Future<$0.CreateThemeResponse> createTheme($grpc.ServiceCall call, $0.CreateThemeRequest request);
  $async.Future<$0.BasicResponse> updateTheme($grpc.ServiceCall call, $0.UpdateThemeRequest request);
  $async.Future<$0.BasicResponse> deleteTheme($grpc.ServiceCall call, $0.DeleteThemeRequest request);
  $async.Future<$0.BasicResponse> exportAllConfig($grpc.ServiceCall call, $0.ExportAllConfigRequest request);
  $async.Future<$0.BasicResponse> deleteUserData($grpc.ServiceCall call, $0.DeleteUserDataRequest request);
}
@$pb.GrpcServiceName('whisperingtime.GroupService')
class GroupServiceClient extends $grpc.Client {
  static final _$listGroups = $grpc.ClientMethod<$0.ListGroupsRequest, $0.ListGroupsResponse>(
      '/whisperingtime.GroupService/ListGroups',
      ($0.ListGroupsRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.ListGroupsResponse.fromBuffer(value));
  static final _$getGroup = $grpc.ClientMethod<$0.GetGroupRequest, $0.GetGroupResponse>(
      '/whisperingtime.GroupService/GetGroup',
      ($0.GetGroupRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.GetGroupResponse.fromBuffer(value));
  static final _$createGroup = $grpc.ClientMethod<$0.CreateGroupRequest, $0.CreateGroupResponse>(
      '/whisperingtime.GroupService/CreateGroup',
      ($0.CreateGroupRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.CreateGroupResponse.fromBuffer(value));
  static final _$updateGroup = $grpc.ClientMethod<$0.UpdateGroupRequest, $0.BasicResponse>(
      '/whisperingtime.GroupService/UpdateGroup',
      ($0.UpdateGroupRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.BasicResponse.fromBuffer(value));
  static final _$deleteGroup = $grpc.ClientMethod<$0.DeleteGroupRequest, $0.BasicResponse>(
      '/whisperingtime.GroupService/DeleteGroup',
      ($0.DeleteGroupRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.BasicResponse.fromBuffer(value));
  static final _$exportGroupConfig = $grpc.ClientMethod<$0.ExportGroupConfigRequest, $0.BasicResponse>(
      '/whisperingtime.GroupService/ExportGroupConfig',
      ($0.ExportGroupConfigRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.BasicResponse.fromBuffer(value));
  static final _$importGroupConfig = $grpc.ClientMethod<$0.BytesChunk, $0.ImportGroupConfigResponse>(
      '/whisperingtime.GroupService/ImportGroupConfig',
      ($0.BytesChunk value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.ImportGroupConfigResponse.fromBuffer(value));

  GroupServiceClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options,
        interceptors: interceptors);

  $grpc.ResponseFuture<$0.ListGroupsResponse> listGroups($0.ListGroupsRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$listGroups, request, options: options);
  }

  $grpc.ResponseFuture<$0.GetGroupResponse> getGroup($0.GetGroupRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getGroup, request, options: options);
  }

  $grpc.ResponseFuture<$0.CreateGroupResponse> createGroup($0.CreateGroupRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$createGroup, request, options: options);
  }

  $grpc.ResponseFuture<$0.BasicResponse> updateGroup($0.UpdateGroupRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$updateGroup, request, options: options);
  }

  $grpc.ResponseFuture<$0.BasicResponse> deleteGroup($0.DeleteGroupRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$deleteGroup, request, options: options);
  }

  $grpc.ResponseFuture<$0.BasicResponse> exportGroupConfig($0.ExportGroupConfigRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$exportGroupConfig, request, options: options);
  }

  $grpc.ResponseFuture<$0.ImportGroupConfigResponse> importGroupConfig($async.Stream<$0.BytesChunk> request, {$grpc.CallOptions? options}) {
    return $createStreamingCall(_$importGroupConfig, request, options: options).single;
  }
}

@$pb.GrpcServiceName('whisperingtime.GroupService')
abstract class GroupServiceBase extends $grpc.Service {
  $core.String get $name => 'whisperingtime.GroupService';

  GroupServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.ListGroupsRequest, $0.ListGroupsResponse>(
        'ListGroups',
        listGroups_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ListGroupsRequest.fromBuffer(value),
        ($0.ListGroupsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetGroupRequest, $0.GetGroupResponse>(
        'GetGroup',
        getGroup_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GetGroupRequest.fromBuffer(value),
        ($0.GetGroupResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.CreateGroupRequest, $0.CreateGroupResponse>(
        'CreateGroup',
        createGroup_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.CreateGroupRequest.fromBuffer(value),
        ($0.CreateGroupResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.UpdateGroupRequest, $0.BasicResponse>(
        'UpdateGroup',
        updateGroup_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.UpdateGroupRequest.fromBuffer(value),
        ($0.BasicResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DeleteGroupRequest, $0.BasicResponse>(
        'DeleteGroup',
        deleteGroup_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.DeleteGroupRequest.fromBuffer(value),
        ($0.BasicResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ExportGroupConfigRequest, $0.BasicResponse>(
        'ExportGroupConfig',
        exportGroupConfig_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ExportGroupConfigRequest.fromBuffer(value),
        ($0.BasicResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.BytesChunk, $0.ImportGroupConfigResponse>(
        'ImportGroupConfig',
        importGroupConfig,
        true,
        false,
        ($core.List<$core.int> value) => $0.BytesChunk.fromBuffer(value),
        ($0.ImportGroupConfigResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.ListGroupsResponse> listGroups_Pre($grpc.ServiceCall call, $async.Future<$0.ListGroupsRequest> request) async {
    return listGroups(call, await request);
  }

  $async.Future<$0.GetGroupResponse> getGroup_Pre($grpc.ServiceCall call, $async.Future<$0.GetGroupRequest> request) async {
    return getGroup(call, await request);
  }

  $async.Future<$0.CreateGroupResponse> createGroup_Pre($grpc.ServiceCall call, $async.Future<$0.CreateGroupRequest> request) async {
    return createGroup(call, await request);
  }

  $async.Future<$0.BasicResponse> updateGroup_Pre($grpc.ServiceCall call, $async.Future<$0.UpdateGroupRequest> request) async {
    return updateGroup(call, await request);
  }

  $async.Future<$0.BasicResponse> deleteGroup_Pre($grpc.ServiceCall call, $async.Future<$0.DeleteGroupRequest> request) async {
    return deleteGroup(call, await request);
  }

  $async.Future<$0.BasicResponse> exportGroupConfig_Pre($grpc.ServiceCall call, $async.Future<$0.ExportGroupConfigRequest> request) async {
    return exportGroupConfig(call, await request);
  }

  $async.Future<$0.ListGroupsResponse> listGroups($grpc.ServiceCall call, $0.ListGroupsRequest request);
  $async.Future<$0.GetGroupResponse> getGroup($grpc.ServiceCall call, $0.GetGroupRequest request);
  $async.Future<$0.CreateGroupResponse> createGroup($grpc.ServiceCall call, $0.CreateGroupRequest request);
  $async.Future<$0.BasicResponse> updateGroup($grpc.ServiceCall call, $0.UpdateGroupRequest request);
  $async.Future<$0.BasicResponse> deleteGroup($grpc.ServiceCall call, $0.DeleteGroupRequest request);
  $async.Future<$0.BasicResponse> exportGroupConfig($grpc.ServiceCall call, $0.ExportGroupConfigRequest request);
  $async.Future<$0.ImportGroupConfigResponse> importGroupConfig($grpc.ServiceCall call, $async.Stream<$0.BytesChunk> request);
}
@$pb.GrpcServiceName('whisperingtime.DocService')
class DocServiceClient extends $grpc.Client {
  static final _$listDocs = $grpc.ClientMethod<$0.ListDocsRequest, $0.ListDocsResponse>(
      '/whisperingtime.DocService/ListDocs',
      ($0.ListDocsRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.ListDocsResponse.fromBuffer(value));
  static final _$createDoc = $grpc.ClientMethod<$0.CreateDocRequest, $0.CreateDocResponse>(
      '/whisperingtime.DocService/CreateDoc',
      ($0.CreateDocRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.CreateDocResponse.fromBuffer(value));
  static final _$updateDoc = $grpc.ClientMethod<$0.UpdateDocRequest, $0.BasicResponse>(
      '/whisperingtime.DocService/UpdateDoc',
      ($0.UpdateDocRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.BasicResponse.fromBuffer(value));
  static final _$deleteDoc = $grpc.ClientMethod<$0.DeleteDocRequest, $0.BasicResponse>(
      '/whisperingtime.DocService/DeleteDoc',
      ($0.DeleteDocRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.BasicResponse.fromBuffer(value));

  DocServiceClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options,
        interceptors: interceptors);

  $grpc.ResponseFuture<$0.ListDocsResponse> listDocs($0.ListDocsRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$listDocs, request, options: options);
  }

  $grpc.ResponseFuture<$0.CreateDocResponse> createDoc($0.CreateDocRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$createDoc, request, options: options);
  }

  $grpc.ResponseFuture<$0.BasicResponse> updateDoc($0.UpdateDocRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$updateDoc, request, options: options);
  }

  $grpc.ResponseFuture<$0.BasicResponse> deleteDoc($0.DeleteDocRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$deleteDoc, request, options: options);
  }
}

@$pb.GrpcServiceName('whisperingtime.DocService')
abstract class DocServiceBase extends $grpc.Service {
  $core.String get $name => 'whisperingtime.DocService';

  DocServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.ListDocsRequest, $0.ListDocsResponse>(
        'ListDocs',
        listDocs_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ListDocsRequest.fromBuffer(value),
        ($0.ListDocsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.CreateDocRequest, $0.CreateDocResponse>(
        'CreateDoc',
        createDoc_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.CreateDocRequest.fromBuffer(value),
        ($0.CreateDocResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.UpdateDocRequest, $0.BasicResponse>(
        'UpdateDoc',
        updateDoc_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.UpdateDocRequest.fromBuffer(value),
        ($0.BasicResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DeleteDocRequest, $0.BasicResponse>(
        'DeleteDoc',
        deleteDoc_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.DeleteDocRequest.fromBuffer(value),
        ($0.BasicResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.ListDocsResponse> listDocs_Pre($grpc.ServiceCall call, $async.Future<$0.ListDocsRequest> request) async {
    return listDocs(call, await request);
  }

  $async.Future<$0.CreateDocResponse> createDoc_Pre($grpc.ServiceCall call, $async.Future<$0.CreateDocRequest> request) async {
    return createDoc(call, await request);
  }

  $async.Future<$0.BasicResponse> updateDoc_Pre($grpc.ServiceCall call, $async.Future<$0.UpdateDocRequest> request) async {
    return updateDoc(call, await request);
  }

  $async.Future<$0.BasicResponse> deleteDoc_Pre($grpc.ServiceCall call, $async.Future<$0.DeleteDocRequest> request) async {
    return deleteDoc(call, await request);
  }

  $async.Future<$0.ListDocsResponse> listDocs($grpc.ServiceCall call, $0.ListDocsRequest request);
  $async.Future<$0.CreateDocResponse> createDoc($grpc.ServiceCall call, $0.CreateDocRequest request);
  $async.Future<$0.BasicResponse> updateDoc($grpc.ServiceCall call, $0.UpdateDocRequest request);
  $async.Future<$0.BasicResponse> deleteDoc($grpc.ServiceCall call, $0.DeleteDocRequest request);
}
@$pb.GrpcServiceName('whisperingtime.ImageService')
class ImageServiceClient extends $grpc.Client {
  static final _$uploadImage = $grpc.ClientMethod<$0.ImageUploadChunk, $0.UploadImageResponse>(
      '/whisperingtime.ImageService/UploadImage',
      ($0.ImageUploadChunk value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.UploadImageResponse.fromBuffer(value));
  static final _$deleteImage = $grpc.ClientMethod<$0.DeleteImageRequest, $0.BasicResponse>(
      '/whisperingtime.ImageService/DeleteImage',
      ($0.DeleteImageRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.BasicResponse.fromBuffer(value));

  ImageServiceClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options,
        interceptors: interceptors);

  $grpc.ResponseFuture<$0.UploadImageResponse> uploadImage($async.Stream<$0.ImageUploadChunk> request, {$grpc.CallOptions? options}) {
    return $createStreamingCall(_$uploadImage, request, options: options).single;
  }

  $grpc.ResponseFuture<$0.BasicResponse> deleteImage($0.DeleteImageRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$deleteImage, request, options: options);
  }
}

@$pb.GrpcServiceName('whisperingtime.ImageService')
abstract class ImageServiceBase extends $grpc.Service {
  $core.String get $name => 'whisperingtime.ImageService';

  ImageServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.ImageUploadChunk, $0.UploadImageResponse>(
        'UploadImage',
        uploadImage,
        true,
        false,
        ($core.List<$core.int> value) => $0.ImageUploadChunk.fromBuffer(value),
        ($0.UploadImageResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DeleteImageRequest, $0.BasicResponse>(
        'DeleteImage',
        deleteImage_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.DeleteImageRequest.fromBuffer(value),
        ($0.BasicResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.BasicResponse> deleteImage_Pre($grpc.ServiceCall call, $async.Future<$0.DeleteImageRequest> request) async {
    return deleteImage(call, await request);
  }

  $async.Future<$0.UploadImageResponse> uploadImage($grpc.ServiceCall call, $async.Stream<$0.ImageUploadChunk> request);
  $async.Future<$0.BasicResponse> deleteImage($grpc.ServiceCall call, $0.DeleteImageRequest request);
}
@$pb.GrpcServiceName('whisperingtime.BackgroundJobService')
class BackgroundJobServiceClient extends $grpc.Client {
  static final _$listJobs = $grpc.ClientMethod<$0.ListBackgroundJobsRequest, $0.ListBackgroundJobsResponse>(
      '/whisperingtime.BackgroundJobService/ListJobs',
      ($0.ListBackgroundJobsRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.ListBackgroundJobsResponse.fromBuffer(value));
  static final _$getJob = $grpc.ClientMethod<$0.GetBackgroundJobRequest, $0.BackgroundJob>(
      '/whisperingtime.BackgroundJobService/GetJob',
      ($0.GetBackgroundJobRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.BackgroundJob.fromBuffer(value));
  static final _$deleteJob = $grpc.ClientMethod<$0.DeleteBackgroundJobRequest, $0.BasicResponse>(
      '/whisperingtime.BackgroundJobService/DeleteJob',
      ($0.DeleteBackgroundJobRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.BasicResponse.fromBuffer(value));
  static final _$downloadJobFile = $grpc.ClientMethod<$0.DownloadBackgroundJobFileRequest, $0.DownloadBackgroundJobFileResponse>(
      '/whisperingtime.BackgroundJobService/DownloadJobFile',
      ($0.DownloadBackgroundJobFileRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.DownloadBackgroundJobFileResponse.fromBuffer(value));

  BackgroundJobServiceClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options,
        interceptors: interceptors);

  $grpc.ResponseFuture<$0.ListBackgroundJobsResponse> listJobs($0.ListBackgroundJobsRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$listJobs, request, options: options);
  }

  $grpc.ResponseFuture<$0.BackgroundJob> getJob($0.GetBackgroundJobRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getJob, request, options: options);
  }

  $grpc.ResponseFuture<$0.BasicResponse> deleteJob($0.DeleteBackgroundJobRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$deleteJob, request, options: options);
  }

  $grpc.ResponseFuture<$0.DownloadBackgroundJobFileResponse> downloadJobFile($0.DownloadBackgroundJobFileRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$downloadJobFile, request, options: options);
  }
}

@$pb.GrpcServiceName('whisperingtime.BackgroundJobService')
abstract class BackgroundJobServiceBase extends $grpc.Service {
  $core.String get $name => 'whisperingtime.BackgroundJobService';

  BackgroundJobServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.ListBackgroundJobsRequest, $0.ListBackgroundJobsResponse>(
        'ListJobs',
        listJobs_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ListBackgroundJobsRequest.fromBuffer(value),
        ($0.ListBackgroundJobsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetBackgroundJobRequest, $0.BackgroundJob>(
        'GetJob',
        getJob_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GetBackgroundJobRequest.fromBuffer(value),
        ($0.BackgroundJob value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DeleteBackgroundJobRequest, $0.BasicResponse>(
        'DeleteJob',
        deleteJob_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.DeleteBackgroundJobRequest.fromBuffer(value),
        ($0.BasicResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DownloadBackgroundJobFileRequest, $0.DownloadBackgroundJobFileResponse>(
        'DownloadJobFile',
        downloadJobFile_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.DownloadBackgroundJobFileRequest.fromBuffer(value),
        ($0.DownloadBackgroundJobFileResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.ListBackgroundJobsResponse> listJobs_Pre($grpc.ServiceCall call, $async.Future<$0.ListBackgroundJobsRequest> request) async {
    return listJobs(call, await request);
  }

  $async.Future<$0.BackgroundJob> getJob_Pre($grpc.ServiceCall call, $async.Future<$0.GetBackgroundJobRequest> request) async {
    return getJob(call, await request);
  }

  $async.Future<$0.BasicResponse> deleteJob_Pre($grpc.ServiceCall call, $async.Future<$0.DeleteBackgroundJobRequest> request) async {
    return deleteJob(call, await request);
  }

  $async.Future<$0.DownloadBackgroundJobFileResponse> downloadJobFile_Pre($grpc.ServiceCall call, $async.Future<$0.DownloadBackgroundJobFileRequest> request) async {
    return downloadJobFile(call, await request);
  }

  $async.Future<$0.ListBackgroundJobsResponse> listJobs($grpc.ServiceCall call, $0.ListBackgroundJobsRequest request);
  $async.Future<$0.BackgroundJob> getJob($grpc.ServiceCall call, $0.GetBackgroundJobRequest request);
  $async.Future<$0.BasicResponse> deleteJob($grpc.ServiceCall call, $0.DeleteBackgroundJobRequest request);
  $async.Future<$0.DownloadBackgroundJobFileResponse> downloadJobFile($grpc.ServiceCall call, $0.DownloadBackgroundJobFileRequest request);
}
@$pb.GrpcServiceName('whisperingtime.FileService')
class FileServiceClient extends $grpc.Client {
  static final _$presignUploadFile = $grpc.ClientMethod<$0.PresignUploadFileRequest, $0.PresignUploadFileResponse>(
      '/whisperingtime.FileService/PresignUploadFile',
      ($0.PresignUploadFileRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.PresignUploadFileResponse.fromBuffer(value));
  static final _$presignDownloadFile = $grpc.ClientMethod<$0.PresignDownloadFileRequest, $0.PresignDownloadFileResponse>(
      '/whisperingtime.FileService/PresignDownloadFile',
      ($0.PresignDownloadFileRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.PresignDownloadFileResponse.fromBuffer(value));
  static final _$deleteFile = $grpc.ClientMethod<$0.DeleteFileRequest, $0.BasicResponse>(
      '/whisperingtime.FileService/DeleteFile',
      ($0.DeleteFileRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.BasicResponse.fromBuffer(value));

  FileServiceClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options,
        interceptors: interceptors);

  $grpc.ResponseFuture<$0.PresignUploadFileResponse> presignUploadFile($0.PresignUploadFileRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$presignUploadFile, request, options: options);
  }

  $grpc.ResponseFuture<$0.PresignDownloadFileResponse> presignDownloadFile($0.PresignDownloadFileRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$presignDownloadFile, request, options: options);
  }

  $grpc.ResponseFuture<$0.BasicResponse> deleteFile($0.DeleteFileRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$deleteFile, request, options: options);
  }
}

@$pb.GrpcServiceName('whisperingtime.FileService')
abstract class FileServiceBase extends $grpc.Service {
  $core.String get $name => 'whisperingtime.FileService';

  FileServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.PresignUploadFileRequest, $0.PresignUploadFileResponse>(
        'PresignUploadFile',
        presignUploadFile_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.PresignUploadFileRequest.fromBuffer(value),
        ($0.PresignUploadFileResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.PresignDownloadFileRequest, $0.PresignDownloadFileResponse>(
        'PresignDownloadFile',
        presignDownloadFile_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.PresignDownloadFileRequest.fromBuffer(value),
        ($0.PresignDownloadFileResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DeleteFileRequest, $0.BasicResponse>(
        'DeleteFile',
        deleteFile_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.DeleteFileRequest.fromBuffer(value),
        ($0.BasicResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.PresignUploadFileResponse> presignUploadFile_Pre($grpc.ServiceCall call, $async.Future<$0.PresignUploadFileRequest> request) async {
    return presignUploadFile(call, await request);
  }

  $async.Future<$0.PresignDownloadFileResponse> presignDownloadFile_Pre($grpc.ServiceCall call, $async.Future<$0.PresignDownloadFileRequest> request) async {
    return presignDownloadFile(call, await request);
  }

  $async.Future<$0.BasicResponse> deleteFile_Pre($grpc.ServiceCall call, $async.Future<$0.DeleteFileRequest> request) async {
    return deleteFile(call, await request);
  }

  $async.Future<$0.PresignUploadFileResponse> presignUploadFile($grpc.ServiceCall call, $0.PresignUploadFileRequest request);
  $async.Future<$0.PresignDownloadFileResponse> presignDownloadFile($grpc.ServiceCall call, $0.PresignDownloadFileRequest request);
  $async.Future<$0.BasicResponse> deleteFile($grpc.ServiceCall call, $0.DeleteFileRequest request);
}
