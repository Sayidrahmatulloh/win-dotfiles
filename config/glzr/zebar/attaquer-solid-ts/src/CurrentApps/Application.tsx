import { appIcons } from './icons';
import { runWidgetAction } from '../actions';
import "./style.css"
import { Component } from "solid-js"
import { GlazeWmOutput } from "zebar"
import { Window } from "glazewm"
import { useAnimatedClick } from "../hooks/useAnimatedClick"

interface ApplicationProps {
  glazewm: GlazeWmOutput | null
  window: Window
}

const Application: Component<ApplicationProps> = (props) => {
  const { isActive, handleClick } = useAnimatedClick()

  const handleAppClick = () => {
    handleClick()
    void runWidgetAction(props.glazewm, 'FocusWindow', props.window.handle)
  }

  return (
    <button type="button" aria-label={"Focus " + props.window.title}
      classList={{
        element: true,
        focus: props.window.hasFocus,
        "clicked-animated": isActive(),
      }}
      title={props.window.title}
      onClick={handleAppClick}
    >
      <img class="app-icon" alt="" src={appIcons[props.window.processName] ?? appIcons.process} onError={e => { e.currentTarget.onerror = null; e.currentTarget.src = appIcons.process; }}/>
    </button>
  )
}

export default Application
