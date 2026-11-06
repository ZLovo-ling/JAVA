package com.fenglin.springboottest.controller;

import com.fenglin.springboottest.common.ApiResult;
import com.fenglin.springboottest.dto.CreateOrderRequest;
import com.fenglin.springboottest.service.IOrderService;
import com.fenglin.springboottest.vo.OrderVO;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 订单接口
 */
@RestController
@RequestMapping("/api/orders")
public class OrderController {

    @Autowired
    private IOrderService orderService;

    /** 下单（购物车结算 / 直接购买） */
    @PostMapping
    public ApiResult<OrderVO> create(@Valid @RequestBody CreateOrderRequest req) {
        return ApiResult.success(orderService.create(req));
    }

    /** 查询我的订单（按用户） */
    @GetMapping
    public ApiResult<List<OrderVO>> list(@RequestParam Long userId) {
        return ApiResult.success(orderService.listByUser(userId));
    }
}
