import React from 'react';
import Icon from './Icon';
import {safeAction} from '../utils';
export default function Shortcut({commandRunner,commands,icon,name}) {
 return <button type="button" className="icon-button shortcut" title={name} aria-label={'Open '+name} onClick={() => safeAction(async () => { for(const command of commands) await commandRunner(command); })}><Icon name={icon}/></button>;
}
