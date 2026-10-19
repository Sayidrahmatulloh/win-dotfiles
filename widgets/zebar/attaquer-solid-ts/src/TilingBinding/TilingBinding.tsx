import { runWm } from '../actions';
import './style.css';
import { Component } from 'solid-js';
import { GlazeWmOutput } from 'zebar';

interface TilingBindingProps {
  glazewm: GlazeWmOutput | null;
}

const TilingBinding: Component<TilingBindingProps> = (props) => {
  return (
    <>
      <div class="template">
        <button
          type="button"
          aria-label="Toggle tiling direction"
          class={`toggle-tiling-direction 
                    ${props.glazewm?.tilingDirection === 'horizontal' ? 'horizontal' : 'vertical'}`}
          onClick={() => {
            runWm(props.glazewm, 'toggle-tiling-direction');
          }}
        >
          <span class="tiling-direction"></span>
        </button>
      </div>
      <div class="template">
        {props.glazewm?.bindingModes.map((bindingMode) => (
          <span class="binding-mode">{bindingMode.displayName ?? bindingMode.name}</span>
        ))}
      </div>
    </>
  );
};

export default TilingBinding;
