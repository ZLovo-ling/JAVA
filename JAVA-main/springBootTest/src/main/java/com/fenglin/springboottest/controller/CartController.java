package com.fenglin.springboottest.controller;

import com.fenglin.springboottest.common.ApiResult;
import com.fenglin.springboottest.dto.AddCartRequest;
import com.fenglin.springboottest.dto.UpdateCartRequest;
import com.fenglin.springboottest.service.ICartService;
import com.fenglin.springboottest.vo.CartVO;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 购物车接口
 */
@RestController
@RequestMapping("/api/cart")
public class CartController {

    @Autowired
    private ICartService cartService;

    /** 加入购物车 */
    @PostMapping("/add")
    public ApiResult<Void> add(@Valid @RequestBody AddCartRequest req) {
        cartService.add(req);
        return ApiResult.success();
    }

    /** 查询购物车（按用户） */
    @GetMapping
    public ApiResult<List<CartVO>> list(@RequestParam Long userId) {
        return ApiResult.success(cartService.listByUser(userId));
    }

    /** 修改数量 */
    @PutMapping
    public ApiResult<Void> update(@Valid @RequestBody UpdateCartRequest req) {
        cartService.update(req);
        return ApiResult.success();
    }

    /** 移除某项（需属于该用户） */
    @DeleteMapping("/{id}")
    public ApiResult<Void> remove(@RequestParam Long userId, @PathVariable Long id) {
        cartService.remove(userId, id);
        return ApiResult.success();
    }

    /** 清空购物车 */
    @DeleteMapping("/clear")
    public ApiResult<Void> clear(@RequestParam Long userId) {
        cartService.clear(userId);
        return ApiResult.success();
    }
}
