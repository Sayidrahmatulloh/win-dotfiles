import './style.css';
import { Component } from 'solid-js';
import { GlazeWmOutput } from 'zebar';

interface WindowTitleProps {
  glazewm: GlazeWmOutput | null;
}

const WindowTitle: Component<WindowTitleProps> = (props) => {
  return (
    <>
      {props.glazewm?.allWindows.map(
        (item) =>
          'title' in item &&
          item.hasFocus && (
            <div class="current-window">
              {item.title &&
                (item.title.length > 90 ? item.title.slice(0, 90) + '...' : item.title)}
            </div>
          ),
      )}
    </>
  );
};

export default WindowTitle;
