import StatusIcon from '../StatusIcon';
import { safely } from '../actions';
import "./style.css";
import { Component } from "solid-js";
import { DateOutput } from "zebar";
import * as zebar from "zebar";
import { useAnimatedClick } from "../hooks/useAnimatedClick";

interface TimeStatusProps {
  date: DateOutput | null;
}

const TimeStatus: Component<TimeStatusProps> = (props) => {
  const { isActive, handleClick } = useAnimatedClick();

  const handleTimeClick = () => {
    handleClick();
    void safely(() => zebar.shellExec("explorer.exe", ["ms-actioncenter://"]), "Notification center");
  };

  return (
    <button type="button" aria-label="Open notification center"
      class={`date ${isActive() ? "clicked-animated" : ""}`}
      data-tooltip={props.date?.formatted}
      onClick={handleTimeClick}
    >
      <span class="content">
        <StatusIcon name="clock"/>
        <span class="time">{props.date?.formatted?.substring(0, 5)}</span>
      </span>
    </button>
  );
};

export default TimeStatus;

