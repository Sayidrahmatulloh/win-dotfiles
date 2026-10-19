import { createSignal, createEffect, onCleanup, type Accessor } from 'solid-js';

export function useMediaMarquee(title: Accessor<string | null | undefined>) {
  let mediaTextRef: HTMLSpanElement | undefined;
  let animationFrameId: number | undefined;
  let startTimeoutId: number | undefined;

  const [scrollPosition, setScrollPosition] = createSignal(0);
  const [isHovering, setIsHovering] = createSignal(false);
  const [animationPhase, setAnimationPhase] = createSignal<{
    direction: 'forward' | 'backward';
    isPaused: boolean;
    startTime: number;
  }>({ direction: 'forward', isPaused: false, startTime: 0 });
  const [scrollDistance, setScrollDistance] = createSignal(0);

  const startScrolling = () => {
    if (!mediaTextRef || window.matchMedia('(prefers-reduced-motion: reduce)').matches) return;

    const textWidth = mediaTextRef.scrollWidth;
    const containerWidth = mediaTextRef.clientWidth;
    const distance = textWidth - containerWidth;

    if (distance <= 0) {
      setScrollPosition(0);
      return;
    }

    setScrollDistance(distance);
    setAnimationPhase({ direction: 'forward', isPaused: false, startTime: 0 });

    if (animationFrameId) {
      cancelAnimationFrame(animationFrameId);
    }
    animationFrameId = requestAnimationFrame(animate);
  };

  const animate = (currentTime: number) => {
    if (!isHovering()) {
      resetAnimation();
      return;
    }

    const phase = animationPhase();
    const pixelsPerSecond = 45;
    const scrollDuration = (scrollDistance() / pixelsPerSecond) * 1000;
    const pauseDuration = 1300;

    if (phase.startTime === 0) {
      setAnimationPhase({ ...phase, startTime: currentTime });
      animationFrameId = requestAnimationFrame(animate);
      return;
    }

    const elapsed = currentTime - phase.startTime;

    if (phase.isPaused) {
      if (elapsed >= pauseDuration) {
        const newDirection = phase.direction === 'forward' ? 'backward' : 'forward';
        setAnimationPhase({
          direction: newDirection,
          isPaused: false,
          startTime: currentTime,
        });
      }
    } else {
      const progress = Math.min(elapsed / scrollDuration, 1);

      if (phase.direction === 'forward') {
        setScrollPosition(-scrollDistance() * progress);
      } else {
        setScrollPosition(-scrollDistance() * (1 - progress));
      }

      if (progress >= 1) {
        setAnimationPhase({ ...phase, isPaused: true, startTime: currentTime });
      }
    }

    animationFrameId = requestAnimationFrame(animate);
  };

  const resetAnimation = () => {
    setScrollPosition(0);
    setAnimationPhase({ direction: 'forward', isPaused: false, startTime: 0 });
  };

  const handleMouseEnter = () => {
    setIsHovering(true);
    if (startTimeoutId) {
      clearTimeout(startTimeoutId);
    }
    startTimeoutId = window.setTimeout(startScrolling, 400);
  };

  const handleMouseLeave = () => {
    setIsHovering(false);
    if (animationFrameId) {
      cancelAnimationFrame(animationFrameId);
      animationFrameId = undefined;
    }
    if (startTimeoutId) {
      clearTimeout(startTimeoutId);
      startTimeoutId = undefined;
    }
    resetAnimation();
  };

  createEffect(() => {
    title();
    handleMouseLeave();
  });

  onCleanup(() => {
    if (animationFrameId) {
      cancelAnimationFrame(animationFrameId);
    }
    if (startTimeoutId) {
      clearTimeout(startTimeoutId);
    }
  });

  return {
    scrollPosition,
    start: handleMouseEnter,
    stop: handleMouseLeave,
    ref: (element: HTMLSpanElement) => {
      mediaTextRef = element;
    },
  };
}
