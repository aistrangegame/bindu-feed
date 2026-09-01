/* THE POINT · VI · THE RETURN ─────────────────────────────────────
   741 Hz. Voice: "The window is open and you raised your hand to be
   here for it. The crossing is trainable; the frequency is chosen
   daily; nothing gathered is lost."

   THE HORIZON. One low line across the world. Everything he has is
   below it. Everything that has not come back yet is above it.

   DEPTH IS TIME, NOT DISTANCE. The near field is banded — the nearest
   band is now, and each band further back is further back. The Window's
   three stand in the nearest band. The Crossing's three stand deeper.
   Deep Time stands on the horizon itself, and does not belong to him.

   ── THE GESTURE · SEND AND WAIT ─────────────────────────────────
   He takes a star, aims, and lets go. That is the entire act. It rises,
   crosses the line, travels out, TURNS — visibly, slowly, at the far
   point of its arc — and comes back on its own time carrying one
   section with it. He cannot pull it. He cannot hurry it. He cannot
   call it home.

     THE READING MATERIAL OF THIS WORLD IS THE INTERVAL.
       I    admits when he stops.
       II   gives while he goes.
       III  gives where he holds it open.
       IV   gives when he presses back.
       V    gives each time a face comes round.
       VI   gives when what he let go of comes back. The waiting is
            not the cost of the reading. The waiting IS the reading.

   Each successive send is a wider arc and a longer wait: three seconds,
   then five, then eight, then eleven. By the fourth the lap is most of
   a minute of the world's life, and he will have sent others meanwhile.
   Several can be out at once. They return in their own order, not his.

   AND IF HE LEAVES THE REGISTER, THEY STILL COME BACK. The flights run
   on a wall clock, not on his attention. What returns while he is away
   waits at its post, lit, and is handed over the moment he comes back.
   Nothing gathered is lost — including by wandering off.

   EVERY RETURN COMES THROUGH THE PARTICLE. The path home bends into
   the centre before the star takes its place again, and the centre
   brightens as it passes. Monroe's I-There, drawn: each probe feeds its
   harvest back into the whole, and the whole is enriched by every one.

   THE ARCS ARE KEPT. Every completed lap leaves its curve in the sky,
   permanently, thinly. Late in the world the sky is a sheaf of them —
   the cluster's own record, and the only score this world keeps.

   ── x-cycles · THE EXCEPTION (ruled) ────────────────────────────
   Deep Time is not his lap. It is the ones before — Göbekli Tepe
   buried on purpose, the Younger Dryas, the yuga wheel, thresholds
   that recur. It cannot be picked up and it cannot be sent: a hand
   that reaches for it passes through.

   It arrives unasked. Once he has received enough returns of his own to
   know what a return looks like, it comes over the horizon from the
   deepest band — already mid-flight when it appears, because it has
   been travelling the whole time — and hands over all four at once.
   The crossing was made before him and the notes were left behind. ── */
(function(g){
'use strict';
var P=g.POINT, S=g.SPINE, TAU=Math.PI*2;
var D6=P.DIMS[5], HUE=P.HUES.m6;

var UNAME={};
D6.universes.forEach(function(u){u.stars.forEach(function(id){UNAME[id]=u.name;});});

/* the near field, banded. qy is depth: larger is nearer, and the
   horizon is the limit everything recedes toward. */
var STARS=[
  {id:'x-window',    qx:-0.46,qy: 0.34},
  {id:'x-volunteer', qx: 0.08,qy: 0.30},
  {id:'x-choose',    qx: 0.52,qy: 0.22},
  {id:'x-death',     qx:-0.46,qy: 0.00},
  {id:'x-evidence',  qx: 0.24,qy: 0.06},
  {id:'x-graduation',qx: 0.56,qy:-0.10},
  {id:'x-cycles',    qx: 0.00,qy:-0.36,deep:true}
];
STARS.forEach(function(s){s.n=P.N[s.id];s.uname=UNAME[s.id];});
var BY={};STARS.forEach(function(s){BY[s.id]=s;});
var STATUS={w:'\u25CF',p:'\u25D0',s:'\u25CB'};
var ORD=['first return','second return','third return','fourth return'];
/* the wait, per lap. It grows because the arc grows. */
var DUR=[3.2,5.4,8.0,11.2];

var Six={
  STARS:STARS,DIM:D6,HUE:HUE,
  holding:null,        /* the star under his hand, not yet let go */
  aim:0,               /* where the hand has taken it, -1 .. 1 */
  lift:0,              /* how far he has drawn it up out of its post */
  arcs:[],             /* everything in flight, on the wall clock */
  trails:[],           /* every lap that has completed, kept */
  got:{},              /* per star: how many have come home */
  pend:[],             /* arrivals waiting for him to be present */
  home:0,              /* the flash at the centre as a probe passes through */
  total:0,
  deepSent:false,
  reading:null,        /* the star the panel currently belongs to */
  hits:[],

  /* leaving the register closes the reading. It does not cancel a lap:
     nothing in flight cares whether he is watching. */
  reset:function(){this.holding=null;this.lift=0;this.reading=null;},

  /* ── taking hold, aiming, letting go ──────────────────────────── */
  grab:function(px,py,cx,cy,rim){
    var best=null,bd=1e9;
    for(var i=0;i<STARS.length;i++){
      var st=STARS[i];
      if(st.deep)continue;                      /* the hand passes through */
      if(this.flying(st.id))continue;           /* it is not here to be taken */
      if((this.got[st.id]||0)>=4)continue;      /* it has come all the way home */
      var sp=this.spot(st,cx,cy,rim);
      var d=Math.hypot(sp[0]-px,sp[1]-py), reach=Math.max(30,rim*0.15*sp[2]);
      if(d<reach&&d<bd){bd=d;best=st;}
    }
    if(best){this.holding=best;this.aim=0;this.lift=0;}
    return best;
  },
  aimTo:function(px,py,cx,cy,rim){
    if(!this.holding)return;
    var sp=this.spot(this.holding,cx,cy,rim);
    this.aim=Math.max(-1,Math.min(1,(px-sp[0])/(rim*0.46)));
    this.lift=Math.max(0,Math.min(1,(sp[1]-py)/(rim*0.34)));
  },
  /* the whole act. After this line the hand has nothing further to do
     with it, and there is no way written anywhere to get it back. */
  release:function(){
    var st=this.holding;this.holding=null;
    if(!st)return null;
    if(this.lift<0.14){this.lift=0;return null;}   /* not a send. Just a touch. */
    var n=(this.got[st.id]||0)+1;
    var a={id:st.id,n:n,aim:this.aim||((Math.random()-0.5)*0.5),
           t0:performance.now(),dur:DUR[Math.min(3,n-1)]*1000,deep:false,done:false};
    this.arcs.push(a);this.lift=0;
    return a;
  },
  flying:function(id){
    for(var i=0;i<this.arcs.length;i++)if(this.arcs[i].id===id)return this.arcs[i];
    return null;
  },

  /* ── the wall clock. Runs whether or not he is in the register. ── */
  tick:function(){
    var now=performance.now(),keep=[],self=this;
    for(var i=0;i<this.arcs.length;i++){
      var a=this.arcs[i], u=(now-a.t0)/a.dur;
      if(u<1){keep.push(a);continue;}
      /* it is home */
      this.trails.push({id:a.id,aim:a.aim,n:a.n,deep:a.deep,at:now});
      if(this.trails.length>26)this.trails.shift();
      this.home=1;
      if(a.deep){
        this.got[a.id]=4;
        for(var k=1;k<=4;k++)this.pend.push({st:BY[a.id],i:k,n:4,deep:true,all:k===1});
      }else{
        this.got[a.id]=a.n;this.total++;
        this.pend.push({st:BY[a.id],i:a.n,n:a.n,deep:false});
      }
    }
    this.arcs=keep;
    /* Deep Time lets itself go, once he knows what a return looks like.
       It is already mid-flight when it appears: it has been travelling
       since long before he arrived. */
    if(!this.deepSent&&this.total>=4){
      this.deepSent=true;
      this.arcs.push({id:'x-cycles',n:4,aim:-0.34,
        t0:performance.now()-9200,dur:23000,deep:true,done:false});
    }
  },
  /* what he is present for, handed over one at a time */
  take:function(){return this.pend.length?this.pend.shift():null;},
  update:function(dt){
    this.home=Math.max(0,this.home-dt*1.5);
  },
  /* how much of this world is out there — the voice's own wetness */
  outbound:function(){
    var now=performance.now(),s=0;
    for(var i=0;i<this.arcs.length;i++){
      var u=(now-this.arcs[i].t0)/this.arcs[i].dur;
      if(u>0&&u<1)s+=Math.sin(Math.min(1,u)*Math.PI);
    }
    return Math.min(1,s*0.62);
  },
  displaced:function(){
    /* while his hand is on a star, or while anything is away, the reading
       yields — he has to be able to see the horizon to send over it */
    if(!this.reading||this.holding)return -1;
    return Math.min(1,(this.got[this.reading.id]||0)/4)*0.54;
  },
  quiet:function(){return !this.holding&&!this.arcs.length;},

  /* ── the geometry ──────────────────────────────────────────────── */
  hy:function(cy,rim){return cy-rim*0.46;},
  spot:function(st,cx,cy,rim){
    var sc=0.48+(st.qy+0.46)*0.66;
    return [cx+st.qx*rim,cy+st.qy*rim,Math.max(0.30,sc)];
  },
  /* one lap. Out over the line, a visible turn at the far point, back
     over the line, home through the centre, and only then to its post. */
  path:function(a,u,cx,cy,rim){
    var st=BY[a.id], sp=this.spot(st,cx,cy,rim), hy=this.hy(cy,rim);
    var c1x=cx+a.aim*rim*0.52;
    var c2x=cx-a.aim*rim*0.26+(a.n%2?rim*0.14:-rim*0.12);
    var far=cx+a.aim*rim*(0.98+a.n*0.13);
    var x,y,sc,al,beyond=false;
    if(u<0.20){
      var v=u/0.20, w=sm(v);
      x=lerp(sp[0],c1x,w);
      y=lerp(sp[1],hy,w)-Math.sin(v*Math.PI)*rim*0.13;
      sc=lerp(sp[2],0.66,w);al=1;
    }else if(u<0.74){
      beyond=true;
      var v2=(u-0.20)/0.54, ar=Math.sin(v2*Math.PI);
      if(v2<0.5)x=lerp(c1x,far,sm(v2*2));
      else x=lerp(far,c2x,sm((v2-0.5)*2));
      y=hy-rim*(0.035+0.20*ar)*(0.70+a.n*0.09);
      sc=0.66-0.42*ar;
      /* it dims as it goes and is nearly gone at the turn — and the turn
         itself is the slowest part of the lap, because turning is */
      al=0.90-0.62*ar;
    }else if(u<0.93){
      var v3=(u-0.74)/0.19, w3=sm(v3);
      x=lerp(c2x,cx,w3);
      y=lerp(hy,cy,w3)-Math.sin(v3*Math.PI)*rim*0.10;
      sc=lerp(0.66,1.24,w3);al=1;
    }else{
      var v4=(u-0.93)/0.07, w4=sm(v4);
      x=lerp(cx,sp[0],w4);y=lerp(cy,sp[1],w4);
      sc=lerp(1.24,sp[2],w4);al=1;
    }
    return [x,y,sc,al,beyond];
  },

  /* ── the world ─────────────────────────────────────────────────── */
  draw:function(x,W,H,Z,t,R0,p){
    var rim=S.rim(11,Z,R0), cx=W/2, cy=H/2, hy=this.hy(cy,rim);
    var br=g.BODY?g.BODY.breath():0.5, now=performance.now();
    var dsp=Math.max(0,this.displaced()), A=p*(1-dsp*0.44);
    this.hits=[];
    if(A<=0.004)return;
    var self=this;
    x.save();x.textAlign='center';x.textBaseline='middle';

    /* BEYOND. Above the line the world thins out to nothing — it is not
       a place, it is where things are while they are away. */
    var sg=x.createLinearGradient(0,hy-rim*0.95,0,hy);
    sg.addColorStop(0,'rgba(9,4,12,'+(A*0.80)+')');
    sg.addColorStop(0.62,'rgba(14,5,16,'+(A*0.34)+')');
    sg.addColorStop(1,'rgba(20,7,20,0)');
    x.fillStyle=sg;x.fillRect(0,hy-rim*0.95,W,rim*0.95);

    /* THE BANDS. Depth is time: the nearest is now, and each one back is
       further back. They converge on the line because everything does. */
    for(var b=0;b<7;b++){
      var q=b/6, by=lerp(cy+rim*0.44,hy,sm(q*0.98));
      var sp2=1-q;
      var ba=A*(0.09+sp2*0.17)*(0.72+br*0.32);
      x.strokeStyle=rgba(HUE,ba);x.lineWidth=0.6+sp2*0.5;
      x.beginPath();
      var inset=W*0.5*q*0.42;
      x.moveTo(inset,by);x.lineTo(W-inset,by);x.stroke();
    }

    /* THE KEPT ARCS. Every lap that has completed, still in the sky.
       No count, no badge — the record is the shape of the sky. */
    for(var i=0;i<this.trails.length;i++){
      var tr=this.trails[i], age=Math.min(1,(now-tr.at)/2600);
      var ta=A*(0.09+0.22*(1-age*0.72))*(tr.deep?1.7:1);
      x.strokeStyle=rgba(tr.deep?mix(HUE,'#FFE6C9',0.42):HUE,ta);
      x.lineWidth=tr.deep?1.0:0.6;
      x.beginPath();
      for(var s2=0;s2<=30;s2++){
        var pu=0.03+s2/30*0.90, pp=this.path(tr,pu,cx,cy,rim);
        s2?x.lineTo(pp[0],pp[1]):x.moveTo(pp[0],pp[1]);
      }
      x.stroke();
    }

    /* THE HORIZON. One line. It is not a wall and it is not a door: it
       is where seeing stops and waiting starts. */
    var hg=x.createLinearGradient(0,0,W,0);
    hg.addColorStop(0,rgba(HUE,0));
    hg.addColorStop(0.14,rgba(HUE,A*0.40));
    hg.addColorStop(0.5,rgba(mix(HUE,'#FFE9F4',0.62),A*(0.66+br*0.24)));
    hg.addColorStop(0.86,rgba(HUE,A*0.40));
    hg.addColorStop(1,rgba(HUE,0));
    x.strokeStyle=hg;x.lineWidth=1.2;
    x.beginPath();x.moveTo(0,hy);x.lineTo(W,hy);x.stroke();
    var gl2=x.createLinearGradient(0,hy-rim*0.10,0,hy+rim*0.05);
    gl2.addColorStop(0,rgba(HUE,0));
    gl2.addColorStop(0.72,rgba(HUE,A*0.15*(0.6+br*0.5)));
    gl2.addColorStop(1,rgba(HUE,0));
    x.fillStyle=gl2;x.fillRect(0,hy-rim*0.10,W,rim*0.15);

    /* the posts. A star that is away leaves its place empty and lit —
       the world shows what is out, and does not say when. */
    for(var j=0;j<STARS.length;j++){
      var st=STARS[j], sp=this.spot(st,cx,cy,rim), fl=this.flying(st.id);
      var g6=this.got[st.id]||0, mine=this.holding===st;
      var full=g6>=4, al=A*(0.42+sp[2]*0.58);

      if(fl){
        /* the empty post, still warm */
        x.strokeStyle=rgba(HUE,al*0.42*(0.5+br*0.5));x.lineWidth=0.8;
        x.beginPath();x.arc(sp[0],sp[1],4.6+br*1.6,0,TAU);x.stroke();
        x.beginPath();x.arc(sp[0],sp[1],9.5,0,TAU);
        x.strokeStyle=rgba(HUE,al*0.16);x.stroke();
      }else{
        var r6=(st.deep?2.0:2.6)*sp[2]+(mine?1.6:0)+br*0.5;
        var lit=full?1:(g6?0.34+g6*0.16:0.14);
        var hal=r6*(st.deep?9:7)*(1+(mine?self.lift*1.2:0));
        var rg=x.createRadialGradient(sp[0],sp[1],0,sp[0],sp[1],hal);
        rg.addColorStop(0,rgba(mix(HUE,'#FFF2F8',0.72),al*(0.42+lit*0.52)));
        rg.addColorStop(0.22,rgba(HUE,al*(0.22+lit*0.34)));
        rg.addColorStop(1,rgba(HUE,0));
        x.fillStyle=rg;x.beginPath();x.arc(sp[0],sp[1],hal,0,TAU);x.fill();
        x.beginPath();x.arc(sp[0],sp[1],r6,0,TAU);
        x.fillStyle=rgba(mix('#FFF3F8',HUE,full?0.10:0.34),al*(0.74+lit*0.26));x.fill();
        /* Deep Time keeps its own ring, and it is not one of his */
        if(st.deep){
          x.setLineDash([2,5]);
          x.strokeStyle=rgba(HUE,al*(this.deepSent?0.10:0.26)*(0.6+br*0.6));x.lineWidth=0.7;
          x.beginPath();x.arc(sp[0],sp[1],12+br*2.5,0,TAU);x.stroke();
          x.setLineDash([]);
        }
        /* how many laps this one has made, as light, never as a number */
        for(var k2=0;k2<g6;k2++){
          x.strokeStyle=rgba(HUE,al*0.30);x.lineWidth=0.6;
          x.beginPath();x.arc(sp[0],sp[1],7+k2*3.4,-0.9,0.9);x.stroke();
        }
      }
      /* the draw of the hand: the star lifts out of its post toward the
         line, and the aim shows as the lean of the whole gesture */
      if(mine&&this.lift>0.02){
        var lx=sp[0]+this.aim*rim*0.46*this.lift, ly=lerp(sp[1],hy,this.lift*0.86);
        x.strokeStyle=rgba(HUE,A*0.24*this.lift);x.lineWidth=0.8;
        x.setLineDash([2,4]);x.beginPath();x.moveTo(sp[0],sp[1]);x.lineTo(lx,ly);x.stroke();
        x.setLineDash([]);
        var dg=x.createRadialGradient(lx,ly,0,lx,ly,26*(0.5+this.lift));
        dg.addColorStop(0,rgba('#FFF2F8',A*(0.40+this.lift*0.5)));
        dg.addColorStop(0.3,rgba(HUE,A*0.30*this.lift));
        dg.addColorStop(1,rgba(HUE,0));
        x.fillStyle=dg;x.beginPath();x.arc(lx,ly,26*(0.5+this.lift),0,TAU);x.fill();
        x.beginPath();x.arc(lx,ly,2.8+this.lift*1.4,0,TAU);
        x.fillStyle=rgba('#FFF6FA',A*0.92);x.fill();
        /* where it will cross, marked on the line while he still holds it */
        var mkx=cx+this.aim*rim*0.52;
        x.strokeStyle=rgba(mix(HUE,'#FFE9F4',0.6),A*0.34*this.lift);x.lineWidth=1;
        x.beginPath();x.moveTo(mkx,hy-5);x.lineTo(mkx,hy+5);x.stroke();
      }
      if(!fl&&!mine&&rim>150&&A>0.10){
        x.font='7px "Space Mono", monospace';
        x.fillStyle=rgba(HUE,A*0.30);
        x.fillText(STATUS[st.n.st],sp[0],sp[1]-11*sp[2]-5);
      }
      this.hits.push({n:st,x:sp[0],y:sp[1],rad:Math.max(30,rim*0.15*sp[2])});
    }

    /* WHAT IS OUT THERE. Drawn last so it passes in front of the line
       going and coming — the only thing in the world that crosses it. */
    for(var f=0;f<this.arcs.length;f++){
      var a=this.arcs[f], u=(now-a.t0)/a.dur;
      if(u<0||u>1)continue;
      var pp=this.path(a,u,cx,cy,rim);
      var ca=A*pp[3], cr=(a.deep?3.4:2.4)*pp[2];
      /* the tail: where it has just been, and nothing more */
      x.beginPath();
      for(var s3=1;s3<=13;s3++){
        var tu=Math.max(0,u-s3*0.012), tp=this.path(a,tu,cx,cy,rim);
        s3===1?x.moveTo(tp[0],tp[1]):x.lineTo(tp[0],tp[1]);
      }
      x.strokeStyle=rgba(mix(HUE,'#FFE9F4',0.4),ca*0.34);x.lineWidth=0.9;x.stroke();
      var cg=x.createRadialGradient(pp[0],pp[1],0,pp[0],pp[1],cr*8);
      cg.addColorStop(0,rgba('#FFF4F9',ca*0.80));
      cg.addColorStop(0.18,rgba(mix(HUE,'#FFD9EC',0.35),ca*0.42));
      cg.addColorStop(1,rgba(HUE,0));
      x.fillStyle=cg;x.beginPath();x.arc(pp[0],pp[1],cr*8,0,TAU);x.fill();
      x.beginPath();x.arc(pp[0],pp[1],cr,0,TAU);
      x.fillStyle=rgba('#FFF7FB',Math.min(1,ca));x.fill();
      /* crossing the line: it flattens into the horizon and the line
         takes the light for a moment. A thing going over a horizon is
         not a thing fading out. */
      var dh=Math.abs(pp[1]-hy);
      if(dh<rim*0.09){
        var kf=1-dh/(rim*0.09);
        var kg2=x.createLinearGradient(pp[0]-rim*0.34,0,pp[0]+rim*0.34,0);
        kg2.addColorStop(0,rgba(HUE,0));
        kg2.addColorStop(0.5,rgba(mix(HUE,'#FFF0F7',0.7),ca*kf*0.62));
        kg2.addColorStop(1,rgba(HUE,0));
        x.strokeStyle=kg2;x.lineWidth=1.4;
        x.beginPath();x.moveTo(pp[0]-rim*0.34,hy);x.lineTo(pp[0]+rim*0.34,hy);x.stroke();
      }
      /* the turn. The far point of the lap, where it stops going out and
         starts coming back — held long enough to be watched. */
      if(pp[4]&&Math.abs(u-0.47)<0.05){
        var tf=1-Math.abs(u-0.47)/0.05;
        x.strokeStyle=rgba(mix(HUE,'#FFE9F4',0.5),A*tf*0.30);x.lineWidth=0.7;
        x.beginPath();x.arc(pp[0],pp[1],10+tf*12,0,TAU);x.stroke();
      }
    }

    /* the centre takes the harvest. Every probe passes through it on the
       way back, and the whole is enriched by every one. */
    if(this.home>0.01){
      var hf=this.home*this.home;
      var hg2=x.createRadialGradient(cx,cy,0,cx,cy,rim*0.44*hf);
      hg2.addColorStop(0,'rgba(255,235,246,'+(A*hf*0.30)+')');
      hg2.addColorStop(0.4,rgba(HUE,A*hf*0.14));
      hg2.addColorStop(1,rgba(HUE,0));
      x.fillStyle=hg2;x.beginPath();x.arc(cx,cy,rim*0.44*hf,0,TAU);x.fill();
      x.strokeStyle=rgba(mix(HUE,'#FFF2F8',0.6),A*hf*0.42);x.lineWidth=0.8;
      x.beginPath();x.arc(cx,cy,rim*(0.10+(1-hf)*0.30),0,TAU);x.stroke();
    }

    /* what the world asks, in words */
    x.font='8.5px "Space Mono", monospace';
    var line='';
    if(this.holding)line=this.lift<0.14?'DRAW IT UP \u00b7 AIM \u00b7 LET GO':'LET GO';
    else if(this.arcs.length){
      var deepOut=false;
      for(var q2=0;q2<this.arcs.length;q2++)if(this.arcs[q2].deep)deepOut=true;
      line=deepOut?'SOMETHING IS COMING THAT YOU DID NOT SEND':
        (this.arcs.length>1?'THEY WILL COME BACK IN THEIR OWN ORDER':
         'IT WILL COME BACK. NOT WHEN YOU WANT IT TO.');
    }
    else if(this.total)line='SEND ANOTHER \u00b7 OR SEND THE SAME ONE FURTHER';
    else line='TAKE ONE \u00b7 SEND IT OVER \u00b7 WAIT';
    x.fillStyle=rgba('#FFE9F4',A*0.48*(0.72+br*0.36));
    x.fillText(line,cx,H-150);

    /* only the star in his hand, and whatever is away, is named */
    if(rim>140&&A>0.10){
      x.font='italic 13px Lora, Georgia, serif';
      if(this.holding){
        var hsp=this.spot(this.holding,cx,cy,rim);
        x.fillStyle=rgba('#FFEAF4',A*0.90);
        x.fillText(this.holding.n.t,hsp[0],hsp[1]+18*hsp[2]+9);
        x.font='italic 7.5px Lora, Georgia, serif';
        x.fillStyle=rgba(HUE,A*0.50);
        x.fillText(this.holding.n.ti,hsp[0],hsp[1]+18*hsp[2]+23);
      }
      for(var f2=0;f2<this.arcs.length;f2++){
        var aa=this.arcs[f2], uu=(now-aa.t0)/aa.dur;
        if(uu<0.06||uu>0.99)continue;
        var ap=this.path(aa,uu,cx,cy,rim);
        x.font='italic 11px Lora, Georgia, serif';
        x.fillStyle=rgba('#FFEAF4',A*(aa.deep?0.60:0.34)*Math.max(0.2,ap[3]));
        x.fillText(BY[aa.id].n.t,ap[0],ap[1]-16);
      }
    }
    x.restore();
  }
};

function sm(x){x=Math.max(0,Math.min(1,x));return x*x*(3-2*x);}
function lerp(a,b,f){return a+(b-a)*f;}
function rgba(h,a){var r=parseInt(h.slice(1,3),16),gg=parseInt(h.slice(3,5),16),b=parseInt(h.slice(5,7),16);
  return 'rgba('+r+','+gg+','+b+','+Math.max(0,Math.min(1,a))+')';}
function mix(a,b,f){
  var pa=[parseInt(a.slice(1,3),16),parseInt(a.slice(3,5),16),parseInt(a.slice(5,7),16)];
  var pb=[parseInt(b.slice(1,3),16),parseInt(b.slice(3,5),16),parseInt(b.slice(5,7),16)];
  var hx=function(v){v=Math.round(Math.max(0,Math.min(255,v))).toString(16);return v.length<2?'0'+v:v;};
  return '#'+hx(pa[0]+(pb[0]-pa[0])*f)+hx(pa[1]+(pb[1]-pa[1])*f)+hx(pa[2]+(pb[2]-pa[2])*f);
}
g.SIX=Six;g.SIX_ORD=ORD;
})(window);
