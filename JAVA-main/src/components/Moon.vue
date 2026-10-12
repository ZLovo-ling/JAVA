<template>
  <div class="moon">
    <div class="moon-crater" style="width: 26px; height: 26px; top: 16px; left: 20px"></div>
    <div class="moon-crater" style="width: 16px; height: 16px; top: 52px; left: 56px"></div>
    <div class="moon-crater" style="width: 11px; height: 11px; top: 30px; left: 66px"></div>
  </div>
</template>

<style scoped>
.moon {
  position: fixed;
  z-index: 1;
  top: 7%;
  right: 9%;
  width: 110px;
  height: 110px;
  border-radius: 50%;
  background: radial-gradient(circle at 35% 35%, #fdf8e8, #f6e7b2 45%, #e9cf8f 100%);
  box-shadow:
    0 0 60px 20px rgba(253, 230, 138, 0.35),
    0 0 120px 45px rgba(253, 230, 138, 0.15),
    inset -18px -14px 40px rgba(190, 160, 95, 0.45);
  animation: moonGlow 6s ease-in-out infinite alternate, moonDrift 40s ease-in-out infinite alternate;
}
@keyframes moonGlow {
  from {
    box-shadow: 0 0 50px 16px rgba(253, 230, 138, 0.3), 0 0 110px 40px rgba(253, 230, 138, 0.12),
      inset -18px -14px 40px rgba(190, 160, 95, 0.45);
  }
  to {
    box-shadow: 0 0 70px 26px rgba(253, 230, 138, 0.45), 0 0 140px 55px rgba(253, 230, 138, 0.2),
      inset -18px -14px 40px rgba(190, 160, 95, 0.45);
  }
}
@keyframes moonDrift {
  from {
    transform: translateY(0);
  }
  to {
    transform: translateY(16px);
  }
}
.moon-crater {
  position: absolute;
  border-radius: 50%;
  background: radial-gradient(circle at 40% 40%, rgba(196, 166, 100, 0.35), rgba(196, 166, 100, 0.12) 70%, transparent);
}

@media (max-width: 480px) {
  .moon {
    width: 80px;
    height: 80px;
    top: 4%;
    right: 6%;
  }
}
</style>
