import StatusIcon from '../StatusIcon';
import {useUsageTone} from '../hooks/useUsageTone';
import { safely } from '../actions';
import { numberText } from '../format';
import "./style.css";
import { Component } from "solid-js";
import { MemoryOutput } from "zebar";
import * as zebar from "zebar";
import { useAnimatedClick } from "../hooks/useAnimatedClick";

interface MemoryStatusProps {
  memory: MemoryOutput | null;
}

const MemoryStatus: Component<MemoryStatusProps> = (props) => {
  const tone = useUsageTone(() => props.memory?.usage);

  const { isActive, handleClick } = useAnimatedClick();

  const handleMemoryClick = () => {
    handleClick();
    void safely(() => zebar.shellExec("taskmgr"), "Task Manager");
  };
  return (
    <button data-tooltip={"Memory usage: " + numberText(props.memory?.usage) + "% — open Task Manager"} type="button" aria-label="Open Task Manager: memory"
      classList={{
        memory: true,
        "usage-warning": tone() === "warning",
        "usage-critical": tone() === "critical",
        "clicked-animated": isActive(),
      }}
      onClick={handleMemoryClick}
    >
      <span class="content">
        <StatusIcon name="memory"/>
        <span class="ram-summary">{numberText((props.memory?.usedMemory ?? NaN) / 1024 ** 3)}/{numberText((props.memory?.totalMemory ?? NaN) / 1024 ** 3)} GB</span>
      </span>
    </button>
  );
};

export default MemoryStatus;

