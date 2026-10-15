package com.fenglin.springboottest.vo;

import lombok.Data;

import java.math.BigDecimal;

/**
 * 购物车项视图（含商品快照信息）
 */
@Data
public class CartVO {

    /** 购物车记录ID */
    private Long id;

    /** 商品ID */
    private Long productId;

    /** 商品名称 */
    private String name;

    /** 图标 */
    private String icon;

    /** 售价 */
    private BigDecimal price;

    /** 原价 */
    private BigDecimal originalPrice;

    /** 秒杀价（若为秒杀商品） */
    private BigDecimal seckillPrice;

    /** 数量 */
    private Integer quantity;

    /** 库存 */
    private Integer stock;

    /** 分类名 */
    private String categoryName;

    /** 小计 = 售价 × 数量 */
    private BigDecimal subtotal;
}
