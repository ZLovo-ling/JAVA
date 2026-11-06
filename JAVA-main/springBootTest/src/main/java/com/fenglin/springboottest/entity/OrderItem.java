package com.fenglin.springboottest.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 订单明细实体，对应 order_item 表
 */
@Data
@TableName("order_item")
public class OrderItem {

    /** 主键，自增 */
    @TableId(type = IdType.AUTO)
    private Long id;

    /** 订单ID */
    private Long orderId;

    /** 商品ID */
    private Long productId;

    /** 商品名称（下单快照） */
    private String productName;

    /** 图标（下单快照） */
    private String icon;

    /** 单价（下单快照） */
    private BigDecimal price;

    /** 购买数量 */
    private Integer quantity;

    /** 创建时间 */
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;

    /** 逻辑删除：0-未删 1-已删 */
    @TableLogic
    private Integer deleted;
}
