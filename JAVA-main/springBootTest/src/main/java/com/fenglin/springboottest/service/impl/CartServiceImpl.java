package com.fenglin.springboottest.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.fenglin.springboottest.common.BusinessException;
import com.fenglin.springboottest.dto.AddCartRequest;
import com.fenglin.springboottest.dto.UpdateCartRequest;
import com.fenglin.springboottest.entity.Cart;
import com.fenglin.springboottest.entity.Category;
import com.fenglin.springboottest.entity.Product;
import com.fenglin.springboottest.mapper.CartMapper;
import com.fenglin.springboottest.mapper.CategoryMapper;
import com.fenglin.springboottest.mapper.ProductMapper;
import com.fenglin.springboottest.service.ICartService;
import com.fenglin.springboottest.vo.CartVO;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.*;
import java.util.stream.Collectors;

/**
 * 购物车服务实现
 */
@Service
public class CartServiceImpl extends ServiceImpl<CartMapper, Cart> implements ICartService {

    private final ProductMapper productMapper;
    private final CategoryMapper categoryMapper;

    public CartServiceImpl(ProductMapper productMapper, CategoryMapper categoryMapper) {
        this.productMapper = productMapper;
        this.categoryMapper = categoryMapper;
    }

    @Override
    public void add(AddCartRequest req) {
        Long userId = req.getUserId();
        Long productId = req.getProductId();
        int qty = req.getQuantity() == null ? 1 : Math.max(1, req.getQuantity());

        Product product = productMapper.selectById(productId);
        if (product == null || product.getStatus() == null || product.getStatus() != 1) {
            throw new BusinessException("商品不存在或已下架");
        }

        Cart exist = getOne(new LambdaQueryWrapper<Cart>()
                .eq(Cart::getUserId, userId).eq(Cart::getProductId, productId));
        if (exist != null) {
            int newQty = exist.getQuantity() + qty;
            if (product.getStock() != null) {
                newQty = Math.min(newQty, product.getStock());
            }
            exist.setQuantity(newQty);
            updateById(exist);
        } else {
            int newQty = (product.getStock() != null) ? Math.min(qty, product.getStock()) : qty;
            Cart c = new Cart();
            c.setUserId(userId);
            c.setProductId(productId);
            c.setQuantity(newQty);
            save(c);
        }
    }

    @Override
    public List<CartVO> listByUser(Long userId) {
        List<Cart> carts = list(new LambdaQueryWrapper<Cart>()
                .eq(Cart::getUserId, userId).orderByDesc(Cart::getCreateTime));
        if (carts.isEmpty()) {
            return new ArrayList<>();
        }
        List<Long> pids = carts.stream().map(Cart::getProductId).collect(Collectors.toList());
        List<Product> products = productMapper.selectList(new LambdaQueryWrapper<Product>().in(Product::getId, pids));
        Map<Long, Product> pmap = products.stream().collect(Collectors.toMap(Product::getId, p -> p, (a, b) -> a));
        Map<Long, String> catName = categoryMapper.selectList(null).stream()
                .collect(Collectors.toMap(Category::getId, Category::getName, (a, b) -> a));

        List<CartVO> vos = new ArrayList<>();
        for (Cart c : carts) {
            Product p = pmap.get(c.getProductId());
            if (p == null) {
                continue; // 商品已删除则跳过
            }
            CartVO vo = new CartVO();
            vo.setId(c.getId());
            vo.setProductId(p.getId());
            vo.setName(p.getName());
            vo.setIcon(p.getIcon());
            vo.setPrice(p.getPrice());
            vo.setOriginalPrice(p.getOriginalPrice());
            vo.setSeckillPrice(p.getSeckillPrice());
            vo.setQuantity(c.getQuantity());
            vo.setStock(p.getStock());
            vo.setCategoryName(catName.get(p.getCategoryId()));
            BigDecimal sub = (p.getPrice() != null) ? p.getPrice().multiply(BigDecimal.valueOf(c.getQuantity())) : BigDecimal.ZERO;
            vo.setSubtotal(sub);
            vos.add(vo);
        }
        return vos;
    }

    @Override
    public void update(UpdateCartRequest req) {
        Cart c = getOne(new LambdaQueryWrapper<Cart>()
                .eq(Cart::getUserId, req.getUserId()).eq(Cart::getProductId, req.getProductId()));
        if (c == null) {
            throw new BusinessException("购物车中无该商品");
        }
        Product p = productMapper.selectById(req.getProductId());
        int qty = Math.max(1, req.getQuantity() == null ? 1 : req.getQuantity());
        if (p != null && p.getStock() != null) {
            qty = Math.min(qty, p.getStock());
        }
        c.setQuantity(qty);
        updateById(c);
    }

    @Override
    public void remove(Long userId, Long id) {
        Cart c = getById(id);
        if (c == null || !c.getUserId().equals(userId)) {
            return;
        }
        removeById(id); // @TableLogic 逻辑删除
    }

    @Override
    public void clear(Long userId) {
        List<Cart> carts = list(new LambdaQueryWrapper<Cart>().eq(Cart::getUserId, userId));
        if (!carts.isEmpty()) {
            removeByIds(carts.stream().map(Cart::getId).collect(Collectors.toList()));
        }
    }
}
