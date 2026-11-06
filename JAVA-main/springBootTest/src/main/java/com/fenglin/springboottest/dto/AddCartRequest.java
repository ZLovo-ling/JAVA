package com.fenglin.springboottest.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

/**
 * 加入购物车请求
 */
@Data
public class AddCartRequest {

    /** 用户ID（前端从登录态 sessionStorage 取） */
    @NotNull(message = "用户ID不能为空")
    private Long userId;

    /** 商品ID */
    @NotNull(message = "商品ID不能为空")
    private Long productId;

    /** 数量，默认 1 */
    private Integer quantity = 1;
}
