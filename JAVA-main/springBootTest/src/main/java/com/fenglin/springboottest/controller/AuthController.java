package com.fenglin.springboottest.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.fenglin.springboottest.common.ApiResult;
import com.fenglin.springboottest.dto.LoginRequest;
import com.fenglin.springboottest.dto.RegisterRequest;
import com.fenglin.springboottest.entity.User;
import com.fenglin.springboottest.service.IUserService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

/**
 * 认证接口：注册 / 登录
 */
@RestController
@RequestMapping("/api/auth")
@Validated
public class AuthController {

    @Autowired
    private IUserService userService;

    @Autowired
    private PasswordEncoder passwordEncoder;

    /**
     * 注册
     */
    @PostMapping("/register")
    public ApiResult<String> register(@Valid @RequestBody RegisterRequest req) {
        // 1. 两次密码一致校验
        if (!req.getPassword().equals(req.getConfirmPassword())) {
            return ApiResult.fail(400, "两次输入的密码不一致");
        }
        // 2. 账号格式校验（手机号或邮箱）
        if (!isValidAccount(req.getAccount())) {
            return ApiResult.fail(400, "账号必须是手机号或邮箱");
        }
        // 3. 账号唯一性校验
        long count = userService.count(new LambdaQueryWrapper<User>().eq(User::getAccount, req.getAccount()));
        if (count > 0) {
            return ApiResult.fail(409, "该账号已被注册");
        }
        // 4. 组装并加密密码入库
        User user = new User();
        user.setUsername(req.getUsername().trim());
        user.setAccount(req.getAccount().trim());
        user.setPassword(passwordEncoder.encode(req.getPassword()));
        if (req.getAccount().contains("@")) {
            user.setEmail(req.getAccount().trim());
        } else {
            user.setPhone(req.getAccount().trim());
        }
        userService.save(user);
        return ApiResult.success("注册成功");
    }

    /**
     * 登录
     */
    @PostMapping("/login")
    public ApiResult<User> login(@Valid @RequestBody LoginRequest req) {
        User user = userService.getOne(new LambdaQueryWrapper<User>().eq(User::getAccount, req.getAccount()));
        if (user == null) {
            return ApiResult.fail(400, "账号不存在");
        }
        if (!passwordEncoder.matches(req.getPassword(), user.getPassword())) {
            return ApiResult.fail(400, "密码错误");
        }
        // 不向前端返回密码
        user.setPassword(null);
        return ApiResult.success(user);
    }

    /** 账号合法校验：中国大陆手机号 或 邮箱 */
    private boolean isValidAccount(String account) {
        if (account == null) {
            return false;
        }
        String phoneRegex = "^1[3-9]\\d{9}$";
        String emailRegex = "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$";
        return account.matches(phoneRegex) || account.matches(emailRegex);
    }
}
