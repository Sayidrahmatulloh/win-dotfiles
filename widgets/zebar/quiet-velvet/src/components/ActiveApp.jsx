import React from 'react';
import Icon from './Icon';
export default function ActiveApp({output}) {
 const window = output.glazewm?.allWindows?.find(window => window.hasFocus);
 if (!window) return null;
 return <div className="active-app" title={window.title}><Icon name="app"/><span>{window.title || window.processName}</span></div>;
}
