import { Component, Show } from 'solid-js';
const paths: Record<string, string> = {
  cpu: 'M8 5h8a3 3 0 0 1 3 3v8a3 3 0 0 1-3 3H8a3 3 0 0 1-3-3V8a3 3 0 0 1 3-3ZM9 9h6v6H9ZM9 2v3m6-3v3M9 19v3m6-3v3M2 9h3m-3 6h3m14-6h3m-3 6h3',
  memory: 'M3 6h18v12H3ZM7 10v4m5-4v4m5-4v4M6 18v3m4-3v3m4-3v3m4-3v3',
  wifi: 'M2 8a16 16 0 0 1 20 0M5 12a11 11 0 0 1 14 0M8 16a6 6 0 0 1 8 0M12 20h.01',
  offline:
    'M2 2l20 20M8 6a16 16 0 0 1 14 2M2 8l2-1m1 5 2-1m5 0a11 11 0 0 1 7 1M8 16a6 6 0 0 1 8 0M12 20h.01',
  ethernet: 'M7 3h10v8H7ZM12 11v5M4 20v-4h16v4M12 16v4',
  volume: 'M11 4 5 9H2v6h3l6 5ZM15 8a6 6 0 0 1 0 8m3-11a10 10 0 0 1 0 14',
  mute: 'M11 4 5 9H2v6h3l6 5ZM16 9l6 6m0-6-6 6',
  battery: 'M4 6h14a2 2 0 0 1 2 2v8a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2ZM22 10v4',
  clock: 'M12 3a9 9 0 1 0 0 18 9 9 0 0 0 0-18ZM12 7v5l3 2',
  search: 'M10 3a7 7 0 1 0 0 14 7 7 0 0 0 0-14ZM15 15l6 6',
};
const StatusIcon: Component<{ name: string; level?: number; charging?: boolean }> = (props) => (
  <svg
    class="status-icon"
    width="18"
    height="18"
    viewBox="0 0 24 24"
    fill="none"
    stroke="currentColor"
    stroke-width="1.7"
    stroke-linecap="round"
    stroke-linejoin="round"
    aria-hidden="true"
  >
    <path d={paths[props.name] ?? paths.offline} />
    <Show when={props.name === 'battery'}>
      <Show
        when={props.charging}
        fallback={
          <rect
            x="5"
            y="9"
            width={(12 * Math.max(0, Math.min(100, props.level ?? 0))) / 100}
            height="6"
            rx=".5"
            fill="currentColor"
            stroke="none"
          />
        }
      >
        <path d="m13 8-4 5h4l-2 3" />
      </Show>
    </Show>
  </svg>
);
export default StatusIcon;
