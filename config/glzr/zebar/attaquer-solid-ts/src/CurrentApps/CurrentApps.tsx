import './style.css';
import { Component, For, createMemo } from 'solid-js';
import { GlazeWmOutput } from 'zebar';
import type { Window } from 'glazewm';
import Application from './Application';
type Child = GlazeWmOutput['allWorkspaces'][number]['children'][number];
export function flattenWindows(children: Child[]): Window[] {
  return children.flatMap(child => child.type === 'window' ? [child] : child.type === 'split' ? flattenWindows(child.children) : []);
}
const CurrentApps: Component<{glazewm: GlazeWmOutput | null}> = props => {
  const windows = createMemo(() => flattenWindows(props.glazewm?.displayedWorkspace?.children ?? []));
  return <div class="template current-apps"><For each={windows()}>{window => <div class="app-entry"><Application window={window} glazewm={props.glazewm}/></div>}</For></div>;
};
export default CurrentApps;
