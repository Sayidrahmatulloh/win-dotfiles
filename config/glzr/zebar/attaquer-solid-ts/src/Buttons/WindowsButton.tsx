import { runWm } from '../actions';
import "./style.css"
import { Component } from "solid-js"
import { GlazeWmOutput } from "zebar"
import { useAnimatedClick } from "../hooks/useAnimatedClick"

interface WindowsButtonProps {
  glazewm: GlazeWmOutput | null
}

const WindowsButton: Component<WindowsButtonProps> = (props) => {
  const { isActive, handleClick } = useAnimatedClick()

  const handleWindowsClick = () => {
    handleClick()
    runWm(props.glazewm, 
      "shell-exec %userprofile%/scoop/apps/autohotkey/current/v2/AutoHotkey64.exe %userprofile%/.glzr/zebar/attaquer-solid-ts/dist/assets/scripts/OpenStartMenu.ahk",
    )
  }
  return (
    <button type="button" aria-label="Start menu" data-tooltip="Open Start menu"
      class={`logo ${isActive() ? "clicked-animated" : ""}`}
      onClick={handleWindowsClick}
    >
      <span class="content"></span>
    </button>
  )
}

export default WindowsButton
