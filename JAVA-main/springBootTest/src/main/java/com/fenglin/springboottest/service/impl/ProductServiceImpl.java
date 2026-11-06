package com.fenglin.springboottest.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.fenglin.springboottest.entity.Category;
import com.fenglin.springboottest.entity.Product;
import com.fenglin.springboottest.mapper.CategoryMapper;
import com.fenglin.springboottest.mapper.ProductMapper;
import com.fenglin.springboottest.service.ICategoryService;
import com.fenglin.springboottest.service.IProductService;
import com.fenglin.springboottest.vo.ProductVO;
import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.stream.Collectors;

/**
 * 商品服务实现
 */
@Service
public class ProductServiceImpl extends ServiceImpl<ProductMapper, Product> implements IProductService {

    private final CategoryMapper categoryMapper;
    private final ICategoryService categoryService;

    public ProductServiceImpl(CategoryMapper categoryMapper, ICategoryService categoryService) {
        this.categoryMapper = categoryMapper;
        this.categoryService = categoryService;
    }

    @Override
    public List<ProductVO> search(String keyword, Long categoryId) {
        LambdaQueryWrapper<Product> w = new LambdaQueryWrapper<>();
        // 仅返回上架商品（逻辑删除由 MyBatis-Plus @TableLogic 自动过滤）
        w.eq(Product::getStatus, 1);

        // 分级分类：传入分类ID时，自动包含其全部后代分类
        if (categoryId != null && categoryId > 0) {
            List<Long> ids = categoryService.collectDescendantIds(categoryId);
            w.in(Product::getCategoryId, ids);
        }

        // 关键词：按商品名称模糊匹配
        if (keyword != null && !keyword.trim().isEmpty()) {
            w.like(Product::getName, keyword.trim());
        }

        // 排序：热销优先，其次销量，再次 ID
        w.orderByDesc(Product::getIsHot)
         .orderByDesc(Product::getSales)
         .orderByAsc(Product::getId);

        return toVOList(list(w));
    }

    @Override
    public ProductVO detail(Long id) {
        Product p = getById(id);
        if (p == null) {
            return null;
        }
        return toVO(p);
    }

    @Override
    public List<ProductVO> seckill() {
        LambdaQueryWrapper<Product> w = new LambdaQueryWrapper<>();
        w.eq(Product::getStatus, 1)
         .eq(Product::getIsSeckill, 1)
         .orderByAsc(Product::getId);
        return toVOList(list(w));
    }

    /** 转 VO 并批量填充分类名 / 分类路径 */
    private List<ProductVO> toVOList(List<Product> list) {
        Map<Long, String> nameMap = categoryMapper.selectList(null).stream()
                .collect(Collectors.toMap(Category::getId, Category::getName, (a, b) -> a));
        Map<Long, Long> parentMap = categoryMapper.selectList(null).stream()
                .collect(Collectors.toMap(Category::getId, Category::getParentId, (a, b) -> a));

        List<ProductVO> vos = new ArrayList<>();
        for (Product p : list) {
            vos.add(toVO(p, nameMap, parentMap));
        }
        return vos;
    }

    /** 单个商品转 VO（填充分类名 + 分类路径） */
    private ProductVO toVO(Product p) {
        Map<Long, String> nameMap = categoryMapper.selectList(null).stream()
                .collect(Collectors.toMap(Category::getId, Category::getName, (a, b) -> a));
        Map<Long, Long> parentMap = categoryMapper.selectList(null).stream()
                .collect(Collectors.toMap(Category::getId, Category::getParentId, (a, b) -> a));
        return toVO(p, nameMap, parentMap);
    }

    private ProductVO toVO(Product p, Map<Long, String> nameMap, Map<Long, Long> parentMap) {
        ProductVO vo = new ProductVO();
        BeanUtils.copyProperties(p, vo);
        vo.setCategoryName(nameMap.get(p.getCategoryId()));
        // 分类路径：从当前分类沿 parent_id 向上回溯到顶级，再反转
        List<String> path = new ArrayList<>();
        Long cur = p.getCategoryId();
        while (cur != null && parentMap.containsKey(cur) && nameMap.containsKey(cur)) {
            path.add(nameMap.get(cur));
            Long parent = parentMap.get(cur);
            if (parent == null || parent == 0) {
                break;
            }
            cur = parent;
        }
        Collections.reverse(path);
        vo.setCategoryPath(path);
        return vo;
    }
}
