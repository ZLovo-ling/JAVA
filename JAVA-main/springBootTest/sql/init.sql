-- =====================================================
-- 星购(starshop) 项目 - 建库建表语句
-- 数据库：MySQL 8.0
-- 说明：本文件为文本形式的建库建表脚本，可直接在 MySQL 客户端执行
--       mysql -uroot -p123456 --default-character-set=utf8mb4 < sql/init.sql
-- 重复执行安全：所有表均先 DROP 再 CREATE
-- =====================================================

-- 1. 创建数据库（若不存在）
CREATE DATABASE IF NOT EXISTS `starshop`
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_general_ci;

-- 2. 使用数据库
USE `starshop`;

-- 3. 用户表（登录/注册）
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

-- 4. 分类表（支持分级/多级分类，parent_id 自关联；顶级分类 parent_id=0）
DROP TABLE IF EXISTS `category`;
CREATE TABLE `category` (
  `id`          BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `name`        VARCHAR(50)  NOT NULL                COMMENT '分类名称',
  `parent_id`   BIGINT       NOT NULL DEFAULT 0      COMMENT '父分类ID，0 表示顶级分类',
  `level`       TINYINT      NOT NULL DEFAULT 1      COMMENT '层级：1-顶级 2-二级 ...',
  `sort`        INT          NOT NULL DEFAULT 0      COMMENT '排序号，越小越靠前',
  `create_time` DATETIME     DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted`     TINYINT      NOT NULL DEFAULT 0       COMMENT '逻辑删除：0-未删 1-已删',
  PRIMARY KEY (`id`),
  KEY `idx_parent` (`parent_id`)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_general_ci
  COMMENT='商品分类表（支持多级）';

-- 5. 商品表
DROP TABLE IF EXISTS `product`;
CREATE TABLE `product` (
  `id`             BIGINT        NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `name`           VARCHAR(120)  NOT NULL                COMMENT '商品名称',
  `category_id`    BIGINT        NOT NULL DEFAULT 0      COMMENT '所属分类ID（叶子分类）',
  `icon`           VARCHAR(20)   DEFAULT NULL            COMMENT '展示图标（emoji）',
  `price`          DECIMAL(10,2) NOT NULL DEFAULT 0.00   COMMENT '售价',
  `original_price` DECIMAL(10,2) DEFAULT NULL            COMMENT '原价（划线价）',
  `description`    VARCHAR(255)  DEFAULT NULL            COMMENT '商品简介',
  `stock`          INT           NOT NULL DEFAULT 0      COMMENT '库存',
  `sales`          INT           NOT NULL DEFAULT 0      COMMENT '销量',
  `is_hot`         TINYINT       NOT NULL DEFAULT 0      COMMENT '是否热销：1-是 0-否',
  `status`         TINYINT       NOT NULL DEFAULT 1      COMMENT '状态：1-上架 0-下架',
  -- 秒杀相关字段
  `is_seckill`     TINYINT       NOT NULL DEFAULT 0      COMMENT '是否秒杀商品：1-是 0-否',
  `seckill_price`  DECIMAL(10,2) DEFAULT NULL           COMMENT '秒杀价',
  `seckill_stock`  INT           DEFAULT NULL            COMMENT '秒杀库存',
  `seckill_start`  DATETIME      DEFAULT NULL            COMMENT '秒杀开始时间',
  `seckill_end`    DATETIME      DEFAULT NULL            COMMENT '秒杀结束时间',
  `create_time`    DATETIME      DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time`    DATETIME      DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted`        TINYINT       NOT NULL DEFAULT 0       COMMENT '逻辑删除：0-未删 1-已删',
  PRIMARY KEY (`id`),
  KEY `idx_category` (`category_id`),
  KEY `idx_name` (`name`)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_general_ci
  COMMENT='商品表';

-- 6. 购物车表（同一用户同一商品唯一）
DROP TABLE IF EXISTS `cart`;
CREATE TABLE `cart` (
  `id`          BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `user_id`     BIGINT       NOT NULL                COMMENT '用户ID',
  `product_id`  BIGINT       NOT NULL                COMMENT '商品ID',
  `quantity`    INT          NOT NULL DEFAULT 1      COMMENT '购买数量',
  `create_time` DATETIME     DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted`     TINYINT      NOT NULL DEFAULT 0       COMMENT '逻辑删除：0-未删 1-已删',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_product` (`user_id`, `product_id`),
  KEY `idx_user` (`user_id`)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_general_ci
  COMMENT='购物车表';

-- 7. 订单表
DROP TABLE IF EXISTS `orders`;
CREATE TABLE `orders` (
  `id`            BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `order_no`      VARCHAR(32)  NOT NULL                COMMENT '订单编号（唯一）',
  `user_id`       BIGINT       NOT NULL                COMMENT '用户ID',
  `total_amount`  DECIMAL(10,2) NOT NULL DEFAULT 0.00  COMMENT '订单总金额',
  `status`        TINYINT      NOT NULL DEFAULT 1      COMMENT '状态：1-待支付 2-已支付 3-已发货 4-已完成 5-已取消',
  `receiver_name` VARCHAR(50)  DEFAULT NULL            COMMENT '收货人',
  `receiver_phone`VARCHAR(20)  DEFAULT NULL            COMMENT '收货电话',
  `address`       VARCHAR(255) DEFAULT NULL            COMMENT '收货地址',
  `create_time`   DATETIME     DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time`   DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted`       TINYINT      NOT NULL DEFAULT 0       COMMENT '逻辑删除：0-未删 1-已删',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_order_no` (`order_no`),
  KEY `idx_user` (`user_id`)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_general_ci
  COMMENT='订单表';

-- 8. 订单明细表
DROP TABLE IF EXISTS `order_item`;
CREATE TABLE `order_item` (
  `id`           BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `order_id`     BIGINT       NOT NULL                COMMENT '订单ID',
  `product_id`   BIGINT       NOT NULL                COMMENT '商品ID',
  `product_name` VARCHAR(120) DEFAULT NULL            COMMENT '商品名称（下单快照）',
  `icon`         VARCHAR(20)  DEFAULT NULL            COMMENT '图标（下单快照）',
  `price`        DECIMAL(10,2) NOT NULL DEFAULT 0.00  COMMENT '单价（下单快照）',
  `quantity`     INT          NOT NULL DEFAULT 1      COMMENT '购买数量',
  `create_time`  DATETIME     DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `deleted`      TINYINT      NOT NULL DEFAULT 0       COMMENT '逻辑删除：0-未删 1-已删',
  PRIMARY KEY (`id`),
  KEY `idx_order` (`order_id`)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_general_ci
  COMMENT='订单明细表';

-- =====================================================
-- 种子数据
-- =====================================================

-- 插入测试账号（密码均为 123456，已用 BCrypt 加密）
INSERT INTO `user` (`username`, `account`, `password`, `email`, `phone`) VALUES
('星空测试员', 'test@starshop.com', '$2b$10$NdrCtyOwXCx5INe7Dw/IXekL22/e1IFblUQ/JzkSQ1sKIOXpGaqc2', 'test@starshop.com', NULL),
('追星星的人', '13800138000',      '$2b$10$NdrCtyOwXCx5INe7Dw/IXekL22/e1IFblUQ/JzkSQ1sKIOXpGaqc2', NULL, '13800138000');

-- 插入分级分类（显式指定 id，便于子分类 parent_id 映射）
--    顶级分类
INSERT INTO `category` (`id`, `name`, `parent_id`, `level`, `sort`) VALUES
(1,  '数码电子', 0, 1, 1),
(2,  '家居生活', 0, 1, 2),
(3,  '服饰鞋包', 0, 1, 3),
(4,  '美妆个护', 0, 1, 4),
(5,  '食品零食', 0, 1, 5),
(6,  '手工兽装', 0, 1, 6),
(7,  '二次元周边', 0, 1, 7),
(8,  '宠物用品', 0, 1, 8),
(9,  '户外运动', 0, 1, 9);
--    二级分类
INSERT INTO `category` (`id`, `name`, `parent_id`, `level`, `sort`) VALUES
(11, '耳机音响',   1, 2, 1),
(12, '电脑外设',   1, 2, 2),
(13, '摄影摄像',   1, 2, 3),
(21, '灯饰照明',   2, 2, 1),
(22, '香薰日用',   2, 2, 2),
(31, '鞋靴',       3, 2, 1),
(32, '箱包',       3, 2, 2),
(41, '彩妆',       4, 2, 1),
(42, '护肤',       4, 2, 2),
(51, '巧克力糖果', 5, 2, 1),
(52, '咖啡饮品',   5, 2, 2),
(53, '坚果零食',   5, 2, 3),
(54, '肉脯熟食',   5, 2, 4),
--    手工兽装
(61, '兽头头套',   6, 2, 1),
(62, '兽爪手套',   6, 2, 2),
(63, '全身兽装',   6, 2, 3),
(64, '兽装配件',   6, 2, 4),
--    二次元周边
(71, '手办模型',   7, 2, 1),
(72, '联名盲盒',   7, 2, 2),
(73, '角色服饰',   7, 2, 3),
--    宠物用品
(81, '宠物零食',   8, 2, 1),
(82, '宠物玩具',   8, 2, 2),
(83, '猫狗窝具',   8, 2, 3),
--    户外运动
(91, '露营装备',   9, 2, 1),
(92, '骑行装备',   9, 2, 2),
(93, '徒步鞋服',   9, 2, 3);

-- 插入商品（category_id 通过子查询按分类名定位，避免硬编码 id）
INSERT INTO `product` (`name`, `category_id`, `icon`, `price`, `original_price`, `description`, `stock`, `sales`, `is_hot`, `status`) VALUES
('星轨降噪蓝牙耳机',     (SELECT id FROM category WHERE name='耳机音响'),   '🎧', 399.00, 499.00, '主动降噪，沉浸式星轨音质',   200, 1280, 1, 1),
('银河机械键盘 87 键',   (SELECT id FROM category WHERE name='电脑外设'),   '⌨️', 329.00, 429.00, '客制化轴体，银河配色',       320, 860,  0, 1),
('星云无线鼠标',         (SELECT id FROM category WHERE name='电脑外设'),   '🖱️', 129.00, 169.00, '轻量化人体工学，静音点击',   500, 1500, 0, 1),
('观星者入门天文望远镜', (SELECT id FROM category WHERE name='摄影摄像'),   '🔭', 1299.00,1599.00, '70mm 大口径，追星入门首选',   80, 210,  0, 1),
('口袋云台相机',         (SELECT id FROM category WHERE name='摄影摄像'),   '📷', 1899.00,2199.00, '三轴防抖，随手拍出星河',     60, 320,  0, 1),
('星空投影氛围灯',       (SELECT id FROM category WHERE name='灯饰照明'),   '🌌', 159.00, 219.00, '360° 旋转星河，卧室浪漫',   420, 2300, 1, 1),
('月相夜灯',             (SELECT id FROM category WHERE name='灯饰照明'),   '💡', 79.00,  99.00,  '八种月相，温柔伴眠',         360, 980,  0, 1),
('月夜香薰蜡烛礼盒',     (SELECT id FROM category WHERE name='香薰日用'),   '🕯️', 89.00, 119.00, '天然大豆蜡，助眠香氛',       280, 760,  0, 1),
('流星轻便跑鞋',         (SELECT id FROM category WHERE name='鞋靴'),       '👟', 459.00, 599.00, '回弹中底，奔跑如流星',       240, 540,  1, 1),
('星尘登山靴',           (SELECT id FROM category WHERE name='鞋靴'),       '🥾', 529.00, 699.00, '防水防滑，征服山野',         150, 230,  0, 1),
('星云帆布双肩包',       (SELECT id FROM category WHERE name='箱包'),       '🎒', 199.00, 259.00, '大容量防泼水，通勤必备',     300, 1120, 0, 1),
('人鱼姬星闪唇釉',       (SELECT id FROM category WHERE name='彩妆'),       '💄', 119.00, 159.00, '镜面质地，星河碎钻闪',       260, 1880, 1, 1),
('极光指甲油套装',       (SELECT id FROM category WHERE name='彩妆'),       '💅', 69.00,  89.00, '六色极光，持久不掉',         400, 690,  0, 1),
('月光保湿修护面霜',     (SELECT id FROM category WHERE name='护肤'),       '🧴', 239.00, 299.00, '神经酰胺，熬夜救星',         220, 940,  0, 1),
('陨石黑巧克力礼盒',     (SELECT id FROM category WHERE name='巧克力糖果'), '🍫', 99.00, 139.00, '72% 纯可可，醇苦回甘',       350, 1230, 0, 1),
('云端冷萃咖啡液 12 颗', (SELECT id FROM category WHERE name='咖啡饮品'),   '☕', 69.00,  89.00, '低温慢萃，随时一杯星河',     480, 1740, 0, 1);

-- 食品零食扩充（新的独立 INSERT 语句）
INSERT INTO `product` (`name`, `category_id`, `icon`, `price`, `original_price`, `description`, `stock`, `sales`, `is_hot`, `status`) VALUES
('坚果星空礼盒',   (SELECT id FROM category WHERE name='坚果零食'), '🥜', 89.00, 119.00, '七种坚果，锁鲜罐装',     220, 1120, 1, 1),
('手撕蜜汁肉脯',   (SELECT id FROM category WHERE name='肉脯熟食'), '🥓', 39.00,  49.00, '独立小包，追剧必备',     320, 1340, 0, 1),

-- 手工兽装
('星河狐兽头头套', (SELECT id FROM category WHERE name='兽头头套'), '🦊', 1299.00, 1599.00, '手工植毛，灵动大眼，专属定制', 30, 120, 1, 1),
('龙鳞兽爪手套',   (SELECT id FROM category WHERE name='兽爪手套'), '🐾', 299.00,  399.00, '硅胶爪垫，柔软贴合',         80, 260, 0, 1),
('狼形半身兽装',   (SELECT id FROM category WHERE name='全身兽装'), '🐺', 3599.00, 4299.00, '全身毛发手工缝制，演出级',   12,  45, 0, 1),
('兽装静音散热风扇', (SELECT id FROM category WHERE name='兽装配件'), '🌬️', 159.00,  199.00, '头套内置，久戴不闷',         60, 310, 0, 1),

-- 二次元周边
('星之少女限定手办', (SELECT id FROM category WHERE name='手办模型'), '🎎', 459.00, 599.00, '1/7 比例，珠光涂装',         50, 430, 1, 1),
('十二星座联名盲盒', (SELECT id FROM category WHERE name='联名盲盒'), '🎁',  69.00,  89.00, '一盒六抽，隐藏款随机',       300, 1560, 0, 1),
('角色 cos 服饰套装', (SELECT id FROM category WHERE name='角色服饰'), '👗', 329.00, 429.00, '还原原作，含假发配饰',       70, 280, 0, 1),

-- 宠物用品
('星空冻干宠物零食', (SELECT id FROM category WHERE name='宠物零食'), '🦴', 49.00,  69.00, '无谷低敏，毛孩子爱吃',       200, 980, 0, 1),
('发光宠物玩具球',   (SELECT id FROM category WHERE name='宠物玩具'), '🔮', 39.00,  49.00, '夜间自发光，耐咬静音',       260, 870, 1, 1),
('云朵星空猫窝',     (SELECT id FROM category WHERE name='猫狗窝具'), '🛏️', 199.00, 259.00, '半封闭保暖，航天棉内芯',     120, 540, 0, 1),

-- 户外运动
('银河观星帐篷',   (SELECT id FROM category WHERE name='露营装备'), '⛺', 899.00, 1199.00, '双面涂银，360° 观星顶',      40, 210, 1, 1),
('夜骑星轨前灯',   (SELECT id FROM category WHERE name='骑行装备'), '🚴', 159.00,  199.00, '800 流明，Type-C 快充',      130, 560, 0, 1),
('星尘徒步鞋',     (SELECT id FROM category WHERE name='徒步鞋服'), '🥾', 549.00,  699.00, 'VIBRAM 大底，防滑透气',      90, 330, 0, 1);

-- 标记部分商品为秒杀商品（秒杀价 / 秒杀库存 / 起止时间）
UPDATE `product` SET is_seckill=1, seckill_price=299.00, seckill_stock=50,  seckill_start=DATE_SUB(NOW(), INTERVAL 1 DAY), seckill_end=DATE_ADD(NOW(), INTERVAL 7 DAY) WHERE name='星轨降噪蓝牙耳机';
UPDATE `product` SET is_seckill=1, seckill_price=99.00,  seckill_stock=100, seckill_start=DATE_SUB(NOW(), INTERVAL 1 DAY), seckill_end=DATE_ADD(NOW(), INTERVAL 7 DAY) WHERE name='星空投影氛围灯';
UPDATE `product` SET is_seckill=1, seckill_price=79.00,  seckill_stock=80,  seckill_start=DATE_SUB(NOW(), INTERVAL 1 DAY), seckill_end=DATE_ADD(NOW(), INTERVAL 7 DAY) WHERE name='人鱼姬星闪唇釉';
UPDATE `product` SET is_seckill=1, seckill_price=49.00,  seckill_stock=120, seckill_start=DATE_SUB(NOW(), INTERVAL 1 DAY), seckill_end=DATE_ADD(NOW(), INTERVAL 7 DAY) WHERE name='云端冷萃咖啡液 12 颗';
UPDATE `product` SET is_seckill=1, seckill_price=359.00, seckill_stock=60,  seckill_start=DATE_SUB(NOW(), INTERVAL 1 DAY), seckill_end=DATE_ADD(NOW(), INTERVAL 7 DAY) WHERE name='流星轻便跑鞋';

-- =====================================================
-- 社区评价模块（与 sql/review.sql 内容一致，便于全新初始化）
-- =====================================================

-- 9. 社区评价表：各用户对各类商品的评分与评价
DROP TABLE IF EXISTS `review`;
CREATE TABLE `review` (
  `id`          BIGINT        NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `user_id`     BIGINT        NOT NULL                COMMENT '评价用户ID',
  `username`    VARCHAR(50)   NOT NULL                COMMENT '用户昵称（发表时快照，用于展示）',
  `product_id`  BIGINT        NOT NULL                COMMENT '商品ID',
  `rating`      TINYINT       NOT NULL DEFAULT 5      COMMENT '评分：1-5 星',
  `content`     VARCHAR(500)  NOT NULL                COMMENT '评价内容',
  `create_time` DATETIME      DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME      DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted`     TINYINT       NOT NULL DEFAULT 0       COMMENT '逻辑删除：0-未删 1-已删',
  PRIMARY KEY (`id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_product` (`product_id`),
  KEY `idx_create` (`create_time`)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_general_ci
  COMMENT='商品评价表（社区）';

-- 10. 社区种子用户（密码均为 123456，BCrypt 加密；账号已存在则跳过）
INSERT INTO `user` (`username`, `account`, `password`, `email`) VALUES
('星河漫步',   'walker@starshop.com',    '$2b$10$NdrCtyOwXCx5INe7Dw/IXekL22/e1IFblUQ/JzkSQ1sKIOXpGaqc2', 'walker@starshop.com'),
('银河邮递员', 'postman@starshop.com',   '$2b$10$NdrCtyOwXCx5INe7Dw/IXekL22/e1IFblUQ/JzkSQ1sKIOXpGaqc2', 'postman@starshop.com'),
('月背观星人', 'moongazer@starshop.com', '$2b$10$NdrCtyOwXCx5INe7Dw/IXekL22/e1IFblUQ/JzkSQ1sKIOXpGaqc2', 'moongazer@starshop.com'),
('猎户座电波', 'orion@starshop.com',     '$2b$10$NdrCtyOwXCx5INe7Dw/IXekL22/e1IFblUQ/JzkSQ1sKIOXpGaqc2', 'orion@starshop.com'),
('彗尾收藏家', 'comet@starshop.com',     '$2b$10$NdrCtyOwXCx5INe7Dw/IXekL22/e1IFblUQ/JzkSQ1sKIOXpGaqc2', 'comet@starshop.com'),
('南门二旅人', 'acentauri@starshop.com', '$2b$10$NdrCtyOwXCx5INe7Dw/IXekL22/e1IFblUQ/JzkSQ1sKIOXpGaqc2', 'acentauri@starshop.com'),
('仙女座诗织', 'andromeda@starshop.com', '$2b$10$NdrCtyOwXCx5INe7Dw/IXekL22/e1IFblUQ/JzkSQ1sKIOXpGaqc2', 'andromeda@starshop.com'),
('天狼星电台', 'sirius@starshop.com',    '$2b$10$NdrCtyOwXCx5INe7Dw/IXekL22/e1IFblUQ/JzkSQ1sKIOXpGaqc2', 'sirius@starshop.com')
ON DUPLICATE KEY UPDATE `username` = VALUES(`username`);

-- 11. 种子评价（覆盖各类商品：数码、家居、美妆、食品、兽装、二次元、宠物、户外…）
INSERT INTO `review` (`user_id`, `username`, `product_id`, `rating`, `content`) VALUES
((SELECT id FROM `user` WHERE account='walker@starshop.com'),    '星河漫步',   (SELECT id FROM `product` WHERE name='星轨降噪蓝牙耳机'),   5, '降噪效果惊艳，戴上耳机整个世界只剩星河。通勤地铁里听后摇，细节纤毫毕现，值回票价！'),
((SELECT id FROM `user` WHERE account='moongazer@starshop.com'), '月背观星人', (SELECT id FROM `product` WHERE name='星轨降噪蓝牙耳机'),   4, '音质很棒，佩戴也舒适。只是连续佩戴三小时后耳朵略有胀感，摘下来歇一会儿就好。'),
((SELECT id FROM `user` WHERE account='orion@starshop.com'),     '猎户座电波', (SELECT id FROM `product` WHERE name='银河机械键盘 87 键'),  5, '轴体手感顺滑，大键调教在线，打字像在银河里敲击星辰。配色耐看，桌面颜值直线上升。'),
((SELECT id FROM `user` WHERE account='sirius@starshop.com'),    '天狼星电台', (SELECT id FROM `product` WHERE name='星云无线鼠标'),       4, '轻若无物，静音微动很舒服，深夜办公不会吵到室友。续航表现中规中矩，一周一充可以接受。'),
((SELECT id FROM `user` WHERE account='walker@starshop.com'),    '星河漫步',   (SELECT id FROM `product` WHERE name='观星者入门天文望远镜'), 5, '70mm 口径看月亮环形山清晰锐利，第一次亲眼看到木星条纹的瞬间起鸡皮疙瘩。入门首选没有之一！'),
((SELECT id FROM `user` WHERE account='acentauri@starshop.com'), '南门二旅人', (SELECT id FROM `product` WHERE name='口袋云台相机'),       4, '防抖真的很顶，边走边拍画面稳得像架了轨道。夜景噪点略多，光线好的场景无可挑剔。'),
((SELECT id FROM `user` WHERE account='postman@starshop.com'),   '银河邮递员', (SELECT id FROM `product` WHERE name='星空投影氛围灯'),     5, '送给女朋友的生日礼物，投影开满整面墙的那一刻她眼睛比星星还亮。360° 旋转星河氛围感拉满。'),
((SELECT id FROM `user` WHERE account='andromeda@starshop.com'), '仙女座诗织', (SELECT id FROM `product` WHERE name='星空投影氛围灯'),     5, '卧室氛围神器！睡前开着当星空顶，八分钟定时关闭很贴心，入睡幸福感+10086。'),
((SELECT id FROM `user` WHERE account='comet@starshop.com'),     '彗尾收藏家', (SELECT id FROM `product` WHERE name='月相夜灯'),           4, '八种月相切换很有仪式感，暖光温柔不刺眼。做工细节稍微粗糙，但这个价位无可厚非。'),
((SELECT id FROM `user` WHERE account='andromeda@starshop.com'), '仙女座诗织', (SELECT id FROM `product` WHERE name='月夜香薰蜡烛礼盒'),   5, '点燃后满室桂花月夜香，天然大豆蜡燃烧无黑烟，睡前点半小时，整个人都松弛下来。'),
((SELECT id FROM `user` WHERE account='sirius@starshop.com'),    '天狼星电台', (SELECT id FROM `product` WHERE name='流星轻便跑鞋'),       5, '回弹中底踩起来像流星滑行，五公里后脚感依旧澎湃。透气网面夏天跑步也不闷脚。'),
((SELECT id FROM `user` WHERE account='orion@starshop.com'),     '猎户座电波', (SELECT id FROM `product` WHERE name='星尘登山靴'),         4, '上周爬野山实测：防滑大底抓地稳，过溪水鞋面没湿。稍重，长途徒步需要适应一两趟。'),
((SELECT id FROM `user` WHERE account='postman@starshop.com'),   '银河邮递员', (SELECT id FROM `product` WHERE name='星云帆布双肩包'),     4, '容量真的能装，通勤电脑+雨伞+饭盒无压力，防泼水小雨天实测靠谱。背带偏硬，用一段时间会软。'),
((SELECT id FROM `user` WHERE account='andromeda@starshop.com'), '仙女座诗织', (SELECT id FROM `product` WHERE name='人鱼姬星闪唇釉'),     5, '镜面水光质地绝美！星闪细碎钻光在灯下流动，薄涂日常厚涂惊艳，已回购第三支。'),
((SELECT id FROM `user` WHERE account='comet@starshop.com'),     '彗尾收藏家', (SELECT id FROM `product` WHERE name='极光指甲油套装'),     4, '六色极光在阳光下偏光超梦幻，涂两层显色饱满。持久度四天起边，对这个价位算优秀。'),
((SELECT id FROM `user` WHERE account='moongazer@starshop.com'), '月背观星人', (SELECT id FROM `product` WHERE name='月光保湿修护面霜'),   5, '神经酰胺修护名不虚传，熬夜后厚敷一层，第二天脸不垮不暗沉。质地清爽不闷痘。'),
((SELECT id FROM `user` WHERE account='postman@starshop.com'),   '银河邮递员', (SELECT id FROM `product` WHERE name='陨石黑巧克力礼盒'),   4, '72% 的醇苦带着回甘，配冷萃咖啡是绝配。一两块刚好满足甜食欲，控卡党福音。'),
((SELECT id FROM `user` WHERE account='walker@starshop.com'),    '星河漫步',   (SELECT id FROM `product` WHERE name='云端冷萃咖啡液 12 颗'), 5, '一颗一袋超方便，冰水一冲三秒即溶，风味干净带莓果酸香。办公室下午的救命星河。'),
((SELECT id FROM `user` WHERE account='sirius@starshop.com'),    '天狼星电台', (SELECT id FROM `product` WHERE name='坚果星空礼盒'),       4, '七种坚果都很新鲜，锁鲜罐装没有油耗味。送礼盒子好看，自己吃性价比也不错。'),
((SELECT id FROM `user` WHERE account='acentauri@starshop.com'), '南门二旅人', (SELECT id FROM `product` WHERE name='手撕蜜汁肉脯'),       3, '蜜汁味不错，独立小包方便。但肉质偏干硬，嚼久了腮帮子累，追剧慢慢吃还行。'),
((SELECT id FROM `user` WHERE account='moongazer@starshop.com'), '月背观星人', (SELECT id FROM `product` WHERE name='星河狐兽头头套'),     5, '手工植毛的层次感太强了，大眼灵动得像活的！上兽装聚回头率爆表，等了六周完全值得。'),
((SELECT id FROM `user` WHERE account='comet@starshop.com'),     '彗尾收藏家', (SELECT id FROM `product` WHERE name='龙鳞兽爪手套'),       4, '硅胶爪垫触感柔软，握拳张合都很顺畅。透气性一般，配散热风扇一起用完美解决。'),
((SELECT id FROM `user` WHERE account='andromeda@starshop.com'), '仙女座诗织', (SELECT id FROM `product` WHERE name='兽装静音散热风扇'),   5, '装进头套后久戴不闷汗，噪音控制得几乎无感，续航五小时+,漫展全天无忧。'),
((SELECT id FROM `user` WHERE account='walker@starshop.com'),    '星河漫步',   (SELECT id FROM `product` WHERE name='星之少女限定手办'),   5, '1/7 比例细节爆炸，珠光涂装在灯下流光溢彩，底座星星配件良心。柜中 C 位预定。'),
((SELECT id FROM `user` WHERE account='sirius@starshop.com'),    '天狼星电台', (SELECT id FROM `product` WHERE name='十二星座联名盲盒'),   4, '一盒六抽手感均好，抽到隐藏款白羊座时整层楼都听到我在尖叫。重复率可以接受。'),
((SELECT id FROM `user` WHERE account='acentauri@starshop.com'), '南门二旅人', (SELECT id FROM `product` WHERE name='角色 cos 服饰套装'),   3, '版型还原度不错，假发发丝量充足。但面料略薄，灯下需要打底，这个价位算及格偏上。'),
((SELECT id FROM `user` WHERE account='postman@starshop.com'),   '银河邮递员', (SELECT id FROM `product` WHERE name='星空冻干宠物零食'),   5, '家里两只猫闻到就疯跑过来，无谷低敏配方吃着放心，冻干复水后毛孩子碗里一扫而空。'),
((SELECT id FROM `user` WHERE account='moongazer@starshop.com'), '月背观星人', (SELECT id FROM `product` WHERE name='发光宠物玩具球'),     4, '夜里自动发光，狗子追着满屋子跑，静音设计不吵邻居。耐咬度超出预期，power 模式狗子超爱。'),
((SELECT id FROM `user` WHERE account='andromeda@starshop.com'), '仙女座诗织', (SELECT id FROM `product` WHERE name='云朵星空猫窝'),       5, '半封闭设计很招猫，航天棉内芯蓬松保暖，主子进窝秒变液体。星空配色和家里装修莫名搭。'),
((SELECT id FROM `user` WHERE account='orion@starshop.com'),     '猎户座电波', (SELECT id FROM `product` WHERE name='银河观星帐篷'),       5, '360° 观星顶名不虚传！躺在帐篷里看银河划过天际，双面涂银白天也不闷，露营党强烈推荐。'),
((SELECT id FROM `user` WHERE account='comet@starshop.com'),     '彗尾收藏家', (SELECT id FROM `product` WHERE name='夜骑星轨前灯'),       4, '800 流明夜骑足够，切远光路面全亮。Type-C 快充两小时满电，防水淋了场暴雨无恙。'),
((SELECT id FROM `user` WHERE account='acentauri@starshop.com'), '南门二旅人', (SELECT id FROM `product` WHERE name='星尘徒步鞋'),         2, 'VIBRAM 大底防滑没问题，但鞋楦偏窄夹脚，走完十公里脚侧磨出泡，宽脚慎重入手。');

-- 12. 演示测试账号评价
INSERT INTO `review` (`user_id`, `username`, `product_id`, `rating`, `content`) VALUES
((SELECT id FROM `user` WHERE account='test@starshop.com'), '星空测试员', (SELECT id FROM `product` WHERE name='星空投影氛围灯'), 5, '测试账号也来顶一下：投影氛围一流，操作简单，家里老人都会用。');
