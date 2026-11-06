package com.fenglin.springboottest.vo;

import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

/**
 * 商品视图对象（用于 /api/goods 返回，含分类名）
 */
@Data
public class ProductVO {

    /** 商品ID */
    private Long id;

    /** 商品名称 */
    private String name;

    /** 展示图标 */
    private String icon;

    /** 售价 */
    private BigDecimal price;

    /** 原价 */
    private BigDecimal originalPrice;

    /** 简介 */
    private String description;

    /** 销量 */
    private Integer sales;

    /** 是否热销：1-是 0-否 */
    private Integer isHot;

    /** 所属分类ID */
    private Long categoryId;

    /** 所属分类名称（由后端填充，非数据库字段） */
    private String categoryName;

    /** 分类路径（从顶级到叶子，由后端填充，非数据库字段） */
    private List<String> categoryPath;

    /** 是否秒杀商品：1-是 0-否 */
    private Integer isSeckill;

    /** 秒杀价 */
    private BigDecimal seckillPrice;

    /** 秒杀库存 */
    private Integer seckillStock;

    /** 秒杀开始时间 */
    private LocalDateTime seckillStart;

    /** 秒杀结束时间 */
    private LocalDateTime seckillEnd;
}
