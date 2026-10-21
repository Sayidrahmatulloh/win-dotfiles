import { runWm } from '../../services/desktop/actions';
import './style.css';
import { Component } from 'solid-js';
import { GlazeWmOutput } from 'zebar';

interface WorkspaceProps {
  workspace: GlazeWmOutput['currentWorkspaces'][number];
  glazewm: GlazeWmOutput | null;
}

const Workspace: Component<WorkspaceProps> = (props) => {
  return (
    <button
      type="button"
      aria-label={'Workspace ' + (props.workspace.displayName ?? props.workspace.name)}
      classList={{
        workspace: true,
        focused: props.workspace.hasFocus,
        displayed: props.workspace.isDisplayed,
      }}
      onClick={() => runWm(props.glazewm, `focus --workspace ${props.workspace.name}`)}
      id={props.workspace.name}
    >
      <span class="workspace-icon">
        {props.workspace.name === 'web' ? (
          <img
            src="./assets/icons/icons8-brave-web-browser-32.png"
            alt=""
            class="i-brave"
            height="16"
            width="16"
          ></img>
        ) : (
          (props.workspace.displayName ?? props.workspace.name)
        )}
      </span>
    </button>
  );
};

export default Workspace;
