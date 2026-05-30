-- =============================================================================
-- Syne TikTok Platform - Database Initialization Script
-- Target Database: PostgreSQL
-- Default Database Name: syne_tiktok
-- =============================================================================

-- 1. 创建各个微服务对应的 Schema
CREATE SCHEMA IF NOT EXISTS user_schema;
CREATE SCHEMA IF NOT EXISTS video_schema;
CREATE SCHEMA IF NOT EXISTS admin_schema;

-- =============================================================================
-- 1. 用户服务表 (user_schema)
-- =============================================================================

-- 用户基本信息表
CREATE TABLE IF NOT EXISTS user_schema.t_user (
    id BIGSERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(100) NOT NULL,
    nickname VARCHAR(50) DEFAULT '',
    avatar VARCHAR(255) DEFAULT '',
    signature VARCHAR(150) DEFAULT '',
    phone VARCHAR(20) DEFAULT '',
    email VARCHAR(50) DEFAULT '',
    status SMALLINT DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted SMALLINT DEFAULT 0
);

COMMENT ON TABLE user_schema.t_user IS '用户基本信息表';
COMMENT ON COLUMN user_schema.t_user.id IS '用户ID (主键)';
COMMENT ON COLUMN user_schema.t_user.username IS '登录用户名 (唯一)';
COMMENT ON COLUMN user_schema.t_user.password IS '加密密码哈希';
COMMENT ON COLUMN user_schema.t_user.nickname IS '用户昵称';
COMMENT ON COLUMN user_schema.t_user.avatar IS '头像链接';
COMMENT ON COLUMN user_schema.t_user.signature IS '个性签名';
COMMENT ON COLUMN user_schema.t_user.phone IS '手机号';
COMMENT ON COLUMN user_schema.t_user.email IS '邮箱';
COMMENT ON COLUMN user_schema.t_user.status IS '状态 (0: 正常, 1: 禁用)';
COMMENT ON COLUMN user_schema.t_user.created_at IS '注册时间';
COMMENT ON COLUMN user_schema.t_user.updated_at IS '更新时间';
COMMENT ON COLUMN user_schema.t_user.deleted IS '逻辑删除 (0: 未删除, 1: 已删除)';

-- 用户关注关系表
CREATE TABLE IF NOT EXISTS user_schema.t_relation (
    id BIGSERIAL PRIMARY KEY,
    follower_id BIGINT NOT NULL,
    following_id BIGINT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_relation_follower_following ON user_schema.t_relation(follower_id, following_id);
CREATE INDEX IF NOT EXISTS idx_relation_following ON user_schema.t_relation(following_id);

COMMENT ON TABLE user_schema.t_relation IS '用户关注与粉丝关系表';
COMMENT ON COLUMN user_schema.t_relation.id IS '关系ID (主键)';
COMMENT ON COLUMN user_schema.t_relation.follower_id IS '粉丝用户ID (发起关注的人)';
COMMENT ON COLUMN user_schema.t_relation.following_id IS '被关注用户ID (被关注的人)';
COMMENT ON COLUMN user_schema.t_relation.created_at IS '关注时间';


-- =============================================================================
-- 2. 视频服务表 (video_schema)
-- =============================================================================

-- 视频基本信息表
CREATE TABLE IF NOT EXISTS video_schema.t_video (
    id BIGSERIAL PRIMARY KEY,
    title VARCHAR(255) DEFAULT '',
    video_url VARCHAR(500) NOT NULL,
    cover_url VARCHAR(500) DEFAULT '',
    author_id BIGINT NOT NULL,
    music_title VARCHAR(150) DEFAULT '原声',
    music_author VARCHAR(100) DEFAULT '',
    play_count BIGINT DEFAULT 0,
    like_count BIGINT DEFAULT 0,
    comment_count BIGINT DEFAULT 0,
    favorite_count BIGINT DEFAULT 0,
    share_count BIGINT DEFAULT 0,
    status SMALLINT DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted SMALLINT DEFAULT 0
);

CREATE INDEX IF NOT EXISTS idx_video_author ON video_schema.t_video(author_id);
CREATE INDEX IF NOT EXISTS idx_video_status ON video_schema.t_video(status);

COMMENT ON TABLE video_schema.t_video IS '视频基本信息表';
COMMENT ON COLUMN video_schema.t_video.id IS '视频ID (主键)';
COMMENT ON COLUMN video_schema.t_video.title IS '视频描述或标题';
COMMENT ON COLUMN video_schema.t_video.video_url IS '视频播放文件地址';
COMMENT ON COLUMN video_schema.t_video.cover_url IS '视频封面图片地址';
COMMENT ON COLUMN video_schema.t_video.author_id IS '视频作者ID';
COMMENT ON COLUMN video_schema.t_video.music_title IS '背景音乐名称';
COMMENT ON COLUMN video_schema.t_video.music_author IS '背景音乐作者';
COMMENT ON COLUMN video_schema.t_video.play_count IS '播放次数';
COMMENT ON COLUMN video_schema.t_video.like_count IS '获得点赞次数';
COMMENT ON COLUMN video_schema.t_video.comment_count IS '总评论数';
COMMENT ON COLUMN video_schema.t_video.favorite_count IS '收藏次数';
COMMENT ON COLUMN video_schema.t_video.share_count IS '分享次数';
COMMENT ON COLUMN video_schema.t_video.status IS '状态 (0: 待审核, 1: 审核通过/已发布, 2: 审核驳回)';
COMMENT ON COLUMN video_schema.t_video.created_at IS '上传时间';
COMMENT ON COLUMN video_schema.t_video.updated_at IS '更新时间';
COMMENT ON COLUMN video_schema.t_video.deleted IS '逻辑删除 (0: 未删除, 1: 已删除)';

-- 视频点赞表
CREATE TABLE IF NOT EXISTS video_schema.t_video_like (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    video_id BIGINT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_vlike_user_video ON video_schema.t_video_like(user_id, video_id);
CREATE INDEX IF NOT EXISTS idx_vlike_video ON video_schema.t_video_like(video_id);

COMMENT ON TABLE video_schema.t_video_like IS '视频点赞关联表';
COMMENT ON COLUMN video_schema.t_video_like.id IS '主键ID';
COMMENT ON COLUMN video_schema.t_video_like.user_id IS '点赞用户ID';
COMMENT ON COLUMN video_schema.t_video_like.video_id IS '被点赞视频ID';
COMMENT ON COLUMN video_schema.t_video_like.created_at IS '点赞时间';

-- 视频收藏表
CREATE TABLE IF NOT EXISTS video_schema.t_video_favorite (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    video_id BIGINT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_vfav_user_video ON video_schema.t_video_favorite(user_id, video_id);
CREATE INDEX IF NOT EXISTS idx_vfav_video ON video_schema.t_video_favorite(video_id);

COMMENT ON TABLE video_schema.t_video_favorite IS '视频收藏关联表';
COMMENT ON COLUMN video_schema.t_video_favorite.id IS '主键ID';
COMMENT ON COLUMN video_schema.t_video_favorite.user_id IS '收藏用户ID';
COMMENT ON COLUMN video_schema.t_video_favorite.video_id IS '被收藏视频ID';
COMMENT ON COLUMN video_schema.t_video_favorite.created_at IS '收藏时间';

-- 视频评论表
CREATE TABLE IF NOT EXISTS video_schema.t_video_comment (
    id BIGSERIAL PRIMARY KEY,
    video_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    parent_id BIGINT DEFAULT 0,
    content TEXT NOT NULL,
    like_count INT DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted SMALLINT DEFAULT 0
);

CREATE INDEX IF NOT EXISTS idx_comment_video ON video_schema.t_video_comment(video_id);
CREATE INDEX IF NOT EXISTS idx_comment_parent ON video_schema.t_video_comment(parent_id);

COMMENT ON TABLE video_schema.t_video_comment IS '视频评论表';
COMMENT ON COLUMN video_schema.t_video_comment.id IS '评论ID (主键)';
COMMENT ON COLUMN video_schema.t_video_comment.video_id IS '视频ID';
COMMENT ON COLUMN video_schema.t_video_comment.user_id IS '评论发布者用户ID';
COMMENT ON COLUMN video_schema.t_video_comment.parent_id IS '父评论ID (0为第一级主评论)';
COMMENT ON COLUMN video_schema.t_video_comment.content IS '评论内容文本';
COMMENT ON COLUMN video_schema.t_video_comment.like_count IS '评论获赞数';
COMMENT ON COLUMN video_schema.t_video_comment.created_at IS '评论时间';
COMMENT ON COLUMN video_schema.t_video_comment.updated_at IS '更新时间';
COMMENT ON COLUMN video_schema.t_video_comment.deleted IS '逻辑删除 (0: 未删除, 1: 已删除)';


-- =============================================================================
-- 3. 后台管理与审核表 (admin_schema)
-- =============================================================================

-- 管理员信息表
CREATE TABLE IF NOT EXISTS admin_schema.t_admin (
    id BIGSERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(100) NOT NULL,
    nickname VARCHAR(50) DEFAULT '',
    avatar VARCHAR(255) DEFAULT '',
    role VARCHAR(50) DEFAULT 'admin',
    status SMALLINT DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted SMALLINT DEFAULT 0
);

COMMENT ON TABLE admin_schema.t_admin IS '系统管理员表';
COMMENT ON COLUMN admin_schema.t_admin.id IS '管理员ID (主键)';
COMMENT ON COLUMN admin_schema.t_admin.username IS '管理员登录名 (唯一)';
COMMENT ON COLUMN admin_schema.t_admin.password IS '加密密码哈希';
COMMENT ON COLUMN admin_schema.t_admin.nickname IS '管理员昵称';
COMMENT ON COLUMN admin_schema.t_admin.avatar IS '管理员头像链接';
COMMENT ON COLUMN admin_schema.t_admin.role IS '管理员角色 (admin, super_admin)';
COMMENT ON COLUMN admin_schema.t_admin.status IS '状态 (0: 正常, 1: 禁用)';
COMMENT ON COLUMN admin_schema.t_admin.created_at IS '创建时间';
COMMENT ON COLUMN admin_schema.t_admin.updated_at IS '更新时间';
COMMENT ON COLUMN admin_schema.t_admin.deleted IS '逻辑删除 (0: 未删除, 1: 已删除)';

-- 视频审核日志表
CREATE TABLE IF NOT EXISTS admin_schema.t_video_audit (
    id BIGSERIAL PRIMARY KEY,
    video_id BIGINT NOT NULL,
    auditor_id BIGINT DEFAULT NULL,
    status SMALLINT DEFAULT 0,
    reason VARCHAR(255) DEFAULT '',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted SMALLINT DEFAULT 0
);

CREATE INDEX IF NOT EXISTS idx_audit_video ON admin_schema.t_video_audit(video_id);
CREATE INDEX IF NOT EXISTS idx_audit_status ON admin_schema.t_video_audit(status);

COMMENT ON TABLE admin_schema.t_video_audit IS '视频审核历史记录表';
COMMENT ON COLUMN admin_schema.t_video_audit.id IS '主键ID';
COMMENT ON COLUMN admin_schema.t_video_audit.video_id IS '关联的视频ID';
COMMENT ON COLUMN admin_schema.t_video_audit.auditor_id IS '执行审核的管理员ID';
COMMENT ON COLUMN admin_schema.t_video_audit.status IS '审核状态 (0: 待审核, 1: 审核通过, 2: 审核拒绝)';
COMMENT ON COLUMN admin_schema.t_video_audit.reason IS '审核意见或拒绝原因说明';
COMMENT ON COLUMN admin_schema.t_video_audit.created_at IS '提交/审核时间';
COMMENT ON COLUMN admin_schema.t_video_audit.updated_at IS '更新时间';
COMMENT ON COLUMN admin_schema.t_video_audit.deleted IS '逻辑删除';


-- =============================================================================
-- 4. 插入测试 mock 数据（匹配前端展示内容）
-- =============================================================================

-- 4.1 插入测试用户数据（密码均为 123456，其 BCrypt 加密哈希为：$2a$10$8.KclwV4aK4fJQX4.P2lKeNtb.F9v8C25uC4pIqB.5uR6mNfS0V5O）
INSERT INTO user_schema.t_user (id, username, password, nickname, avatar, signature) VALUES
(1, 'nature_lover', '$2a$10$8.KclwV4aK4fJQX4.P2lKeNtb.F9v8C25uC4pIqB.5uR6mNfS0V5O', 'Nature Lover', 'https://api.dicebear.com/7.x/notionists/svg?seed=Emma', 'Fresh forest stream in the morning sunlight. Nature heals! 🌲☀️'),
(2, 'cat_memes', '$2a$10$8.KclwV4aK4fJQX4.P2lKeNtb.F9v8C25uC4pIqB.5uR6mNfS0V5O', 'Cat Memes Hub', 'https://api.dicebear.com/7.x/notionists/svg?seed=Sophia', 'Look at those paws! He is just looking for attention. 🐾😻'),
(3, 'dev_guru', '$2a$10$8.KclwV4aK4fJQX4.P2lKeNtb.F9v8C25uC4pIqB.5uR6mNfS0V5O', 'Developer Guru', 'https://api.dicebear.com/7.x/notionists/svg?seed=Lucas', 'Vue 3 + Spring Boot fullstack developer.'),
(4, 'food_vlog', '$2a$10$8.KclwV4aK4fJQX4.P2lKeNtb.F9v8C25uC4pIqB.5uR6mNfS0V5O', 'Foodie Vlog', 'https://api.dicebear.com/7.x/notionists/svg?seed=Oliver', 'Fast knife cooking skill. Dinner starts here! 🔪🌶️'),
(5, 'ui_designer', '$2a$10$8.KclwV4aK4fJQX4.P2lKeNtb.F9v8C25uC4pIqB.5uR6mNfS0V5O', 'UI/UX Designer', 'https://api.dicebear.com/7.x/notionists/svg?seed=Liam', 'Building glassmorphic user interfaces.'),
(6, 'aixcrimson', '$2a$10$8.KclwV4aK4fJQX4.P2lKeNtb.F9v8C25uC4pIqB.5uR6mNfS0V5O', 'Aix Crimson', 'https://api.dicebear.com/7.x/notionists/svg?seed=User', 'TikTok frontend tester.')
ON CONFLICT (username) DO NOTHING;

-- 同步用户表自增序列（防止手动导入主键后，自增主键发生冲突）
SELECT setval('user_schema.t_user_id_seq', COALESCE((SELECT MAX(id)+1 FROM user_schema.t_user), 1), false);

-- 4.2 插入关注关系
INSERT INTO user_schema.t_relation (follower_id, following_id) VALUES
(6, 1), -- aixcrimson 关注了 nature_lover
(6, 2), -- aixcrimson 关注了 cat_memes
(6, 3), -- aixcrimson 关注了 dev_guru
(2, 3), -- cat_memes 关注了 dev_guru
(3, 2)  -- dev_guru 关注了 cat_memes
ON CONFLICT DO NOTHING;

-- 4.3 插入测试视频数据
-- 状态: 0:待审核, 1:已发布, 2:已拒绝
INSERT INTO video_schema.t_video (id, title, video_url, cover_url, author_id, music_title, music_author, play_count, like_count, comment_count, favorite_count, share_count, status) VALUES
(1, 'Fresh forest stream in the morning sunlight. Nature heals! 🌲☀️ #nature #relax #view', 'https://assets.mixkit.co/videos/preview/mixkit-forest-stream-in-the-sunlight-529-large.mp4', 'https://picsum.photos/id/10/200/300', 1, 'Original Sound - nature_lover', 'nature_lover', 120000, 58200, 3, 4000, 4200, 1),
(2, 'Look at those paws! He is just looking for attention. 🐾😻 #cats #funny #cute', 'https://assets.mixkit.co/videos/preview/mixkit-playful-cat-lying-on-a-carpet-43286-large.mp4', 'https://picsum.photos/id/20/200/300', 2, 'Cute Cat Instrumental - Lofi Beats', 'Lofi Beats', 500000, 231400, 4, 15000, 8900, 1),
(3, 'Building custom Liquid Glass elements in Vue 3 has never been easier! Let me show you how. 💻✨ #vuejs #javascript #coding', 'https://assets.mixkit.co/videos/preview/mixkit-typing-on-a-backlit-keyboard-in-the-dark-44026-large.mp4', 'https://picsum.photos/id/30/200/300', 3, 'Cyberpunk Synthwave - Developer Tune', 'Developer Tune', 98000, 45300, 2, 3000, 1200, 1),
(4, 'Fast knife cooking skill. Dinner starts here! 🔪🌶️ #foodie #cooking #streetfood', 'https://assets.mixkit.co/videos/preview/mixkit-cutting-vegetables-on-a-wooden-board-43026-large.mp4', 'https://picsum.photos/id/40/200/300', 4, 'Acoustic Folk Cooking Beats - Chef', 'Chef', 25000, 9100, 0, 500, 310, 2),
(5, 'Liquid Glass Tutorial - Designing beautiful glassmorphism dashboards with interactive hover effects. 🎨💎 #uiux #dashboard #design', 'https://assets.mixkit.co/videos/preview/mixkit-woman-working-on-a-laptop-in-a-cafe-43028-large.mp4', 'https://picsum.photos/id/50/200/300', 5, 'Chill Lofi Workspace', 'Workspace Tunes', 0, 0, 0, 0, 0, 0)
ON CONFLICT (id) DO NOTHING;

-- 同步视频表自增序列
SELECT setval('video_schema.t_video_id_seq', COALESCE((SELECT MAX(id)+1 FROM video_schema.t_video), 1), false);

-- 4.4 插入评论数据
INSERT INTO video_schema.t_video_comment (id, video_id, user_id, parent_id, content, like_count) VALUES
-- 视频1的评论与回复
(1, 1, 6, 0, 'Wow! This forest stream look is absolutely stunning. I can literally feel the sunlight through my screen! 🌞🍃', 580),
(2, 1, 3, 1, 'Same! The color grading here is spectacular.', 45),
(3, 1, 4, 0, 'Nature always has the best screen savers. Outstanding resolution!', 120),
-- 视频2的评论与回复
(4, 2, 6, 0, 'Oh my goodness, those little paws! I cannot stop watching this cat. Absolutely adorable! 🐾😻', 1240),
(5, 2, 3, 4, 'Cutest video on the internet today, hands down!', 310),
(6, 2, 6, 4, 'Agreed! Saved this to watch when I have a bad day.', 150),
(7, 2, 2, 0, 'Cats are liquid, confirmed. 😹', 412),
-- 视频3的评论与回复
(8, 3, 6, 0, 'Vue 3 + Vite is such a game changer. The liquid glass component you built in the demo is incredibly fluid. Great tutorial!', 342),
(9, 3, 5, 8, 'Totally agree. Standard WebGL takes 10x more boilerplate.', 88)
ON CONFLICT (id) DO NOTHING;

-- 同步评论表自增序列
SELECT setval('video_schema.t_video_comment_id_seq', COALESCE((SELECT MAX(id)+1 FROM video_schema.t_video_comment), 1), false);

-- 4.5 插入视频点赞和收藏记录
INSERT INTO video_schema.t_video_like (user_id, video_id) VALUES
(6, 1),
(6, 2),
(6, 3),
(3, 2),
(4, 2)
ON CONFLICT DO NOTHING;

INSERT INTO video_schema.t_video_favorite (user_id, video_id) VALUES
(6, 2),
(3, 2)
ON CONFLICT DO NOTHING;

-- 4.6 插入管理员数据（密码为 123456）
INSERT INTO admin_schema.t_admin (id, username, password, nickname, role, status) VALUES
(1, 'admin', '$2a$10$8.KclwV4aK4fJQX4.P2lKeNtb.F9v8C25uC4pIqB.5uR6mNfS0V5O', '系统超级管理员', 'super_admin', 0)
ON CONFLICT (username) DO NOTHING;

-- 同步管理员表自增序列
SELECT setval('admin_schema.t_admin_id_seq', COALESCE((SELECT MAX(id)+1 FROM admin_schema.t_admin), 1), false);

-- 4.7 插入审核历史记录流水
INSERT INTO admin_schema.t_video_audit (video_id, auditor_id, status, reason) VALUES
(1, 1, 1, '内容积极向上，自然风光画质极高，审核通过。'),
(2, 1, 1, '萌宠类视频，无违规内容，审核通过。'),
(3, 1, 1, '编程教学视频，质量高，审核通过。'),
(4, 1, 2, '含有尖锐刀具的快速切割特写，为安全防范考虑，予以退回修改。'),
(5, 1, 0, '新上传待审核。')
ON CONFLICT DO NOTHING;
