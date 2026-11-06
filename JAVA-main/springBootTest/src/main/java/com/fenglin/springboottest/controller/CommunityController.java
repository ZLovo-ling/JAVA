package com.fenglin.springboottest.controller;

import com.fenglin.springboottest.common.ApiResult;
import com.fenglin.springboottest.dto.AddReviewRequest;
import com.fenglin.springboottest.service.IReviewService;
import com.fenglin.springboottest.vo.CommunityOverviewVO;
import com.fenglin.springboottest.vo.ProductRankVO;
import com.fenglin.springboottest.vo.ReviewVO;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 社区接口：各用户对各类商品的评价
 *   GET  /api/community/reviews   评价列表（筛选/排序）
 *   GET  /api/community/ranks     商品口碑榜（Top 10）
 *   GET  /api/community/overview  社区总览（总评价数/平均分/星级分布）
 *   GET  /api/community/my        我的评价
 *   POST /api/community/reviews   发布评价
 */
@RestController
@RequestMapping("/api/community")
public class CommunityController {

    @Autowired
    private IReviewService reviewService;

    /**
     * 评价列表
     * @param keyword   关键词（匹配评价内容/商品名称/用户昵称，可空）
     * @param productId 商品ID（可空表示全部）
     * @param minRating 最小评分（含），可空
     * @param maxRating 最大评分（含），可空
     * @param sort      latest 最新（默认）/ rating 评分高优先
     */
    @GetMapping("/reviews")
    public ApiResult<List<ReviewVO>> reviews(@RequestParam(required = false) String keyword,
                                             @RequestParam(required = false) Long productId,
                                             @RequestParam(required = false) Integer minRating,
                                             @RequestParam(required = false) Integer maxRating,
                                             @RequestParam(required = false, defaultValue = "latest") String sort) {
        return ApiResult.success(reviewService.listReviews(keyword, productId, minRating, maxRating, sort));
    }

    /** 商品口碑榜（Top 10） */
    @GetMapping("/ranks")
    public ApiResult<List<ProductRankVO>> ranks() {
        return ApiResult.success(reviewService.productRanks());
    }

    /** 社区总览 */
    @GetMapping("/overview")
    public ApiResult<CommunityOverviewVO> overview() {
        return ApiResult.success(reviewService.overview());
    }

    /** 我的评价 */
    @GetMapping("/my")
    public ApiResult<List<ReviewVO>> my(@RequestParam Long userId) {
        return ApiResult.success(reviewService.listByUser(userId));
    }

    /** 发布评价（失败时以 400 业务码返回原因） */
    @PostMapping("/reviews")
    public ApiResult<Void> add(@Valid @RequestBody AddReviewRequest req) {
        String error = reviewService.addReview(req);
        if (error != null) {
            return ApiResult.fail(400, error);
        }
        return ApiResult.success();
    }
}
