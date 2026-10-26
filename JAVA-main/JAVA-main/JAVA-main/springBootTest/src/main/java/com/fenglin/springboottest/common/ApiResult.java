package com.fenglin.springboottest.common;

import lombok.Data;

/**
 * 统一接口返回结构
 * code: 200 成功；400 参数/业务错误；401 未认证；500 系统错误
 */
@Data
public class ApiResult<T> {

    private int code;
    private String message;
    private T data;

    public static <T> ApiResult<T> success(T data) {
        ApiResult<T> r = new ApiResult<>();
        r.setCode(200);
        r.setMessage("success");
        r.setData(data);
        return r;
    }

    public static <T> ApiResult<T> success() {
        return success(null);
    }

    public static <T> ApiResult<T> fail(int code, String message) {
        ApiResult<T> r = new ApiResult<>();
        r.setCode(code);
        r.setMessage(message);
        r.setData(null);
        return r;
    }
}
