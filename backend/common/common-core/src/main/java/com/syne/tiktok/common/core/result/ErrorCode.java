package com.syne.tiktok.common.core.result;

import lombok.AllArgsConstructor;
import lombok.Getter;

/**
 * 错误码枚举
 * <p>
 * 错误码分段规则：
 * - 1xxx: 用户服务
 * - 2xxx: 视频服务
 * - 3xxx: 管理服务
 * - 4xxx: 文件服务
 * - 9xxx: 系统级错误
 */
@Getter
@AllArgsConstructor
public enum ErrorCode {

    // ========== 系统级错误 ==========
    SYSTEM_ERROR(9999, "系统内部错误"),
    PARAM_ERROR(9001, "参数错误"),
    UNAUTHORIZED(9002, "未登录或认证已过期"),
    FORBIDDEN(9003, "无权限访问"),

    // ========== 用户服务 1xxx ==========
    USER_ALREADY_EXISTS(1001, "用户名已存在"),
    USER_AUTH_FAILED(1002, "用户名或密码错误"),
    USER_NOT_FOUND(1003, "用户不存在"),
    CANNOT_FOLLOW_SELF(1004, "不能关注自己"),
    ALREADY_FOLLOWED(1005, "已经关注"),
    NOT_FOLLOWED(1006, "未关注"),
    USER_BANNED(1007, "账号已被封禁"),
    USER_MUTED(1008, "账号已被禁言"),

    // ========== 视频服务 2xxx ==========
    VIDEO_NOT_FOUND(2001, "视频不存在"),
    VIDEO_REMOVED(2002, "视频已下架"),
    VIDEO_NOT_APPROVED(2003, "视频审核未通过"),
    VIDEO_NO_PERMISSION(2004, "无权操作他人视频"),
    FILE_FORMAT_NOT_SUPPORTED(2005, "文件格式不支持"),
    FILE_SIZE_EXCEEDED(2006, "文件大小超限"),
    UPLOAD_FAILED(2007, "上传失败"),
    ALREADY_LIKED(2008, "视频已点赞"),
    NOT_LIKED(2009, "视频未点赞"),
    ALREADY_FAVORITED(2010, "视频已收藏"),
    NOT_FAVORITED(2011, "视频未收藏"),
    COMMENT_EMPTY(2012, "评论内容不能为空"),

    // ========== 管理服务 3xxx ==========
    ADMIN_AUTH_FAILED(3001, "用户名或密码错误"),
    NO_ADMIN_PERMISSION(3002, "无管理员权限"),
    ADMIN_VIDEO_NOT_FOUND(3003, "视频不存在"),
    VIDEO_STATUS_INVALID(3004, "视频状态不允许此操作"),
    COMMENT_NOT_FOUND(3005, "评论不存在"),
    ADMIN_USER_NOT_FOUND(3006, "用户不存在"),
    USER_ALREADY_BANNED(3007, "用户已被封禁"),
    REPORT_NOT_FOUND(3008, "举报不存在"),

    // ========== 文件服务 4xxx ==========
    FILE_UPLOAD_ERROR(4001, "文件上传失败"),
    FILE_NOT_FOUND(4002, "文件不存在"),
    FILE_DELETE_ERROR(4003, "文件删除失败");

    private final int code;
    private final String message;
}
