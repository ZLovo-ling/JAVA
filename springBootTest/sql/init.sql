-- =====================================================
-- 星购(starshop) 项目 - 建库建表语句
-- 数据库：MySQL 8.0
-- 说明：本文件为文本形式的建库建表脚本，可直接在 MySQL 客户端执行
--       mysql -u root -p123456 < sql/init.sql
-- =====================================================

-- 1. 创建数据库（若不存在）
CREATE DATABASE IF NOT EXISTS `starshop`
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_general_ci;

-- 2. 使用数据库
USE `starshop`;

-- 3. 创建用户表（若已存在则先删除，方便重复执行）
DROP TABLE IF EXISTS `user`;

CREATE TABLE `user` (
  `id`          BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `username`    VARCHAR(50)  NOT NULL                COMMENT '昵称',
  `account`     VARCHAR(100) NOT NULL                COMMENT '登录账号（手机号或邮箱，唯一）',
  `password`    VARCHAR(100) NOT NULL                COMMENT '密码（BCrypt 加密存储）',
  `email`       VARCHAR(100) DEFAULT NULL            COMMENT '邮箱（account 为邮箱时回填）',
  `phone`       VARCHAR(20)  DEFAULT NULL            COMMENT '手机号（account 为手机号时回填）',
  `create_time` DATETIME     DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted`     TINYINT      NOT NULL DEFAULT 0       COMMENT '逻辑删除：0-未删 1-已删',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_account` (`account`)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_general_ci
  COMMENT='用户表';
