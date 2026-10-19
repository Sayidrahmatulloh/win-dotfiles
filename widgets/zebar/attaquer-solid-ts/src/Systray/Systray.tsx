import { safely } from '../actions';
import './style.css';
import { Component, For, createSignal } from 'solid-js';
import { SystrayOutput, GlazeWmOutput } from 'zebar';
import { useAnimatedClick } from '../hooks/useAnimatedClick';

interface SystrayProps {
  systray: SystrayOutput | null;
  glazewm: GlazeWmOutput | null;
}

const Systray: Component<SystrayProps> = (props) => {
  const [expanded, setExpanded] = createSignal(false);

  return (
    <>
      <div class="systray-container">
        {props.systray?.icons && (
          <div class={`systray ${expanded() ? 'expanded' : ''}`}>
            <For each={props.systray?.icons}>
              {(icon) => {
                const { isActive: isIconActive, handleClick: handleIconClick } = useAnimatedClick();
                return (
                  <button
                    type="button"
                    aria-label={icon.tooltip || 'Tray application'}
                    tabIndex={expanded() ? 0 : -1}
                    class="systray-icon-container"
                    title={icon.tooltip}
                    onClick={(e) => {
                      e.preventDefault();
                      handleIconClick();
                      void safely(() => props.systray?.onLeftClick(icon.id), 'Tray click');
                    }}
                    onContextMenu={(e) => {
                      e.preventDefault();
                      handleIconClick();
                      void safely(() => props.systray?.onRightClick(icon.id), 'Tray menu');
                    }}
                  >
                    <img
                      alt=""
                      class={`systray-icon ${isIconActive() ? 'clicked-animated' : ''}`}
                      src={icon.iconUrl}
                    />
                  </button>
                );
              }}
            </For>
          </div>
        )}
        <button
          type="button"
          aria-label="Show or hide tray icons"
          aria-expanded={expanded()}
          class={`systray-toggle ${expanded() == true ? 'expanded' : 'tucked'}`}
          onClick={() => setExpanded(!expanded())}
        >
          <span class="content"></span>
        </button>
      </div>
    </>
  );
};

export default Systray;
