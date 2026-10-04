import StatusIcon from '../StatusIcon';
import { runWm } from '../actions';
import "./style.css"
import { Component } from "solid-js"
import { GlazeWmOutput } from "zebar"
import { useAnimatedClick } from "../hooks/useAnimatedClick"

interface SearchButtonProps {
  glazewm: GlazeWmOutput | null
}

const SearchButton: Component<SearchButtonProps> = (props) => {
  const { isActive, handleClick } = useAnimatedClick()

  const handleSearchClick = () => {
    handleClick()
    runWm(props.glazewm, 
      "shell-exec %userprofile%/scoop/apps/autohotkey/current/v2/AutoHotkey64.exe %userprofile%/.glzr/zebar/attaquer-solid-ts/dist/assets/scripts/OpenWindowsSearch.ahk",
    )
  }
  return (
    <button type="button" aria-label="Windows search" data-tooltip="Open Windows search"
      class={`search ${isActive() ? "clicked-animated" : ""}`}
      onClick={handleSearchClick}
    >
      <span class="content">
        <StatusIcon name="search"/>
      </span>
    </button>
  )
}

export default SearchButton
