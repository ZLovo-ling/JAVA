<template>
  <section class="usage">
    <div class="usage-title">✦ 网站用途简介 ✦</div>
    <div class="usage-sub">星购商城 —— 集精选购物、限时优惠、会员权益与极速配送于一体的一站式星空购物平台</div>

    <div class="usage-grid">
      <div class="usage-item">
        <div class="u-ic">🛍️</div>
        <div class="u-title">精选好物</div>
        <div class="u-desc">全球甄选百万商品，品质严选，品类齐全，让您一站购齐所需</div>
      </div>
      <div class="usage-item">
        <div class="u-ic">⚡</div>
        <div class="u-title">限时秒杀</div>
        <div class="u-desc">每日星空专场限时开抢，超值折扣、优惠券叠加，省钱看得见</div>
      </div>
      <div class="usage-item">
        <div class="u-ic">👑</div>
        <div class="u-title">会员权益</div>
        <div class="u-desc">星等级会员成长体系，专享折扣、积分返现与生日专属礼遇</div>
      </div>
      <div class="usage-item">
        <div class="u-ic">🚚</div>
        <div class="u-title">极速配送</div>
        <div class="u-desc">全国仓配网络覆盖，次日送达，物流状态全程实时可追踪</div>
      </div>
    </div>

    <div class="usage-about">
      <b>关于本站：</b>星购商城致力于为用户提供<b>高性价比、正品保障、服务贴心</b>的在线购物体验。<br />
      支持商品浏览与搜索、购物车管理、在线支付、订单追踪、售后服务与收藏清单等全流程功能，<br />
      让您足不出户，便能穿越星海，轻松选购心仪好物。
      <div>
        <span class="tag">正品保障</span>
        <span class="tag">七天无理由退换</span>
        <span class="tag">在线支付</span>
        <span class="tag">售后无忧</span>
      </div>
    </div>
  </section>
</template>

<style scoped>
.usage {
  width: 100%;
  max-width: 880px;
  padding: 34px 30px 28px;
  border-radius: 26px;
  position: relative;
  text-align: center;
  background: linear-gradient(160deg, rgba(26, 30, 72, 0.45), rgba(16, 19, 48, 0.38));
  backdrop-filter: blur(14px);
  -webkit-backdrop-filter: blur(14px);
  border: 1px solid rgba(148, 170, 255, 0.18);
  box-shadow: 0 24px 60px rgba(0, 0, 0, 0.45), inset 0 1px 0 rgba(255, 255, 255, 0.1);
  animation: usageIn 1s 0.25s cubic-bezier(0.2, 0.8, 0.2, 1) both;
}
@keyframes usageIn {
  from {
    opacity: 0;
    transform: translateY(24px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}
.usage::before {
  content: "";
  position: absolute;
  bottom: -1px;
  left: 20%;
  width: 60%;
  height: 2px;
  border-radius: 2px;
  background: linear-gradient(90deg, transparent, var(--gold), var(--pink), var(--cyan), transparent);
  opacity: 0.8;
}

.usage-title {
  font-size: 20px;
  letter-spacing: 5px;
  font-weight: 700;
  color: transparent;
  background: linear-gradient(92deg, var(--cyan), var(--violet) 50%, var(--pink));
  -webkit-background-clip: text;
  background-clip: text;
  filter: drop-shadow(0 0 12px rgba(167, 139, 250, 0.5));
}
.usage-sub {
  margin-top: 8px;
  font-size: 12.5px;
  letter-spacing: 2px;
  color: rgba(196, 206, 255, 0.6);
}

.usage-grid {
  margin-top: 26px;
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 18px;
}
.usage-item {
  padding: 20px 14px;
  border-radius: 18px;
  background: rgba(14, 18, 46, 0.5);
  border: 1px solid rgba(148, 170, 255, 0.15);
  transition: all 0.35s;
  cursor: default;
}
.usage-item:hover {
  transform: translateY(-6px);
  border-color: rgba(167, 139, 250, 0.55);
  box-shadow: 0 14px 32px rgba(88, 60, 200, 0.35), 0 0 24px rgba(139, 92, 246, 0.25);
  background: rgba(22, 26, 62, 0.62);
}
.u-ic {
  font-size: 26px;
  margin-bottom: 10px;
  filter: drop-shadow(0 0 10px rgba(167, 139, 250, 0.6));
}
.u-title {
  font-size: 15px;
  font-weight: 600;
  letter-spacing: 2px;
  color: transparent;
  background: linear-gradient(90deg, var(--gold), var(--pink));
  -webkit-background-clip: text;
  background-clip: text;
  margin-bottom: 8px;
}
.u-desc {
  font-size: 12.5px;
  line-height: 1.7;
  color: rgba(198, 208, 246, 0.78);
  letter-spacing: 0.5px;
}

.usage-about {
  margin-top: 26px;
  padding-top: 20px;
  border-top: 1px dashed rgba(148, 170, 255, 0.2);
  font-size: 12.5px;
  line-height: 1.9;
  color: rgba(190, 202, 244, 0.7);
  letter-spacing: 1px;
}
.usage-about b {
  color: transparent;
  background: linear-gradient(90deg, var(--cyan), var(--violet));
  -webkit-background-clip: text;
  background-clip: text;
  font-weight: 600;
}
.usage-about .tag {
  display: inline-block;
  margin: 8px 5px 0;
  padding: 5px 13px;
  border-radius: 20px;
  font-size: 11.5px;
  color: #dbe6ff;
  background: rgba(90, 80, 200, 0.22);
  border: 1px solid rgba(148, 170, 255, 0.25);
}

@media (max-width: 860px) {
  .usage-grid {
    grid-template-columns: repeat(2, 1fr);
  }
}
@media (max-width: 480px) {
  .usage {
    padding: 26px 18px 22px;
  }
  .usage-grid {
    grid-template-columns: 1fr;
    gap: 14px;
  }
  .usage-title {
    font-size: 17px;
    letter-spacing: 3px;
  }
}
</style>
