/* THE UNIVERSE · THE FALL ──────────────────────────────────────────
   One continuous camera move, four conceptual layers (Amendment 01 §8.2):

     1 the approach   the star grows into a small sun; its halo IS the
                      Resonance Voice \u2014 the one that speaks as "You",
                      unattributed, so it has a glow and no body
     2 the gathering  the company stops orbiting and takes its seats:
                      who spoke here, settled, still sitting with it
     3 the strata     beneath them, his own rings — every return, aged
     4 the mouth      the deepest stratum opens the Return. The fall is
                      the Summons; the ceremony is entered, never drifted
                      into, so the crossing is a threshold and a dissolve.

   The camera travels. Nothing here is a screen. ─────────────────── */
(function(global){
'use strict';
var U=global.UNI, F=global.UNIFIELD, TAU=U.TAU, BONE=U.BONE;
var hash=U.hash, mix=U.mix, rgba=U.rgba, ring=U.ring, breath=U.breath;

/* how much of each layer is showing, at this depth */
function layers(d){
  var seg=function(a,b){return Math.max(0,Math.min(1,(d-a)/(b-a)));};
  return {app:1-seg(0.16,0.34), gath:seg(0.14,0.30)*(1-seg(0.52,0.74)),
    strat:seg(0.44,0.66), mouth:seg(0.84,0.96),
    n:d<0.20?0:d<0.50?1:d<0.88?2:3};
}

/* the seat each presence settles into — ceremony order, laid on a wide,
   staggered fan beneath the story-heart, so no two sit on one line and
   nothing sits directly under it. Ash sits closest; he was answering. */
function seat(co,i,cx,cy,S){
  var n=co.length, a=co[i];
  if(a.ash)return [cx-S*0.24,cy+S*0.46];
  var m=0,idx=0;
  for(var j=0;j<n;j++){if(!co[j].ash){if(j===i)idx=m;m++;}}
  var f=m<2?0.5:(idx+0.5)/m;
  var ang=(0.11+f*0.78)*Math.PI;                  /* 20° → 160°, below the heart */
  var out=1+(idx%2)*0.24;                         /* every other one sits further out */
  return [cx+Math.cos(ang)*S*1.06*out,cy+Math.sin(ang)*S*0.98*out];
}

var hits=[];

function render(x,W,H,t,v,lens){
  var s=v.fallStar, room=U.ROOMS[s.room], col=mix(room.rgb,BONE,lens*0.3);
  var enter=Math.min(1,v.fall), d=v.desc||0, L=layers(d), br=breath(t), co=F.company(s);
  /* the heart rises as the company settles, so the seated field has room */
  var cx=W/2, cy=H*(0.40-0.10*L.gath+0.05*L.strat)+(v.dy||0)*8;
  hits=[];

  /* the sky closes over. What was above stays only as atmosphere. */
  x.fillStyle='rgba(4,3,7,'+(0.80*enter+0.15*L.strat)+')';x.fillRect(0,0,W,H);

  /* ── 3 · the strata ── his own rings, rising to meet him ── */
  if(L.strat>0.004){
    var n=s.depth;
    for(var k=n;k>=0;k--){
      var age=n?k/n:0, local=Math.max(0,Math.min(1,(L.strat*(n+1))-(n-k)));
      var rr=(52+k*40)*(0.5+L.strat*0.5)*(1+local*1.7)*(1+br*0.02);
      var par=1+k*0.18, ox=(v.dx||0)*par*11, oy=(v.dy||0)*par*9;
      var a=(0.36-age*0.19)*L.strat*(1-local*0.82);
      if(a<=0.004)continue;
      x.beginPath();x.ellipse(cx+ox,cy+oy,rr,rr*0.9,0,0,TAU);
      x.strokeStyle=rgba(mix(col,BONE,age*0.7),a);x.lineWidth=(1.6-age*0.9)*(1+local);x.stroke();
      /* the ink of that stratum — recent selves clear, far ones faded.
         His own voice can be raised out of a ring by touching its ink. */
      var ix=cx+ox+rr*0.72, iy=cy+oy-rr*0.30, lit=s._ringLit===k?1:0;
      ring(x,ix,iy,1.6+(1-age)*1.6+lit*2.2);
      x.fillStyle=rgba(mix(col,BONE,age*0.8),Math.min(1,a*1.8+lit*0.5));x.fill();
      if(lit){ring(x,ix,iy,9+br*4);x.strokeStyle=rgba(mix(col,BONE,0.5),0.34);x.lineWidth=0.8;x.stroke();}
      if(a>0.05)hits.push({kind:'ring',x:ix,y:iy,r:16,k:k,age:age});
    }
  }

  /* ── 1 · the approach ── the sun, and the halo that is the one voice
        speaking as You. It is warmth, not a body: no glyph, no name. ── */
  var Sr=(6+br*2.6)*enter*(1+L.app*3.4+d*2.0);
  var hal=Sr*(7.4+L.app*2.2)*(0.94+br*0.10);
  var hg=x.createRadialGradient(cx,cy,0,cx,cy,hal);
  hg.addColorStop(0,rgba(mix(col,[255,250,242],0.72),(0.80*enter)*(0.55+L.app*0.45)));
  hg.addColorStop(0.16,rgba(mix(col,[255,242,226],0.34),0.40*enter));
  hg.addColorStop(0.46,rgba(col,0.17*enter*(0.6+L.app*0.4)));
  hg.addColorStop(1,rgba(col,0));
  x.fillStyle=hg;ring(x,cx,cy,hal);x.fill();
  /* the halo breathes a half-beat behind the field: the story turned to him
     first, and is still turned */
  var hb=(Math.sin(t*TAU/10-0.9)+1)/2;
  ring(x,cx,cy,hal*0.30*(0.9+hb*0.16));
  x.strokeStyle=rgba(mix(col,[255,248,238],0.6),0.10*enter*(0.4+L.app*0.6));x.lineWidth=1;x.stroke();
  ring(x,cx,cy,Sr);x.fillStyle=rgba([255,253,250],0.95*enter);x.fill();

  /* ── 2 · the gathering ── the orbit settles into a seated field ── */
  if(co.length&&L.gath>0.004){
    var set=Math.max(0,Math.min(1,(d-0.17)/0.16));         /* orbit → seat */
    var S=Math.min(W*0.40,158);
    /* which story they are sitting with */
    if(set>0.35&&s.title){
      var ta=L.gath*(set-0.35)/0.65;
      x.textAlign='center';x.textBaseline='alphabetic';
      x.font='8px "Space Mono", monospace';
      x.fillStyle=rgba(BONE,ta*0.30);x.fillText(s.codex,cx,cy-hal*0.42-15);
      x.font='italic 14px Lora, Georgia, serif';
      x.fillStyle=rgba(BONE,ta*0.58);x.fillText(s.title,cx,cy-hal*0.42);
    }
    for(var i=0;i<co.length;i++){
      var a2=co[i], orb=F.at(a2,cx,cy,Sr*2.2,t*(1-set*0.92),lens), st=seat(co,i,cx,cy,S);
      var px=orb[0]+(st[0]-orb[0])*set, py=orb[1]+(st[1]-orb[1])*set;
      var al=L.gath*(0.66+set*0.34), open=s._open===i?1:0;
      var c2=a2.ash?mix(a2.v.rgb,[255,236,222],0.10*(1-(a2.patina||0))):a2.v.rgb;
      /* the thread back to the story: they are sitting with it, not near it */
      if(set>0.2){x.beginPath();x.moveTo(cx,cy);x.lineTo(px,py);
        x.strokeStyle=rgba(c2,al*0.13*set);x.lineWidth=0.7;x.stroke();}
      var gl=x.createRadialGradient(px,py,0,px,py,30);
      gl.addColorStop(0,rgba(c2,al*(0.34+open*0.30)));gl.addColorStop(1,rgba(c2,0));
      x.fillStyle=gl;ring(x,px,py,30);x.fill();
      x.textAlign='center';x.textBaseline='middle';
      x.font=(a2.ash?13:18)+'px Lora, Georgia, serif';
      x.fillStyle=rgba(mix(c2,[255,252,248],0.30),al*(0.86+open*0.14));
      x.fillText(a2.v.g,px,py);
      if(set>0.6){
        var na=L.gath*(set-0.6)/0.4;
        x.font='8px "Space Mono", monospace';x.textBaseline='top';
        x.fillStyle=rgba(mix(c2,BONE,0.30),na*0.74);
        x.fillText(a2.v.name.toUpperCase(),px,py+15);
        /* a word waits near the presence, where the Archive holds one */
        if(a2.word&&!open){var wy=py+27+Math.sin(t*0.24+i)*1.6;
          x.font='7.5px "Space Mono", monospace';
          x.fillStyle=rgba(BONE,na*0.30);x.fillText('touch',px,wy);}
      }
      if(al>0.10)hits.push({kind:'presence',x:px,y:py,r:30,i:i,a:a2});
    }
    /* who was silent is simply not here. Nothing marks the absence. */
  }

  /* the mote-company keeps orbiting until it settles — above the seats,
     the star's own light still moving */
  if(co.length&&d<0.20)F.motes(x,s,cx,cy,Sr*2.2,t,20,lens,1-d*4);

  /* ── 4 · the mouth ── the deepest stratum opens ── */
  if(L.mouth>0.01){
    var mr=(34+br*12)*L.mouth;
    var mg=x.createRadialGradient(cx,cy,0,cx,cy,mr*3.0);
    mg.addColorStop(0,rgba([255,246,230],0.44*L.mouth));
    mg.addColorStop(0.34,rgba(mix(col,[218,182,112],0.7),0.26*L.mouth));
    mg.addColorStop(1,rgba(col,0));
    x.fillStyle=mg;ring(x,cx,cy,mr*3.0);x.fill();
    ring(x,cx,cy,mr*(1.5+br*0.14));
    x.strokeStyle=rgba(mix(col,[236,206,150],0.8),0.20*L.mouth);x.lineWidth=1;x.stroke();
  }

  /* where he is in the fall — four words, one per layer, never a number */
  if(enter>0.9){
    var names=['the story, close','who sat with it','what you left here','the mouth of the return'];
    x.textAlign='center';x.textBaseline='alphabetic';
    x.font='8.5px "Space Mono", monospace';
    var fade=L.n===3?L.mouth:0.5+0.5*Math.sin(t*0.5)*0.2+0.4;
    x.fillStyle=rgba(BONE,0.26*Math.min(1,fade));
    x.fillText(names[L.n].toUpperCase(),cx,H-172);
  }
  return L;
}

function hitTest(px,py){
  for(var i=hits.length-1;i>=0;i--){var h=hits[i];
    if(Math.hypot(h.x-px,h.y-py)<h.r)return h;}
  return null;
}

global.UNIFALL={render:render,layers:layers,hitTest:hitTest,hits:function(){return hits;}};
})(window);
