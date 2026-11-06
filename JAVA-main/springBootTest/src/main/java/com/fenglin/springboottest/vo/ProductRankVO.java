package com.fenglin.springboottest.vo;

import lombok.Data;

import java.math.BigDecimal;

/**
 * 商品口碑榜条目：某商品的评价聚合（平均分 + 评价数）
 */
@Data
public class ProductRankVO {

    /** 商品ID */
    private Long productId;

    /** 商品名称 */
    private String productName;

    /** 商品图标 */
    private String icon;

    /** 商品售价 */
    private BigDecimal price;

    /** 销量 */
    private Integer sales;

    /** 所属分类名称 */
    private String categoryName;

    /** 平均评分（保留 1 位小数） */
    private BigDecimal avgRating;

    /** 评价数 */
    private Long reviewCount;
}
