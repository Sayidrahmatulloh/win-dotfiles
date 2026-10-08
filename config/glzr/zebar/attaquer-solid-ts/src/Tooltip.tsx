import {createSignal,onMount,onCleanup,Show} from 'solid-js';
import {LogicalSize} from '@tauri-apps/api/dpi';
import {currentWidget} from 'zebar';
import './tooltip.css';

export default function Tooltip(){
 const [text,setText]=createSignal('');
 const [left,setLeft]=createSignal(8);
 const [inline,setInline]=createSignal(false);
 let active:HTMLElement|null=null, timer:ReturnType<typeof setTimeout>|undefined;
 let blocked:HTMLElement|null=null;
 const hoverDelay=700;
 let box:HTMLDivElement|undefined, revision=0, disposed=false;
 let queue:Promise<unknown>=Promise.resolve();
 let expanded=false;
 const windowApi=()=>currentWidget().tauriWindow;
 function resize(height:number){
  const result=queue.then(async()=>{
   await windowApi().setSize(new LogicalSize(window.innerWidth,height));
   expanded=height>40;
  });
  queue=result.catch(()=>{});
  return result;
 }
 function hide(){
  revision++;clearTimeout(timer);active?.removeAttribute('aria-describedby');active=null;setText('');
  if(expanded)void resize(40).catch(error=>console.warn('Tooltip window reset',error));
 }
 async function show(target:HTMLElement,version:number){
  try{await resize(120);setInline(false)}
  catch(error){console.warn('Tooltip uses inline fallback',error);setInline(true)}
  if(disposed||version!==revision||active!==target){
   if(expanded&&!active)void resize(40).catch(()=>{});
   return;
  }
  setText(target.dataset.tooltip??'');
  target.setAttribute('aria-describedby','bar-tooltip');
  const rect=target.getBoundingClientRect();
  const width=box?.getBoundingClientRect().width??240;
  setLeft(Math.max(8,Math.min(window.innerWidth-width-8,rect.left+rect.width/2-width/2)));
 }
 function enter(event:Event){
  const target=(event.target as Element)?.closest<HTMLElement>('[data-tooltip]');
  if(!target||!target.closest('.app')||!target.dataset.tooltip){hide();return}
  if(target===blocked)return;
  if(event instanceof PointerEvent&&(event.pointerType!=='mouse'||event.buttons!==0)){hide();return}
  if(target===active)return;
  hide();active=target;
  const version=revision;
  timer=setTimeout(()=>{void show(target,version)},hoverDelay);
 }
 function leave(event:Event){
  const related=(event as MouseEvent|FocusEvent).relatedTarget as Node|null;
  if(event.type==='pointerout'&&blocked&&(!related||!blocked.contains(related)))blocked=null;
  if(!active)return;
  if(!related||!active.contains(related))hide();
 }
 function dismiss(event:Event){
  blocked=(event.target as Element)?.closest<HTMLElement>('[data-tooltip]')??null;
  hide();
 }
 function move(event:PointerEvent){if(event.clientY>=40)hide()}
 function keyboard(event:KeyboardEvent){
  if(event.key==='Tab')blocked=null;
  if(event.key==='Escape')hide();
  if(event.key==='Enter'||event.key===' ')dismiss(event);
 }
 let observer:MutationObserver|undefined;
 onMount(()=>{
  document.addEventListener('pointerover',enter);
  document.addEventListener('pointerout',leave);
  document.addEventListener('focusin',enter);
  document.addEventListener('focusout',leave);
  document.addEventListener('pointerdown',dismiss);
  document.addEventListener('click',dismiss);
  document.addEventListener('pointermove',move);
  document.addEventListener('keydown',keyboard);
  window.addEventListener('blur',hide);
  document.documentElement.addEventListener('pointerleave',hide);
  observer=new MutationObserver(()=>{
   if(active&&!active.isConnected)hide();
   else if(active&&text())setText(active.dataset.tooltip??'');
  });
  observer.observe(document.querySelector('.app')!,{subtree:true,childList:true,attributes:true,attributeFilter:['data-tooltip']});
 });
 onCleanup(()=>{
  disposed=true;hide();observer?.disconnect();
  document.removeEventListener('pointerover',enter);
  document.removeEventListener('pointerout',leave);
  document.removeEventListener('focusin',enter);
  document.removeEventListener('focusout',leave);
  document.removeEventListener('pointerdown',dismiss);
  document.removeEventListener('click',dismiss);
  document.removeEventListener('pointermove',move);
  document.removeEventListener('keydown',keyboard);
  window.removeEventListener('blur',hide);
  document.documentElement.removeEventListener('pointerleave',hide);
 });
 return <Show when={text()}><div id="bar-tooltip" ref={box} role="tooltip" class="bar-tooltip" classList={{'bar-tooltip-inline':inline()}} style={{left:left()+'px'}}>{text()}</div></Show>;
}
