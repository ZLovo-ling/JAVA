package com.fenglin.springboottest.common;

/**
 * 业务异常：用于库存不足、商品不存在等可预期的业务错误，
 * 由 GlobalExceptionHandler 统一转为 ApiResult.fail(400, message)
 */
public class BusinessException extends RuntimeException {

    public BusinessException(String message) {
        super(message);
    }
}
