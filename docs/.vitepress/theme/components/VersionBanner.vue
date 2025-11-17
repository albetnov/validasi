<template>
  <div :class="['version-banner', type]">
    <div class="banner-icon">{{ icon }}</div>
    <div class="banner-content">
      <h3 class="banner-title">{{ title }}</h3>
      <p class="banner-message">{{ message }}</p>
      <a v-if="link" :href="link" class="banner-link">
        {{ linkText }} →
      </a>
    </div>
  </div>
</template>

<script setup lang="ts">
defineProps<{
  type?: 'warning' | 'info' | 'tip'
  icon?: string
  title: string
  message: string
  link?: string
  linkText?: string
}>()
</script>

<style scoped>
.version-banner {
  display: flex;
  gap: 1rem;
  padding: 1.5rem;
  margin: 2rem 0;
  border-radius: 8px;
  border-left: 4px solid;
  background: rgba(255, 255, 255, 0.05);
  backdrop-filter: blur(10px);
}

.dark .version-banner {
  background: rgba(0, 0, 0, 0.2);
}

.version-banner.warning {
  border-color: #f59e0b;
  background: linear-gradient(135deg, rgba(245, 158, 11, 0.1) 0%, rgba(245, 158, 11, 0.05) 100%);
}

.version-banner.info {
  border-color: #3b82f6;
  background: linear-gradient(135deg, rgba(59, 130, 246, 0.1) 0%, rgba(59, 130, 246, 0.05) 100%);
}

.version-banner.tip {
  border-color: #10b981;
  background: linear-gradient(135deg, rgba(16, 185, 129, 0.1) 0%, rgba(16, 185, 129, 0.05) 100%);
}

.banner-icon {
  font-size: 2rem;
  line-height: 1;
  flex-shrink: 0;
}

.banner-content {
  flex: 1;
}

.banner-title {
  margin: 0 0 0.5rem 0;
  font-size: 1.1rem;
  font-weight: 600;
  color: var(--vp-c-text-1);
}

.banner-message {
  margin: 0 0 0.75rem 0;
  line-height: 1.6;
  color: var(--vp-c-text-2);
}

.banner-link {
  display: inline-block;
  color: #1e88e5;
  font-weight: 500;
  text-decoration: none;
  transition: all 0.2s;
}

.banner-link:hover {
  color: #2196f3;
  text-decoration: underline;
}
</style>
