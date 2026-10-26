package com.fenglin.springboottest.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.fenglin.springboottest.entity.Category;
import com.fenglin.springboottest.mapper.CategoryMapper;
import com.fenglin.springboottest.service.ICategoryService;
import com.fenglin.springboottest.vo.CategoryVO;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.stream.Collectors;

/**
 * 分类服务实现
 */
@Service
public class CategoryServiceImpl extends ServiceImpl<CategoryMapper, Category> implements ICategoryService {

    @Override
    public List<CategoryVO> tree() {
        List<Category> all = list();
        // parentId -> 子分类列表
        Map<Long, List<Category>> childrenMap = all.stream()
                .filter(c -> c.getParentId() != null && c.getParentId() != 0)
                .collect(Collectors.groupingBy(Category::getParentId));

        List<CategoryVO> roots = new ArrayList<>();
        for (Category c : all) {
            if (c.getParentId() == null || c.getParentId() == 0) {
                roots.add(toVO(c, childrenMap));
            }
        }
        roots.sort(Comparator.comparingInt(c -> c.getSort() == null ? 0 : c.getSort()));
        return roots;
    }

    /** 递归构建分类树节点 */
    private CategoryVO toVO(Category c, Map<Long, List<Category>> childrenMap) {
        CategoryVO vo = new CategoryVO();
        vo.setId(c.getId());
        vo.setName(c.getName());
        vo.setLevel(c.getLevel());
        vo.setSort(c.getSort());
        List<Category> kids = childrenMap.get(c.getId());
        if (kids != null) {
            kids.sort(Comparator.comparingInt(k -> k.getSort() == null ? 0 : k.getSort()));
            List<CategoryVO> childVos = new ArrayList<>();
            for (Category k : kids) {
                childVos.add(toVO(k, childrenMap));
            }
            vo.setChildren(childVos);
        }
        return vo;
    }

    @Override
    public List<Long> collectDescendantIds(Long categoryId) {
        List<Category> all = list();
        Map<Long, List<Category>> childrenMap = all.stream()
                .filter(c -> c.getParentId() != null && c.getParentId() != 0)
                .collect(Collectors.groupingBy(Category::getParentId));

        List<Long> result = new ArrayList<>();
        if (categoryId != null) {
            result.add(categoryId);
            collect(childrenMap, categoryId, result);
        }
        return result;
    }

    /** 递归收集后代 ID */
    private void collect(Map<Long, List<Category>> childrenMap, Long pid, List<Long> out) {
        List<Category> kids = childrenMap.get(pid);
        if (kids != null) {
            for (Category k : kids) {
                out.add(k.getId());
                collect(childrenMap, k.getId(), out);
            }
        }
    }
}
