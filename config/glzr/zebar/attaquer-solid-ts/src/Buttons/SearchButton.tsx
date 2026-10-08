import StatusIcon from '../StatusIcon';
import { runWidgetAction } from '../actions';
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
    void runWidgetAction(props.glazewm, 'OpenWindowsSearch')
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
