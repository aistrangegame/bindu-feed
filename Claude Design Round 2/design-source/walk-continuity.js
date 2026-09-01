/* ═══════════════════════════════════════════════════════════════════
   A STRANGE FEED · walk-continuity.js
   ───────────────────────────────────────────────────────────────────
   THE CONTINUITY HANDOFF.

   The Rite and the Return stay separate documents, and that is right:
   a ceremony is CROSSED INTO, never drifted into. What was wrong was
   that they forgot whose walk they were continuing — he crossed from a
   depth on the axis and came back to a cold Door.

   One small object travels with him (sessionStorage 'asf.walk', written
   by the instrument at every departure): the depth he left from, the
   breath mid-cycle, the particle's age, and the ledger of the walk.
   The ceremony's own engine still stands up fresh. It simply knows.

   Two things this does, and nothing more:
     1 · the ceremony's exit returns him to the DEPTH HE LEFT FROM,
         not to a generic door — so the whole thing reads as one body;
     2 · the breath he arrives on is the breath he left on, so the
         0.1 Hz clock under the app never restarts mid-walk.

   It writes nothing back. A ceremony is not a place that keeps score.
   ═══════════════════════════════════════════════════════════════════ */
(function(g){
'use strict';
var KEY='asf.walk', SPINE='The Instrument v3.html', TTL=1000*60*90;

var w=null;
try{w=JSON.parse(sessionStorage.getItem(KEY)||'null');}catch(e){}
if(w&&(Date.now()-(w.t||0))>TTL)w=null;

var W={
  from:w,
  ok:!!w,
  /* the depth he crossed from. A ceremony opened from the Feed returns
     to the Feed; one opened from the fall returns to the fall. */
  z:w&&typeof w.z==='number'?w.z:null,
  at:w?w.at:null,
  /* the one clock. He left mid-breath; he arrives mid-breath. */
  breath:w&&typeof w.breath==='number'?w.breath:0,
  phase:function(){
    return ((performance.now()/1000)+(this.breath||0))%10;
  },
  /* what he was already carrying when he crossed. Read-only, and never
     rendered as a count \u2014 a ceremony may colour itself by it, nothing more. */
  carry:(w&&w.carry)||[],
  carved:(w&&w.carved)|0,
  crossed:(w&&w.crossed)|0,
  home:function(){
    return this.ok&&this.z!==null?(SPINE+'?z='+this.z):null;
  }
};

/* the exits. Any anchor that leaves for the Door or the Archive is an
   exit; if he came from the axis, it returns him to the axis instead \u2014
   at the depth he left, with the way back already open behind him. */
var EXITS=['A Strange Feed.html','Home Feed.html'];
document.addEventListener('click',function(e){
  if(!W.ok)return;
  var a=e.target&&e.target.closest?e.target.closest('a[href]'):null;
  if(!a)return;
  var h=a.getAttribute('href')||'';
  if(EXITS.indexOf(h)<0)return;
  var to=W.home();
  if(!to)return;
  e.preventDefault();
  document.body.style.transition='opacity .34s ease-in';
  document.body.style.opacity=0;
  setTimeout(function(){window.location.href=to;},340);
},true);

g.WALK=W;
})(window);
