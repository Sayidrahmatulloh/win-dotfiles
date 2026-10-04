import React from 'react';
import {safeAction} from '../utils';
export default function Shortcut({commandRunner,commands,iconClass,name}) {
 return <button type="button" className="shortcut clean-button" aria-label={'Open '+name} onClick={() => safeAction(async () => { for(const command of commands) await commandRunner(command); })}><i className={'nf '+iconClass}/><span>{name}</span></button>;
}
