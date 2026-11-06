-- =====================================================
-- 星购(starshop) 社区评价模块 - 建表语句 + 种子数据
-- 数据库：MySQL 8.0
-- 说明：独立脚本，可直接在已初始化的 starshop 库上执行
--       mysql -uroot -p123456 --default-character-set=utf8mb4 < sql/review.sql
-- 重复执行安全：review 表先 DROP 再 CREATE；社区用户用
--       INSERT ... ON DUPLICATE KEY UPDATE 幂等写入
-- =====================================================

-- 1. 使用数据库
USE `starshop`;

-- 2. 社区评价表：各用户对各类商品的评分与评价
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

-- 3. 社区种子用户（密码均为 123456，BCrypt 加密；账号已存在则跳过）
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

-- 4. 种子评价（覆盖各类商品：数码、家居、美妆、食品、兽装、二次元、宠物、户外…）
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

-- 5. 演示用的测试账号评价（test@starshop.com，方便登录后看到自己的评价上下文）
INSERT INTO `review` (`user_id`, `username`, `product_id`, `rating`, `content`) VALUES
((SELECT id FROM `user` WHERE account='test@starshop.com'), '星空测试员', (SELECT id FROM `product` WHERE name='星空投影氛围灯'), 5, '测试账号也来顶一下：投影氛围一流，操作简单，家里老人都会用。');
