<template>
  <div class="liquid-glass-wrapper" :style="wrapperStyle">
    <!-- Glass Container -->
    <div
      ref="containerRef"
      class="liquid-glass-container"
      :style="containerStyle"
      @mousedown="onMouseDown"
    >
      <div class="glass-content-wrapper">
        <slot></slot>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onUnmounted } from 'vue';

const props = defineProps({
  draggable: { type: Boolean, default: false },
  borderRadius: { type: String, default: '24px' },
  blur: { type: String, default: '20px' }, // Follows iOS system blur specification
  opacity: { type: Number, default: 0.08 }  // Pure, thin glass transparency
});

const containerRef = ref(null);
const position = ref({ x: 0, y: 0 });

// Dragging support (for widget style panels)
let isDragging = false;
let startX, startY, initialX, initialY;

const onDragMove = (e) => {
  if (isDragging && props.draggable) {
    const deltaX = e.clientX - startX;
    const deltaY = e.clientY - startY;
    position.value = { x: initialX + deltaX, y: initialY + deltaY };
  }
};

const onDragEnd = () => {
  isDragging = false;
  document.removeEventListener('mousemove', onDragMove);
  document.removeEventListener('mouseup', onDragEnd);
};

const onMouseDown = (e) => {
  if (!props.draggable) return;
  
  // Ignore clicks on buttons/inputs
  if (e.target.closest('button, input, textarea, a')) return;

  isDragging = true;
  startX = e.clientX;
  startY = e.clientY;
  initialX = position.value.x; 
  initialY = position.value.y;
  
  document.addEventListener('mousemove', onDragMove);
  document.addEventListener('mouseup', onDragEnd);
};

onUnmounted(() => {
  document.removeEventListener('mousemove', onDragMove);
  document.removeEventListener('mouseup', onDragEnd);
});

const wrapperStyle = computed(() => {
  return {
    width: '100%',
    height: '100%',
    position: 'relative',
    display: 'flex',
    flexDirection: 'column',
    flex: '1',
    minHeight: '0'
  };
});

const containerStyle = computed(() => {
  // Apple Liquid Glass combines 20px blur with high saturation (1.8) and slight contrast
  const backdropFilterValue = `blur(${props.blur}) saturate(1.8) contrast(1.02) brightness(1.02)`;

  const style = {
    width: '100%',
    height: '100%',
    borderRadius: props.borderRadius,
    backdropFilter: backdropFilterValue,
    WebkitBackdropFilter: backdropFilterValue,
    zIndex: 10,
    backgroundColor: `rgba(255, 255, 255, ${props.opacity})`,
    border: '1px solid rgba(255, 255, 255, 0.08)',
    boxShadow: '0 8px 32px 0 rgba(0, 0, 0, 0.25)',
    position: props.draggable ? 'absolute' : 'relative',
    boxSizing: 'border-box',
    overflow: 'hidden',
    display: 'flex',
    flexDirection: 'column',
    flex: '1',
    minHeight: '0',
    isolation: 'isolate'
  };
  
  if (props.draggable) {
    style.transform = `translate(${position.value.x}px, ${position.value.y}px)`;
    style.cursor = isDragging ? 'grabbing' : 'grab';
  }
  
  return style;
});
</script>

<style scoped>
.liquid-glass-wrapper {
  display: flex;
  flex-direction: column;
  flex: 1;
  min-height: 0;
}

.liquid-glass-container {
  transition: 
    border-color 0.3s ease, 
    box-shadow 0.3s ease, 
    background-color 0.3s ease;
}

.glass-content-wrapper {
  position: relative;
  z-index: 2;
  width: 100%;
  height: 100%;
  display: flex;
  flex-direction: column;
  flex: 1;
  min-height: 0;
}

/* Subtle outer glaze and dynamic light reflection from Apple's design resources */
.liquid-glass-container::before {
  content: '';
  position: absolute;
  inset: 0;
  z-index: 0;
  pointer-events: none;
  border-radius: inherit;
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.12) 0%, rgba(255, 255, 255, 0.01) 50%, transparent 100%);
  opacity: 0.85;
}

.liquid-glass-container:hover {
  border-color: rgba(255, 255, 255, 0.16);
  box-shadow: 0 12px 40px 0 rgba(0, 0, 0, 0.35);
  background-color: rgba(255, 255, 255, 0.1);
}
</style>
