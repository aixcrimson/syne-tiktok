<template>
  <div class="liquid-glass-wrapper" :style="wrapperStyle">
    <!-- SVG Filter -->
    <svg v-if="distortion" width="0" height="0" class="liquid-glass-svg">
      <defs>
        <filter :id="`${id}_filter`" x="-20%" y="-20%" width="140%" height="140%">
          <feImage :id="`${id}_map`" :width="internalWidth" :height="internalHeight" preserveAspectRatio="none" />
          <feDisplacementMap 
            in="SourceGraphic" 
            :in2="`${id}_map`" 
            xChannelSelector="R" 
            yChannelSelector="G" 
          />
        </filter>
      </defs>
    </svg>

    <!-- Glass Container -->
    <div
      ref="containerRef"
      class="liquid-glass-container"
      :style="containerStyle"
      @mousedown="onMouseDown"
    >
      <div class="glass-highlight" :style="highlightStyle"></div>
      <slot></slot>
    </div>

    <!-- Hidden Canvas for Displacement Map -->
    <canvas v-if="distortion" ref="canvasRef" :width="internalWidth * dpi" :height="internalHeight * dpi" style="display: none;"></canvas>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted, shallowRef } from 'vue';

const props = defineProps({
  interactive: { type: Boolean, default: true },
  draggable: { type: Boolean, default: false },
  borderRadius: { type: String, default: '24px' },
  blur: { type: String, default: '20px' }, // Strong blur for iOS style
  opacity: { type: Number, default: 0.15 },
  // SDF Shader Options
  edgeRefraction: { type: Number, default: 0.08 },
  distortion: { type: Boolean, default: true },
});

const dpi = window.devicePixelRatio || 1;
const id = 'lg-' + Math.random().toString(36).substring(2, 9);

const containerRef = ref(null);
const canvasRef = ref(null);
const context = shallowRef(null);

const internalWidth = ref(100);
const internalHeight = ref(100);

const position = ref({ x: 0, y: 0 });
const mouse = ref({ x: 0, y: 0, active: false });
let isThrottled = false;
let containerRect = null;

// SDF and math functions
function smoothStep(a, b, t) {
  t = Math.max(0, Math.min(1, (t - a) / (b - a)));
  return t * t * (3 - 2 * t);
}

function length(x, y) {
  return Math.sqrt(x * x + y * y);
}

function roundedRectSDF(x, y, width, height, radius) {
  const qx = Math.abs(x) - width + radius;
  const qy = Math.abs(y) - height + radius;
  return Math.min(Math.max(qx, qy), 0) + length(Math.max(qx, 0), Math.max(qy, 0)) - radius;
}

function texture(x, y) {
  return { type: 't', x, y };
}

// Fragment Shader - creates the iPhone Liquid/Magnifying glass edge
const fragment = (uv) => {
  const ix = uv.x - 0.5;
  const iy = uv.y - 0.5;
  
  let distortion = 0;
  if (props.interactive && mouse.value.active) {
    const mx = mouse.value.x - 0.5;
    const my = mouse.value.y - 0.5;
    const distToMouse = length(ix - mx, iy - my);
    // Create a localized droplet effect at mouse
    if (distToMouse < 0.2) {
      distortion = smoothStep(0.2, 0, distToMouse) * 0.1;
    }
  }

  // Create edge refraction (bending light near the container boundaries)
  const distanceToEdge = roundedRectSDF(ix, iy, 0.5 - props.edgeRefraction, 0.5 - props.edgeRefraction, 0.1);
  const displacement = smoothStep(0.2, 0, distanceToEdge) + distortion;
  const scaled = smoothStep(0, 1, displacement);
  
  return texture(ix * scaled + 0.5, iy * scaled + 0.5);
};

const updateShader = () => {
  if (!props.distortion) return;
  if (!context.value || !canvasRef.value || internalWidth.value <= 0 || internalHeight.value <= 0) return;

  // OPTIMIZATION: Cap the displacement map resolution (max 64px).
  // SVG feDisplacementMap uses hardware-accelerated GPU scaling, so 64px is plenty.
  const maxDimension = 64;
  let w, h;
  if (internalWidth.value > internalHeight.value) {
    w = maxDimension;
    h = Math.max(1, Math.round(maxDimension * (internalHeight.value / internalWidth.value)));
  } else {
    h = maxDimension;
    w = Math.max(1, Math.round(maxDimension * (internalWidth.value / internalHeight.value)));
  }
  
  if (w <= 0 || h <= 0) return;

  // Avoid unnecessary canvas resizes which reset canvas state
  if (canvasRef.value.width !== w || canvasRef.value.height !== h) {
    canvasRef.value.width = w;
    canvasRef.value.height = h;
  }

  const data = new Uint8ClampedArray(w * h * 4);
  const rawValues = [];
  let maxScale = 0;

  for (let i = 0; i < data.length; i += 4) {
    const x = (i / 4) % w;
    const y = Math.floor(i / 4 / w);
    const pos = fragment({ x: x / w, y: y / h });
    const dx = pos.x * w - x;
    const dy = pos.y * h - y;
    maxScale = Math.max(maxScale, Math.abs(dx), Math.abs(dy));
    rawValues.push(dx, dy);
  }

  maxScale *= 0.5;
  if (maxScale === 0) maxScale = 0.0001; 

  let index = 0;
  for (let i = 0; i < data.length; i += 4) {
    const r = rawValues[index++] / maxScale + 0.5;
    const g = rawValues[index++] / maxScale + 0.5;
    data[i] = r * 255;
    data[i + 1] = g * 255;
    data[i + 2] = 0;
    data[i + 3] = 255;
  }

  context.value.putImageData(new ImageData(data, w, h), 0, 0);
  
  const feImage = document.getElementById(`${id}_map`);
  if (feImage) {
    // Highly optimized encoding since the canvas is tiny (64px)
    feImage.setAttributeNS('http://www.w3.org/1999/xlink', 'href', canvasRef.value.toDataURL('image/jpeg', 0.5));
  }
  
  const feMap = document.querySelector(`filter#${id}_filter feDisplacementMap`);
  if (feMap) {
    // scale translation back to original dimensions
    const finalScale = (maxScale / w) * internalWidth.value;
    feMap.setAttribute('scale', finalScale.toString());
  }
};

// Dragging event handlers (bound only when actively dragging)
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
  isDragging = true;
  startX = e.clientX;
  startY = e.clientY;
  initialX = position.value.x; 
  initialY = position.value.y;
  
  document.addEventListener('mousemove', onDragMove);
  document.addEventListener('mouseup', onDragEnd);
};

// Hover / Interactive event handlers (bound to container, NOT globally)
const onMouseEnter = () => {
  if (props.interactive && containerRef.value) {
    // Cache the rect to avoid forced layout sync / thrashing in mousemove
    containerRect = containerRef.value.getBoundingClientRect();
    mouse.value.active = true;
  }
};

const onMouseMove = (e) => {
  if (props.interactive && containerRect) {
    mouse.value.x = (e.clientX - containerRect.left) / containerRect.width;
    mouse.value.y = (e.clientY - containerRect.top) / containerRect.height;
    
    if (!isThrottled) {
       isThrottled = true;
       requestAnimationFrame(() => {
         updateShader();
         isThrottled = false;
       });
    }
  }
};

const onMouseLeave = () => {
  mouse.value.active = false;
  containerRect = null;
  if (props.interactive) {
    requestAnimationFrame(updateShader);
  }
};

let resizeObserver;

const onResize = (entries) => {
  for (let entry of entries) {
    const { width, height } = entry.contentRect;
    if (width > 0 && height > 0) {
      internalWidth.value = width;
      internalHeight.value = height;
      if (mouse.value.active && containerRef.value) {
        containerRect = containerRef.value.getBoundingClientRect();
      }
      requestAnimationFrame(updateShader);
    }
  }
};

onMounted(() => {
  if (props.distortion && canvasRef.value) {
    context.value = canvasRef.value.getContext('2d', { willReadFrequently: true });
  }
  
  if (containerRef.value) {
    resizeObserver = new ResizeObserver(onResize);
    resizeObserver.observe(containerRef.value);
    
    // Bind interaction listeners directly to the container
    if (props.interactive) {
      containerRef.value.addEventListener('mouseenter', onMouseEnter);
      containerRef.value.addEventListener('mousemove', onMouseMove);
      containerRef.value.addEventListener('mouseleave', onMouseLeave);
    }
  }

  // Initial draw
  if (props.distortion) {
    requestAnimationFrame(updateShader);
  }
});

onUnmounted(() => {
  if (containerRef.value) {
    containerRef.value.removeEventListener('mouseenter', onMouseEnter);
    containerRef.value.removeEventListener('mousemove', onMouseMove);
    containerRef.value.removeEventListener('mouseleave', onMouseLeave);
  }
  document.removeEventListener('mousemove', onDragMove);
  document.removeEventListener('mouseup', onDragEnd);
  if (resizeObserver) resizeObserver.disconnect();
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
  const backdropFilterValue = props.distortion
    ? `url(#${id}_filter) blur(${props.blur}) saturate(1.8) contrast(1.1) brightness(1.1)`
    : `blur(${props.blur}) saturate(1.8) contrast(1.1) brightness(1.1)`;

  const style = {
    width: '100%',
    height: '100%',
    borderRadius: props.borderRadius,
    backdropFilter: backdropFilterValue,
    WebkitBackdropFilter: backdropFilterValue,
    zIndex: 10,
    backgroundColor: `rgba(255, 255, 255, ${props.opacity})`,
    border: '1px solid rgba(255, 255, 255, 0.25)',
    boxShadow: '0 8px 32px rgba(0, 0, 0, 0.2), inset 0 1px 2px rgba(255, 255, 255, 0.4)',
    position: props.draggable ? 'absolute' : 'relative',
    boxSizing: 'border-box',
    overflow: 'hidden',
    display: 'flex',
    flexDirection: 'column',
    flex: '1',
    minHeight: '0'
  };
  
  if (props.draggable) {
    style.transform = `translate(${position.value.x}px, ${position.value.y}px)`;
    style.cursor = isDragging ? 'grabbing' : 'grab';
  }
  
  return style;
});

const highlightStyle = computed(() => {
  if (!mouse.value.active || !props.interactive) return { opacity: 0 };
  
  return {
    position: 'absolute',
    top: `${mouse.value.y * 100}%`,
    left: `${mouse.value.x * 100}%`,
    width: '300px',
    height: '300px',
    transform: 'translate(-50%, -50%)',
    background: 'radial-gradient(circle, rgba(255,255,255,0.15) 0%, rgba(255,255,255,0) 70%)',
    pointerEvents: 'none',
    zIndex: 0,
    transition: 'opacity 0.3s ease'
  };
});
</script>

<style scoped>
.liquid-glass-wrapper {
  display: flex;
  flex-direction: column;
  flex: 1;
  min-height: 0;
}

.liquid-glass-svg {
  position: absolute;
  pointer-events: none;
  z-index: -1;
}

.liquid-glass-container {
  transition: box-shadow 0.3s ease, border 0.3s ease;
}

.glass-highlight {
  opacity: 1;
}
</style>
