package com.fenglin.springboottest.dto;

import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.util.List;

/**
 * 下单请求（购物车结算 / 直接购买）
 */
@Data
public class CreateOrderRequest {

    /** 用户ID */
    @NotNull(message = "用户ID不能为空")
    private Long userId;

    /** 收货人 */
    private String receiverName;

    /** 收货电话 */
    private String receiverPhone;

    /** 收货地址 */
    private String address;

    /** 下单明细 */
    @NotEmpty(message = "订单明细不能为空")
    private List<Item> items;

    /** 订单单项 */
    @Data
    public static class Item {
        @NotNull(message = "商品ID不能为空")
        private Long productId;
        @NotNull(message = "数量不能为空")
        private Integer quantity;
    }
}
