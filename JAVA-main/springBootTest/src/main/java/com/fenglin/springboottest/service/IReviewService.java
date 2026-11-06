package com.fenglin.springboottest.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.fenglin.springboottest.dto.AddReviewRequest;
import com.fenglin.springboottest.entity.Review;
import com.fenglin.springboottest.vo.CommunityOverviewVO;
import com.fenglin.springboottest.vo.ProductRankVO;
import com.fenglin.springboottest.vo.ReviewVO;

import java.util.List;

/**
 * 社区评价服务
 */
public interface IReviewService extends IService<Review> {

    /**
     * 评价列表（支持筛选与排序）
     * @param keyword   关键词（匹配评价内容/商品名称/用户昵称，可空）
     * @param productId 商品ID（可空表示全部）
     * @param minRating 最小评分（含），可空
     * @param maxRating 最大评分（含），可空
     * @param sort      排序：latest 最新（默认）/ rating 评分高优先
     */
    List<ReviewVO> listReviews(String keyword, Long productId, Integer minRating, Integer maxRating, String sort);

    /**
     * 商品口碑榜：按平均分排序的商品评价聚合（前 10 名）
     */
    List<ProductRankVO> productRanks();

    /**
     * 社区总览：评价总数 / 平均分 / 参与人数 / 星级分布
     */
    CommunityOverviewVO overview();

    /**
     * 我（某用户）发表过的评价
     */
    List<ReviewVO> listByUser(Long userId);

    /**
     * 发布评价
     * @return 成功返回 null；失败返回错误信息
     */
    String addReview(AddReviewRequest req);
}
