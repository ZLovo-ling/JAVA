package com.fenglin.springboottest.dto;

import jakarta.validation.constraints.*;
import lombok.Data;

/**
 * 发布评价请求
 */
@Data
public class AddReviewRequest {

    /** 用户ID（前端从登录态 sessionStorage 取） */
    @NotNull(message = "用户ID不能为空")
    private Long userId;

    /** 商品ID */
    @NotNull(message = "商品ID不能为空")
    private Long productId;

    /** 评分：1-5 星 */
    @NotNull(message = "评分不能为空")
    @Min(value = 1, message = "评分最低 1 星")
    @Max(value = 5, message = "评分最高 5 星")
    private Integer rating;

    /** 评价内容 */
    @NotBlank(message = "评价内容不能为空")
    @Size(min = 5, max = 500, message = "评价内容长度需在 5-500 字之间")
    private String content;
}
