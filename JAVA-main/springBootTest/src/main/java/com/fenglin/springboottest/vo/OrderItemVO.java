package com.fenglin.springboottest.vo;

import lombok.Data;

import java.math.BigDecimal;

/**
 * 订单明细视图
 */
@Data
public class OrderItemVO {

    /** 商品ID */
    private Long productId;

    /** 商品名称 */
    private String productName;

    /** 图标 */
    private String icon;

    /** 单价（下单快照） */
    private BigDecimal price;

    /** 数量 */
    private Integer quantity;
}
