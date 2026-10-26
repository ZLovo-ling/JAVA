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
