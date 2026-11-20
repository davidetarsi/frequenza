const {spawn}=require('node:child_process');
const fs=require('node:fs');
const path=require('node:path');
const {pathToFileURL}=require('node:url');
const os=require('node:os');
const root=path.resolve(__dirname,'../..');
const chrome=process.env.CHROME_BIN;
if(!chrome)throw Error('Set CHROME_BIN to a Chromium or Chrome executable');
const profile=fs.mkdtempSync(path.join(os.tmpdir(),'frequenza-pages-'));
const child=spawn(chrome,['--headless=new','--no-sandbox','--disable-dev-shm-usage','--remote-debugging-port=9341','--user-data-dir='+profile,'about:blank'],{stdio:'ignore'});
const pause=ms=>new Promise(r=>setTimeout(r,ms));
(async()=>{
 let socket;
 try {
  let targets;
  for(let i=0;i<60;i++) {try{targets=await(await fetch('http://127.0.0.1:9341/json/list')).json();if(targets.length)break;}catch{}await pause(100);}
  socket=new WebSocket(targets.find(t=>t.type==='page').webSocketDebuggerUrl);
  await new Promise((r,j)=>{socket.addEventListener('open',r,{once:true});socket.addEventListener('error',j,{once:true});});
  const pending=new Map();let next=0;
  socket.addEventListener('message',e=>{const d=JSON.parse(e.data);if(pending.has(d.id)){const {r,j}=pending.get(d.id);pending.delete(d.id);d.error?j(Error(JSON.stringify(d.error))):r(d.result);}});
  const send=(method,params={})=>new Promise((r,j)=>{const id=++next;pending.set(id,{r,j});socket.send(JSON.stringify({id,method,params}));});
  const evaluate=async expression=>{const d=await send('Runtime.evaluate',{expression,returnByValue:true,awaitPromise:true});if(d.exceptionDetails)throw Error(JSON.stringify(d.exceptionDetails));return d.result.value;};
  await send('Page.enable');await send('Runtime.enable');
  const base=pathToFileURL(root+path.sep).href;
  const capture=async (path,full=false)=>{let params={format:'png',captureBeyondViewport:true};if(full){const m=await send('Page.getLayoutMetrics');params.clip={x:0,y:0,width:m.cssContentSize.width,height:m.cssContentSize.height,scale:1};}const d=await send('Page.captureScreenshot',params);fs.writeFileSync(path,Buffer.from(d.data,'base64'));};
  await send('Emulation.setDeviceMetricsOverride',{width:1200,height:630,deviceScaleFactor:1,mobile:false});
  await send('Page.navigate',{url:base+'tool/preview/social.html'});await pause(400);
  await evaluate('Promise.all(Array.from(document.images).map(i=>i.decode()))');
  await capture(path.join(root,'docs/img/anteprima-radio-diario.png'));
  for(const width of [390,1280])for(const lang of ['it','en'])for(const theme of ['light','dark']) {
   await send('Emulation.setDeviceMetricsOverride',{width,height:900,deviceScaleFactor:1,mobile:width<500});
   await send('Emulation.setEmulatedMedia',{features:[{name:'prefers-color-scheme',value:theme}]});
   await send('Page.navigate',{url:base+'docs/index.html'});await pause(150);
   await evaluate(`document.querySelector('[data-set="${lang}"]').click()`);
   await evaluate('Promise.all(Array.from(document.images).map(i=>i.decode()))');
   const check=await evaluate(`({lang:document.documentElement.lang,overflow:document.documentElement.scrollWidth>innerWidth,visibleImages:[...document.querySelectorAll('.shots img')].filter(i=>getComputedStyle(i).display!=='none').length,broken:[...document.images].filter(i=>!i.naturalWidth).length})`);
   if(check.lang!==lang||check.overflow||check.visibleImages!==2||check.broken)throw Error(JSON.stringify({width,lang,theme,...check}));
   console.log(JSON.stringify({width,lang,theme,...check}));
   if(lang==='it'&&theme==='light')await capture(path.join(os.tmpdir(),`frequenza-pages-${width}.png`),true);
  }
 }finally{socket?.close();child.kill('SIGTERM');}
})().catch(e=>{console.error(e);process.exitCode=1;});
