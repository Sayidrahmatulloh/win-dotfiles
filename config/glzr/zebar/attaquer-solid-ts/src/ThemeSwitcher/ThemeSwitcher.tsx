import {createSignal,createEffect,onCleanup} from 'solid-js';
import './style.css';
import {currentWidget,shellExec} from 'zebar';
import {safely} from '../actions';
const key='zebar.theme.v1';
const themes=[{id:'green',label:'Green',accent:'#a6e22e',surface:'#a6e22e18'},{id:'blue',label:'Blue',accent:'#96c5ff',surface:'#96c5ff20'},{id:'purple',label:'Purple',accent:'#c4a7e7',surface:'#c4a7e720'}];
function valid(value:string|null){return themes.find(theme=>theme.id===value)?.id ?? 'green'}
function stored(){try{return valid(localStorage.getItem(key))}catch{return 'green'}}
export default function ThemeSwitcher(){
 const [selected,setSelected]=createSignal(stored());
 let disc:SVGSVGElement|undefined;
 let motion:Animation|undefined;
 let updates:Promise<unknown>=Promise.resolve();
 const current=()=>themes.find(theme=>theme.id===selected())!;
 const next=()=>themes[(themes.findIndex(theme=>theme.id===selected())+1)%themes.length];
 createEffect(()=>{
  const theme=current();
  document.documentElement.style.setProperty('--theme-accent',theme.accent);
  document.documentElement.style.setProperty('--theme-active-bg',theme.surface);
  updates=updates.then(()=>safely(async()=>{
   const script=currentWidget().htmlPath.replace(/\\/g,'/').replace(/\/[^/]*$/,'/assets/scripts/SetGlazeTheme.ps1');
   const result=await shellExec('powershell.exe',['-NoProfile','-NonInteractive','-ExecutionPolicy','Bypass','-WindowStyle','Hidden','-File',script,'-Theme',theme.id]);
   if(result.code!==0)throw new Error(result.stderr||'GlazeWM theme update failed');
  },'GlazeWM theme'));
 });
 function cycle(){
  const id=next().id;setSelected(id);
  try{localStorage.setItem(key,id)}catch(error){console.warn('Theme preference could not be saved',error)}
  motion?.cancel();
  if(!window.matchMedia('(prefers-reduced-motion: reduce)').matches){
   motion=disc?.animate?.([{transform:'rotate(0deg)'},{transform:'rotate(360deg)'}],{duration:500,easing:'ease-in-out'});
  }
 }
 function sync(event:StorageEvent){if(event.storageArea===localStorage&&(event.key===key||event.key===null))setSelected(event.key===null?'green':valid(event.newValue))}
 window.addEventListener('storage',sync);
 onCleanup(()=>{window.removeEventListener('storage',sync);motion?.cancel()});
 return <div class="theme-switcher">
  <button type="button" class="theme-trigger" aria-label={'Theme: '+current().label+'. Switch to '+next().label} data-tooltip={'Theme: '+current().label+' → '+next().label} onClick={cycle}>
   <svg ref={disc} class="theme-moon" aria-hidden="true" viewBox="0 0 24 24" fill="currentColor">
    <circle cx="12" cy="12" r="10"/>
    <g fill="#15191f" fill-opacity=".62">
     <circle cx="7.5" cy="10" r="3.6"/>
     <circle cx="13.5" cy="17" r="2.3"/>
     <circle cx="17.7" cy="9.7" r=".95"/>
    </g>
   </svg>
  </button>
 </div>;
}

