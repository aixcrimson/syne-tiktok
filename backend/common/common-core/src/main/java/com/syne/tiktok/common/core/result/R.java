package com.syne.tiktok.common.core.result;

import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;

/**
 * 统一返回结果封装
 *
 * @param <T> 数据类型
 */
@Data
@NoArgsConstructor
public class R<T> implements Serializable {

    private static final long serialVersionUID = 1L;

    /** 状态码，0 表示成功 */
    private int code;

    /** 提示信息 */
    private String message;

    /** 返回数据 */
    private T data;

    private R(int code, String message, T data) {
        this.code = code;
        this.message = message;
        this.data = data;
    }

    /**
     * 成功（无数据）
     */
    public static <T> R<T> ok() {
        return new R<>(0, "success", null);
    }

    /**
     * 成功（带数据）
     */
    public static <T> R<T> ok(T data) {
        return new R<>(0, "success", data);
    }

    /**
     * 成功（带消息和数据）
     */
    public static <T> R<T> ok(String message, T data) {
        return new R<>(0, message, data);
    }

    /**
     * 失败
     */
    public static <T> R<T> fail(int code, String message) {
        return new R<>(code, message, null);
    }

    /**
     * 失败（使用错误码枚举）
     */
    public static <T> R<T> fail(ErrorCode errorCode) {
        return new R<>(errorCode.getCode(), errorCode.getMessage(), null);
    }
}
