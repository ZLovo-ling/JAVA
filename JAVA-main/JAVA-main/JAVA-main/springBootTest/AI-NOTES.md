# AI-NOTES（给 AI 助手的项目速查笔记，每次开机先读我）

> 目的：这台电脑每次开机都会重置环境，下次会话先读本文件，**不要重新探索**，直接按下面的事实操作。

## 项目是什么

- 星购商城（starshop）登录/注册后端：Spring Boot 3.4.5 + MyBatis-Plus 3.5.9 + MySQL 8.0，Java 17 编译（本机 JDK 是 Zulu 21，兼容）。
- 包名：`com.fenglin.springboottest`，主类 `SpringBootTestApplication`。
- 运行端口：**8081**（profile=dev，配置在 `src/main/resources/application-dev.properties`）。
- 前端页面：`src/main/resources/static/` 下有 `starshop-login.html`（登录页）和 `starshop-home.html`（首页：导航栏+搜索栏+静态商品占位，纯前端），访问 `http://localhost:8081/` 自动跳转登录页；登录成功存 `sessionStorage.starshop_user` 并跳首页；首页未登录自动跳回登录页。
- 源码副本在桌面：`C:\Users\Administrator\Desktop\JAVA-main\` 下的 `starshop-login.html` 和 `starshop-home.html`，改页面时**先改桌面副本再 cp 到 static/**，两处保持一致。

## 启动 / 停止（首选脚本）

- 启动：双击或在终端运行项目根目录的 **`start.bat`**（自动检查数据库→编译→启动）。
- 停止：**`stop.bat`**（按 8081 端口找进程并结束）。重启：**`restart.bat`**。
- 脚本为 GBK 编码、相对路径，可直接在 cmd 运行。

## 手动启动命令（脚本不可用时）

```bash
cd 项目目录
# 编译（每次开机 target 被删除，必须重新编译）
"D:/IntelliJ IDEA 2024.3.2.2/plugins/maven/lib/maven3/bin/mvn.cmd" -s maven-settings.xml -DskipTests package
# 启动（注意先剔除会覆盖端口的环境变量）
env -u SERVER__PORT -u SERVER__HOST java -jar target/springBootTest-0.0.1-SNAPSHOT.jar
```

## 本机环境事实（不要再去探测）

| 项目 | 位置/值 |
|---|---|
| JDK | `java` 在 PATH（Zulu 21） |
| Maven | **不在 PATH**，用 IDEA 自带：`D:\IntelliJ IDEA 2024.3.2.2\plugins\maven\lib\maven3\bin\mvn.cmd`，必须加 `-s maven-settings.xml`（阿里云镜像） |
| MySQL | 8.0，3306 端口常驻；客户端 `C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe`；账号 `root` / `123456`；库名 `starshop`，表 `user` |
| 建库脚本 | `sql/init.sql`（含两个测试账号，密码都是 `123456`） |
| 测试账号 | `test@starshop.com` / `123456`；`13800138000` / `123456` |

## 接口

- `POST /api/auth/register` `{username, account, password, confirmPassword}` → 200 成功 / 409 已注册 / 400 参数错误
- `POST /api/auth/login` `{account, password}` → 200 返回用户（password 字段置空）/ 400 账号不存在或密码错误
- 统一返回结构 `ApiResult{code, message, data}`

## 已踩过的坑（不要重蹈）

1. **`SERVER__PORT` / `SERVER__HOST` 环境变量**：WorkBuddy 的 shell 会注入这两个变量，Spring Boot 宽松绑定会把它当成 `server.port`/`server.host` 覆盖配置（曾导致端口变成 59286）。命令行启动前必须 `env -u` 或 `set "SERVER__PORT="` 清空。**start.bat 已处理**。IDEA 里运行不受影响。
2. **JDBC `characterEncoding` 必须是 `UTF-8`**，不能写 `utf8mb4`（后者抛 UnsupportedEncodingException → CannotGetJdbcConnectionException）。**已修复，勿改回**。
3. **curl 访问本机要加 `--noproxy "*"`**，否则走代理返回 502。
4. **mysql.exe 执行含中文的 SQL 要加 `--default-character-set=utf8mb4`**，否则报 `ERROR 1406 Data too long`（实为字符集错位）。
5. 全局异常处理器会吞掉底层异常根因，排错时若日志只有 "Failed to obtain JDBC Connection"，写个最小 JDBC 直连类（`DriverManager.getConnection`）定位。
6. `mvnw`/`mvnw.cmd` **不能独立使用**（项目没有 `.mvn/wrapper`），别用它，用 IDEA 自带 Maven。
7. `mvn spring-boot:run` 管道接 `| tail` 时日志会被缓冲到进程结束才可见；要实时日志就重定向到文件。
8. 电脑每次开机重置：`target/`、`node_modules/` 会被删除，所以**每次都要重新 `mvn package`**，不要假设编译产物还在。
9. **开机重置也会删掉 MySQL 里的 `starshop` 库**（只保留 `ruoyi` 等）。启动时若接口报 `CannotGetJdbcConnectionException`，先确认库是否存在：
   `"C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" -uroot -p123456 --default-character-set=utf8mb4 < sql/init.sql`
   脚本为「DROP + CREATE」，可重复执行，含 2 个测试账号与 16 个商品种子数据。
10. VUE 前端（`JAVA-main\VUE`）已接真实后端，走 Vite 代理 `/api → http://localhost:8081`（见 `VUE/vite.config.js`），后端 `WebConfig` 已开 CORS。两端需同时启动：后端 `java -jar target/*.jar`（8081）、前端 `npm run dev`（5173）。
11. 前端已不仅限于鉴权：`src/services/goods.js` 封装了 `GET /api/categories`（分类树）、`GET /api/goods?keyword=&categoryId=`（列表/搜索，顶级分类自动含后代）、`GET /api/goods/seckill`（秒杀）。新增 `src/pages/HomePage.vue`（`/home`）消费这三个接口；登录成功后 `LoginCard.vue` 写 `sessionStorage.starshop_user` 并跳 `/home`；`router/index.js` 用 `meta.requiresAuth` 做守卫，未登录访问 `/home` 打回 `/login`。退出登录清 sessionStorage。

## 已知遗留（暂不影响使用，勿主动删除用户文件）

- `src/main/java/com/fenglin/springboottest/UserController.java` 和 `src/main/resources/templates/user/login.html` 是早期演示代码，未删除。
- `application-prob.properties` 文件名是 `prod` 的笔误，未改名以免破坏引用。
- 登录未发 token（无 JWT/Session），是教学版实现。
