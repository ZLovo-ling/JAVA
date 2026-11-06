package com.fenglin.springboottest.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 商品评价实体（社区），对应 review 表
 */
@Data
@TableName("review")
public class Review {

    /** 主键，自增 */
    @TableId(type = IdType.AUTO)
    private Long id;

    /** 评价用户ID */
    private Long userId;

    /** 用户昵称（发表时快照，用于展示） */
    private String username;

    /** 商品ID */
    private Long productId;

    /** 评分：1-5 星 */
    private Integer rating;

    /** 评价内容 */
    private String content;

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
