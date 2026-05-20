package com.syne.tiktok.common.core.enums;

import lombok.AllArgsConstructor;
import lombok.Getter;

/**
 * 视频审核状态枚举
 */
@Getter
@AllArgsConstructor
public enum VideoStatus {

    PENDING("PENDING", "待审核"),
    APPROVED("APPROVED", "已通过"),
    REJECTED("REJECTED", "已拒绝"),
    REMOVED("REMOVED", "已下架");

    private final String code;
    private final String description;
}
