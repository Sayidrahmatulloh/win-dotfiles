import StatusIcon from '../StatusIcon';
import './style.css';
import {Component,createEffect,createSignal} from 'solid-js';
import {AudioOutput,GlazeWmOutput} from 'zebar';
import {Slider} from '@kobalte/core/slider';
import {safely} from '../actions';
import {percent} from '../format';
const VolumeStatus: Component<{audio:AudioOutput|null;glazewm:GlazeWmOutput|null}> = props => {
 const [volume,setVolume]=createSignal(0),[expanded,setExpanded]=createSignal(false);
 let trigger: HTMLButtonElement | undefined;
 let writes:Promise<unknown>=Promise.resolve();
 let revision=0;
 function changeVolume(value:number){
  const audio=props.audio,device=audio?.defaultPlaybackDevice;
  if(!audio||!device)return;
  const next=percent(value);
  if(next===volume())return;
  const version=++revision;
  setVolume(next);
  writes=writes.then(()=>safely(async()=>{
   try{await audio.setVolume(next,{deviceId:device.deviceId})}
   catch(error){if(version===revision)setVolume(percent(props.audio?.defaultPlaybackDevice?.volume));throw error}
  },'Set volume'));
 }
 function scrollVolume(event:WheelEvent){
  if(event.ctrlKey||!Number.isFinite(event.deltaY)||event.deltaY===0||!props.audio?.defaultPlaybackDevice)return;
  event.preventDefault();
  changeVolume(volume()+(event.deltaY<0?5:-5));
 }
 createEffect(()=>{setVolume(percent(props.audio?.defaultPlaybackDevice?.volume));if(!props.audio?.defaultPlaybackDevice)setExpanded(false)});
 const icon=()=>{const vol=props.audio?.defaultPlaybackDevice?.isMuted?0:volume();return vol>80?3:vol>40?2:vol>0?1:0};
 return <>{props.audio?.defaultPlaybackDevice && <div class="template volume" onFocusOut={event=>{if(!event.currentTarget.contains(event.relatedTarget as Node|null))setExpanded(false)}} onKeyDown={event=>{if(event.key==='Escape'){setExpanded(false);trigger?.focus()}}}>
 <button ref={trigger} type="button" class="volume-icon" aria-label="Volume: scroll to adjust, click for slider" aria-expanded={expanded()} onWheel={scrollVolume} onClick={()=>setExpanded(!expanded())} data-tooltip={(props.audio?.defaultPlaybackDevice?.isMuted?'Muted · ':'')+'Volume: '+Math.round(volume())+'% · Scroll to adjust'}>
 <StatusIcon name={icon()===0?"mute":"volume"}/><span class="volume-text">{props.audio?.defaultPlaybackDevice?.isMuted?'Muted':Math.round(volume())+'%'}</span>
 </button>
 <div class="volume-slider" hidden={!expanded()}>
 <Slider class="SliderRoot expanded" aria-label="Volume" disabled={!expanded()} step={2} minValue={0} maxValue={100} value={[volume()]} onChange={([value])=>changeVolume(value)}>
 <Slider.Track class="SliderTrack"><Slider.Fill class="SliderRange"/><Slider.Thumb class="SliderThumb"><Slider.Input/></Slider.Thumb></Slider.Track>
 </Slider></div></div>}</>;
};
export default VolumeStatus;

