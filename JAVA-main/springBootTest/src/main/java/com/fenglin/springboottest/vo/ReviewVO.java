package com.fenglin.springboottest.vo;

import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 评价视图对象（用于 /api/community 返回，含商品信息）
 */
@Data
public class ReviewVO {

    /** 评价ID */
    private Long id;

    /** 评价用户ID */
    private Long userId;

    /** 用户昵称 */
    private String username;

    /** 商品ID */
    private Long productId;

    /** 商品名称（由后端填充） */
    private String productName;

    /** 商品图标（由后端填充） */
    private String productIcon;

    /** 商品售价（由后端填充） */
    private BigDecimal productPrice;

    /** 商品所属分类名称（由后端填充） */
    private String categoryName;

    /** 评分：1-5 星 */
    private Integer rating;

    /** 评价内容 */
    private String content;

    /** 发表时间 */
    private LocalDateTime createTime;
}
