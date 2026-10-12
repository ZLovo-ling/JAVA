package com.fenglin.springboottest.common;

import jakarta.validation.ConstraintViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.util.stream.Collectors;

/**
 * 全局异常处理：把校验失败等异常转成统一 ApiResult 结构返回给前端
 */
@RestControllerAdvice
public class GlobalExceptionHandler {

    /** @Valid 标注的 @RequestBody 参数校验失败 */
    @ExceptionHandler(MethodArgumentNotValidException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public ApiResult<Void> handleValid(MethodArgumentNotValidException ex) {
        String msg = ex.getBindingResult().getFieldErrors().stream()
                .map(FieldError::getDefaultMessage)
                .collect(Collectors.joining("；"));
        return ApiResult.fail(400, msg);
    }

    /** @Validated 标注的 Controller 方法参数校验失败（如 @NotBlank 直接作用在方法参数上） */
    @ExceptionHandler(ConstraintViolationException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public ApiResult<Void> handleConstraint(ConstraintViolationException ex) {
        return ApiResult.fail(400, ex.getMessage());
    }

    /** 其它未预期异常 */
    @ExceptionHandler(Exception.class)
    @ResponseStatus(HttpStatus.INTERNAL_SERVER_ERROR)
    public ApiResult<Void> handleOther(Exception ex) {
        return ApiResult.fail(500, "系统异常：" + ex.getMessage());
    }
}
