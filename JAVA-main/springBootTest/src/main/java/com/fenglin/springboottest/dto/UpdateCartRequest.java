package com.fenglin.springboottest.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

/**
 * 修改购物车数量请求
 */
@Data
public class UpdateCartRequest {

    /** 用户ID */
    @NotNull(message = "用户ID不能为空")
    private Long userId;

    /** 商品ID */
    @NotNull(message = "商品ID不能为空")
    private Long productId;

    /** 新的数量（>=1） */
    @NotNull(message = "数量不能为空")
    private Integer quantity;
}
