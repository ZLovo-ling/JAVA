package com.fenglin.springboottest.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.fenglin.springboottest.dto.AddCartRequest;
import com.fenglin.springboottest.dto.UpdateCartRequest;
import com.fenglin.springboottest.entity.Cart;
import com.fenglin.springboottest.vo.CartVO;

import java.util.List;

/**
 * 购物车服务接口
 */
public interface ICartService extends IService<Cart> {

    /** 加入购物车（已存在则累加数量，并受库存上限约束） */
    void add(AddCartRequest req);

    /** 查询某用户的购物车（含商品快照） */
    List<CartVO> listByUser(Long userId);

    /** 修改购物车某商品数量 */
    void update(UpdateCartRequest req);

    /** 移除购物车项（需属于该用户） */
    void remove(Long userId, Long id);

    /** 清空购物车 */
    void clear(Long userId);
}
