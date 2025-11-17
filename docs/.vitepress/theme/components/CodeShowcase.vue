<template>
  <div class="code-showcase">
    <div class="showcase-header">
      <div class="showcase-tabs">
        <button
          v-for="tab in tabs"
          :key="tab.id"
          :class="['tab', { active: activeTab === tab.id }]"
          @click="activeTab = tab.id"
        >
          {{ tab.label }}
        </button>
      </div>
    </div>
    <div class="showcase-content">
      <slot :name="activeTab" />
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'

const props = defineProps<{
  tabs: Array<{ id: string; label: string }>
}>()

const activeTab = ref(props.tabs[0]?.id || '')
</script>

<style scoped>
.code-showcase {
  border-radius: 12px;
  overflow: hidden;
  border: 1px solid var(--vp-c-divider);
  background: var(--vp-c-bg);
  margin: 2rem 0;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1),
              0 2px 4px -1px rgba(0, 0, 0, 0.06);
}

.showcase-header {
  background: var(--vp-c-bg-soft);
  border-bottom: 1px solid var(--vp-c-divider);
  padding: 0.5rem 1rem;
}

.showcase-tabs {
  display: flex;
  gap: 0.5rem;
}

.tab {
  padding: 0.5rem 1rem;
  border: none;
  background: transparent;
  color: var(--vp-c-text-2);
  cursor: pointer;
  border-radius: 6px;
  font-size: 0.875rem;
  font-weight: 500;
  transition: all 0.2s;
}

.tab:hover {
  background: var(--vp-c-bg);
  color: var(--vp-c-text-1);
}

.tab.active {
  background: var(--vp-c-brand-1);
  color: white;
}

.showcase-content {
  padding: 1.5rem;
}

.showcase-content :deep(pre) {
  margin: 0;
  border-radius: 8px;
}
</style>
