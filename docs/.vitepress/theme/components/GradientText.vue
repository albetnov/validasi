<template>
  <span class="gradient-text">
    <slot />
  </span>
</template>

<style scoped>
.gradient-text {
  background: linear-gradient(120deg, #1e88e5 0%, #42a5f5 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  font-weight: 700;
}
</style>
