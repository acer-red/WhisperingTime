-- Don't modify this.

CREATE TABLE IF NOT EXISTS users (
  id                UUID PRIMARY KEY DEFAULT uuidv7()
);
COMMENT ON TABLE users IS '用户表';
COMMENT ON COLUMN users.id IS '用户ID,uuid格式,对外显示uid';



CREATE TABLE IF NOT EXISTS theme (
  id                UUID PRIMARY KEY DEFAULT uuidv7(),
  uid               UUID NOT NULL REFERENCES users (id) ON DELETE CASCADE,

  name              bytea NOT NULL,
  encrypted_key     bytea NOT NULL,

  created_at        timestamptz NOT NULL DEFAULT now (),
  updated_at        timestamptz NOT NULL DEFAULT now (),
  deleted_at        timestamptz
);
COMMENT ON TABLE theme IS '主题表';
COMMENT ON COLUMN theme.uid IS '所属用户ID';
COMMENT ON COLUMN theme.name IS '主题名称,加密存储';
COMMENT ON COLUMN theme.encrypted_key IS '信封密钥';
COMMENT ON COLUMN theme.created_at IS '创建时间';
COMMENT ON COLUMN theme.updated_at IS '更新时间';
COMMENT ON COLUMN theme.deleted_at IS '删除时间';


CREATE TABLE IF NOT EXISTS "groups" (
  id                  UUID PRIMARY KEY DEFAULT uuidv7(),
  uid                 UUID NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  tid                 UUID NOT NULL REFERENCES theme (id) ON DELETE CASCADE,

  name                bytea NOT NULL,
  encrypted_key       bytea NOT NULL,
  default_group       boolean NOT NULL DEFAULT false,
  levels_str          text,
  view_type           integer NOT NULL DEFAULT 0,
  sort_type           integer NOT NULL DEFAULT 0,
  auto_freeze_days    integer NOT NULL DEFAULT 30,

  over_at             timestamptz,
  create_at           timestamptz NOT NULL DEFAULT now (),
  update_at           timestamptz NOT NULL DEFAULT now (),
  deleted_at          timestamptz
);  
COMMENT ON TABLE "groups" IS '分组表, 隶属于主题';
COMMENT ON COLUMN "groups".uid IS '所属用户ID';
COMMENT ON COLUMN "groups".tid IS '所属主题ID';
COMMENT ON COLUMN "groups".name IS '分组名称,加密存储';
COMMENT ON COLUMN "groups".encrypted_key IS '信封密钥';
COMMENT ON COLUMN "groups".default_group IS '是否为默认分组';
COMMENT ON COLUMN "groups".levels_str IS '等级字符串';
COMMENT ON COLUMN "groups".view_type IS '视图类型';
COMMENT ON COLUMN "groups".sort_type IS '排序类型';
COMMENT ON COLUMN "groups".auto_freeze_days IS '自动冻结天数';
COMMENT ON COLUMN "groups".over_at IS '结束时间';



CREATE TABLE IF NOT EXISTS doc (
  id                  UUID PRIMARY KEY DEFAULT uuidv7(),
  uid                 UUID NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  gid                 UUID NOT NULL REFERENCES groups (id) ON DELETE CASCADE,
  
  title               bytea,
  rich                bytea,
  scales              bytea,
  level               bytea,
  encrypted_key       bytea NOT NULL,
    
  is_show_tool        boolean NOT NULL DEFAULT false,
  display_priority    integer NOT NULL DEFAULT 0,
    
  create_at           timestamptz NOT NULL DEFAULT now (),
  update_at           timestamptz NOT NULL DEFAULT now (),
  deleted_at          timestamptz
);
COMMENT ON TABLE doc IS '文档表, 隶属于分组';
COMMENT ON COLUMN doc.title IS '文档标题,加密存储';
COMMENT ON COLUMN doc.rich IS '富文本内容,加密存储';
COMMENT ON COLUMN doc.scales IS '刻度,加密存储';
COMMENT ON COLUMN doc.level IS '等级,加密存储';
COMMENT ON COLUMN doc.encrypted_key IS '信封密钥';
COMMENT ON COLUMN doc.is_show_tool IS '是否显示工具栏';
COMMENT ON COLUMN doc.display_priority IS '显示优先级';



CREATE TABLE IF NOT EXISTS permission (
  id                  bigserial PRIMARY KEY,
  uid                 UUID NOT NULL REFERENCES users (id) ON DELETE CASCADE,

  role                text NOT NULL CHECK (role IN ('owner', 'editor', 'viewer')),
  resource_type       text NOT NULL CHECK (resource_type IN ('theme', 'group', 'doc')),
  resource_id         UUID NOT NULL,
  encrypted_key       bytea NOT NULL,

  created_at          timestamptz NOT NULL DEFAULT now (),
  updated_at          timestamptz NOT NULL DEFAULT now (),
  UNIQUE (uid, resource_type, resource_id)
);
COMMENT ON TABLE permission IS '权限表, 记录用户对资源(主题、分组、文档)的权限';
COMMENT ON COLUMN permission.resource_id IS '资源ID,uuid格式';
COMMENT ON COLUMN permission.encrypted_key IS '信封密钥';



CREATE TABLE IF NOT EXISTS filemeta (
  id                  UUID PRIMARY KEY DEFAULT uuidv7(),
  uid                 UUID NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  did                 UUID NOT NULL REFERENCES doc (id) ON DELETE CASCADE,

  object_path         text NOT NULL,
  mime                text NOT NULL,
  size                bigint NOT NULL,
  encrypted_key       bytea NOT NULL,
  iv                  bytea NOT NULL,
  encrypted_metadata  bytea NOT NULL,

  created_at          timestamptz NOT NULL DEFAULT now (),
  updated_at          timestamptz NOT NULL DEFAULT now (),
  deleted_at          timestamptz
);
COMMENT ON TABLE filemeta IS '文档元信息表';
COMMENT ON COLUMN filemeta.object_path IS '存储对象路径';
COMMENT ON COLUMN filemeta.mime IS '文件MIME类型';
COMMENT ON COLUMN filemeta.size IS '文件大小(字节)';
COMMENT ON COLUMN filemeta.iv IS '初始化向量';
COMMENT ON COLUMN filemeta.encrypted_metadata IS '加密的文件元数据';



CREATE TABLE IF NOT EXISTS scale_template (
  id                  UUID PRIMARY KEY DEFAULT uuidv7(),
  uid                 UUID NOT NULL REFERENCES users (id) ON DELETE CASCADE,

  encrypted_metadata  bytea NOT NULL,

  created_at          timestamptz NOT NULL DEFAULT now ()
);
COMMENT ON TABLE scale_template IS '刻度模板表';
COMMENT ON COLUMN scale_template.encrypted_metadata IS '加密的刻度元数据';



CREATE TABLE IF NOT EXISTS bg_job (
  id                  UUID PRIMARY KEY DEFAULT uuidv7(),
  uid                 UUID NOT NULL REFERENCES users (id) ON DELETE CASCADE,

  job_type            text NOT NULL ,
  name                text NOT NULL,
  status              text NOT NULL CHECK ( status IN ('pending', 'running', 'completed', 'failed') ) DEFAULT 'pending',

  payload             bytea,
  result              bytea,
  error_code          integer,
  error_message       text,
  priority            integer NOT NULL DEFAULT 0,
  retry_count         integer NOT NULL DEFAULT 0,

  created_at          timestamptz NOT NULL DEFAULT now (),
  started_at          timestamptz,
  completed_at        timestamptz
);
COMMENT ON TABLE bg_job IS '后台任务表';
COMMENT ON COLUMN bg_job.payload IS '任务负载';
COMMENT ON COLUMN bg_job.result IS '任务结果';
COMMENT ON COLUMN bg_job.priority IS '优先级';
COMMENT ON COLUMN bg_job.retry_count IS '重试次数';