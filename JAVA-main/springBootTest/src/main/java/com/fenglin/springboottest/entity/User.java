package com.fenglin.springboottest.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 用户实体，对应数据库 user 表
 */
@Data
@TableName("user")
public class User {

    /** 主键，自增 */
    @TableId(type = IdType.AUTO)
    private Long id;

    /** 昵称 */
    private String username;

    /** 登录账号（手机号或邮箱，唯一） */
    private String account;

    /** 密码（BCrypt 加密后存储） */
    private String password;

    /** 邮箱（account 为邮箱时回填） */
    private String email;

    /** 手机号（account 为手机号时回填） */
    private String phone;

    /** 创建时间 */
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;

    /** 更新时间 */
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updateTime;

    /** 逻辑删除：0-未删 1-已删 */
    @TableLogic
    private Integer deleted;
}
