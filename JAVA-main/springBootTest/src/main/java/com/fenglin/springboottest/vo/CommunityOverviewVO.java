package com.fenglin.springboottest.vo;

import lombok.Data;

import java.math.BigDecimal;
import java.util.Map;

/**
 * 社区总览：评价总数 / 平均分 / 参与人数 / 星级分布
 */
@Data
public class CommunityOverviewVO {

    /** 评价总数 */
    private Long totalReviews;

    /** 全站平均评分（保留 1 位小数） */
    private BigDecimal avgRating;

    /** 参与评价的用户数（去重） */
    private Long reviewerCount;

    /** 被评价过的商品数（去重） */
    private Long productCount;

    /** 星级分布：{1: 数量, 2: 数量, ... 5: 数量} */
    private Map<Integer, Long> ratingDistribution;
}
