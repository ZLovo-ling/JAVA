package com.fenglin.springboottest.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.fenglin.springboottest.dto.AddReviewRequest;
import com.fenglin.springboottest.entity.Category;
import com.fenglin.springboottest.entity.Product;
import com.fenglin.springboottest.entity.Review;
import com.fenglin.springboottest.entity.User;
import com.fenglin.springboottest.mapper.CategoryMapper;
import com.fenglin.springboottest.mapper.ProductMapper;
import com.fenglin.springboottest.mapper.ReviewMapper;
import com.fenglin.springboottest.mapper.UserMapper;
import com.fenglin.springboottest.service.IReviewService;
import com.fenglin.springboottest.vo.CommunityOverviewVO;
import com.fenglin.springboottest.vo.ProductRankVO;
import com.fenglin.springboottest.vo.ReviewVO;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.*;
import java.util.stream.Collectors;

/**
 * 社区评价服务实现
 */
@Service
public class ReviewServiceImpl extends ServiceImpl<ReviewMapper, Review> implements IReviewService {

    @Autowired
    private ProductMapper productMapper;

    @Autowired
    private CategoryMapper categoryMapper;

    @Autowired
    private UserMapper userMapper;

    @Override
    public List<ReviewVO> listReviews(String keyword, Long productId, Integer minRating, Integer maxRating, String sort) {
        LambdaQueryWrapper<Review> w = new LambdaQueryWrapper<>();
        if (productId != null && productId > 0) {
            w.eq(Review::getProductId, productId);
        }
        if (minRating != null) {
            w.ge(Review::getRating, minRating);
        }
        if (maxRating != null) {
            w.le(Review::getRating, maxRating);
        }
        // 关键词：匹配评价内容 / 用户昵称
        if (keyword != null && !keyword.trim().isEmpty()) {
            String k = keyword.trim();
            w.and(q -> q.like(Review::getContent, k).or().like(Review::getUsername, k));
        }
        if ("rating".equalsIgnoreCase(sort)) {
            w.orderByDesc(Review::getRating).orderByDesc(Review::getCreateTime);
        } else {
            w.orderByDesc(Review::getCreateTime).orderByDesc(Review::getId);
        }
        List<Review> reviews = list(w);

        // 关键词同时匹配商品名称：先按内容/昵称查出，再补充商品名命中结果
        if (keyword != null && !keyword.trim().isEmpty()) {
            String k = keyword.trim();
            Set<Long> existIds = reviews.stream().map(Review::getId).collect(Collectors.toSet());
            List<Long> matchedProductIds = productMapper.selectList(
                            new LambdaQueryWrapper<Product>().like(Product::getName, k))
                    .stream().map(Product::getId).toList();
            if (!matchedProductIds.isEmpty()) {
                List<Review> extra = list(new LambdaQueryWrapper<Review>().in(Review::getProductId, matchedProductIds));
                for (Review r : extra) {
                    if (!existIds.contains(r.getId())) {
                        reviews.add(r);
                    }
                }
            }
            // 保持原排序
            if ("rating".equalsIgnoreCase(sort)) {
                reviews.sort(Comparator.comparing(Review::getRating).reversed()
                        .thenComparing(Comparator.comparing(Review::getCreateTime).reversed()));
            } else {
                reviews.sort(Comparator.comparing(Review::getCreateTime).reversed()
                        .thenComparing(Comparator.comparing(Review::getId).reversed()));
            }
        }

        return toVOList(reviews);
    }

    @Override
    public List<ProductRankVO> productRanks() {
        List<Review> all = list(new LambdaQueryWrapper<>());
        if (all.isEmpty()) {
            return Collections.emptyList();
        }
        // 按商品聚合：平均分 + 评价数
        Map<Long, List<Review>> grouped = all.stream()
                .collect(Collectors.groupingBy(Review::getProductId));

        // 商品与分类信息
        Map<Long, Product> productMap = productMapper.selectList(null).stream()
                .collect(Collectors.toMap(Product::getId, p -> p, (a, b) -> a));
        Map<Long, String> categoryNameMap = categoryMapper.selectList(null).stream()
                .collect(Collectors.toMap(Category::getId, Category::getName, (a, b) -> a));

        List<ProductRankVO> ranks = new ArrayList<>();
        for (Map.Entry<Long, List<Review>> e : grouped.entrySet()) {
            Product p = productMap.get(e.getKey());
            if (p == null) {
                continue; // 商品已删除的评论不进榜
            }
            List<Review> rs = e.getValue();
            ProductRankVO vo = new ProductRankVO();
            vo.setProductId(p.getId());
            vo.setProductName(p.getName());
            vo.setIcon(p.getIcon());
            vo.setPrice(p.getPrice());
            vo.setSales(p.getSales());
            vo.setCategoryName(categoryNameMap.get(p.getCategoryId()));
            double avg = rs.stream().mapToInt(Review::getRating).average().orElse(0);
            vo.setAvgRating(BigDecimal.valueOf(avg).setScale(1, RoundingMode.HALF_UP));
            vo.setReviewCount((long) rs.size());
            ranks.add(vo);
        }
        // 排序：平均分降序，其次评价数降序，取前 10
        ranks.sort(Comparator.comparing(ProductRankVO::getAvgRating).reversed()
                .thenComparing(Comparator.comparing(ProductRankVO::getReviewCount).reversed()));
        return ranks.size() > 10 ? ranks.subList(0, 10) : ranks;
    }

    @Override
    public CommunityOverviewVO overview() {
        List<Review> all = list(new LambdaQueryWrapper<>());
        CommunityOverviewVO vo = new CommunityOverviewVO();
        vo.setTotalReviews((long) all.size());
        double avg = all.stream().mapToInt(Review::getRating).average().orElse(0);
        vo.setAvgRating(BigDecimal.valueOf(avg).setScale(1, RoundingMode.HALF_UP));
        vo.setReviewerCount(all.stream().map(Review::getUserId).distinct().count());
        vo.setProductCount(all.stream().map(Review::getProductId).distinct().count());
        Map<Integer, Long> dist = all.stream()
                .collect(Collectors.groupingBy(Review::getRating, Collectors.counting()));
        // 补全 1-5 星，避免前端取不到 key
        Map<Integer, Long> full = new TreeMap<>(Comparator.reverseOrder());
        for (int i = 5; i >= 1; i--) {
            full.put(i, dist.getOrDefault(i, 0L));
        }
        vo.setRatingDistribution(full);
        return vo;
    }

    @Override
    public List<ReviewVO> listByUser(Long userId) {
        List<Review> reviews = list(new LambdaQueryWrapper<Review>()
                .eq(Review::getUserId, userId)
                .orderByDesc(Review::getCreateTime));
        return toVOList(reviews);
    }

    @Override
    public String addReview(AddReviewRequest req) {
        // 1. 校验用户
        User user = userMapper.selectById(req.getUserId());
        if (user == null) {
            return "用户不存在，请先登录";
        }
        // 2. 校验商品（须上架）
        Product product = productMapper.selectById(req.getProductId());
        if (product == null || product.getStatus() == null || product.getStatus() != 1) {
            return "商品不存在或已下架";
        }
        // 3. 同一用户对同一商品只能评价一次
        long count = count(new LambdaQueryWrapper<Review>()
                .eq(Review::getUserId, req.getUserId())
                .eq(Review::getProductId, req.getProductId()));
        if (count > 0) {
            return "你已评价过该商品啦，不能重复评价";
        }
        // 4. 入库（昵称取发表时快照）
        Review review = new Review();
        review.setUserId(req.getUserId());
        review.setUsername(user.getUsername());
        review.setProductId(req.getProductId());
        review.setRating(req.getRating());
        review.setContent(req.getContent().trim());
        save(review);
        return null;
    }

    /** 批量转 VO 并填充商品信息 */
    private List<ReviewVO> toVOList(List<Review> reviews) {
        if (reviews == null || reviews.isEmpty()) {
            return new ArrayList<>();
        }
        Set<Long> productIds = reviews.stream().map(Review::getProductId).collect(Collectors.toSet());
        Map<Long, Product> productMap = productMapper.selectBatchIds(productIds).stream()
                .collect(Collectors.toMap(Product::getId, p -> p, (a, b) -> a));
        Map<Long, String> categoryNameMap = categoryMapper.selectList(null).stream()
                .collect(Collectors.toMap(Category::getId, Category::getName, (a, b) -> a));

        List<ReviewVO> vos = new ArrayList<>();
        for (Review r : reviews) {
            ReviewVO vo = new ReviewVO();
            BeanUtils.copyProperties(r, vo);
            Product p = productMap.get(r.getProductId());
            if (p != null) {
                vo.setProductName(p.getName());
                vo.setProductIcon(p.getIcon());
                vo.setProductPrice(p.getPrice());
                vo.setCategoryName(categoryNameMap.get(p.getCategoryId()));
            }
            vos.add(vo);
        }
        return vos;
    }
}
