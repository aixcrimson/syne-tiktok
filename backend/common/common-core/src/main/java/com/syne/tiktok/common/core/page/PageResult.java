package com.syne.tiktok.common.core.page;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;
import java.util.List;

/**
 * 分页结果封装
 *
 * @param <T> 数据类型
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class PageResult<T> implements Serializable {

    private static final long serialVersionUID = 1L;

    /** 数据列表 */
    private List<T> content;

    /** 总记录数 */
    private long total;

    /** 当前页码 */
    private long page;

    /** 每页大小 */
    private long size;

    public static <T> PageResult<T> of(List<T> content, long total, long page, long size) {
        return new PageResult<>(content, total, page, size);
    }
}
