/* THE POINT · IV · THE CHAMBER ─────────────────────────────────────
   528 Hz. Voice: "You are the magma layer — pressured by every shell
   above. The pressure is the point; the vessel came with equipment;
   the rules are learnable."

   The one architectural register. Everywhere else is field, drift,
   curtain, orbit. This has WALLS — and walls are the only surface in
   the instrument that can be inscribed, so this is where the reading
   becomes a thing pressed into a surface rather than a thing that
   arrives.

   Three claims, three parts of the room:

   YOU ARE THE MAGMA LAYER, PRESSURED BY EVERY SHELL ABOVE. The light
   comes from BELOW him — he is the molten layer, so the floor glows
   and the vault is dark. And the shells above are not metaphor: the
   number of registers standing over this one sets the load. The vault
   descends on the breath, the walls bow inward, and stress hairlines
   open in the ceiling where the load concentrates.

   THE PRESSURE IS THE POINT. So it is never relieved. It is used.

     THE READING MATERIAL OF THIS WORLD IS BEARING.
       I    admits when he stops.
       II   gives while he goes.
       III  gives where he holds it open.
       IV   gives when he PRESSES BACK — and the harder the press, the
            deeper the inscription is struck into the wall. This is
            letterpress: without pressure there is no impression at
            all. Release and the wall relaxes, and what was struck
            stays struck.

   THE VESSEL CAME WITH EQUIPMENT; THE RULES ARE LEARNABLE. The Vessel
   is the left wall, because equipment hangs on walls. The Rules of
   Play is the FLOOR — the rules are what he is standing on. The
   Others is the back wall, facing him: where every philosophy takes
   its exam is the wall you cannot walk around.

   And this is the rope's home. The rope hangs here, visible, because
   the chamber is the register the rope was built for. ──────────── */
(function(g){
'use strict';
var P=g.POINT, S=g.SPINE, TAU=Math.PI*2;
var D4=P.DIMS[3], HUE=P.HUES.m4;

/* ── the room ─────────────────────────────────────────────────────
   left wall · the Vessel      four niches, at working height
   floor     · the Rules       six flagstones, underfoot
   back wall · the Others      one niche, facing him, unavoidable */
var NICHES=[];
(function build(){
  var U=D4.universes;
  U[0].stars.forEach(function(id,i){
    NICHES.push({id:id,n:P.N[id],u:0,uname:U[0].name,wall:'left',
      d:0.18+i*0.21, h:0.40+((i%2)?0.12:-0.06)});
  });
  U[1].stars.forEach(function(id,i){
    NICHES.push({id:id,n:P.N[id],u:1,uname:U[1].name,wall:'floor',
      d:0.14+Math.floor(i/2)*0.28, h:(i%2)?0.30:0.70});
  });
  U[2].stars.forEach(function(id,i){
    NICHES.push({id:id,n:P.N[id],u:2,uname:U[2].name,wall:'back',d:0.27,h:0.16});
  });
})();
var STATUS={w:'\u25CF',p:'\u25D0',s:'\u25CB'};

var Four={
  NICHES:NICHES,DIM:D4,HUE:HUE,
  press:0,          /* how hard he is bearing, 0 \u2192 1 */
  on:null,          /* the niche he is pressing */
  given:0,
  struck:{},        /* what has already been struck into the wall \u2014 it stays */
  easing:0,
  hits:[],

  reset:function(){this.press=0;this.on=null;this.given=0;this.easing=0;},

  /* the load standing over this register. Not decoration: it is the count
     of shells above, and it is what the room is holding up. */
  load:function(Z){return Math.max(0,Math.min(1,(Z+4)/9));},

  /* ── the projection ────────────────────────────────────────────
     One-point perspective, vanishing on the particle. Under load the
     vault descends and the walls bow: the room deforms because it is
     bearing something. */
  BACK:0.30,                        /* how far off the back wall stands */
  proj:function(wall,d,h,cx,cy,rim,pr){
    var sc=1/(1+d*3.1);
    var W=rim*(1.04-pr*0.05), H=rim*(1.12-pr*0.13);
    var bow=Math.sin(d*Math.PI)*pr*rim*0.09;
    if(wall==='left') return [cx-(W-bow)*sc, cy+(h-0.5)*2*H*sc, sc];
    if(wall==='right')return [cx+(W-bow)*sc, cy+(h-0.5)*2*H*sc, sc];
    if(wall==='floor')return [cx+(h-0.5)*2*W*sc, cy+(H-bow*0.6)*sc, sc];
    /* the back wall: d runs across it, h runs up it. Both, or it is not a
       wall — and the vanishing point belongs to the particle, never to a
       niche. */
    var k=this.BACK;
    return [cx+(d-0.5)*2*W*k, cy+(h-0.5)*2*H*k, k];
  },

  /* ── bearing ───────────────────────────────────────────────────
     He presses a surface. The press is a hold, and holding is the whole
     of it: nothing here is a tap, because an impression cannot be made
     by touching. */
  set:function(px,py,cx,cy,rim,Z){
    var best=null,bd=1e9;
    for(var i=0;i<NICHES.length;i++){
      var nn=NICHES[i], p=this.proj(nn.wall,nn.d,nn.h,cx,cy,rim,this.press);
      var d=Math.hypot(p[0]-px,p[1]-py);
      var reach=Math.max(26,rim*0.15*p[2]+22);
      if(d<reach&&d<bd){bd=d;best=nn;}
    }
    if(best!==this.on){this.on=best;this.given=0;}
    return best;
  },
  bear:function(dt,Z){
    if(!this.on)return null;
    /* the deeper the shell, the more load there already is, so his own
       press has more to work with */
    this.press=Math.min(1,this.press+dt*(0.30+this.load(Z)*0.26));
    var gates=[0.22,0.46,0.70,0.92];
    if(this.given<4&&this.press>=gates[this.given]){
      this.given++;
      this.struck[this.on.id]=Math.max(this.struck[this.on.id]||0,this.given);
      return {k:['say','walk','hand','open'][this.given-1],i:this.given};
    }
    return null;
  },
  release:function(){if(this.on&&this.press>0.1)this.easing=1;},
  update:function(dt,holding){
    if(!holding){
      this.press=Math.max(0,this.press-dt*0.52);
      if(this.press<=0.02){this.on=null;this.given=0;}
    }
    if(this.easing>0)this.easing=Math.max(0,this.easing-dt*0.8);
  },
  displaced:function(){return this.given/4;},

  /* ── the room, drawn ─────────────────────────────────────────── */
  draw:function(x,W,H,Z,t,R0,p){
    var rim=S.rim(9,Z,R0), cx=W/2, cy=H/2;
    var br=g.BODY?g.BODY.breath():0.5;
    var ld=this.load(Z), pr=Math.max(ld*0.34,this.press);
    var dsp=this.displaced(), A=p*(1-dsp*0.46);
    this.hits=[];
    if(A<=0.004)return;
    var self=this;
    x.save();

    /* the magma under the floor. He is the molten layer, so the light
       comes from below and the vault is dark. */
    var fl=this.proj('floor',0,0.5,cx,cy,rim,pr);
    var mg=x.createLinearGradient(0,cy+rim*0.30,0,H);
    mg.addColorStop(0,rgba(HUE,0));
    mg.addColorStop(0.42,rgba(HUE,A*0.10*(0.7+br*0.4)));
    mg.addColorStop(1,rgba(mix(HUE,'#FFD9A8',0.30),A*(0.20+pr*0.16)*(0.8+br*0.3)));
    x.fillStyle=mg;x.fillRect(0,cy,W,H-cy);

    /* the room's edges, receding to the particle */
    var corners=[['left',0],['left',1],['right',0],['right',1]];
    x.strokeStyle=rgba(HUE,A*0.20);x.lineWidth=0.8;
    [0,1].forEach(function(hh){
      ['left','right'].forEach(function(wall){
        var a=self.proj(wall,0,hh,cx,cy,rim,pr), b=self.proj(wall,1,hh,cx,cy,rim,pr);
        x.beginPath();x.moveTo(a[0],a[1]);x.lineTo(b[0],b[1]);x.stroke();
      });
    });
    /* the back wall: the one he cannot walk around */
    var bl=this.proj('back',0,0.5,cx,cy,rim,pr), brt=this.proj('back',1,0.5,cx,cy,rim,pr);
    var bh=rim*(1.12-pr*0.13)*this.BACK;
    x.strokeStyle=rgba(HUE,A*0.26);x.lineWidth=1;
    x.strokeRect(bl[0],cy-bh,brt[0]-bl[0],bh*2);

    /* THE LOAD. Stress hairlines open in the vault where it concentrates,
       and they open further the more he presses back. */
    var vaults=9;
    for(var v=0;v<vaults;v++){
      var f=(v+0.5)/vaults;
      var conc=Math.pow(Math.sin(f*Math.PI),1.6);
      var a0=this.proj('left',0,1,cx,cy,rim,pr), a1=this.proj('right',0,1,cx,cy,rim,pr);
      var sx=a0[0]+(a1[0]-a0[0])*f;
      var sag=conc*(ld*rim*0.05+pr*rim*0.055);
      x.beginPath();
      x.moveTo(sx,a0[1]);
      x.quadraticCurveTo(sx,a0[1]+sag*1.6,cx+(sx-cx)*this.BACK,cy-bh+sag*0.5);
      x.strokeStyle=rgba(mix(HUE,'#FFE2C4',conc*0.5),A*(0.06+conc*(0.10+pr*0.20)));
      x.lineWidth=0.6+conc*pr*1.0;x.stroke();
    }

    /* the shells above, named as weight \u2014 never as a number */
    if(A>0.20&&rim>150){
      x.textAlign='center';x.textBaseline='middle';
      x.font='7.5px "Space Mono", monospace';
      x.fillStyle=rgba(mix(HUE,'#FFE8D4',0.5),A*(0.20+pr*0.24));
      x.fillText('EVERY SHELL ABOVE IS STANDING ON THIS ONE',cx,cy-bh-18);
    }

    /* ── the niches, and what is struck into them ── */
    for(var i=0;i<NICHES.length;i++){
      var nn=NICHES[i], pt=this.proj(nn.wall,nn.d,nn.h,cx,cy,rim,pr);
      var mine=this.on===nn, st=this.struck[nn.id]||0;
      var R=Math.max(1.8,rim*0.017*pt[2]*2.2);
      var lit=mine?this.press:0;
      var al=A*(0.44+lit*0.56)*(0.72+pt[2]*0.7);
      /* the niche itself: a cut in the wall, lit from the floor */
      var col=mix(HUE,'#FFE0BC',0.18+lit*0.42);
      var gr=x.createRadialGradient(pt[0],pt[1],0,pt[0],pt[1],R*(6+lit*8));
      gr.addColorStop(0,rgba(col,al*(0.40+lit*0.34)));
      gr.addColorStop(0.24,rgba(HUE,al*0.18));
      gr.addColorStop(1,rgba(HUE,0));
      x.fillStyle=gr;x.beginPath();x.arc(pt[0],pt[1],R*(6+lit*8),0,TAU);x.fill();
      x.beginPath();x.arc(pt[0],pt[1],R,0,TAU);
      x.fillStyle=rgba(mix(col,'#FFF6EC',0.4),Math.min(1,al*1.2));x.fill();
      /* what has been struck stays struck \u2014 a debossed ring in the wall */
      if(st>0){
        for(var k=0;k<st;k++){
          x.beginPath();x.arc(pt[0],pt[1],R*(2.6+k*1.5),0,TAU);
          x.strokeStyle=rgba(mix(HUE,'#2A150C',0.4),A*0.30);x.lineWidth=1.1;x.stroke();
          x.beginPath();x.arc(pt[0]-0.6,pt[1]-0.6,R*(2.6+k*1.5),0,TAU);
          x.strokeStyle=rgba('#FFE8D0',A*0.14);x.lineWidth=0.6;x.stroke();
        }
      }
      x.textAlign='center';x.textBaseline='middle';
      if(pt[2]>0.30&&A>0.10){
        x.font='7px "Space Mono", monospace';
        x.fillStyle=rgba(HUE,A*0.36);
        x.fillText(STATUS[nn.n.st],pt[0],pt[1]-R*3.6);
      }
      /* the title is struck into the wall, not laid on it: an impression
         needs a dark side and a lit side, and it deepens under load */
      if(mine&&this.press>0.05){
        var ta=A*Math.min(1,this.press*2.4);
        x.font='italic 13.5px Lora, Georgia, serif';
        var ty=pt[1]+R*4.6;
        x.fillStyle=rgba('#28130A',ta*0.86);x.fillText(nn.n.t,pt[0]+0.9,ty+0.9);
        x.fillStyle=rgba(mix('#FFEEDC',HUE,0.18),ta*0.94);x.fillText(nn.n.t,pt[0],ty);
      }
      this.hits.push({n:nn,x:pt[0],y:pt[1],rad:Math.max(26,rim*0.15*pt[2]+22)});
    }

    /* the three parts of the room, named where they are */
    if(A>0.06&&rim>140){
      x.textAlign='center';x.textBaseline='middle';
      x.font='7.5px "Space Mono", monospace';
      var lp=this.proj('left',0.52,0.86,cx,cy,rim,pr);
      x.fillStyle=rgba(HUE,A*0.38);x.fillText(D4.universes[0].name.toUpperCase(),lp[0]+42,lp[1]);
      var fp=this.proj('floor',0.42,0.5,cx,cy,rim,pr);
      x.fillStyle=rgba(mix(HUE,'#FFD9A8',0.3),A*0.34);
      x.fillText(D4.universes[1].name.toUpperCase(),fp[0],fp[1]+16);
      var op=this.proj('back',0.27,0.16,cx,cy,rim,pr);
      x.fillStyle=rgba(HUE,A*0.44);x.fillText(D4.universes[2].name.toUpperCase(),op[0],op[1]-16);
    }

    /* the rope hangs here. This is its home; it is not explained. */
    var rx=cx+rim*0.62, ry0=cy-bh*1.1;
    x.beginPath();
    for(var q=0;q<=16;q++){
      var f2=q/16, yy=ry0+f2*rim*0.60;
      var xx=rx+Math.sin(f2*2.2+t*0.16)*rim*0.012;
      q?x.lineTo(xx,yy):x.moveTo(xx,yy);
    }
    x.strokeStyle=rgba(mix(HUE,'#E8D6C2',0.5),A*0.24);x.lineWidth=1.1;x.stroke();

    /* what the world asks, in words */
    x.textAlign='center';x.textBaseline='middle';
    x.font='8.5px "Space Mono", monospace';
    if(!this.on&&this.easing<=0.02&&A>0.30){
      x.fillStyle=rgba('#EDE8E3',A*0.38*(0.7+br*0.4));
      x.fillText('PRESS A WALL \u00b7 AND BEAR IT',cx,H-150);
    }else if(this.on){
      var word=this.given>=4?'struck':this.press<0.22?'bearing':
        this.press<0.50?'it is taking':this.press<0.76?'deeper':'nearly through';
      x.fillStyle=rgba('#EDE8E3',A*0.46);
      x.fillText(word.toUpperCase(),cx,H-150);
    }else if(this.easing>0.02){
      x.fillStyle=rgba('#EDE8E3',this.easing*p*0.30);
      x.fillText('THE WALL EASED. WHAT WAS STRUCK STAYS STRUCK.',cx,H-150);
    }
    x.restore();
  }
};

function rgba(h,a){
  var r=parseInt(h.slice(1,3),16),gg=parseInt(h.slice(3,5),16),b=parseInt(h.slice(5,7),16);
  return 'rgba('+r+','+gg+','+b+','+Math.max(0,Math.min(1,a))+')';
}
function mix(a,b,f){
  var pa=[parseInt(a.slice(1,3),16),parseInt(a.slice(3,5),16),parseInt(a.slice(5,7),16)];
  var pb=[parseInt(b.slice(1,3),16),parseInt(b.slice(3,5),16),parseInt(b.slice(5,7),16)];
  var hx=function(v){v=Math.round(Math.max(0,Math.min(255,v))).toString(16);return v.length<2?'0'+v:v;};
  return '#'+hx(pa[0]+(pb[0]-pa[0])*f)+hx(pa[1]+(pb[1]-pa[1])*f)+hx(pa[2]+(pb[2]-pa[2])*f);
}
g.FOUR=Four;
})(window);
