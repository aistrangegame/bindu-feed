/* THE UNIVERSE SIDE, AT ITS CEILING ───────────────────────────────
   The Point side is what he has gathered, arranged, walked inward.
   This side is what has met him — accumulated, walked outward. Same
   axis, opposite direction, and the two are not symmetrical: one
   teaches, the other remembers.

   Four registers, each with its own language and its own gesture:

     −4  THE SKY      the thirteen at their true coordinates, each
                      drawn by its own geometry law, all of it lit
                      from ONE source at the centre.
                      gesture · THE SWEEP — draw a line across
                      everything you have lived and it answers.
     −3  A REGION     one room, its own weather, its settlements at
                      their authored positions.
                      gesture · DWELL — hold still and the room says
                      what it holds.
     −2  A WORLD      one story as a body, lit by the field.
                      gesture · TURN — three faces: the story, who
                      sat with it, how often you came back.
     −1  THE FALL     the orrery of selves. Every return a ring,
                      aged. Touch a ring's ink and your own voice
                      from that time rises out of it.

   THE RECOGNITION. Hold still at the sky and every room bends its
   light toward the centre — and the centre is the same particle he
   has been touching since the first post. The Point walks inward and
   arrives at the point. The Universe walks outward and finds the
   point was what had been holding the whole sky together. Both
   directions land on the same fact from opposite ends: he is not
   looking at a record. The record is looking back.

   Nothing here is invented. Where the Archive holds words, they are
   verbatim; where it does not, the presence is shown and stays
   silent. ─────────────────────────────────────────────────────── */
(function(g){
'use strict';
var U=g.UNI, FL=g.UNIFIELD, S=g.SPINE, TAU=Math.PI*2;
if(!U)return;

/* ── each room's weather: turbulence · drift · grain ───────────────
   Authored per room, from what the room is. The Forge churns; the
   Signal is nearly still and dry; the Forgetting is all grain. */
var WX={
  forge:      [0.92,0.055,0.30],
  signal:     [0.16,0.012,0.62],
  descent:    [0.74,0.040,0.16],
  garden:     [0.40,0.020,0.10],
  maya:       [0.30,0.026,0.44],
  watcher:    [0.12,0.008,0.06],
  field:      [0.55,0.016,0.22],
  thread:     [0.34,0.030,0.14],
  body:       [0.66,0.034,0.20],
  forgetting: [0.48,0.010,0.86],
  remembering:[0.36,0.018,0.28],
  circle:     [0.26,0.022,0.12],
  'return':   [0.44,0.028,0.18]
};

/* how much of him each room holds — from the record, not from a guess */
var DENS={},MAXD=1;
U.ROOMS.forEach(function(r,i){
  var d=0;
  U.STARS.forEach(function(s){if(s.room===i&&s.met)d+=1+s.depth*0.6;});
  DENS[i]=d;if(d>MAXD)MAXD=d;
});

/* the sky in normalised coordinates, for the field to light */
var EXT=1;
U.ROOMS.forEach(function(r){EXT=Math.max(EXT,Math.abs(r.x),Math.abs(r.y));});
var SKY=new Float32Array(39);
U.ROOMS.forEach(function(r,i){
  SKY[i*3]=r.x/EXT*0.88;SKY[i*3+1]=r.y/EXT*0.88;SKY[i*3+2]=DENS[i]/MAXD;
});

var Deep={
  SKY:SKY,WX:WX,DENS:DENS,EXT:EXT,
  sweep:{ang:0,str:0,hits:[]},
  dwell:0,               /* stillness, 0 → 1 */
  turn:0,                /* the world's rotation */
  room:null,star:null,
  ringLit:-1,openSeat:-1,
  said:null,             /* what the sky answered, and when */

  init:function(){
    var d=U.DEEP.slice().sort(function(a,b){return b.depth-a.depth;});
    this.star=d[0]||U.MET[0];
    this.room=U.ROOMS[this.star.room];
    return this;
  },
  weather:function(){var w=WX[this.room?this.room.id:'field'];return w||[0.4,0.02,0.2];},

  /* ── the sweep ────────────────────────────────────────────────
     A line drawn across everything he has lived. Whatever it crosses
     answers — with its own title, and with the field's words where
     the Archive holds them. It is the record turned toward him. */
  drawSweep:function(dx,dy){
    var m=Math.hypot(dx,dy);if(m<3)return;
    this.sweep.ang=Math.atan2(dy,dx);
    this.sweep.str=Math.min(1,this.sweep.str+m*0.010);
    this.gather();
  },
  gather:function(){
    var a=this.sweep.ang, nx=-Math.sin(a), ny=Math.cos(a), out=[];
    for(var i=0;i<U.STARS.length;i++){
      var s=U.STARS[i];if(!s.met)continue;
      var d=Math.abs((s.x/EXT*0.88)*nx+(s.y/EXT*0.88)*ny);
      if(d<0.055)out.push(s);
    }
    out.sort(function(p,q){return q.depth-p.depth;});
    this.sweep.hits=out.slice(0,3);
    if(out.length)this.said=performance.now();
  },
  fade:function(dt){
    this.sweep.str=Math.max(0,this.sweep.str-dt*0.30);
    if(this.sweep.str<=0)this.sweep.hits=[];
  },

  /* ── the sky ─────────────────────────────────────────────────
     Thirteen geometry laws at once, each at its true coordinate,
     every one lit from the single source at the centre. This is what
     he looks like from outside. */
  drawSkyLayer:function(x,W,H,Z,t,R0,p){
    var rim=S.rim(0,Z,R0), cx=W/2, cy=H/2;
    var scale=rim*0.88/EXT;
    /* the recognition: every room bends its light toward the centre */
    if(this.dwell>0.02){
      for(var i=0;i<U.ROOMS.length;i++){
        var r=U.ROOMS[i], px=cx+r.x*scale, py=cy+r.y*scale;
        x.beginPath();x.moveTo(px,py);x.lineTo(cx,cy);
        x.strokeStyle=rgba(r.rgb,p*this.dwell*0.16*(0.35+DENS[i]/MAXD*0.65));
        x.lineWidth=0.7;x.stroke();
      }
    }
    for(var i2=0;i2<U.ROOMS.length;i2++){
      var rm=U.ROOMS[i2], px2=cx+rm.x*scale, py2=cy+rm.y*scale, RR=rm.r*scale;
      if(RR<3)continue;
      var den=DENS[i2]/MAXD;
      /* lit from the one source — the further out, the cooler */
      var dc=Math.hypot(px2-cx,py2-cy)/Math.max(1,rim);
      var lit=0.44+0.56/(1+dc*1.7);
      /* the room's own law, drawn as authored */
      if(rm.arm&&RR>7){x.save();
        try{rm.arm(x,px2,py2,RR,t,p*(0.30+den*0.52)*lit,rm.rgb);}catch(e){}
        x.restore();}
      /* its settlements */
      for(var j=0;j<rm.n;j++){
        var loc=rm.place(j,rm.n,RR);
        var sx=px2+loc[0], sy=py2+loc[1];
        x.beginPath();x.arc(sx,sy,Math.max(0.7,RR*0.032),0,TAU);
        x.fillStyle=rgba(rm.rgb,p*(0.24+den*0.44)*lit);x.fill();
      }
      if(RR>26){
        x.font='8px "Space Mono", monospace';x.textAlign='center';x.textBaseline='middle';
        x.fillStyle=rgba(rm.rgb,p*(0.32+den*0.34));
        x.fillText(rm.name.toUpperCase(),px2,py2-RR*0.98);
        if(RR>58){
          x.font='7px "Space Mono", monospace';
          x.fillStyle=rgba(rm.rgb,p*0.24);
          x.fillText(rm.civ,px2,py2+RR*1.02);
        }
      }
    }
    /* what the sweep crossed, in its own words */
    if(this.sweep.hits.length){
      var al=Math.min(1,this.sweep.str*1.6)*p;
      x.textAlign='center';x.textBaseline='alphabetic';
      for(var h=0;h<this.sweep.hits.length;h++){
        var s2=this.sweep.hits[h], yy=H-228+h*31;
        x.font='7.5px "Space Mono", monospace';
        x.fillStyle=rgba(U.BONE,al*0.34);
        x.fillText(s2.codex+' \u00b7 '+U.ROOMS[s2.room].name.toUpperCase(),W/2,yy);
        x.font='italic 14px Lora, Georgia, serif';
        x.fillStyle=rgba(U.BONE,al*0.82);
        x.fillText(s2.title,W/2,yy+16);
      }
    }
    /* the recognition, said once, and only when he has held still */
    if(this.dwell>0.62){
      x.textAlign='center';x.textBaseline='alphabetic';
      x.font='italic 15px Lora, Georgia, serif';
      x.fillStyle=rgba(U.BONE,p*Math.min(1,(this.dwell-0.62)/0.30)*0.72);
      x.fillText('This is what you look like from outside.',W/2,H-126);
    }
  },

  /* ── a region: one room, its own air, its own law ────────────── */
  drawRegionLayer:function(x,W,H,Z,t,R0,p){
    var rm=this.room;if(!rm)return;
    var rim=S.rim(1,Z,R0), cx=W/2, cy=H/2, RR=rim*0.62;
    /* the room's authored atmosphere — thirteen weathers, one per room */
    if(rm.field){x.save();try{rm.field(x,W,H,t,p*0.40,rm.rgb);}catch(e){}x.restore();}
    if(rm.arm){x.save();try{rm.arm(x,cx,cy,RR,t,p*0.88,rm.rgb);}catch(e){}x.restore();}
    /* its settlements, and which of them he has actually lived on */
    var ri=U.ROOMS.indexOf(rm), mine=[];
    U.STARS.forEach(function(s){if(s.room===ri)mine.push(s);});
    for(var i=0;i<rm.n;i++){
      var loc=rm.place(i,rm.n,RR), sx=cx+loc[0], sy=cy+loc[1];
      var s3=mine[i], met=s3&&s3.met;
      x.beginPath();x.arc(sx,sy,met?2.6:1.4,0,TAU);
      x.fillStyle=rgba(rm.rgb,p*(met?0.88:0.28));x.fill();
      if(met&&s3.depth>0){
        x.beginPath();x.arc(sx,sy,6+s3.depth*1.5,0,TAU);
        x.strokeStyle=rgba(rm.rgb,p*0.20);x.lineWidth=0.7;x.stroke();
      }
    }
    x.textAlign='center';x.textBaseline='middle';
    x.font='8px "Space Mono", monospace';
    x.fillStyle=rgba(rm.rgb,p*0.42);
    x.fillText(rm.civ.toUpperCase(),cx,cy-rim*0.72);
    /* DWELL · hold still and the room shows what built it. These are the
       belief-structures rooted here, as the structure lens holds them:
       nothing is red, nothing is a diagnosis, and one long met sits
       looser than one still tight. */
    if(this.dwell>0.08&&U.STRUCTURES){
      var al=p*Math.min(1,(this.dwell-0.08)/0.55);
      var here=U.STRUCTURES.filter(function(st){return st.room===ri;});
      x.textAlign='left';x.textBaseline='alphabetic';
      var yy=H-236;
      x.font='7.5px "Space Mono", monospace';
      x.fillStyle=rgba(U.BONE,al*0.30);
      x.fillText(here.length?'WHAT BUILT THIS PLACE':'WHAT THIS ROOM HOLDS',34,yy);
      if(here.length){
        for(var k2=0;k2<Math.min(3,here.length);k2++){
          var st2=here[k2], loose=st2.loose||0;
          x.font='13.5px Lora, Georgia, serif';
          x.fillStyle=rgba(U.BONE,al*(0.44+loose*2.4>0.86?0.86:0.44+loose*2.4));
          x.fillText(st2.name,34,yy+22+k2*23);
          /* the looser it sits, the more the line beneath it has let go */
          var wdt=x.measureText(st2.name).width;
          x.beginPath();
          for(var d2=0;d2<wdt;d2+=3){
            var off=Math.sin(d2*0.09+t*0.6)*loose*9;
            d2?x.lineTo(34+d2,yy+27+k2*23+off):x.moveTo(34,yy+27+k2*23+off);
          }
          x.strokeStyle=rgba(U.BONE,al*0.20);x.lineWidth=0.6;x.stroke();
        }
      }else{
        var lst=mine.filter(function(s){return s.met;});
        for(var k3=0;k3<Math.min(3,lst.length);k3++){
          x.font='13.5px Lora, Georgia, serif';
          x.fillStyle=rgba(U.BONE,al*0.78);
          x.fillText((lst[k3].depth>0?'\u25CF  ':'\u25CB  ')+lst[k3].title,34,yy+22+k3*23);
        }
      }
    }
  },

  /* ── a world: one story, and its three faces ─────────────────── */
  drawWorldLayer:function(x,W,H,Z,t,R0,p){
    var s=this.star;if(!s)return;
    var rim=S.rim(2,Z,R0), cx=W/2, cy=H/2, rm=U.ROOMS[s.room];
    /* still in that room's air */
    if(rm.field){x.save();try{rm.field(x,W,H,t,p*0.30,rm.rgb);}catch(e){}x.restore();}
    var face=((this.turn%TAU)+TAU)%TAU, third=Math.floor(face/(TAU/3));
    /* the body's own terminator, and the seam he is turning */
    x.beginPath();x.arc(cx,cy,rim*0.60,0,TAU);
    x.strokeStyle=rgba(rm.rgb,p*0.26);x.lineWidth=1;x.stroke();
    for(var m=0;m<3;m++){
      var a=this.turn+m*TAU/3;
      x.beginPath();
      for(var q=0;q<=24;q++){
        var f=q/24, yy=cy-rim*0.60+f*rim*1.20;
        var wide=Math.sqrt(Math.max(0,1-Math.pow((yy-cy)/(rim*0.60),2)));
        var xx=cx+Math.cos(a)*rim*0.60*wide;
        if(q===0)x.moveTo(xx,yy);else x.lineTo(xx,yy);
      }
      x.strokeStyle=rgba(rm.rgb,p*(m===0?0.34:0.14));x.lineWidth=m===0?1:0.6;x.stroke();
    }
    x.textAlign='center';x.textBaseline='middle';
    var al=p*0.92;
    if(third===0){
      x.font='7.5px "Space Mono", monospace';
      x.fillStyle=rgba(U.BONE,al*0.34);
      x.fillText(s.codex+' \u00b7 '+rm.name.toUpperCase(),cx,cy+rim*0.86);
      x.font='italic 16px Lora, Georgia, serif';
      x.fillStyle=rgba(U.BONE,al*0.86);
      x.fillText(s.title,cx,cy+rim*0.86+21);
    }else if(third===1&&FL){
      var co=FL.company(s);
      x.font='7.5px "Space Mono", monospace';
      x.fillStyle=rgba(U.BONE,al*0.34);
      x.fillText('WHO SAT WITH IT',cx,cy+rim*0.86);
      var gx=cx-(co.length-1)*13, gy=cy+rim*0.86+22;
      for(var i3=0;i3<co.length;i3++){
        x.font='15px Lora, Georgia, serif';
        x.fillStyle=rgba(co[i3].v.rgb,al*0.90);
        x.fillText(co[i3].v.g,gx+i3*26,gy);
      }
    }else{
      x.font='7.5px "Space Mono", monospace';
      x.fillStyle=rgba(U.BONE,al*0.34);
      x.fillText('HOW OFTEN YOU CAME BACK',cx,cy+rim*0.86);
      for(var k3=0;k3<=s.depth;k3++){
        var rr=8+k3*7;
        x.beginPath();x.arc(cx,cy+rim*0.86+34,rr,0,TAU);
        x.strokeStyle=rgba(rm.rgb,al*(0.30-k3*0.03));x.lineWidth=0.7;x.stroke();
      }
    }
    x.font='7px "Space Mono", monospace';
    x.fillStyle=rgba(U.BONE,p*0.24);
    x.fillText('TURN IT',cx,H-186);
  },

  /* ── the fall: the orrery of selves ──────────────────────────── */
  drawFallLayer:function(x,W,H,Z,t,R0,p){
    var s=this.star;if(!s)return;
    var rim=S.rim(3,Z,R0), cx=W/2, cy=H/2, rm=U.ROOMS[s.room], n=s.depth;
    this.hits=[];
    /* every return a ring, each turning at its own rate, ageing */
    for(var k=n;k>=0;k--){
      var age=n?k/n:0, rr=rim*(0.20+k*0.13);
      var spin=t*(0.05+0.03*(n-k))*(k%2?1:-1);
      x.beginPath();x.ellipse(cx,cy,rr,rr*0.88,spin*0.2,0,TAU);
      x.strokeStyle=rgba(mix(rm.rgb,U.BONE,age*0.70),p*(0.34-age*0.17));
      x.lineWidth=1.4-age*0.8;x.stroke();
      var ia=spin, ix=cx+Math.cos(ia)*rr, iy=cy+Math.sin(ia)*rr*0.88;
      var lit=this.ringLit===k?1:0;
      x.beginPath();x.arc(ix,iy,1.7+(1-age)*1.7+lit*2.2,0,TAU);
      x.fillStyle=rgba(mix(rm.rgb,U.BONE,age*0.80),p*Math.min(1,0.60+lit*0.4));x.fill();
      if(lit){x.beginPath();x.arc(ix,iy,10,0,TAU);
        x.strokeStyle=rgba(mix(rm.rgb,U.BONE,0.5),p*0.34);x.lineWidth=0.8;x.stroke();}
      this.hits.push({kind:'ring',x:ix,y:iy,r:17,k:k,age:age});
    }
    /* the company, seated */
    if(FL){
      var co=FL.company(s);
      for(var i=0;i<co.length;i++){
        var a2=co[i],px,py;
        if(a2.ash){px=cx-rim*0.22;py=cy+rim*0.44;}
        else{
          var m=0,idx=0;
          for(var j=0;j<co.length;j++){if(!co[j].ash){if(j===i)idx=m;m++;}}
          var f=(idx+0.5)/Math.max(1,m), ang=(0.11+f*0.78)*Math.PI, out=1+(idx%2)*0.24;
          px=cx+Math.cos(ang)*rim*0.98*out;py=cy+Math.sin(ang)*rim*0.90*out;
        }
        var open=this.openSeat===i?1:0;
        var gg=x.createRadialGradient(px,py,0,px,py,28);
        gg.addColorStop(0,rgba(a2.v.rgb,p*(0.30+open*0.28)));gg.addColorStop(1,rgba(a2.v.rgb,0));
        x.fillStyle=gg;x.beginPath();x.arc(px,py,28,0,TAU);x.fill();
        x.textAlign='center';x.textBaseline='middle';
        x.font=(a2.ash?12:17)+'px Lora, Georgia, serif';
        x.fillStyle=rgba(a2.v.rgb,p*0.90);x.fillText(a2.v.g,px,py);
        x.font='7.5px "Space Mono", monospace';x.textBaseline='top';
        x.fillStyle=rgba(a2.v.rgb,p*0.52);x.fillText(a2.v.name.toUpperCase(),px,py+14);
        this.hits.push({kind:'seat',x:px,y:py,r:30,i:i,a:a2});
      }
    }
  },

  hit:function(px,py){
    if(!this.hits)return null;
    for(var i=this.hits.length-1;i>=0;i--){
      var h=this.hits[i];
      if(Math.hypot(h.x-px,h.y-py)<h.r)return h;
    }
    return null;
  }
};

function rgba(c,a){return 'rgba('+c[0]+','+c[1]+','+c[2]+','+Math.max(0,Math.min(1,a))+')';}
function mix(a,b,f){return [a[0]+(b[0]-a[0])*f,a[1]+(b[1]-a[1])*f,a[2]+(b[2]-a[2])*f];}

g.UNIDEEP=Deep.init();
})(window);
