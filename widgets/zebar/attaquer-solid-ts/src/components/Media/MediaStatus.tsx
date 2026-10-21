import { useMediaMarquee } from './useMediaMarquee';
import { safely } from '../../services/desktop/actions';
import { progressPercent } from '../../shared/format';
import './style.css';
import { Component } from 'solid-js';
import { MediaOutput } from 'zebar';

interface MediaStatusProps {
  media: MediaOutput | null;
}

const MediaStatus: Component<MediaStatusProps> = (props) => {
  const {
    scrollPosition,
    start: handleMouseEnter,
    stop: handleMouseLeave,
    ref: setTextElement,
  } = useMediaMarquee(() => props.media?.currentSession?.title);

  const MediaIcons: Record<string, import('solid-js').JSX.Element> = {
    media: <img alt="" src="./assets/icons/icons8-musical-note-32.png" height={23} width={23} />,
    Brave: <img alt="" src="./assets/icons/icons8-brave-32.png" height={23} width={23} />,
    'Spotify.exe': <img alt="" src="./assets/icons/icons8-spotify-32.png" height={23} width={23} />,
  };

  return (
    <>
      {props.media?.currentSession && (
        <div
          class={`template media`}
          title={[props.media?.currentSession?.title, props.media?.currentSession?.artist]
            .filter(Boolean)
            .join(' — ')}
          onMouseEnter={handleMouseEnter}
          onMouseLeave={handleMouseLeave}
          onFocusIn={handleMouseEnter}
          onFocusOut={handleMouseLeave}
        >
          {MediaIcons[props.media?.currentSession.sessionId] ?? MediaIcons['media']}
          <button
            type="button"
            aria-label="Previous track"
            class="prev"
            onClick={() => {
              void safely(() => props.media?.previous(), 'Previous track');
            }}
          >
            <span class="content">󰒮</span>
          </button>
          <button
            type="button"
            aria-label="Play or pause"
            class="play-pause"
            onClick={() => {
              void safely(() => props.media?.togglePlayPause(), 'Play or pause');
            }}
          >
            <span class="content">{props.media?.currentSession.isPlaying ? '󰏤' : '󰐊'}</span>
          </button>
          <button
            type="button"
            aria-label="Next track"
            class="next"
            onClick={() => {
              void safely(() => props.media?.next(), 'Next track');
            }}
          >
            <span class="content">󰒭</span>
          </button>
          <div class="media-text">
            <span ref={setTextElement} style={{ transform: `translateX(${scrollPosition()}px)` }}>
              {props.media?.currentSession?.title} |&#x20;
              {props.media?.currentSession?.artist}
            </span>
          </div>
          <div
            class="progress-play"
            style={`width: ${progressPercent(props.media?.currentSession?.position, props.media?.currentSession?.endTime)}%`}
          ></div>
        </div>
      )}
    </>
  );
};

export default MediaStatus;
