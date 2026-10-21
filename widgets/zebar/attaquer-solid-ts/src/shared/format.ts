export const finite = (value: unknown): value is number =>
  typeof value === 'number' && Number.isFinite(value);
export const percent = (value: unknown) => (finite(value) ? Math.min(100, Math.max(0, value)) : 0);
export const numberText = (value: unknown) => (finite(value) ? String(Math.round(value)) : '—');
export const durationText = (value: unknown) => {
  if (!finite(value) || value < 0) return 'Time unavailable';
  const minutes = Math.floor(value / 60000);
  return minutes < 1
    ? 'Less than 1 min left'
    : (minutes >= 60 ? Math.floor(minutes / 60) + 'h ' : '') + (minutes % 60) + 'min left';
};
export const progressPercent = (position: unknown, total: unknown) =>
  finite(position) && finite(total) && total > 0 ? percent((position / total) * 100) : 0;
