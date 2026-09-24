package com.fenglin.springboottest.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

/**
 * 注册请求参数
 */
@Data
public class RegisterRequest {

    /** 昵称 */
    @NotBlank(message = "昵称不能为空")
    private String username;

    /** 登录账号（手机号或邮箱） */
    @NotBlank(message = "账号不能为空")
    private String account;

    /** 密码 */
    @NotBlank(message = "密码不能为空")
    private String password;

    /** 确认密码 */
    @NotBlank(message = "确认密码不能为空")
    private String confirmPassword;
}
