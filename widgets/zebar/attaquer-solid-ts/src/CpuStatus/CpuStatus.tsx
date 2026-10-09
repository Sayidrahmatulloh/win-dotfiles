import StatusIcon from '../StatusIcon';
import {useUsageTone} from '../hooks/useUsageTone';
import { safely } from '../actions';
import { numberText } from '../format';
import "./style.css";
import { Component } from "solid-js";
import { CpuOutput } from "zebar";
import { GlazeWmOutput } from "zebar";
import * as zebar from "zebar";
import { useAnimatedClick } from "../hooks/useAnimatedClick";

interface CpuStatusProps {
  cpu: CpuOutput | null;
  glazewm: GlazeWmOutput | null;
}

const CpuStatus: Component<CpuStatusProps> = (props) => {
  const tone = useUsageTone(() => props.cpu?.usage);

  const { isActive, handleClick } = useAnimatedClick();

  const handleCpuClick = () => {
    handleClick();
    void safely(() => zebar.shellExec("taskmgr"), "Task Manager");
  };

  return (
    <button type="button" aria-label="Open Task Manager: CPU"
      data-tooltip={"CPU usage: " + numberText(props.cpu?.usage) + "% — open Task Manager"}
      classList={{
        cpu: true,
        "usage-warning": tone() === "warning",
        "usage-critical": tone() === "critical",
        "clicked-animated": isActive(),
      }}
      onClick={handleCpuClick}
    >
      <span class="content">
        <StatusIcon name="cpu"/>
        <span class="cpu-bar">{numberText(props.cpu?.usage)}%</span>
      </span>
    </button>
  );
};

export default CpuStatus;
