package com.fenglin.springboottest.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 商品实体，对应 product 表
 */
@Data
@TableName("product")
public class Product {

    /** 主键，自增 */
    @TableId(type = IdType.AUTO)
    private Long id;

    /** 商品名称 */
    private String name;

    /** 所属分类ID（叶子分类） */
    private Long categoryId;

    /** 展示图标（emoji） */
    private String icon;

    /** 售价 */
    private BigDecimal price;

    /** 原价（划线价） */
    private BigDecimal originalPrice;

    /** 商品简介 */
    private String description;

    /** 库存 */
    private Integer stock;

    /** 销量 */
    private Integer sales;

    /** 是否热销：1-是 0-否 */
    private Integer isHot;

    /** 状态：1-上架 0-下架 */
    private Integer status;

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

    /** 创建时间 */
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;

    /** 更新时间 */
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updateTime;

    /** 逻辑删除：0-未删 1-已删 */
    @TableLogic
    private Integer deleted;
}
