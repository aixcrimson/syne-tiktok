package com.syne.tiktok.common.core.enums;

import lombok.AllArgsConstructor;
import lombok.Getter;

/**
 * 用户角色枚举
 */
@Getter
@AllArgsConstructor
public enum UserRole {

    USER("USER", "普通用户"),
    ADMIN("ADMIN", "管理员");

    private final String code;
    private final String description;
}
