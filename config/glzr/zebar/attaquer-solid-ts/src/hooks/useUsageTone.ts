import {createEffect,createMemo,createSignal,onCleanup} from 'solid-js';
export function useUsageTone(read:()=>number|undefined){
 const desired=createMemo(()=>{const value=read();return value==null||!Number.isFinite(value)?'normal':value>=95?'critical':value>=85?'warning':'normal'});
 const [tone,setTone]=createSignal('normal');
 createEffect(()=>{const target=desired();if(target==='normal'){setTone('normal');return}const timer=setTimeout(()=>setTone(target),10000);onCleanup(()=>clearTimeout(timer));});
 return tone;
}
