package com.syne.tiktok.common.core.enums;

import lombok.AllArgsConstructor;
import lombok.Getter;

/**
 * 用户账号状态枚举
 */
@Getter
@AllArgsConstructor
public enum UserStatus {

    NORMAL("NORMAL", "正常"),
    BANNED("BANNED", "封号"),
    MUTED("MUTED", "禁言");

    private final String code;
    private final String description;
}
