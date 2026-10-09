import React from 'react';
const paths = {
 windows: <><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/></>,
 terminal: <><path d="m5 7 5 5-5 5M13 17h6"/><rect x="2" y="3" width="20" height="18" rx="4"/></>,
 globe: <><circle cx="12" cy="12" r="9"/><ellipse cx="12" cy="12" rx="4" ry="9"/><path d="M3 12h18"/></>,
 search: <><circle cx="10.5" cy="10.5" r="6.5"/><path d="m16 16 5 5"/></>,
 settings: <><path d="M4 7h16M4 17h16"/><circle cx="9" cy="7" r="3"/><circle cx="16" cy="17" r="3"/></>,
 cpu: <><rect x="6" y="6" width="12" height="12" rx="3"/><path d="M9 2v4m6-4v4M9 18v4m6-4v4M2 9h4m-4 6h4m12-6h4m-4 6h4"/></>,
 memory: <><rect x="3" y="6" width="18" height="12" rx="3"/><path d="M7 10v4m5-4v4m5-4v4M7 18v3m5-3v3m5-3v3"/></>,
 battery: <><rect x="2" y="6" width="18" height="12" rx="3"/><path d="M23 10v4M6 10v4m4-4v4m4-4v4"/></>,
 sun: <><circle cx="12" cy="12" r="4"/><path d="M12 2v2m0 16v2M2 12h2m16 0h2M5 5l1.5 1.5m11 11L19 19M5 19l1.5-1.5m11-11L19 5"/></>,
 cloud: <path d="M7 18a5 5 0 1 1 .5-10A7 7 0 0 1 21 12a3 3 0 0 1-1 6Z"/>,
 app: <><rect x="3" y="4" width="18" height="16" rx="3"/><path d="M3 9h18M7 6.5h.01"/></>,
 music: <><path d="M9 18V5l11-2v13M9 8l11-2"/><circle cx="6" cy="18" r="3"/><circle cx="17" cy="16" r="3"/></>,
 play: <path d="m9 5 11 7-11 7Z"/>, pause: <><path d="M8 5v14M16 5v14"/></>,
 previous: <><path d="m17 5-10 7 10 7ZM4 5v14"/></>, next: <><path d="m7 5 10 7-10 7ZM20 5v14"/></>,
 horizontal: <><path d="M4 12h16m-4-4 4 4-4 4M8 8l-4 4 4 4"/></>,
 vertical: <><path d="M12 4v16m-4-4 4 4 4-4M8 8l4-4 4 4"/></>,
 close: <path d="m6 6 12 12M6 18 18 6"/>, warning: <><path d="m12 3 10 18H2Z"/><path d="M12 9v5m0 3h.01"/></>
};
export default function Icon({name, className = ''}) {
 return <svg className={`icon ${className}`} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round" aria-hidden="true">{paths[name] ?? paths.app}</svg>;
}
