package com.fenglin.springboottest.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.fenglin.springboottest.common.BusinessException;
import com.fenglin.springboottest.dto.CreateOrderRequest;
import com.fenglin.springboottest.entity.Order;
import com.fenglin.springboottest.entity.OrderItem;
import com.fenglin.springboottest.entity.Product;
import com.fenglin.springboottest.mapper.CartMapper;
import com.fenglin.springboottest.mapper.OrderItemMapper;
import com.fenglin.springboottest.mapper.OrderMapper;
import com.fenglin.springboottest.mapper.ProductMapper;
import com.fenglin.springboottest.service.IOrderService;
import com.fenglin.springboottest.vo.OrderItemVO;
import com.fenglin.springboottest.vo.OrderVO;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;

/**
 * 订单服务实现
 */
@Service
public class OrderServiceImpl extends ServiceImpl<OrderMapper, Order> implements IOrderService {

    private final ProductMapper productMapper;
    private final OrderItemMapper orderItemMapper;
    private final CartMapper cartMapper;

    public OrderServiceImpl(ProductMapper productMapper, OrderItemMapper orderItemMapper, CartMapper cartMapper) {
        this.productMapper = productMapper;
        this.orderItemMapper = orderItemMapper;
        this.cartMapper = cartMapper;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public OrderVO create(CreateOrderRequest req) {
        Long userId = req.getUserId();
        if (req.getItems() == null || req.getItems().isEmpty()) {
            throw new BusinessException("订单明细不能为空");
        }

        // 1. 校验商品并计算总额（下单价以商品当前售价快照）
        BigDecimal total = BigDecimal.ZERO;
        List<OrderItem> items = new ArrayList<>();
        for (CreateOrderRequest.Item it : req.getItems()) {
            Product p = productMapper.selectById(it.getProductId());
            if (p == null || p.getStatus() == null || p.getStatus() != 1) {
                throw new BusinessException("商品「" + (p == null ? it.getProductId() : p.getName()) + "」不存在或已下架");
            }
            int qty = Math.max(1, it.getQuantity() == null ? 1 : it.getQuantity());
            if (p.getStock() == null || p.getStock() < qty) {
                throw new BusinessException("商品「" + p.getName() + "」库存不足");
            }
            BigDecimal lineTotal = p.getPrice().multiply(BigDecimal.valueOf(qty));
            total = total.add(lineTotal);

            OrderItem oi = new OrderItem();
            oi.setProductId(p.getId());
            oi.setProductName(p.getName());
            oi.setIcon(p.getIcon());
            oi.setPrice(p.getPrice());
            oi.setQuantity(qty);
            items.add(oi);

            // 扣库存、加销量
            p.setStock(p.getStock() - qty);
            p.setSales((p.getSales() == null ? 0 : p.getSales()) + qty);
            productMapper.updateById(p);
        }

        // 2. 保存订单
        Order order = new Order();
        order.setOrderNo(genOrderNo());
        order.setUserId(userId);
        order.setTotalAmount(total);
        order.setStatus(1); // 待支付
        order.setReceiverName(req.getReceiverName());
        order.setReceiverPhone(req.getReceiverPhone());
        order.setAddress(req.getAddress());
        save(order);

        // 3. 保存明细
        for (OrderItem oi : items) {
            oi.setOrderId(order.getId());
            orderItemMapper.insert(oi);
        }

        // 4. 结算后清空购物车中已购商品
        for (CreateOrderRequest.Item it : req.getItems()) {
            cartMapper.delete(new LambdaQueryWrapper<com.fenglin.springboottest.entity.Cart>()
                    .eq(com.fenglin.springboottest.entity.Cart::getUserId, userId)
                    .eq(com.fenglin.springboottest.entity.Cart::getProductId, it.getProductId()));
        }

        return toVO(order);
    }

    @Override
    public List<OrderVO> listByUser(Long userId) {
        List<Order> orders = list(new LambdaQueryWrapper<Order>()
                .eq(Order::getUserId, userId).orderByDesc(Order::getCreateTime));
        List<OrderVO> vos = new ArrayList<>();
        for (Order o : orders) {
            vos.add(toVO(o));
        }
        return vos;
    }

    /** 订单 -> 视图（含明细） */
    private OrderVO toVO(Order o) {
        OrderVO vo = new OrderVO();
        vo.setId(o.getId());
        vo.setOrderNo(o.getOrderNo());
        vo.setTotalAmount(o.getTotalAmount());
        vo.setStatus(o.getStatus());
        vo.setStatusText(statusText(o.getStatus()));
        vo.setReceiverName(o.getReceiverName());
        vo.setReceiverPhone(o.getReceiverPhone());
        vo.setAddress(o.getAddress());
        vo.setCreateTime(o.getCreateTime());

        List<OrderItem> items = orderItemMapper.selectList(
                new LambdaQueryWrapper<OrderItem>().eq(OrderItem::getOrderId, o.getId()));
        List<OrderItemVO> ivos = new ArrayList<>();
        for (OrderItem it : items) {
            OrderItemVO iv = new OrderItemVO();
            iv.setProductId(it.getProductId());
            iv.setProductName(it.getProductName());
            iv.setIcon(it.getIcon());
            iv.setPrice(it.getPrice());
            iv.setQuantity(it.getQuantity());
            ivos.add(iv);
        }
        vo.setItems(ivos);
        return vo;
    }

    private String statusText(Integer status) {
        if (status == null) return "未知";
        switch (status) {
            case 1: return "待支付";
            case 2: return "已支付";
            case 3: return "已发货";
            case 4: return "已完成";
            case 5: return "已取消";
            default: return "未知";
        }
    }

    /** 生成唯一订单号：SO + 时间 + 4 位随机数 */
    private String genOrderNo() {
        String t = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss"));
        int r = new Random().nextInt(9000) + 1000;
        return "SO" + t + r;
    }
}
