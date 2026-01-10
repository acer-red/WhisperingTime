package grpcserver

import (
	"bytes"
	"context"
	"encoding/base64"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"os"
	"path"
	"path/filepath"
	"strconv"
	"time"

	m "github.com/acer-red/whisperingtime/engine/model"
	"github.com/acer-red/whisperingtime/engine/pb"
	"github.com/acer-red/whisperingtime/engine/service/db"
	minioSvc "github.com/acer-red/whisperingtime/engine/service/minio"
	"github.com/acer-red/whisperingtime/engine/util"
	"github.com/google/uuid"
	log "github.com/tengfei-xy/go-log"
	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/metadata"
	"google.golang.org/grpc/status"
)

// Service aggregates all RPC handlers.
type Service struct {
	pb.UnimplementedThemeServiceServer
	pb.UnimplementedGroupServiceServer
	pb.UnimplementedDocServiceServer
	pb.UnimplementedImageServiceServer
	pb.UnimplementedBackgroundJobServiceServer
	pb.UnimplementedFileServiceServer
	pb.UnimplementedScaleServiceServer

	publicHTTPBase string
}

// ------------------------------
// Zero-Knowledge Scale Templates
// ------------------------------

func (s *Service) ListScaleTemplates(ctx context.Context, req *pb.ListScaleTemplatesRequest) (*pb.ListScaleTemplatesResponse, error) {
	log.Infof("[grpc] ListScaleTemplates uid=%s", getUID(ctx))
	uoid := getUOID(ctx)
	if uoid == "" {
		return &pb.ListScaleTemplatesResponse{Err: 1, Msg: "unauthenticated"}, nil
	}

	records, err := db.ScaleTemplatesList(uoid)
	if err != nil {
		return &pb.ListScaleTemplatesResponse{Err: 1, Msg: err.Error()}, nil
	}

	res := make([]*pb.ScaleTemplate, 0, len(records))
	for _, r := range records {
		res = append(res, &pb.ScaleTemplate{
			Id:                r.ID,
			EncryptedMetadata: r.EncryptedMetadata,
			CreatedAt:         r.CreateAt.Unix(),
		})
	}
	return &pb.ListScaleTemplatesResponse{Err: 0, Msg: "ok", Templates: res}, nil
}

func (s *Service) CreateScaleTemplate(ctx context.Context, req *pb.CreateScaleTemplateRequest) (*pb.CreateScaleTemplateResponse, error) {
	log.Infof("[grpc] CreateScaleTemplate uid=%s", getUID(ctx))
	uoid := getUOID(ctx)
	if uoid == "" {
		return &pb.CreateScaleTemplateResponse{Err: 1, Msg: "unauthenticated"}, nil
	}

	if len(req.GetEncryptedMetadata()) == 0 {
		return &pb.CreateScaleTemplateResponse{Err: 1, Msg: "encrypted_metadata is empty"}, nil
	}

	id, err := db.ScaleTemplateCreate(uoid, req.GetEncryptedMetadata())
	if err != nil {
		return &pb.CreateScaleTemplateResponse{Err: 1, Msg: err.Error()}, nil
	}
	return &pb.CreateScaleTemplateResponse{Err: 0, Msg: "ok", Id: id}, nil
}

func (s *Service) UpdateScaleTemplate(ctx context.Context, req *pb.UpdateScaleTemplateRequest) (*pb.BasicResponse, error) {
	log.Infof("[grpc] UpdateScaleTemplate uid=%s id=%s", getUID(ctx), req.GetId())
	uoid := getUOID(ctx)
	if uoid == "" {
		return &pb.BasicResponse{Err: 1, Msg: "unauthenticated"}, nil
	}
	if req.GetId() == "" {
		return &pb.BasicResponse{Err: 1, Msg: "id is empty"}, nil
	}
	if len(req.GetEncryptedMetadata()) == 0 {
		return &pb.BasicResponse{Err: 1, Msg: "encrypted_metadata is empty"}, nil
	}

	if err := db.ScaleTemplateUpdate(uoid, req.GetId(), req.GetEncryptedMetadata()); err != nil {
		return &pb.BasicResponse{Err: 1, Msg: err.Error()}, nil
	}
	return &pb.BasicResponse{Err: 0, Msg: "ok"}, nil
}

func (s *Service) DeleteScaleTemplate(ctx context.Context, req *pb.DeleteScaleTemplateRequest) (*pb.BasicResponse, error) {
	log.Infof("[grpc] DeleteScaleTemplate uid=%s id=%s", getUID(ctx), req.GetId())
	uoid := getUOID(ctx)
	if uoid == "" {
		return &pb.BasicResponse{Err: 1, Msg: "unauthenticated"}, nil
	}
	if req.GetId() == "" {
		return &pb.BasicResponse{Err: 1, Msg: "id is empty"}, nil
	}

	if err := db.ScaleTemplateDelete(uoid, req.GetId()); err != nil {
		return &pb.BasicResponse{Err: 1, Msg: err.Error()}, nil
	}
	return &pb.BasicResponse{Err: 0, Msg: "ok"}, nil
}

func toGroupConfig(cfg m.GroupConfig) *pb.GroupConfig {
	return &pb.GroupConfig{
		Levels:         cfg.Levels,
		ViewType:       int32(cfg.View_type),
		SortType:       int32(cfg.Sort_type),
		AutoFreezeDays: int32(cfg.AutoFreezeDays),
	}
}

// func fromGroupConfig(cfg *pb.GroupConfig) *m.GroupConfig {
// 	if cfg == nil {
// 		return nil
// 	}
// 	return &m.GroupConfig{
// 		Levels:         cfg.GetLevels(),
// 		View_type:      int(cfg.GetViewType()),
// 		Sort_type:      int(cfg.GetSortType()),
// 		AutoFreezeDays: int(cfg.GetAutoFreezeDays()),
// 	}
// }

// ThemeService
func (s *Service) ListThemes(ctx context.Context, req *pb.ListThemesRequest) (*pb.ListThemesResponse, error) {
	log.Infof("[grpc] ListThemes uid=%s includeDocs=%v includeDetail=%v", getUID(ctx), req.GetIncludeDocs(), req.GetIncludeDetail())
	uoid := getUOID(ctx)
	if uoid == "" {
		return &pb.ListThemesResponse{Err: 1, Msg: "unauthenticated"}, nil
	}

	// no docs
	if !req.GetIncludeDocs() && !req.GetIncludeDetail() {
		themes, err := db.ThemesGet(uoid)
		if err != nil {
			return &pb.ListThemesResponse{Err: 1, Msg: err.Error()}, nil
		}
		ids := make([]string, 0, len(themes))
		for _, t := range themes {
			ids = append(ids, t.ID)
		}
		perms, _ := db.PermissionsFor(uoid, db.ResourceTypeTheme, ids)
		res := make([]*pb.ThemeDetail, 0, len(themes))
		for _, t := range themes {
			res = append(res, &pb.ThemeDetail{Id: t.ID, Name: t.Name, Permission: permissionEnvelopeFromMap(perms, t.ID)})
		}
		return &pb.ListThemesResponse{Err: 0, Msg: "ok", Themes: res}, nil
	}

	if req.GetIncludeDetail() {
		raw, err := db.ThemesGetAndDocsDetail(uoid, false)
		if err != nil {
			return &pb.ListThemesResponse{Err: 1, Msg: err.Error()}, nil
		}
		var items []struct {
			Tid       string `json:"tid"`
			ThemeName string `json:"theme_name"`
			Groups    []struct {
				Gid  string `json:"gid"`
				Name string `json:"name"`
				Docs []struct {
					Did      string       `json:"did"`
					Content  m.DocContent `json:"content"`
					Legacy   int32        `json:"level"`
					CreateAt time.Time    `json:"createAt"`
					UpdateAt time.Time    `json:"updateAt"`
				} `json:"docs"`
			} `json:"groups"`
		}
		b, _ := json.Marshal(raw)
		_ = json.Unmarshal(b, &items)
		themeIDs := make([]string, 0, len(items))
		groupIDs := make([]string, 0)
		docIDs := make([]string, 0)
		for _, t := range items {
			themeIDs = append(themeIDs, t.Tid)
			for _, g := range t.Groups {
				groupIDs = append(groupIDs, g.Gid)
				for _, d := range g.Docs {
					docIDs = append(docIDs, d.Did)
				}
			}
		}
		themePerms, _ := db.PermissionsFor(uoid, db.ResourceTypeTheme, themeIDs)
		groupPerms, _ := db.PermissionsFor(uoid, db.ResourceTypeGroup, groupIDs)
		docPerms, _ := db.PermissionsFor(uoid, db.ResourceTypeDoc, docIDs)
		res := make([]*pb.ThemeDetail, 0, len(items))
		for _, t := range items {
			td := &pb.ThemeDetail{Id: t.Tid, Name: decodeNameBytes(t.ThemeName), Permission: permissionEnvelopeFromMap(themePerms, t.Tid)}
			for _, g := range t.Groups {
				gd := &pb.GroupDetail{Id: g.Gid, Name: decodeNameBytes(g.Name), Permission: permissionEnvelopeFromMap(groupPerms, g.Gid)}
				for _, d := range g.Docs {
					gd.Docs = append(gd.Docs, &pb.DocDetail{
						Id: d.Did,
						Content: &pb.Content{
							Title:  d.Content.Title,
							Scales: firstNonEmptyBytes(d.Content.Scales, d.Content.Rich),
							Level:  levelBytes(d.Content.Level, d.Legacy),
						},
						CreateAt:   d.CreateAt.Unix(),
						UpdateAt:   d.UpdateAt.Unix(),
						Permission: permissionEnvelopeFromMap(docPerms, d.Did),
					})
				}
				td.Groups = append(td.Groups, gd)
			}
			res = append(res, td)
		}
		return &pb.ListThemesResponse{Err: 0, Msg: "ok", Themes: res}, nil
	}

	// include docs summary
	raw, err := db.ThemesGetAndDocs(uoid, false)
	if err != nil {
		return &pb.ListThemesResponse{Err: 1, Msg: err.Error()}, nil
	}
	var items []struct {
		Tid       string `json:"tid"`
		ThemeName []byte `json:"theme_name"`
		Groups    []struct {
			Gid  string `json:"gid"`
			Name []byte `json:"name"`
			Docs []struct {
				Did      string       `json:"did"`
				Content  m.DocContent `json:"content"`
				Legacy   int32        `json:"level"`
				CreateAt time.Time    `json:"createAt"`
				UpdateAt time.Time    `json:"updateAt"`
			} `json:"docs"`
		} `json:"groups"`
	}
	b, _ := json.Marshal(raw)
	_ = json.Unmarshal(b, &items)
	themeIDs := make([]string, 0, len(items))
	groupIDs := make([]string, 0)
	docIDs := make([]string, 0)
	for _, t := range items {
		themeIDs = append(themeIDs, t.Tid)
		for _, g := range t.Groups {
			groupIDs = append(groupIDs, g.Gid)
			for _, d := range g.Docs {
				docIDs = append(docIDs, d.Did)
			}
		}
	}
	themePerms, _ := db.PermissionsFor(uoid, db.ResourceTypeTheme, themeIDs)
	groupPerms, _ := db.PermissionsFor(uoid, db.ResourceTypeGroup, groupIDs)
	docPerms, _ := db.PermissionsFor(uoid, db.ResourceTypeDoc, docIDs)
	res := make([]*pb.ThemeDetail, 0, len(items))
	for _, t := range items {
		td := &pb.ThemeDetail{Id: t.Tid, Name: t.ThemeName, Permission: permissionEnvelopeFromMap(themePerms, t.Tid)}
		for _, g := range t.Groups {
			gd := &pb.GroupDetail{Id: g.Gid, Name: g.Name, Permission: permissionEnvelopeFromMap(groupPerms, g.Gid)}
			for _, d := range g.Docs {
				gd.Docs = append(gd.Docs, &pb.DocDetail{
					Id:         d.Did,
					Content:    &pb.Content{Title: d.Content.Title, Scales: firstNonEmptyBytes(d.Content.Scales, d.Content.Rich), Level: levelBytes(d.Content.Level, d.Legacy)},
					CreateAt:   d.CreateAt.Unix(),
					UpdateAt:   d.UpdateAt.Unix(),
					Permission: permissionEnvelopeFromMap(docPerms, d.Did),
				})
			}
			td.Groups = append(td.Groups, gd)
		}
		res = append(res, td)
	}
	return &pb.ListThemesResponse{Err: 0, Msg: "ok", Themes: res}, nil
}

func (s *Service) CreateTheme(ctx context.Context, req *pb.CreateThemeRequest) (*pb.CreateThemeResponse, error) {
	log.Infof("[grpc] CreateTheme uid=%s", getUID(ctx))
	uoid := getUOID(ctx)
	if uoid == "" {
		return &pb.CreateThemeResponse{Err: 1, Msg: "unauthenticated"}, nil
	}

	r := db.RequestThemePost{}
	r.Data.Name = req.GetName()
	r.Data.CreateAt = nowString()
	r.Data.EncryptedKey = req.GetEncryptedKey()
	defaultGroupName := req.GetDefaultGroupName()
	if len(defaultGroupName) == 0 {
		defaultGroupName = []byte("默认分组")
	}
	r.Data.DefaultGroup.Name = defaultGroupName
	r.Data.DefaultGroup.EncryptedKey = req.GetDefaultGroupEncryptedKey()
	def := 30
	r.Data.DefaultGroup.CreateAt = nowString()
	r.Data.DefaultGroup.Config = &struct {
		AutoFreezeDays *int `json:"auto_freeze_days"`
	}{AutoFreezeDays: &def}

	tid, err := db.ThemeCreate(uoid, &r)
	if err != nil {
		return &pb.CreateThemeResponse{Err: 1, Msg: err.Error()}, nil
	}
	// 创建主题后立即写入当前用户的权限密钥，方便客户端解密主题名称
	_ = db.PermissionUpsert(uoid, tid, db.ResourceTypeTheme, db.RoleOwner, req.GetEncryptedKey())

	gid, err := db.GroupCreateDefault(uoid, tid, r.Data.DefaultGroup)
	if err != nil {
		return &pb.CreateThemeResponse{Err: 1, Msg: err.Error()}, nil
	}
	// 默认分组同样需要权限记录，否则列表接口无法返回用于解密的 envelope
	_ = db.PermissionUpsert(uoid, gid, db.ResourceTypeGroup, db.RoleOwner, req.GetDefaultGroupEncryptedKey())
	return &pb.CreateThemeResponse{Err: 0, Msg: "ok", Id: tid}, nil
}

func (s *Service) UpdateTheme(ctx context.Context, req *pb.UpdateThemeRequest) (*pb.BasicResponse, error) {
	log.Infof("[grpc] UpdateTheme uid=%s id=%s", getUID(ctx), req.GetId())
	uoid := getUOID(ctx)
	if uoid == "" {
		return &pb.BasicResponse{Err: 1, Msg: "unauthenticated"}, nil
	}
	r := db.RequestThemePut{}
	r.Data.Name = req.GetName()
	r.Data.UpdateAt = nowString()
	if err := db.ThemeUpdate(req.GetId(), &r); err != nil {
		return &pb.BasicResponse{Err: 1, Msg: err.Error()}, nil
	}
	if len(req.GetEncryptedKey()) > 0 {
		_ = db.PermissionUpsert(uoid, req.GetId(), db.ResourceTypeTheme, db.RoleOwner, req.GetEncryptedKey())
	}
	return &pb.BasicResponse{Err: 0, Msg: "ok"}, nil
}

func (s *Service) DeleteTheme(ctx context.Context, req *pb.DeleteThemeRequest) (*pb.BasicResponse, error) {
	log.Infof("[grpc] DeleteTheme uid=%s id=%s", getUID(ctx), req.GetId())
	if err := db.ThemeDelete(req.GetId()); err != nil {
		return &pb.BasicResponse{Err: 1, Msg: err.Error()}, nil
	}
	return &pb.BasicResponse{Err: 0, Msg: "ok"}, nil
}

func (s *Service) ExportAllConfig(ctx context.Context, _ *pb.ExportAllConfigRequest) (*pb.BasicResponse, error) {
	log.Infof("[grpc] ExportAllConfig uid=%s", getUID(ctx))
	uoid := getUOID(ctx)
	if uoid == "" {
		return &pb.BasicResponse{Err: 1, Msg: "unauthenticated"}, nil
	}
	taskID, err := db.ExportAllThemesConfig(uoid)
	if err != nil {
		return &pb.BasicResponse{Err: 1, Msg: err.Error()}, nil
	}
	return &pb.BasicResponse{Err: 0, Msg: taskID}, nil
}

func (s *Service) DeleteUserData(ctx context.Context, _ *pb.DeleteUserDataRequest) (*pb.BasicResponse, error) {
	log.Infof("[grpc] DeleteUserData uid=%s", getUID(ctx))
	uoid := getUOID(ctx)
	if uoid == "" {
		return &pb.BasicResponse{Err: 1, Msg: "unauthenticated"}, nil
	}

	// 1. Delete all themes (cascades to groups and docs)
	themes, err := db.ThemesGet(uoid)
	if err != nil {
		return &pb.BasicResponse{Err: 1, Msg: err.Error()}, nil
	}
	for _, t := range themes {
		if err := db.ThemeDelete(t.ID); err != nil {
			log.Errorf("failed to delete theme %s: %v", t.ID, err)
			// continue to try deleting others
		}
	}

	// 2. Delete all files in Minio and FileMeta
	uid := getUID(ctx)
	files, err := db.FileMetaListByUser(ctx, uid)
	if err != nil {
		log.Errorf("failed to list files for user %s: %v", uid, err)
	} else {
		for _, f := range files {
			if err := s.deleteOneFile(ctx, &f); err != nil {
				log.Errorf("failed to delete file %s: %v", f.ID, err)
			}
		}
	}

	// 3. Delete background jobs
	jobs, err := db.BGJobsGet(uoid)
	if err != nil {
		log.Errorf("failed to list jobs for user %s: %v", uid, err)
	} else {
		for _, j := range jobs {
			if err := db.BGJobDelete(uoid, j.ID); err != nil {
				log.Errorf("failed to delete job %s: %v", j.ID, err)
			}
		}
	}

	// 4. Delete user record
	if err := db.UserDelete(uoid); err != nil {
		log.Errorf("failed to delete user %s: %v", uid, err)
		return &pb.BasicResponse{Err: 1, Msg: err.Error()}, nil
	}

	return &pb.BasicResponse{Err: 0, Msg: "ok"}, nil
}

// GroupService
func (s *Service) ListGroups(ctx context.Context, req *pb.ListGroupsRequest) (*pb.ListGroupsResponse, error) {
	log.Infof("[grpc] ListGroups uid=%s themeId=%s", getUID(ctx), req.GetThemeId())
	uoid := getUOID(ctx)
	if uoid == "" {
		return &pb.ListGroupsResponse{Err: 1, Msg: "unauthenticated"}, nil
	}
	groups, err := db.GroupsGet(req.GetThemeId())
	if err != nil {
		return &pb.ListGroupsResponse{Err: 1, Msg: err.Error()}, nil
	}
	ids := make([]string, 0, len(groups))
	for _, g := range groups {
		ids = append(ids, g.ID)
	}
	perms, _ := db.PermissionsFor(uoid, db.ResourceTypeGroup, ids)
	res := make([]*pb.GroupSummary, 0, len(groups))
	for _, g := range groups {
		var over int64
		if g.OverAt != "" {
			over = util.StringtoTime(g.OverAt).Unix()
		}
		res = append(res, &pb.GroupSummary{
			Id:         g.ID,
			Name:       g.Name,
			CreateAt:   util.StringtoTime(g.CreateAt).Unix(),
			UpdateAt:   util.StringtoTime(g.UpdateAt).Unix(),
			OverAt:     over,
			Config:     toGroupConfig(g.Config),
			Permission: permissionEnvelopeFromMap(perms, g.ID),
		})
	}
	return &pb.ListGroupsResponse{Err: 0, Msg: "ok", Groups: res}, nil
}

func (s *Service) GetGroup(ctx context.Context, req *pb.GetGroupRequest) (*pb.GetGroupResponse, error) {
	log.Infof("[grpc] GetGroup uid=%s themeId=%s groupId=%s includeDocs=%v includeDetail=%v", getUID(ctx), req.GetThemeId(), req.GetGroupId(), req.GetIncludeDocs(), req.GetIncludeDetail())
	uoid := getUOID(ctx)

	if req.GetIncludeDetail() || req.GetIncludeDocs() {
		g, err := db.GroupGetAndDocDetail(req.GetThemeId(), req.GetGroupId())
		if err != nil {
			return &pb.GetGroupResponse{Err: 1, Msg: err.Error()}, nil
		}
		permMap, _ := db.PermissionsFor(uoid, db.ResourceTypeDoc, extractDocIDs(g.Docs))
		groupPerm, _ := db.PermissionGet(uoid, db.ResourceTypeGroup, g.GID)
		gd := &pb.GroupDetail{Id: g.GID, Name: g.Name, Config: toGroupConfig(g.Config), Permission: permissionEnvelopeFromPermission(&groupPerm)}
		for _, d := range g.Docs {
			gd.Docs = append(gd.Docs, &pb.DocDetail{
				Id:         d.ID,
				Content:    &pb.Content{Title: d.Content.Title, Rich: d.Content.Rich, Scales: firstNonEmptyBytes(d.Content.Scales, d.Content.Rich), Level: levelBytes(d.Content.Level, d.LegacyLevel)},
				CreateAt:   d.CreateAt.Unix(),
				UpdateAt:   d.UpdateAt.Unix(),
				Permission: permissionEnvelopeFromMap(permMap, d.ID),
			})
		}
		return &pb.GetGroupResponse{Err: 0, Msg: "ok", Group: gd}, nil
	}

	g, err := db.GroupGet(req.GetThemeId(), req.GetGroupId())
	if err != nil {
		return &pb.GetGroupResponse{Err: 1, Msg: err.Error()}, nil
	}
	groupPerm, _ := db.PermissionGet(uoid, db.ResourceTypeGroup, g.ID)
	gd := &pb.GroupDetail{Id: g.ID, Name: g.Name, Config: toGroupConfig(g.Config), Permission: permissionEnvelopeFromPermission(&groupPerm)}
	return &pb.GetGroupResponse{Err: 0, Msg: "ok", Group: gd}, nil
}

func (s *Service) CreateGroup(ctx context.Context, req *pb.CreateGroupRequest) (*pb.CreateGroupResponse, error) {
	log.Infof("[grpc] CreateGroup uid=%s themeId=%s name=%s", getUID(ctx), req.GetThemeId(), req.GetName())
	uoid := getUOID(ctx)
	if uoid == "" {
		return &pb.CreateGroupResponse{Err: 1, Msg: "unauthenticated"}, nil
	}
	r := db.RequestGroupPost{}
	r.Data.Name = req.GetName()
	r.Data.CreateAt = nowString()
	r.Data.UpdateAt = nowString()
	r.Data.EncryptedKey = req.GetEncryptedKey()
	r.Data.Config = &struct {
		AutoFreezeDays *int `json:"auto_freeze_days"`
	}{AutoFreezeDays: intPtr(int(req.GetAutoFreezeDays()))}

	id, err := db.GroupPost(uoid, req.GetThemeId(), r)
	if err != nil {
		return &pb.CreateGroupResponse{Err: 1, Msg: err.Error()}, nil
	}
	// 建分组后补齐权限密钥，确保客户端能解密名称
	_ = db.PermissionUpsert(uoid, id, db.ResourceTypeGroup, db.RoleOwner, req.GetEncryptedKey())
	return &pb.CreateGroupResponse{Err: 0, Msg: "ok", Id: id}, nil
}

func (s *Service) UpdateGroup(ctx context.Context, req *pb.UpdateGroupRequest) (*pb.BasicResponse, error) {
	log.Infof("[grpc] UpdateGroup uid=%s themeId=%s groupId=%s", getUID(ctx), req.GetThemeId(), req.GetGroupId())
	uoid := getUOID(ctx)
	if uoid == "" {
		return &pb.BasicResponse{Err: 1, Msg: "unauthenticated"}, nil
	}

	r := db.RequestGroupPut{}
	r.Data.UpdateAt = strPtr(nowString())
	if req.Name != nil {
		name := req.GetName()
		r.Data.Name = &name
	}
	if req.OverAt != 0 {
		t := time.Unix(req.GetOverAt(), 0).Format("2006-01-02 15:04:05")
		r.Data.OverAt = &t
	}
	if cfg := req.GetConfig(); cfg != nil {
		r.Data.Config = &struct {
			Levels         *[]bool `json:"levels"`
			View_type      *int    `json:"view_type"`
			Sort_type      *int    `json:"sort_type"`
			AutoFreezeDays *int    `json:"auto_freeze_days"`
		}{}
		lv := cfg.GetLevels()
		r.Data.Config.Levels = &lv
		vt := int(cfg.GetViewType())
		st := int(cfg.GetSortType())
		af := int(cfg.GetAutoFreezeDays())
		r.Data.Config.View_type = &vt
		r.Data.Config.Sort_type = &st
		r.Data.Config.AutoFreezeDays = &af
	}

	if err := db.GroupPut(req.GetGroupId(), r); err != nil {
		return &pb.BasicResponse{Err: 1, Msg: err.Error()}, nil
	}
	if len(req.GetEncryptedKey()) > 0 {
		_ = db.PermissionUpsert(uoid, req.GetGroupId(), db.ResourceTypeGroup, db.RoleOwner, req.GetEncryptedKey())
	}
	return &pb.BasicResponse{Err: 0, Msg: "ok"}, nil
}

func (s *Service) DeleteGroup(ctx context.Context, req *pb.DeleteGroupRequest) (*pb.BasicResponse, error) {
	log.Infof("[grpc] DeleteGroup uid=%s themeId=%s groupId=%s", getUID(ctx), req.GetThemeId(), req.GetGroupId())
	if err := db.GroupDeleteOne(req.GetGroupId()); err != nil {
		return &pb.BasicResponse{Err: 1, Msg: err.Error()}, nil
	}
	return &pb.BasicResponse{Err: 0, Msg: "ok"}, nil
}

func (s *Service) ExportGroupConfig(ctx context.Context, req *pb.ExportGroupConfigRequest) (*pb.BasicResponse, error) {
	log.Infof("[grpc] ExportGroupConfig not implemented")
	return &pb.BasicResponse{Err: 1, Msg: "not implemented"}, nil
}

// ImportGroupConfig: client streaming bytes
func (s *Service) ImportGroupConfig(stream pb.GroupService_ImportGroupConfigServer) error {
	log.Infof("[grpc] ImportGroupConfig not implemented")
	return status.Error(codes.Unimplemented, "not implemented")
}

// DocService
func (s *Service) ListDocs(ctx context.Context, req *pb.ListDocsRequest) (*pb.ListDocsResponse, error) {
	log.Infof("[grpc] ListDocs uid=%s groupId=%s year=%d month=%d", getUID(ctx), req.GetGroupId(), req.GetYear(), req.GetMonth())
	uoid := getUOID(ctx)
	if uoid == "" {
		return &pb.ListDocsResponse{Err: 1, Msg: "unauthenticated"}, nil
	}
	docs, err := db.DocsGet(req.GetGroupId(), db.DocFilter{Year: int(req.GetYear()), Month: int(req.GetMonth())})
	if err != nil {
		return &pb.ListDocsResponse{Err: 1, Msg: err.Error()}, nil
	}
	ids := make([]string, 0, len(docs))
	for _, d := range docs {
		ids = append(ids, d.ID)
	}
	perms, _ := db.PermissionsFor(uoid, db.ResourceTypeDoc, ids)
	res := make([]*pb.DocSummary, 0, len(docs))
	for _, d := range docs {
		res = append(res, &pb.DocSummary{
			Id: d.ID,
			Content: &pb.Content{
				Title:  d.Content.Title,
				Scales: firstNonEmptyBytes(d.Content.Scales, d.Content.Rich),
				Level:  levelBytes(d.Content.Level, d.LegacyLevel),
			},
			CreateAt:   d.CreateAt.Unix(),
			UpdateAt:   d.UpdateAt.Unix(),
			Permission: permissionEnvelopeFromMap(perms, d.ID),
			Config: &pb.DocConfig{
				IsShowTool:      d.Config.IsShowTool,
				DisplayPriority: int32(d.Config.DisplayPriority),
			},
		})
	}
	return &pb.ListDocsResponse{Err: 0, Msg: "ok", Docs: res}, nil
}

func (s *Service) CreateDoc(ctx context.Context, req *pb.CreateDocRequest) (*pb.CreateDocResponse, error) {
	log.Infof("[grpc] CreateDoc uid=%s groupId=%s", getUID(ctx), req.GetGroupId())
	uoid := getUOID(ctx)
	if uoid == "" {
		return &pb.CreateDocResponse{Err: 1, Msg: "unauthenticated"}, nil
	}
	r := db.RequestDocPost{}
	r.Data.Content = m.DocContent{
		Title:  req.GetContent().GetTitle(),
		Scales: req.GetContent().GetScales(),
		Level:  req.GetContent().GetLevel(),
	}
	r.Data.CreateAt = fmt.Sprintf("%d", req.GetCreateAt())
	if req.GetConfig() != nil {
		r.Data.Config = &m.DocConfig{
			IsShowTool:      req.GetConfig().GetIsShowTool(),
			DisplayPriority: int(req.GetConfig().GetDisplayPriority()),
		}
	} else {
		r.Data.Config = &m.DocConfig{IsShowTool: true}
	}
	r.Data.EncryptedKey = req.GetEncryptedKey()

	did, err := db.DocPost(uoid, req.GetGroupId(), &r)
	if err != nil {
		return &pb.CreateDocResponse{Err: 1, Msg: err.Error()}, nil
	}
	return &pb.CreateDocResponse{Err: 0, Msg: "ok", Id: did}, nil
}

func (s *Service) UpdateDoc(ctx context.Context, req *pb.UpdateDocRequest) (*pb.BasicResponse, error) {
	log.Infof("[grpc] UpdateDoc uid=%s groupId=%s docId=%s", getUID(ctx), req.GetGroupId(), req.GetDocId())
	uoid := getUOID(ctx)
	if uoid == "" {
		return &pb.BasicResponse{Err: 1, Msg: "unauthenticated"}, nil
	}

	r := db.RequestDocPut{}
	if req.Content != nil {
		c := m.DocContent{}
		if req.GetContent().Title != nil {
			c.Title = req.GetContent().Title
		}
		if req.GetContent().Rich != nil {
			c.Rich = req.GetContent().Rich
		}
		if req.GetContent().Scales != nil {
			c.Scales = req.GetContent().Scales
		}
		if req.GetContent().Level != nil {
			c.Level = req.GetContent().Level
		}
		r.Doc.Content = &c
	}
	if req.CreateAt != 0 {
		t := fmt.Sprintf("%d", req.GetCreateAt())
		r.Doc.CreateAt = &t
	}
	upd := time.Now().Format("2006-01-02 15:04:05")
	r.Doc.UpdateAt = &upd

	if req.Config != nil {
		r.Doc.Config = &m.DocConfig{
			IsShowTool:      req.GetConfig().GetIsShowTool(),
			DisplayPriority: int(req.GetConfig().GetDisplayPriority()),
		}
	}

	if err := db.DocPut(req.GetGroupId(), req.GetDocId(), &r); err != nil {
		return &pb.BasicResponse{Err: 1, Msg: err.Error()}, nil
	}
	if len(req.GetEncryptedKey()) > 0 {
		_ = db.PermissionUpsert(uoid, req.GetDocId(), db.ResourceTypeDoc, db.RoleOwner, req.GetEncryptedKey())
	}
	return &pb.BasicResponse{Err: 0, Msg: "ok"}, nil
}

func levelBytes(contentLevel []byte, legacyLevel int32) []byte {
	if len(contentLevel) > 0 {
		return contentLevel
	}
	return []byte(strconv.Itoa(int(legacyLevel)))
}

func firstNonEmptyBytes(primary []byte, fallback []byte) []byte {
	if len(primary) > 0 {
		return primary
	}
	return fallback
}

func (s *Service) DeleteDoc(ctx context.Context, req *pb.DeleteDocRequest) (*pb.BasicResponse, error) {
	log.Infof("[grpc] DeleteDoc uid=%s groupId=%s docId=%s", getUID(ctx), req.GetGroupId(), req.GetDocId())
	if err := db.DocDelete(req.GetGroupId(), req.GetDocId()); err != nil {
		return &pb.BasicResponse{Err: 1, Msg: err.Error()}, nil
	}
	if err := s.deleteAllFilesForDoc(ctx, req.GetDocId()); err != nil {
		return &pb.BasicResponse{Err: 1, Msg: err.Error()}, nil
	}
	return &pb.BasicResponse{Err: 0, Msg: "ok"}, nil
}

// ImageService
func (s *Service) UploadImage(stream pb.ImageService_UploadImageServer) error {
	ctx := stream.Context()
	uid := getUID(ctx)
	uoid := getUOID(ctx)
	log.Infof("[grpc] UploadImage start uid=%s", uid)
	if uid == "" || uoid == "" {
		return status.Error(codes.Unauthenticated, "unauthenticated")
	}

	var mime string
	var data bytes.Buffer

	first := true
	for {
		chunk, err := stream.Recv()
		if err == io.EOF {
			break
		}
		if err != nil {
			return err
		}
		if first {
			mime = chunk.GetMime()
			first = false
		}
		data.Write(chunk.GetData())
	}

	if mime == "" {
		mime = "image/png"
	}
	name := fmt.Sprintf("%s.%s", uuid.NewString(), mimeExt(mime))

	url := fmt.Sprintf("%s/image/%s/%s", s.publicHTTPBase, uid, name)
	log.Infof("[grpc] UploadImage done uid=%s name=%s mime=%s size=%d bytes", uid, name, mime, data.Len())
	return stream.SendAndClose(&pb.UploadImageResponse{Err: 0, Msg: "ok", Name: name, Url: url})
}

func (s *Service) DeleteImage(ctx context.Context, req *pb.DeleteImageRequest) (*pb.BasicResponse, error) {
	log.Infof("[grpc] DeleteImage uid=%s name=%s", getUID(ctx), req.GetName())
	return &pb.BasicResponse{Err: 0, Msg: "ok"}, nil
}

// FileService
func (s *Service) PresignUploadFile(ctx context.Context, req *pb.PresignUploadFileRequest) (*pb.PresignUploadFileResponse, error) {
	uid := getUID(ctx)
	uoid := getUOID(ctx)
	log.Infof("[grpc] PresignUploadFile uid=%s themeId=%s groupId=%s docId=%s filename=%s size=%d mime=%s expires=%d", uid, req.GetThemeId(), req.GetGroupId(), req.GetDocId(), req.GetFilename(), req.GetSize(), req.GetMime(), req.GetExpiresInSec())
	if uid == "" || uoid == "" {
		return &pb.PresignUploadFileResponse{Err: 1, Msg: "unauthenticated"}, nil
	}

	if req.GetThemeId() == "" || req.GetGroupId() == "" || req.GetDocId() == "" {
		return &pb.PresignUploadFileResponse{Err: 1, Msg: "missing theme/group/doc id"}, nil
	}
	if len(req.GetEncryptedKey()) == 0 {
		return &pb.PresignUploadFileResponse{Err: 1, Msg: "missing encrypted key"}, nil
	}

	// Permission check on doc level; fallback to group if doc missing
	if _, err := db.PermissionGet(uoid, db.ResourceTypeDoc, req.GetDocId()); err != nil {
		if !errors.Is(err, db.ErrRecordNotFound) {
			return &pb.PresignUploadFileResponse{Err: 1, Msg: err.Error()}, nil
		}
		if _, err := db.PermissionGet(uoid, db.ResourceTypeGroup, req.GetGroupId()); err != nil {
			return &pb.PresignUploadFileResponse{Err: 403, Msg: "permission denied"}, nil
		}
	}

	filename := req.GetFilename()
	if filename == "" {
		filename = fmt.Sprintf("%s.bin", uuid.NewString())
	} else {
		filename = filepath.Base(filename)
	}

	objectPath := path.Join(uid, req.GetThemeId(), req.GetGroupId(), req.GetDocId(), filename)

	expires := time.Duration(req.GetExpiresInSec()) * time.Second
	url, expAt, err := minioSvc.GetClient().PresignPut(ctx, objectPath, req.GetMime(), expires)
	if err != nil {
		return &pb.PresignUploadFileResponse{Err: 1, Msg: err.Error()}, nil
	}

	meta := &db.FileMeta{
		UID:               uid,
		ThemeID:           req.GetThemeId(),
		GroupID:           req.GetGroupId(),
		DocID:             req.GetDocId(),
		ObjectPath:        objectPath,
		Mime:              req.GetMime(),
		Size:              req.GetSize(),
		EncryptedKey:      req.GetEncryptedKey(),
		IV:                req.GetIv(),
		EncryptedMetadata: req.GetEncryptedMetadata(),
	}
	fileID, err := db.FileMetaCreate(ctx, meta)
	if err != nil {
		return &pb.PresignUploadFileResponse{Err: 1, Msg: err.Error()}, nil
	}

	return &pb.PresignUploadFileResponse{
		Err:        0,
		Msg:        "ok",
		FileId:     fileID,
		ObjectPath: objectPath,
		UploadUrl:  url,
		ExpiresAt:  expAt.Unix(),
	}, nil
}

func (s *Service) PresignDownloadFile(ctx context.Context, req *pb.PresignDownloadFileRequest) (*pb.PresignDownloadFileResponse, error) {
	uid := getUID(ctx)
	uoid := getUOID(ctx)
	log.Infof("[grpc] PresignDownloadFile uid=%s fileId=%s", uid, req.GetFileId())
	if uid == "" || uoid == "" {
		return &pb.PresignDownloadFileResponse{Err: 1, Msg: "unauthenticated"}, nil
	}

	meta, err := db.FileMetaGet(ctx, req.GetFileId())
	if err != nil {
		if errors.Is(err, db.ErrRecordNotFound) {
			return &pb.PresignDownloadFileResponse{Err: 404, Msg: "not found"}, nil
		}
		return &pb.PresignDownloadFileResponse{Err: 1, Msg: err.Error()}, nil
	}

	if meta.UID != uid {
		// Check doc permission for non-owner
		if _, err := db.PermissionGet(uoid, db.ResourceTypeDoc, meta.DocID); err != nil {
			return &pb.PresignDownloadFileResponse{Err: 403, Msg: "permission denied"}, nil
		}
	}

	url, expAt, err := minioSvc.GetClient().PresignGet(ctx, meta.ObjectPath, 0)
	if err != nil {
		return &pb.PresignDownloadFileResponse{Err: 1, Msg: err.Error()}, nil
	}

	return &pb.PresignDownloadFileResponse{
		Err:               0,
		Msg:               "ok",
		FileId:            meta.ID,
		ObjectPath:        meta.ObjectPath,
		DownloadUrl:       url,
		ExpiresAt:         expAt.Unix(),
		OwnerUid:          meta.UID,
		ThemeId:           meta.ThemeID,
		GroupId:           meta.GroupID,
		DocId:             meta.DocID,
		Mime:              meta.Mime,
		Size:              meta.Size,
		EncryptedKey:      meta.EncryptedKey,
		Iv:                meta.IV,
		EncryptedMetadata: meta.EncryptedMetadata,
	}, nil
}

func (s *Service) DeleteFile(ctx context.Context, req *pb.DeleteFileRequest) (*pb.BasicResponse, error) {
	uid := getUID(ctx)
	uoid := getUOID(ctx)
	log.Infof("[grpc] DeleteFile uid=%s fileId=%s", uid, req.GetFileId())
	if uid == "" || uoid == "" {
		return &pb.BasicResponse{Err: 1, Msg: "unauthenticated"}, nil
	}
	meta, err := db.FileMetaGet(ctx, req.GetFileId())
	if err != nil {
		if errors.Is(err, db.ErrRecordNotFound) {
			return &pb.BasicResponse{Err: 404, Msg: "not found"}, nil
		}
		return &pb.BasicResponse{Err: 1, Msg: err.Error()}, nil
	}
	if meta.UID != uid {
		if _, err := db.PermissionGet(uoid, db.ResourceTypeDoc, meta.DocID); err != nil {
			return &pb.BasicResponse{Err: 403, Msg: "permission denied"}, nil
		}
	}
	if err := s.deleteOneFile(ctx, meta); err != nil {
		return &pb.BasicResponse{Err: 1, Msg: err.Error()}, nil
	}
	return &pb.BasicResponse{Err: 0, Msg: "ok"}, nil
}

// deleteAllFilesForDoc removes all files bound to a doc from minio and mongo.
func (s *Service) deleteAllFilesForDoc(ctx context.Context, docID string) error {
	items, err := db.FileMetaListByDoc(ctx, docID)
	if err != nil {
		if errors.Is(err, db.ErrRecordNotFound) {
			return nil
		}
		return err
	}
	for _, fm := range items {
		if err := s.deleteOneFile(ctx, &fm); err != nil {
			return err
		}
	}
	return nil
}

func (s *Service) deleteOneFile(ctx context.Context, meta *db.FileMeta) error {
	if meta == nil {
		return fmt.Errorf("nil filemeta")
	}
	if err := minioSvc.GetClient().DeleteObject(ctx, meta.ObjectPath); err != nil {
		return err
	}
	_, err := db.FileMetaDelete(ctx, meta.ID)
	return err
}

// BackgroundJobService
func (s *Service) ListJobs(ctx context.Context, _ *pb.ListBackgroundJobsRequest) (*pb.ListBackgroundJobsResponse, error) {
	log.Infof("[grpc] ListJobs uid=%s", getUID(ctx))
	uoid := getUOID(ctx)
	jobs, err := db.BGJobsGet(uoid)
	if err != nil {
		return &pb.ListBackgroundJobsResponse{Err: 1, Msg: err.Error()}, nil
	}
	res := make([]*pb.BackgroundJob, 0, len(jobs))
	for _, j := range jobs {
		res = append(res, &pb.BackgroundJob{
			Id:          j.ID,
			Name:        j.Name,
			JobType:     j.JobType,
			Status:      j.Status,
			CreatedAt:   j.CreatedAt.Format(time.RFC3339),
			StartedAt:   timePtrToString(j.StartedAt),
			CompletedAt: timePtrToString(j.CompletedAt),
			Priority:    int32(j.Priority),
			RetryCount:  int32(j.RetryCount),
			ResultJson:  toJSON(j.Result),
			ErrorJson:   toJSON(j.Error),
		})
	}
	return &pb.ListBackgroundJobsResponse{Err: 0, Msg: "ok", Jobs: res}, nil
}

func (s *Service) GetJob(ctx context.Context, req *pb.GetBackgroundJobRequest) (*pb.BackgroundJob, error) {
	log.Infof("[grpc] GetJob uid=%s id=%s", getUID(ctx), req.GetId())
	uoid := getUOID(ctx)
	job, err := db.BGJobGet(uoid, req.GetId())
	if err != nil {
		return nil, status.Error(codes.Internal, err.Error())
	}
	return &pb.BackgroundJob{
		Id:          job.ID,
		Name:        job.Name,
		JobType:     job.JobType,
		Status:      job.Status,
		CreatedAt:   job.CreatedAt.Format(time.RFC3339),
		StartedAt:   timePtrToString(job.StartedAt),
		CompletedAt: timePtrToString(job.CompletedAt),
		Priority:    int32(job.Priority),
		RetryCount:  int32(job.RetryCount),
		ResultJson:  toJSON(job.Result),
		ErrorJson:   toJSON(job.Error),
	}, nil
}

func (s *Service) DeleteJob(ctx context.Context, req *pb.DeleteBackgroundJobRequest) (*pb.BasicResponse, error) {
	log.Infof("[grpc] DeleteJob uid=%s id=%s", getUID(ctx), req.GetId())
	uoid := getUOID(ctx)
	// Use req.GetId() (string) directly
	if err := db.BGJobDelete(uoid, req.GetId()); err != nil {
		return &pb.BasicResponse{Err: 1, Msg: err.Error()}, nil
	}
	return &pb.BasicResponse{Err: 0, Msg: "ok"}, nil
}

func (s *Service) DownloadJobFile(ctx context.Context, req *pb.DownloadBackgroundJobFileRequest) (*pb.DownloadBackgroundJobFileResponse, error) {
	log.Infof("[grpc] DownloadJobFile uid=%s id=%s", getUID(ctx), req.GetId())
	uoid := getUOID(ctx)
	job, err := db.BGJobGet(uoid, req.GetId())
	if err != nil {
		return &pb.DownloadBackgroundJobFileResponse{Err: 1, Msg: err.Error()}, nil
	}
	if job.Status != db.JobStatusCompleted {
		return &pb.DownloadBackgroundJobFileResponse{Err: 400, Msg: "任务未完成"}, nil
	}
	var filePath string
	if job.Result != nil {
		if resultMap, ok := job.Result.(map[string]interface{}); ok {
			if filename, ok := resultMap["filename"].(string); ok {
				filePath = filename
			}
		}
	}
	if filePath == "" {
		return &pb.DownloadBackgroundJobFileResponse{Err: 404, Msg: "文件未找到"}, nil
	}
	data, err := os.ReadFile(filePath)
	if err != nil {
		return &pb.DownloadBackgroundJobFileResponse{Err: 404, Msg: err.Error()}, nil
	}
	return &pb.DownloadBackgroundJobFileResponse{Err: 0, Msg: "ok", Data: data, Filename: filepath.Base(filePath)}, nil
}

// helpers
func intPtr(v int) *int { return &v }

// func boolPtr(v bool) *bool    { return &v }
func strPtr(v string) *string { return &v }

func mimeExt(m string) string {
	switch m {
	case "image/jpeg":
		return "jpg"
	case "image/png":
		return "png"
	default:
		return "bin"
	}
}

func permissionEnvelopeFromMap(m map[string]db.Permission, id string) *pb.PermissionEnvelope {
	if m == nil {
		return nil
	}
	if p, ok := m[id]; ok {
		return &pb.PermissionEnvelope{
			EncryptedKey: p.EncryptedKey,
			Role:         p.Role,
		}
	}
	return nil
}

func permissionEnvelopeFromPermission(p *db.Permission) *pb.PermissionEnvelope {
	if p == nil {
		return nil
	}
	return &pb.PermissionEnvelope{EncryptedKey: p.EncryptedKey, Role: p.Role}
}

func extractDocIDs(docs []m.Doc) []string {
	ids := make([]string, 0, len(docs))
	for _, d := range docs {
		ids = append(ids, d.ID)
	}
	return ids
}

func toJSON(v interface{}) string {
	if v == nil {
		return ""
	}
	b, _ := json.Marshal(v)
	return string(b)
}

func decodeNameBytes(s string) []byte {
	if b, err := base64.StdEncoding.DecodeString(s); err == nil {
		return b
	}
	return []byte(s)
}

func nowString() string {
	return time.Now().Format("2006-01-02 15:04:05")
}

func timePtrToString(t *time.Time) string {
	if t == nil {
		return ""
	}
	return t.Format(time.RFC3339)
}

// metadataParam pulls a param from incoming metadata.
func metadataParam(stream grpc.ServerStream, key string) (string, error) {
	md, ok := metadata.FromIncomingContext(stream.Context())
	if !ok {
		return "", fmt.Errorf("missing metadata")
	}
	vals := md.Get(key)
	if len(vals) == 0 {
		return "", fmt.Errorf("missing %s", key)
	}
	return vals[0], nil
}
