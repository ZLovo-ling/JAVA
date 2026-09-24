package com.fenglin.springboottest.config;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.context.annotation.Configuration;

/**
 * MyBatis-Plus 配置：扫描 Mapper 接口
 * （分页插件 PaginationInnerInterceptor 已独立到 mybatis-plus-jsqlparser 模块，
 *   本项目注册/登录无需分页，暂不引入以免增加依赖体积）
 */
@Configuration
@MapperScan("com.fenglin.springboottest.mapper")
public class MybatisPlusConfig {
}
