package com.fenglin.springboottest.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.fenglin.springboottest.entity.Product;
import com.fenglin.springboottest.vo.ProductVO;

import java.util.List;

/**
 * 商品服务接口
 */
public interface IProductService extends IService<Product> {

    /**
     * 商品搜索 / 首页展示
     * @param keyword    关键词（按商品名称模糊匹配，可空）
     * @param categoryId 分类ID（分级：自动包含该分类及其全部后代；可空表示全部）
     * @return 商品视图列表（已填充分类名，按热销、销量倒序）
     */
    List<ProductVO> search(String keyword, Long categoryId);

    /**
     * 商品详情
     * @param id 商品ID
     * @return 商品视图（含分类路径），不存在返回 null
     */
    ProductVO detail(Long id);

    /**
     * 秒杀商品列表（is_seckill=1 且上架）
     */
    List<ProductVO> seckill();
}
