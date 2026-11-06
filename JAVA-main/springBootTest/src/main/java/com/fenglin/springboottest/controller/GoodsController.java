package com.fenglin.springboottest.controller;

import com.fenglin.springboottest.common.ApiResult;
import com.fenglin.springboottest.service.IProductService;
import com.fenglin.springboottest.vo.ProductVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 商品接口：首页展示 + 搜索（支持分级分类）+ 详情 + 秒杀
 */
@RestController
@RequestMapping("/api/goods")
public class GoodsController {

    @Autowired
    private IProductService productService;

    /**
     * 商品列表 / 搜索
     * @param keyword    关键词（按名称模糊，可空）
     * @param categoryId 分类ID（分级：自动包含其全部后代；可空表示全部）
     */
    @GetMapping
    public ApiResult<List<ProductVO>> list(@RequestParam(required = false) String keyword,
                                           @RequestParam(required = false) Long categoryId) {
        return ApiResult.success(productService.search(keyword, categoryId));
    }

    /**
     * 商品详情
     */
    @GetMapping("/{id}")
    public ApiResult<ProductVO> detail(@PathVariable Long id) {
        ProductVO vo = productService.detail(id);
        if (vo == null) {
            return ApiResult.fail(404, "商品不存在或已下架");
        }
        return ApiResult.success(vo);
    }

    /**
     * 秒杀商品列表
     */
    @GetMapping("/seckill")
    public ApiResult<List<ProductVO>> seckill() {
        return ApiResult.success(productService.seckill());
    }
}
