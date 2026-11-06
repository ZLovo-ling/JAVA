package com.fenglin.springboottest.vo;

import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

/**
 * 订单视图（含明细）
 */
@Data
public class OrderVO {

    /** 订单ID */
    private Long id;

    /** 订单编号 */
    private String orderNo;

    /** 总金额 */
    private BigDecimal totalAmount;

    /** 状态：1-待支付 2-已支付 3-已发货 4-已完成 5-已取消 */
    private Integer status;

    /** 状态文案 */
    private String statusText;

    /** 收货人 */
    private String receiverName;

    /** 收货电话 */
    private String receiverPhone;

    /** 收货地址 */
    private String address;

    /** 创建时间 */
    private LocalDateTime createTime;

    /** 明细 */
    private List<OrderItemVO> items;
}
