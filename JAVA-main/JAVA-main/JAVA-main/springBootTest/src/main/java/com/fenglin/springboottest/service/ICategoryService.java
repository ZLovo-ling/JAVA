package com.fenglin.springboottest.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.fenglin.springboottest.entity.Category;
import com.fenglin.springboottest.vo.CategoryVO;

import java.util.List;

/**
 * 分类服务接口
 */
public interface ICategoryService extends IService<Category> {

    /** 返回完整分类树（顶级 -> 子分类） */
    List<CategoryVO> tree();

    /**
     * 收集某分类自身 + 其全部后代分类的 ID（分级检索用）
     * @param categoryId 分类ID
     * @return 包含自身及所有后代的 ID 列表
     */
    List<Long> collectDescendantIds(Long categoryId);
}
