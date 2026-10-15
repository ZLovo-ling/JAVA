package com.fenglin.springboottest.vo;

import lombok.Data;

import java.util.List;

/**
 * 分类树节点（用于 /api/categories 返回）
 */
@Data
public class CategoryVO {

    /** 分类ID */
    private Long id;

    /** 分类名称 */
    private String name;

    /** 层级：1-顶级 2-二级 */
    private Integer level;

    /** 排序号 */
    private Integer sort;

    /** 子分类（顶级分类下挂二级分类） */
    private List<CategoryVO> children;
}
