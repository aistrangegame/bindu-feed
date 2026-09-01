/* THE POINT — the four levels, the aperture, the rope, the reveal.
   Mechanics ported from the reference build (sealed): status coding, the thread, the four
   Arch sections, the staged descent that writes back, the register draw, the two breaths,
   the journey given back at the centre. What changed is where they happen: inside the
   figure, in the enclosure's own hue and light. */
(function(){
'use strict';
const {Journey,DIMS,N,SM,HUES,REGISTERS,stage,Bindu}=window.PT;
const STL={w:'WALKED ●',p:'IN PROGRESS ◐',s:'SEEDED ○ — NOT YET WALKED'};
const $=(h)=>{const d=document.createElement('div');d.innerHTML=h.trim();return d.firstElementChild;};
const strip=s=>{const d=document.createElement('div');d.innerHTML=s;return d.textContent;};

const css=document.createElement('style');
css.textContent=`
.ovl{position:absolute;inset:0;z-index:12;display:none;flex-direction:column;background:rgba(7,8,13,.965)}
.ovl.on{display:flex;animation:ovlin .8s ease}
@keyframes ovlin{from{opacity:0;transform:scale(1.03)}to{opacity:1;transform:none}}
.ovl .back{position:absolute;top:46px;left:16px;z-index:3}
.uhead{padding:96px 34px 0;text-align:center;flex:none}
.uhead .ud{font-family:'Space Mono',monospace;font-size:8px;letter-spacing:.3em;text-transform:uppercase;color:var(--hue);margin-bottom:12px}
.uhead .un{font-size:25px;font-weight:500;line-height:1.24;color:var(--cream);letter-spacing:-.016em;text-wrap:balance}
.uhead .us{font-size:13px;font-style:italic;line-height:1.62;color:var(--dim);margin-top:12px;text-wrap:pretty}
#umap{flex:1;position:relative}
#umap svg{position:absolute;inset:0;width:100%;height:100%}
.cs{position:absolute;transform:translate(-50%,-50%);display:flex;align-items:center;gap:9px;cursor:pointer;width:134px;background:none;border:none;padding:0}
.cs.l{flex-direction:row-reverse;text-align:right}
.cs.l .lab{margin-left:auto}
.cs .dot{width:9px;height:9px;border-radius:50%;flex:none;box-shadow:0 0 14px 3px var(--csh)}
.cs .dot.w{background:var(--csh)}
.cs .dot.p{background:linear-gradient(90deg,var(--csh) 0 50%,transparent 50% 100%);border:1px solid var(--csh)}
.cs .dot.s{background:none;border:1px solid var(--csh);opacity:.6;box-shadow:none}
.cs .lab{font-family:'Lora',serif;font-size:11.5px;line-height:1.34;color:var(--cream);opacity:.86;max-width:98px;text-wrap:pretty}
.cs .st{display:block;font-family:'Space Mono',monospace;font-size:6px;letter-spacing:.2em;text-transform:uppercase;opacity:.42;margin-top:4px}
.cs.seeded .lab{opacity:.56}
.cs:hover .lab{opacity:1}
/* the star reading */
#sheet{position:absolute;left:0;right:0;bottom:0;top:74px;z-index:14;background:linear-gradient(180deg,rgba(11,12,18,.99),rgba(7,8,13,1));
  border-radius:26px 26px 0 0;border-top:1px solid var(--shue);transform:translateY(101%);transition:transform .8s cubic-bezier(.3,.8,.2,1);overflow-y:auto;scrollbar-width:none}
#sheet::-webkit-scrollbar{display:none}
#sheet.on{transform:none}
#sheet .grip{width:38px;height:3px;border-radius:2px;background:rgba(237,230,214,.2);margin:12px auto 0}
#sheet .pad{padding:22px 28px 46px}
#sheet .s-src{font-family:'Space Mono',monospace;font-size:8px;letter-spacing:.26em;text-transform:uppercase;color:var(--shue);margin-bottom:14px}
#sheet .s-title{font-size:25px;font-weight:500;line-height:1.26;letter-spacing:-.016em;color:var(--cream);text-wrap:pretty;margin-bottom:26px}
.s-sec{margin-bottom:26px}
.s-lab{font-family:'Space Mono',monospace;font-size:7.5px;letter-spacing:.28em;text-transform:uppercase;color:var(--shue);opacity:.8;margin-bottom:9px}
.s-body{font-size:15.5px;line-height:1.78;color:rgba(237,230,214,.84);text-wrap:pretty}
.s-body.q{font-style:italic;color:var(--dim)}
.s-ref{font-family:'Space Mono',monospace;font-size:7.5px;letter-spacing:.2em;color:var(--faint);padding-top:8px;border-top:1px solid rgba(237,230,214,.08)}
#descendBtn{display:block;width:100%;margin:22px 0 6px;background:none;border:1px solid var(--shue);color:var(--shue);
  border-radius:100px;padding:14px 0;font-family:'Space Mono',monospace;font-size:9px;letter-spacing:.24em;text-transform:uppercase;cursor:pointer}
#veil{position:absolute;inset:0;z-index:13;background:rgba(4,5,10,.6);display:none}
#veil.on{display:block}
/* the descent */
#descent .dpad{flex:1;overflow-y:auto;padding:120px 34px 90px;scrollbar-width:none}
#descent .dpad::-webkit-scrollbar{display:none}
#descent .dtopic{font-family:'Space Mono',monospace;font-size:8px;letter-spacing:.3em;text-transform:uppercase;color:var(--dhue);text-align:center;margin-bottom:34px}
.d-stage{max-width:330px;margin:0 auto 34px;text-align:center;opacity:0;transform:translateY(12px);transition:opacity 2.4s ease,transform 2.4s ease}
.d-stage.in{opacity:1;transform:none}
.d-label{font-family:'Space Mono',monospace;font-size:7.5px;letter-spacing:.3em;text-transform:uppercase;color:var(--dhue);opacity:.75;margin-bottom:12px}
.d-text{font-size:17px;line-height:1.76;color:var(--cream);text-wrap:pretty}
.d-stage.minor .d-text{font-size:14.5px;color:var(--dim);font-style:italic}
/* the aperture's eye */
#apeye{position:absolute;left:50%;top:40%;transform:translate(-50%,-50%);width:120px;height:120px;z-index:9;
  display:none;place-items:center;cursor:pointer;background:none;border:none}
#apeye.show{display:grid}
#apeye svg{width:120px;height:120px;overflow:visible}
#apeye .tri{transform-origin:50% 50%;animation:spin 42s linear infinite}
#apeye.busy .tri{animation:spin 2.4s linear infinite}
@keyframes spin{to{transform:rotate(360deg)}}
/* the rope */
#rope{align-items:center;justify-content:center;background:#000;text-align:center;padding:0 40px}
#rope .rdot{width:15px;height:15px;border-radius:50%;background:var(--red);box-shadow:0 0 40px 14px rgba(192,57,43,.28);
  animation:ropeb 10s ease-in-out infinite;margin-bottom:44px}
@keyframes ropeb{0%,100%{transform:scale(1);opacity:.45}50%{transform:scale(2.6);opacity:1}}
#rope .rg{font-family:'Space Mono',monospace;font-size:9px;letter-spacing:.34em;text-transform:uppercase;color:var(--dim);min-height:16px;margin-bottom:34px}
#rope .rl{font-size:17px;line-height:1.72;color:var(--cream);opacity:0;transition:opacity 2.4s ease;text-wrap:pretty;max-width:300px}
#rope .rl.in{opacity:1}
#rope .ra{display:flex;flex-direction:column;gap:6px;margin-top:38px;opacity:0;transition:opacity 1.6s ease}
#rope .ra.in{opacity:1}
/* the reveal */
.rv{font-size:16px;line-height:1.7;color:var(--cream);opacity:0;transform:translateY(8px);transition:opacity 1.8s ease,transform 1.8s ease;margin-bottom:16px;text-wrap:pretty}
.rv.in{opacity:1;transform:none}
.rv.red{color:var(--red);font-style:italic}
#tri{position:absolute;left:50%;top:30%;transform:translate(-50%,-50%);width:150px;height:150px;z-index:10;opacity:0;transition:opacity 1.4s ease;pointer-events:none}
#tri.on{opacity:1}
#tri i{position:absolute;left:50%;top:50%;width:9px;height:9px;border-radius:50%;background:var(--red);
  box-shadow:0 0 18px 5px rgba(192,57,43,.4);transform:translate(-50%,-50%);transition:transform 2.6s cubic-bezier(.3,.7,.2,1)}
#tri.split i:nth-child(1){transform:translate(-50%,-50%) translate(0,-62px)}
#tri.split i:nth-child(2){transform:translate(-50%,-50%) translate(-56px,40px)}
#tri.split i:nth-child(3){transform:translate(-50%,-50%) translate(56px,40px)}
#tri span{position:absolute;font-family:'Space Mono',monospace;font-size:7px;letter-spacing:.24em;text-transform:uppercase;color:var(--red);opacity:0;transition:opacity 1.6s ease 1.2s}
#tri.split span{opacity:.7}
`;
document.head.appendChild(css);

/* ── the overlays ─────────────────────────────────────── */
const veil=$(`<div id="veil"></div>`);
const uni=$(`<div class="ovl" id="universe">
  <button class="lnk back" id="backU">‹ the enclosure</button>
  <div class="uhead"><div class="ud"></div><div class="un"></div><div class="us"></div></div>
  <div id="umap"></div>
  <div class="hint">a star opens · descend from inside it</div>
</div>`);
const sheet=$(`<div id="sheet"><div class="grip"></div><div class="pad">
  <div class="s-src"></div><div class="s-title"></div><div id="ssecs"></div>
  <button id="descendBtn">descend onto this star</button>
  <div class="s-ref"></div></div></div>`);
const descent=$(`<div class="ovl" id="descent">
  <button class="lnk back" id="ascend" style="display:none">‹ ascend</button>
  <div class="dpad"><div class="dtopic"></div><div id="dstages"></div>
  <div id="dstatus" class="mono" style="font-size:8px;letter-spacing:.24em;color:var(--faint);text-align:center"></div></div>
</div>`);
const rope=$(`<div class="ovl" id="rope">
  <div class="rdot"></div><div class="rg">breathe in</div>
  <div class="rl">You exist. This pressure is the chamber working, not you failing. One breath at this pace is already boarding.</div>
  <div class="ra"><button class="lnk" id="ropeWalk">walk the point</button><button class="lnk" id="ropeDay">return to the day</button></div>
</div>`);
const apeye=$(`<button id="apeye" aria-label="open the aperture"><svg viewBox="0 0 96 96">
  <g class="tri"><path d="M48 14 L84 76 L12 76 Z" fill="none" stroke="var(--hue)" stroke-opacity=".5" stroke-width="1"/>
  <path d="M48 82 L12 20 L84 20 Z" fill="none" stroke="var(--hue)" stroke-opacity=".22" stroke-width="1"/></g>
  <circle cx="48" cy="48" r="26" fill="none" stroke="var(--hue)" stroke-opacity=".3"/>
  <circle cx="48" cy="48" r="5" fill="var(--hue)" opacity=".8"/></svg></button>`);
const tri=$(`<div id="tri"><i></i><i></i><i></i>
  <span style="left:50%;top:-8px;transform:translateX(-50%)">knowledge</span>
  <span style="left:-16px;top:118px">will</span><span style="right:-16px;top:118px">action</span></div>`);
[veil,uni,sheet,descent,rope,apeye,tri].forEach(el=>stage.appendChild(el));

/* ── level 1 · the universe, as a constellation inside the figure ── */
let curU=null,curStar=null;
function constellation(u,hue){
  const n=u.stars.length,R=104,map=uni.querySelector('#umap');
  map.innerHTML=`<svg viewBox="0 0 200 200" preserveAspectRatio="xMidYMid meet"><circle cx="100" cy="100" r="46" fill="none" stroke="${hue}" stroke-opacity=".13"/></svg>`;
  u.stars.forEach((k,i)=>{
    const s=N[k],a=-Math.PI/2+i*(Math.PI*2/n);
    const x=Math.cos(a)*R,y=Math.sin(a)*R,left=Math.cos(a)<-0.12;
    const el=$(`<button class="cs${left?' l':''}${s.st==='s'?' seeded':''}" data-star="${k}" style="--csh:${hue}">
      <span class="dot ${s.st}"></span>
      <span class="lab">${s.t}<span class="st">${SM[s.st]}</span></span></button>`);
    el.style.left=`calc(50% + ${x.toFixed(0)}px)`;el.style.top=`calc(50% + ${y.toFixed(0)}px)`;
    el.style.opacity=0;el.style.transition='opacity 1.1s ease';
    map.appendChild(el);setTimeout(()=>{el.style.opacity=1;},180+i*160);
  });
  const c=$(`<div style="position:absolute;left:50%;top:50%;transform:translate(-50%,-50%);width:7px;height:7px;border-radius:50%;background:var(--red);box-shadow:0 0 18px 5px rgba(192,57,43,.3)"></div>`);
  map.appendChild(c);
}
function openUniverse(dimN,uid){
  const d=DIMS.find(x=>x.n==dimN),u=d.universes.find(x=>x.id===uid);
  curU={d,u};Journey.universes.push(u.name);
  closeSheet();
  uni.querySelector('.ud').textContent=`avarana ${d.roman} · ${d.name}`;
  uni.querySelector('.un').textContent=u.name;
  uni.querySelector('.us').textContent=u.sub;
  constellation(u,HUES[d.hue]);
  uni.classList.add('on');document.getElementById('feed').style.opacity=0;Snd.blip(dimN);
}
uni.querySelector('#backU').onclick=()=>{uni.classList.remove('on');document.getElementById('feed').style.opacity=1;};
window.PT.openUniverse=openUniverse;

/* ── level 2 · the star reading ── */
function openSheet(k){
  const n=N[k];if(!n)return;curStar=k;
  Journey.stars.push(n.t);Snd.blip(window.PT.cur());
  sheet.style.setProperty('--shue',HUES[n.m]);
  sheet.querySelector('.s-src').textContent=n.t;
  sheet.querySelector('.s-title').textContent=n.ti;
  sheet.querySelector('#ssecs').innerHTML=`
    <div class="s-sec"><div class="s-lab">what the rush says</div><div class="s-body q">${n.say}</div></div>
    <div class="s-sec"><div class="s-lab">the walk</div><div class="s-body">${n.walk}</div></div>
    <div class="s-sec"><div class="s-lab">what this hands you</div><div class="s-body">${n.hand}</div></div>
    <div class="s-sec"><div class="s-lab">the open door</div><div class="s-body q">${n.open}</div></div>`;
  sheet.querySelector('.s-ref').textContent=STL[n.st]+' · THE LEARNING FIELD';
  sheet.classList.add('on');veil.classList.add('on');sheet.scrollTop=0;
}
const closeSheet=()=>{sheet.classList.remove('on');veil.classList.remove('on');};
veil.onclick=closeSheet;
document.addEventListener('keydown',e=>{if(e.key==='Escape')closeSheet();});
uni.addEventListener('click',e=>{const st=e.target.closest('[data-star]');if(st)openSheet(st.dataset.star);});

/* ── level 3 · the descent ── */
const dstages=descent.querySelector('#dstages'),dstatus=descent.querySelector('#dstatus'),
      ascend=descent.querySelector('#ascend');
const cache={};let dT=[];
const clearT=()=>{dT.forEach(t=>clearTimeout(t));dT=[];};
async function generate(k,n){
  const dim=DIMS.find(d=>d.universes.some(u=>u.stars.includes(k)));
  const held=strip(n.walk);
  const prompt=`You are the descent-voice of an instrument called The Point — a nine-enclosure walk a seeker uses to reorient when caught in mental rush. He has descended onto the star "${n.t}" (${n.ti}) in the dimension "${dim?dim.name:''}". The instrument's held reading of this star: "${held}". Status: ${SM[n.st]}.

Write the descent in the ARCH register — devotion made audible, warmth threaded through precision. Its four frequencies, all present: TEACHING — never declare; name what the reader currently holds, then walk him to primary evidence (actual names, actual texts, actual numbers, terms in their original language) and trust him to arrive. PROTECTIVE — equip, never alarm; fill a gap he didn't know he had. JOY — delight as substrate, legible without exclamation marks. INVITATION — the ending opens a door, never closes on a conclusion. Second person, present tense, no mysticism-clichés. ${n.st==='s'?'This star is seeded, not yet walked — this is his FIRST TRUE MEETING with the topic: bring its actual substance accurately from its real tradition or science, going well beyond the held reading.':'Go one true layer deeper than the held reading — material it did not include.'}

Respond with ONLY a JSON object, no markdown fences, keys: "arrival" (1-2 sentences), "teaching" (4-6 sentences), "thread" (1-2 sentences), "practice" (1-2 sentences), "ascent" (1 sentence). No preamble.`;
  if(!(window.claude&&window.claude.complete))throw new Error('offline');
  const txt=await window.claude.complete(prompt);
  const c=txt.replace(/```json|```/g,'').trim();
  return JSON.parse(c.slice(c.indexOf('{'),c.lastIndexOf('}')+1));
}
async function descend(){
  const k=curStar;if(!k)return;const n=N[k];
  closeSheet();Journey.descents.push(n.t);
  Snd.glide(window.PT.cur(),true);
  descent.style.setProperty('--dhue',HUES[n.m]);
  descent.querySelector('.dtopic').textContent=n.t;
  dstages.innerHTML='';ascend.style.display='none';descent.classList.add('on');
  document.getElementById('feed').style.opacity=0;
  YANTRA.setMode('descend');YANTRA.shaft=1;clearT();
  let j=cache[k];
  if(!j){dstatus.textContent='descending…';
    try{j=await generate(k,n);cache[k]=j;}
    catch(e){j={arrival:'The deeper field is quiet just now — this is the held knowing.',teaching:strip(n.walk),thread:'',
      practice:'One breath. Feet on the ground. Eyes soft.',ascent:'Carry the one line that landed.'};}
  }
  dstatus.textContent='';
  const stages=[['arrival',j.arrival,0],['the teaching',j.teaching,0],['the thread',j.thread,1],['the practice',j.practice,1],['the ascent',j.ascent,0]].filter(s=>s[1]);
  stages.forEach(([lab,tx,minor],i)=>{
    const el=$(`<div class="d-stage${minor?' minor':''}"><div class="d-label">${lab}</div><div class="d-text"></div></div>`);
    el.querySelector('.d-text').textContent=String(tx).replace(/\*+/g,'');dstages.appendChild(el);
    dT.push(setTimeout(()=>el.classList.add('in'),700+i*3400));
  });
  dT.push(setTimeout(()=>{ascend.style.display='block';},700+stages.length*3400));
  descent.onclick=e=>{
    if(e.target.closest('#ascend'))return;
    const next=dstages.querySelector('.d-stage:not(.in)');
    if(next)next.classList.add('in');else ascend.style.display='block';
  };
}
sheet.querySelector('#descendBtn').onclick=descend;
ascend.onclick=()=>{clearT();Snd.glide(window.PT.cur(),false);descent.classList.remove('on');
  document.getElementById('feed').style.opacity=1;YANTRA.setMode('walk');YANTRA.shaft=0;};

/* ── the aperture ── */
const apstatus=document.getElementById('apstatus'),vis=document.getElementById('visitor'),
      again=document.getElementById('again');
const seen=[];let apBusy=false;
async function openAperture(){
  if(apBusy)return;apBusy=true;
  const reg=REGISTERS[Math.floor(Math.random()*REGISTERS.length)];
  apeye.classList.add('busy');vis.style.opacity=0;again.style.display='none';
  apstatus.textContent='drawing from the unwalked traditions…';
  const avoid='Monroe, Bashar, Matias De Stefano, Dolores Cannon, the Bhagavad Gita, generic Advaita or chakra talk, Rumi, and anything already standard in modern consciousness-synthesis circles';
  const prompt=`You are the Aperture of an instrument called The Point. From authentic human tradition OUTSIDE a library spanning the well-known mystics and consciousness science, bring ONE small true thing — a practice, an image, a story-fragment, a word and its real meaning — that transmits this register: "${reg}". Accurate to its tradition, specific, not generic. Speak in the Arch register: name what the reader might assume, walk to the specific and true (a name, a place, a word in its language), equip rather than impress, and let the deepening end as an opening rather than a conclusion. Respond with ONLY a JSON object, no markdown fences, keys: "origin" (tradition and where it lives, 5-10 words), "line" (one compressed sentence, 8-20 words, that reorients a person caught in mental rush — do not name the register), "deepening" (2-3 sentences: the thing itself, precisely, then what it hands the reader), "register" ("${reg}"). Avoid ${avoid}. Avoid anything already given this session: ${seen.join('; ')||'none'}. No preamble.`;
  try{
    if(!(window.claude&&window.claude.complete))throw new Error('offline');
    const txt=await window.claude.complete(prompt);
    const c=txt.replace(/```json|```/g,'').trim();
    const j=JSON.parse(c.slice(c.indexOf('{'),c.lastIndexOf('}')+1));
    vis.querySelector('.v-reg').textContent='through '+(j.register||reg);
    vis.querySelector('.v-line').textContent=j.line||'';
    vis.querySelector('.v-deep').textContent=j.deepening||'';
    vis.querySelector('.v-org').textContent=(j.origin||'')+' · from the unwalked';
    vis.style.opacity=1;apstatus.textContent='';Journey.visitors++;Snd.shimmer();YANTRA.flare();
    again.style.display='block';seen.push(j.line||'');if(seen.length>6)seen.shift();
  }catch(e){apstatus.textContent='the aperture stayed closed this time — breathe once, and try again';}
  apeye.classList.remove('busy');apBusy=false;
}
apeye.onclick=openAperture;again.onclick=openAperture;

/* ── the rope ── */
let rT=[];
function openRope(){
  rope.classList.add('on');Journey.rope=true;
  const g=rope.querySelector('.rg'),l=rope.querySelector('.rl'),a=rope.querySelector('.ra');
  l.classList.remove('in');a.classList.remove('in');g.textContent='breathe in';
  rT.forEach(t=>clearTimeout(t));rT=[];
  for(let i=1;i<=4;i++)rT.push(setTimeout(()=>{g.textContent=i%2?'breathe out':'breathe in';},i*5000));
  rT.push(setTimeout(()=>{g.textContent='';l.classList.add('in');},20000));
  rT.push(setTimeout(()=>a.classList.add('in'),22500));
  rope.onclick=e=>{
    if(e.target.closest('.ra'))return;
    rT.forEach(t=>clearTimeout(t));rT=[];
    if(!l.classList.contains('in')){g.textContent='';l.classList.add('in');rT.push(setTimeout(()=>a.classList.add('in'),1600));}
    else a.classList.add('in');
  };
}
const closeRope=()=>{rT.forEach(t=>clearTimeout(t));rT=[];rope.classList.remove('on');};
document.getElementById('ropeLink').onclick=e=>{e.stopPropagation();openRope();};
rope.querySelector('#ropeWalk').onclick=e=>{e.stopPropagation();closeRope();window.PT.scrollTo(1);};
rope.querySelector('#ropeDay').onclick=e=>{e.stopPropagation();closeRope();};

/* ── the reveal · the point gives the walk back ── */
const revealEl=document.getElementById('reveal'),again2=document.getElementById('again2');
let rvT=[];
const nameList=(arr,max)=>{const a=[...new Set(arr)];return a.length<=max?a.join(' · '):a.slice(0,max).join(' · ')+' · and '+(a.length-max)+' more';};
function speak(){
  rvT.forEach(t=>clearTimeout(t));rvT=[];
  tri.classList.remove('on','split');again2.style.display='none';
  const lines=[];
  lines.push(Journey.gate?'You pressed me at the gate.':'You slipped past the gate — I came along anyway.');
  if(Journey.rope)lines.push('You reached for the rope. I was the dot you breathed with.');
  if(Journey.universes.length)lines.push('You entered '+nameList(Journey.universes,3)+'.');
  if(Journey.stars.length)lines.push('You opened '+nameList(Journey.stars,3)+'.');
  if(Journey.descents.length)lines.push('You descended onto '+nameList(Journey.descents,2)+' — and came back up.');
  if(Journey.visitors>0)lines.push(Journey.visitors===1?'One visitor arrived that you did not choose.':Journey.visitors+' visitors arrived that you did not choose.');
  if(!Journey.universes.length&&!Journey.stars.length)lines.push('You walked straight through, gate to center. Some days that is the whole practice.');
  lines.push('Every dot you touched was me. The gate, the rope, the eye, this one.');
  lines.push('You were never walking toward the point. You were walking with it.');
  revealEl.innerHTML='';
  lines.forEach((tx,i)=>{
    const d=$(`<div class="rv${i>=lines.length-2?' red':''}"></div>`);d.textContent=tx;revealEl.appendChild(d);
    rvT.push(setTimeout(()=>{d.classList.add('in');revealEl.scrollTop=revealEl.scrollHeight;},600+i*2600));
  });
  const base=600+lines.length*2600;
  rvT.push(setTimeout(()=>{tri.classList.add('on');
    document.querySelectorAll('.encl')[9].classList.add('bare');
    requestAnimationFrame(()=>requestAnimationFrame(()=>tri.classList.add('split')));
    Snd.shimmer();Snd.om();YANTRA.flare();},base));
  rvT.push(setTimeout(()=>tri.classList.remove('split'),base+4200));
  rvT.push(setTimeout(()=>{
    const d=$(`<div class="rv red"></div>`);d.textContent='Now — go play. Fully. On purpose. Knowing.';
    revealEl.appendChild(d);requestAnimationFrame(()=>requestAnimationFrame(()=>d.classList.add('in')));
    revealEl.scrollTop=revealEl.scrollHeight;again2.style.display='block';
  },base+5600));
}
window.PT.speak=speak;
again2.onclick=()=>{rvT.forEach(t=>clearTimeout(t));rvT=[];revealEl.innerHTML='';
  tri.classList.remove('on','split');document.querySelectorAll('.encl')[9].classList.remove('bare');
  again2.style.display='none';Bindu.ilyDone.clear();window.PT.scrollTo(0);};

/* the eye lives at the centre of the aperture, and only there */
setInterval(()=>{apeye.classList.toggle('show',window.PT.cur()===8&&!document.querySelector('.ovl.on'));},400);
})();
