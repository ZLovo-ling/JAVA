package com.fenglin.springboottest.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.fenglin.springboottest.dto.CreateOrderRequest;
import com.fenglin.springboottest.entity.Order;
import com.fenglin.springboottest.vo.OrderVO;

import java.util.List;

/**
 * 订单服务接口
 */
public interface IOrderService extends IService<Order> {

    /** 下单（购物车结算 / 直接购买），返回订单视图 */
    OrderVO create(CreateOrderRequest req);

    /** 查询某用户的订单（含明细） */
    List<OrderVO> listByUser(Long userId);
}
