package com.fenglin.springboottest.controller;

import com.fenglin.springboottest.common.ApiResult;
import com.fenglin.springboottest.service.ICategoryService;
import com.fenglin.springboottest.vo.CategoryVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/**
 * 分类接口：返回分级分类树
 */
@RestController
@RequestMapping("/api/categories")
public class CategoryController {

    @Autowired
    private ICategoryService categoryService;

    /**
     * 获取完整分类树（顶级 -> 子分类）
     */
    @GetMapping
    public ApiResult<List<CategoryVO>> tree() {
        return ApiResult.success(categoryService.tree());
    }
}
