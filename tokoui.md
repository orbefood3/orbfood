<!DOCTYPE html>
<html lang="id">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0, viewport-fit=cover">
<title>OrbFood — Dashboard Toko</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;500;600;700;800&family=Fraunces:ital,opsz,wght@0,9..144,300;0,9..144,700;1,9..144,400&display=swap" rel="stylesheet">
<style>
/* ── TOKENS ── */
:root{
  --bg:       #F7F8FA;
  --surface:  #FFFFFF;
  --navy:     #1C2B3A;
  --navy2:    #243447;
  --orange:   #F97316;
  --orange2:  #EA6C0A;
  --warm:     #FFF7ED;
  --ink:      #2D3748;
  --muted:    #8896A4;
  --line:     #ECEAE6;
  --green:    #22C55E;
  --green-bg: rgba(34,197,94,.1);
  --amber:    #F59E0B;
  --amber-bg: rgba(245,158,11,.1);
  --red:      #F43F5E;
  --red-bg:   rgba(244,63,94,.1);
  --blue:     #3B82F6;
  --blue-bg:  rgba(59,130,246,.1);
  --f-d: 'Fraunces',Georgia,serif;
  --f-b: 'Plus Jakarta Sans',sans-serif;
  --r8:8px; --r12:12px; --r16:16px; --r20:20px; --rfull:9999px;
  --sh-sm: 0 1px 4px rgba(0,0,0,.06);
  --sh-md: 0 4px 20px rgba(0,0,0,.09);
  --sh-o:  0 6px 24px rgba(249,115,22,.32);
  --ease:  cubic-bezier(.4,0,.2,1);
}
*,*::before,*::after{box-sizing:border-box;margin:0;padding:0;}
html{-webkit-text-size-adjust:100%;}
body{
  font-family:var(--f-b);
  background:var(--bg);
  color:var(--ink);
  min-height:100vh;
  max-width:430px;
  margin:0 auto;
  overflow-x:hidden;
}
button{font-family:var(--f-b);cursor:pointer;border:none;background:none;}
input,textarea,select{font-family:var(--f-b);}
::-webkit-scrollbar{display:none;}

/* ── TOPBAR ── */
.topbar{
  position:fixed;top:0;left:50%;transform:translateX(-50%);
  width:100%;max-width:430px;z-index:200;
  background:var(--navy);
  height:56px;
  display:flex;align-items:center;padding:0 18px;gap:12px;
}
.tbar-logo{display:flex;align-items:center;gap:7px;}
.tbar-logo svg{width:26px;height:26px;}
.tbar-logo-name{font-family:var(--f-d);font-weight:700;font-size:18px;color:#fff;letter-spacing:-.02em;}
.tbar-logo-name span{color:var(--orange);}
.tbar-store{
  flex:1;
  font-size:13px;font-weight:700;color:rgba(255,255,255,.75);
  white-space:nowrap;overflow:hidden;text-overflow:ellipsis;
  text-align:center;
}
.tbar-notif{
  width:34px;height:34px;border-radius:var(--rfull);
  background:rgba(255,255,255,.1);
  display:grid;place-items:center;position:relative;
  transition:.2s var(--ease);
}
.tbar-notif:active{background:rgba(255,255,255,.2);}
.tbar-notif svg{width:17px;height:17px;color:rgba(255,255,255,.85);}
.tbar-notif-dot{
  position:absolute;top:5px;right:5px;
  width:7px;height:7px;border-radius:var(--rfull);
  background:var(--orange);border:1.5px solid var(--navy);
}

/* ── PAGES ── */
.page{
  display:none;
  padding-top:56px;
  padding-bottom:calc(72px + env(safe-area-inset-bottom));
  animation:pin .28s var(--ease) both;
}
.page.active{display:block;}
@keyframes pin{from{opacity:0;transform:translateY(7px);}to{opacity:1;transform:translateY(0);}}

/* ── BOTTOM NAV ── */
.bnav{
  position:fixed;bottom:0;left:50%;transform:translateX(-50%);
  width:100%;max-width:430px;
  height:calc(66px + env(safe-area-inset-bottom));
  padding-bottom:env(safe-area-inset-bottom);
  background:var(--navy);
  display:flex;z-index:200;
}
.nb{
  flex:1;display:flex;flex-direction:column;
  align-items:center;justify-content:center;
  gap:3px;color:rgba(255,255,255,.4);
  transition:.18s var(--ease);
}
.nb svg{width:20px;height:20px;stroke-width:1.8;}
.nb span{font-size:9px;font-weight:700;letter-spacing:.02em;text-transform:uppercase;}
.nb.on{color:#fff;}
.nb.on svg{color:var(--orange);}
.nb:active{transform:scale(.9);}
.nb-notif{position:relative;}
.nb-notif-dot{
  position:absolute;top:2px;right:calc(50% - 16px);
  width:6px;height:6px;border-radius:var(--rfull);
  background:var(--orange);
}

/* ── DASHBOARD ── */
.dash-header{
  background:var(--navy);
  padding:20px 18px 24px;
  position:relative;overflow:hidden;
}
.dash-header::before{
  content:'';
  position:absolute;top:-60px;right:-40px;
  width:200px;height:200px;border-radius:var(--rfull);
  background:radial-gradient(circle,rgba(249,115,22,.18),transparent 65%);
  pointer-events:none;
}
.dash-header::after{
  content:'';
  position:absolute;bottom:-80px;left:-50px;
  width:180px;height:180px;border-radius:var(--rfull);
  background:radial-gradient(circle,rgba(59,130,246,.1),transparent 65%);
  pointer-events:none;
}
.dash-store-row{
  display:flex;align-items:center;gap:12px;
  margin-bottom:20px;
  position:relative;z-index:1;
}
.dash-store-icon{
  width:48px;height:48px;border-radius:var(--r12);
  background:rgba(255,255,255,.12);
  border:1.5px solid rgba(255,255,255,.15);
  display:grid;place-items:center;font-size:24px;flex-shrink:0;
}
.dash-store-name{
  font-family:var(--f-d);font-size:18px;font-weight:700;
  color:#fff;line-height:1.15;margin-bottom:4px;
}
.dash-store-status{display:flex;align-items:center;gap:6px;}
.status-pill{
  display:flex;align-items:center;gap:4px;
  padding:3px 9px;border-radius:var(--rfull);
  font-size:11px;font-weight:700;
}
.sp-open{background:rgba(34,197,94,.2);color:#4ade80;}
.sp-closed{background:rgba(255,255,255,.1);color:rgba(255,255,255,.5);}
.status-dot{
  width:6px;height:6px;border-radius:var(--rfull);
}
.sd-open{background:#4ade80;box-shadow:0 0 0 2px rgba(74,222,128,.3);}
.toggle-open{
  margin-left:auto;
  width:42px;height:24px;border-radius:var(--rfull);
  background:rgba(255,255,255,.15);position:relative;
  transition:.25s var(--ease);flex-shrink:0;
}
.toggle-open.on{background:var(--green);}
.toggle-thumb{
  width:18px;height:18px;border-radius:var(--rfull);
  background:#fff;position:absolute;top:3px;left:3px;
  transition:.25s var(--ease);
  box-shadow:0 1px 4px rgba(0,0,0,.2);
}
.toggle-open.on .toggle-thumb{left:calc(100% - 21px);}

/* Stats cards */
.stats-row{
  display:grid;grid-template-columns:repeat(3,1fr);
  gap:8px;position:relative;z-index:1;
}
.stat-card{
  background:rgba(255,255,255,.09);
  border:1px solid rgba(255,255,255,.1);
  border-radius:var(--r12);
  padding:11px 10px;text-align:center;
}
.stat-val{
  font-family:var(--f-d);font-size:20px;font-weight:700;
  color:#fff;line-height:1;margin-bottom:3px;
}
.stat-lbl{font-size:10px;color:rgba(255,255,255,.5);font-weight:600;}

/* Section */
.sec{padding:16px 16px 0;}
.sec-head{
  display:flex;align-items:center;justify-content:space-between;
  margin-bottom:12px;
}
.sec-title{font-size:15px;font-weight:800;color:var(--navy);letter-spacing:-.02em;}
.sec-more{font-size:12px;font-weight:700;color:var(--orange);}

/* ── ORDER CARDS ── */
.order-card{
  background:var(--surface);
  border-radius:var(--r16);
  border:1px solid var(--line);
  overflow:hidden;
  box-shadow:var(--sh-sm);
  margin-bottom:10px;
  transition:.18s var(--ease);
}
.order-card:active{transform:scale(.99);}
.oc-top{
  display:flex;align-items:center;justify-content:space-between;
  padding:11px 14px;
  border-bottom:1px solid var(--line);
}
.oc-num{font-size:11px;font-weight:700;color:var(--muted);}
.oc-time{font-size:11px;color:var(--muted);}
.bdg{
  padding:3px 9px;border-radius:var(--rfull);
  font-size:10px;font-weight:800;
}
.b-new{background:rgba(59,130,246,.1);color:#2563eb;}
.b-done{background:var(--green-bg);color:#16a34a;}
.b-cancel{background:var(--red-bg);color:#e11d48;}
.oc-body{padding:12px 14px;}
.oc-customer{
  font-size:13px;font-weight:700;color:var(--navy);
  margin-bottom:3px;
}
.oc-items{
  font-size:12px;color:var(--muted);
  margin-bottom:10px;line-height:1.5;
}
.oc-foot{
  display:flex;align-items:center;justify-content:space-between;
  gap:8px;
}
.oc-price{
  font-family:var(--f-d);font-size:16px;font-weight:700;color:var(--orange);
}
.oc-actions{display:flex;gap:6px;}
.act-btn{
  padding:7px 14px;border-radius:var(--rfull);
  font-size:12px;font-weight:700;
  transition:.15s var(--ease);
}
.act-done{background:var(--green-bg);color:#16a34a;border:1.5px solid rgba(34,197,94,.2);}
.act-done:active{background:var(--green);color:#fff;}
.act-cancel{background:var(--red-bg);color:#e11d48;border:1.5px solid rgba(244,63,94,.15);}
.act-cancel:active{background:var(--red);color:#fff;}

/* ── EMPTY STATE ── */
.empty{padding:36px 20px;text-align:center;}
.empty-icon{font-size:48px;margin-bottom:12px;}
.empty-title{font-size:15px;font-weight:700;color:var(--navy);margin-bottom:4px;}
.empty-desc{font-size:13px;color:var(--muted);}

/* ── MENU PAGE ── */
.menu-search-bar{
  display:flex;gap:10px;padding:14px 16px;
  background:var(--surface);
  border-bottom:1px solid var(--line);
}
.msb{
  flex:1;display:flex;align-items:center;gap:8px;
  background:var(--bg);border-radius:var(--rfull);
  padding:0 12px;height:38px;
  border:1.5px solid var(--line);
  transition:.2s var(--ease);
}
.msb:focus-within{border-color:var(--orange);box-shadow:0 0 0 3px rgba(249,115,22,.08);}
.msb svg{width:14px;height:14px;color:var(--muted);}
.msb input{flex:1;border:none;background:transparent;outline:none;font-size:13px;color:var(--ink);}
.msb input::placeholder{color:var(--muted);}
.btn-add-menu{
  width:38px;height:38px;border-radius:var(--rfull);
  background:var(--orange);color:#fff;
  display:grid;place-items:center;flex-shrink:0;
  box-shadow:var(--sh-o);
  transition:.18s var(--ease);
}
.btn-add-menu:active{transform:scale(.92);}
.btn-add-menu svg{width:18px;height:18px;}

.menu-grid{
  display:grid;grid-template-columns:repeat(2,1fr);
  gap:10px;padding:14px 14px;
}
.menu-item-card{
  background:var(--surface);
  border-radius:var(--r16);
  border:1px solid var(--line);
  overflow:hidden;
  box-shadow:var(--sh-sm);
}
.mic-img{
  height:100px;display:flex;align-items:center;justify-content:center;
  font-size:44px;position:relative;
}
.mic-status{
  position:absolute;top:7px;right:7px;
  width:8px;height:8px;border-radius:var(--rfull);
}
.mic-status.on{background:var(--green);box-shadow:0 0 0 3px rgba(34,197,94,.2);}
.mic-status.off{background:var(--muted);}
.mic-body{padding:9px 10px 11px;}
.mic-name{font-size:13px;font-weight:700;color:var(--navy);margin-bottom:2px;
  white-space:nowrap;overflow:hidden;text-overflow:ellipsis;}
.mic-price{font-family:var(--f-d);font-size:14px;font-weight:700;color:var(--orange);margin-bottom:8px;}
.mic-actions{display:flex;gap:5px;}
.mic-btn{
  flex:1;padding:5px 0;border-radius:var(--r8);
  font-size:11px;font-weight:700;
  text-align:center;
  transition:.15s var(--ease);
}
.mic-edit{background:var(--bg);color:var(--navy);border:1px solid var(--line);}
.mic-edit:active{background:var(--navy);color:#fff;}
.mic-del{background:var(--red-bg);color:var(--red);border:1px solid rgba(244,63,94,.15);}
.mic-del:active{background:var(--red);color:#fff;}

/* ── SETTINGS PAGE ── */
.settings-section{
  background:var(--surface);
  border-radius:var(--r16);
  border:1px solid var(--line);
  overflow:hidden;
  margin-bottom:12px;
  box-shadow:var(--sh-sm);
}
.ss-head{
  padding:12px 16px;
  border-bottom:1px solid var(--line);
  font-size:11px;font-weight:800;color:var(--muted);
  text-transform:uppercase;letter-spacing:.06em;
  background:var(--bg);
}
.ss-row{
  display:flex;align-items:center;gap:12px;
  padding:13px 16px;
  border-bottom:1px solid var(--line);
}
.ss-row:last-child{border-bottom:none;}
.ss-icon{
  width:36px;height:36px;border-radius:var(--r12);
  display:grid;place-items:center;font-size:16px;flex-shrink:0;
}
.ss-text{flex:1;}
.ss-label{font-size:14px;font-weight:600;color:var(--navy);}
.ss-sub{font-size:12px;color:var(--muted);margin-top:1px;}
.ss-toggle{
  width:42px;height:24px;border-radius:var(--rfull);
  background:var(--line);position:relative;flex-shrink:0;
  transition:.25s var(--ease);
}
.ss-toggle.on{background:var(--orange);}
.ss-toggle-thumb{
  width:18px;height:18px;border-radius:var(--rfull);
  background:#fff;position:absolute;top:3px;left:3px;
  transition:.25s var(--ease);
  box-shadow:0 1px 4px rgba(0,0,0,.15);
}
.ss-toggle.on .ss-toggle-thumb{left:calc(100% - 21px);}
.ss-row-arrow{
  width:28px;height:28px;border-radius:var(--rfull);
  background:var(--bg);display:grid;place-items:center;flex-shrink:0;
}
.ss-row-arrow svg{width:14px;height:14px;color:var(--muted);}
.ss-row.clickable{cursor:pointer;transition:.15s;}
.ss-row.clickable:active{background:var(--bg);}
.ss-val{font-size:13px;font-weight:600;color:var(--orange);}

/* Form inputs in settings */
.form-wrap{padding:14px 16px;}
.fg{margin-bottom:14px;}
.fg:last-child{margin-bottom:0;}
.fg label{
  display:block;font-size:11px;font-weight:800;
  color:var(--muted);text-transform:uppercase;letter-spacing:.05em;
  margin-bottom:6px;
}
.finput{
  width:100%;padding:11px 13px;
  border-radius:var(--r12);border:1.5px solid var(--line);
  background:#fff;font-size:14px;color:var(--ink);
  outline:none;transition:.18s var(--ease);
}
.finput:focus{border-color:var(--orange);box-shadow:0 0 0 3px rgba(249,115,22,.08);}
.finput::placeholder{color:var(--muted);}
textarea.finput{resize:none;min-height:80px;line-height:1.6;}
.fselect{
  width:100%;padding:11px 13px;
  border-radius:var(--r12);border:1.5px solid var(--line);
  background:#fff;font-size:14px;color:var(--ink);
  outline:none;appearance:none;
  transition:.18s var(--ease);
}
.fselect:focus{border-color:var(--orange);}
.time-row{display:grid;grid-template-columns:1fr 1fr;gap:10px;}
.btn-save{
  width:100%;margin-top:16px;padding:14px;
  border-radius:var(--r16);background:var(--orange);color:#fff;
  font-size:14px;font-weight:800;
  box-shadow:var(--sh-o);
  transition:.18s var(--ease);
  display:flex;align-items:center;justify-content:center;gap:8px;
}
.btn-save:active{transform:scale(.98);background:var(--orange2);}

/* Upload Box */
.upload-box{
  border:2px dashed var(--line);border-radius:var(--r16);
  padding:22px;text-align:center;cursor:pointer;
  transition:.2s var(--ease);background:var(--bg);
}
.upload-box:active{border-color:var(--orange);background:var(--warm);}
.upload-box-icon{font-size:32px;margin-bottom:8px;}
.upload-box-text{font-size:13px;color:var(--muted);}
.upload-box-text strong{color:var(--orange);}

/* ── GROUP ORDER ── */
.go-card{
  background:var(--surface);
  border-radius:var(--r16);
  border:1px solid var(--line);
  overflow:hidden;
  margin-bottom:10px;
  box-shadow:var(--sh-sm);
}
.go-header{
  background:linear-gradient(135deg,var(--orange),#fb923c);
  padding:14px 16px;
  display:flex;align-items:center;justify-content:space-between;
  position:relative;overflow:hidden;
}
.go-header::after{
  content:'👥';
  position:absolute;right:12px;top:50%;
  transform:translateY(-50%);
  font-size:36px;opacity:.25;
}
.go-code{
  font-family:var(--f-d);font-size:22px;font-weight:700;
  color:#fff;letter-spacing:.08em;
}
.go-code-lbl{font-size:11px;color:rgba(255,255,255,.75);font-weight:600;margin-bottom:2px;}
.go-status-pill{
  padding:4px 10px;border-radius:var(--rfull);
  background:rgba(255,255,255,.2);
  font-size:11px;font-weight:700;color:#fff;
  backdrop-filter:blur(4px);
}
.go-body{padding:0;}
.go-member{
  display:flex;align-items:center;gap:10px;
  padding:11px 16px;
  border-bottom:1px solid var(--line);
}
.go-member:last-child{border-bottom:none;}
.go-av{
  width:34px;height:34px;border-radius:var(--rfull);
  display:grid;place-items:center;font-size:13px;font-weight:800;color:#fff;flex-shrink:0;
}
.go-member-name{flex:1;font-size:13px;font-weight:700;color:var(--navy);}
.go-member-items{font-size:11px;color:var(--muted);}
.go-member-price{font-family:var(--f-d);font-size:14px;font-weight:700;color:var(--orange);}
.go-member-check{font-size:16px;}
.go-foot{
  padding:12px 16px;
  border-top:1px solid var(--line);
  display:flex;align-items:center;justify-content:space-between;
  background:var(--bg);
}
.go-total-lbl{font-size:12px;font-weight:700;color:var(--muted);}
.go-total-val{font-family:var(--f-d);font-size:17px;font-weight:700;color:var(--navy);}
.btn-go-rekap{
  padding:8px 16px;border-radius:var(--rfull);
  background:var(--navy);color:#fff;
  font-size:12px;font-weight:700;
  transition:.18s var(--ease);
}
.btn-go-rekap:active{background:var(--orange);}
.btn-new-go{
  width:100%;padding:14px;border-radius:var(--r16);
  background:var(--navy);color:#fff;
  font-size:14px;font-weight:800;
  display:flex;align-items:center;justify-content:center;gap:8px;
  transition:.18s var(--ease);
  box-shadow:var(--sh-md);
}
.btn-new-go:active{transform:scale(.98);}

/* ── SLIDE SHEET (modal) ── */
.overlay{
  position:fixed;inset:0;z-index:300;
  background:rgba(28,43,58,.55);
  backdrop-filter:blur(5px);
  opacity:0;pointer-events:none;
  transition:.25s var(--ease);
}
.overlay.open{opacity:1;pointer-events:all;}
.sheet{
  position:absolute;bottom:0;left:0;right:0;
  background:var(--surface);
  border-radius:22px 22px 0 0;
  max-height:90vh;overflow-y:auto;
  transform:translateY(100%);
  transition:.32s cubic-bezier(.32,0,.67,0);
}
.overlay.open .sheet{
  transform:translateY(0);
  transition:.32s cubic-bezier(.33,1,.68,1);
}
.sheet-handle{width:36px;height:4px;border-radius:2px;background:var(--line);margin:12px auto 0;}
.sheet-title{
  font-family:var(--f-d);font-size:20px;font-weight:700;color:var(--navy);
  padding:14px 20px 0;
}
.sheet-sub{padding:3px 20px 14px;font-size:13px;color:var(--muted);border-bottom:1px solid var(--line);}
.sheet-body{padding:16px 20px;}
.sheet-foot{
  padding:12px 20px calc(12px + env(safe-area-inset-bottom));
  border-top:1px solid var(--line);
  display:flex;gap:10px;
}
.sbtn-primary{
  flex:1;padding:13px;border-radius:var(--r12);
  background:var(--orange);color:#fff;
  font-size:14px;font-weight:800;
  transition:.18s;box-shadow:var(--sh-o);
}
.sbtn-primary:active{transform:scale(.97);}
.sbtn-secondary{
  padding:13px 18px;border-radius:var(--r12);
  border:1.5px solid var(--line);background:var(--surface);
  color:var(--navy);font-size:14px;font-weight:700;
  transition:.18s;
}
.sbtn-secondary:active{border-color:var(--navy);}

/* ── ANALYTIC CHART (CSS bars) ── */
.chart-wrap{
  padding:16px;
  background:var(--surface);
  border-radius:var(--r16);
  border:1px solid var(--line);
  margin-bottom:12px;
  box-shadow:var(--sh-sm);
}
.chart-title{font-size:12px;font-weight:800;color:var(--muted);text-transform:uppercase;letter-spacing:.05em;margin-bottom:14px;}
.chart-bars{
  display:flex;align-items:flex-end;gap:6px;height:80px;
}
.cbar-wrap{flex:1;display:flex;flex-direction:column;align-items:center;gap:4px;}
.cbar{
  width:100%;border-radius:var(--r4) var(--r4) 0 0;
  background:var(--orange);opacity:.3;
  transition:.6s var(--ease);
  animation:bar-grow .6s var(--ease) both;
}
.cbar.today{opacity:1;}
@keyframes bar-grow{from{height:0;}to{height:var(--h);}}
.cbar-lbl{font-size:9px;font-weight:700;color:var(--muted);}
.chart-stats{
  display:flex;gap:0;
  border-top:1px solid var(--line);
  margin-top:14px;padding-top:12px;
}
.cst{flex:1;text-align:center;border-right:1px solid var(--line);}
.cst:last-child{border-right:none;}
.cst-val{font-family:var(--f-d);font-size:18px;font-weight:700;color:var(--navy);margin-bottom:2px;}
.cst-lbl{font-size:10px;color:var(--muted);font-weight:600;}

/* ── ANNOUNCEMENT BANNER ── */
.ann-banner{
  display:flex;align-items:center;gap:10px;
  margin:12px 16px 0;
  padding:11px 14px;
  background:var(--warm);
  border-radius:var(--r12);
  border:1px solid rgba(249,115,22,.2);
}
.ann-icon{font-size:18px;flex-shrink:0;}
.ann-text{font-size:12px;color:var(--orange);font-weight:600;line-height:1.5;}

/* ── MISC ── */
.spacer{height:12px;}
.pg-pad{padding:14px 16px 0;}
.load-more{display:flex;justify-content:center;padding:16px;}
.btn-more{padding:9px 22px;border-radius:var(--rfull);border:1.5px solid var(--line);font-size:13px;font-weight:700;color:var(--muted);background:var(--surface);transition:.18s;}
.btn-more:active{border-color:var(--orange);color:var(--orange);}
</style>
</head>
<body>

<!-- ══ TOPBAR ══ -->
<header class="topbar">
  <div class="tbar-logo">
    <svg viewBox="0 0 100 100" fill="none">
      <circle cx="50" cy="50" r="44" stroke="#F97316" stroke-width="8"/>
      <circle cx="50" cy="50" r="31" stroke="rgba(255,255,255,.5)" stroke-width="5"/>
      <ellipse cx="44" cy="43" rx="12" ry="12" fill="rgba(255,255,255,.7)"/>
      <line x1="50" y1="43" x2="50" y2="71" stroke="rgba(255,255,255,.7)" stroke-width="6" stroke-linecap="round"/>
    </svg>
    <span class="tbar-logo-name">Orb<span>Food</span></span>
  </div>
  <div class="tbar-store">Warung Bu Sari</div>
  <button class="tbar-notif">
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
      <path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 0 1-3.46 0"/>
    </svg>
    <span class="tbar-notif-dot"></span>
  </button>
</header>

<!-- ══════════════════════════════
     DASHBOARD
══════════════════════════════ -->
<main class="page active" id="page-dashboard">

  <!-- Header -->
  <div class="dash-header">
    <div class="dash-store-row">
      <div class="dash-store-icon">🍜</div>
      <div style="flex:1">
        <div class="dash-store-name">Warung Bu Sari</div>
        <div class="dash-store-status">
          <div class="status-pill sp-open">
            <span class="status-dot sd-open"></span> Buka
          </div>
        </div>
      </div>
      <button class="toggle-open on" onclick="this.classList.toggle('on')">
        <div class="toggle-thumb"></div>
      </button>
    </div>
    <div class="stats-row">
      <div class="stat-card">
        <div class="stat-val">28</div>
        <div class="stat-lbl">Pesanan Hari Ini</div>
      </div>
      <div class="stat-card">
        <div class="stat-val">420k</div>
        <div class="stat-lbl">Pendapatan</div>
      </div>
      <div class="stat-card">
        <div class="stat-val">4.8★</div>
        <div class="stat-lbl">Rating Toko</div>
      </div>
    </div>
  </div>

  <!-- Announcement -->
  <div class="ann-banner">
    <span class="ann-icon">📢</span>
    <span class="ann-text">OrbFood hadir di 12 desa baru! Bagikan link tokomu ke lebih banyak pelanggan.</span>
  </div>

  <!-- Chart -->
  <div class="pg-pad">
    <div class="chart-wrap">
      <div class="chart-title">Pesanan 7 Hari Terakhir</div>
      <div class="chart-bars">
        <div class="cbar-wrap"><div class="cbar" style="--h:48px;height:48px"></div><span class="cbar-lbl">Sen</span></div>
        <div class="cbar-wrap"><div class="cbar" style="--h:60px;height:60px"></div><span class="cbar-lbl">Sel</span></div>
        <div class="cbar-wrap"><div class="cbar" style="--h:34px;height:34px"></div><span class="cbar-lbl">Rab</span></div>
        <div class="cbar-wrap"><div class="cbar" style="--h:72px;height:72px"></div><span class="cbar-lbl">Kam</span></div>
        <div class="cbar-wrap"><div class="cbar" style="--h:55px;height:55px"></div><span class="cbar-lbl">Jum</span></div>
        <div class="cbar-wrap"><div class="cbar" style="--h:68px;height:68px"></div><span class="cbar-lbl">Sab</span></div>
        <div class="cbar-wrap"><div class="cbar today" style="--h:80px;height:80px"></div><span class="cbar-lbl" style="color:var(--orange);font-weight:800">Min</span></div>
      </div>
      <div class="chart-stats">
        <div class="cst"><div class="cst-val">142</div><div class="cst-lbl">Total Pesanan</div></div>
        <div class="cst"><div class="cst-val">2.1jt</div><div class="cst-lbl">Pendapatan</div></div>
        <div class="cst"><div class="cst-val">89</div><div class="cst-lbl">Chat WA</div></div>
      </div>
    </div>
  </div>

  <!-- Pesanan Terbaru -->
  <div class="sec">
    <div class="sec-head">
      <span class="sec-title">Pesanan Masuk</span>
      <span class="sec-more" onclick="nav('orders')">Lihat semua →</span>
    </div>

    <div class="order-card">
      <div class="oc-top">
        <span class="oc-num">#ORD-001 · Ahmad Fauzi</span>
        <span class="bdg b-new">Baru 🔔</span>
      </div>
      <div class="oc-body">
        <div class="oc-items">Nasi Ayam Spesial × 2 · Es Teh Manis × 2</div>
        <div class="oc-foot">
          <span class="oc-price">Rp 40.000</span>
          <div class="oc-actions">
            <button class="act-btn act-done" onclick="markDone(this)">✓ Selesai</button>
            <button class="act-btn act-cancel">✕</button>
          </div>
        </div>
      </div>
    </div>

    <div class="order-card">
      <div class="oc-top">
        <span class="oc-num">#ORD-002 · Budi Santoso</span>
        <span class="bdg b-new">Baru 🔔</span>
      </div>
      <div class="oc-body">
        <div class="oc-items">Ayam Geprek Level 3 × 1 · Pecel Komplit × 1</div>
        <div class="oc-foot">
          <span class="oc-price">Rp 30.000</span>
          <div class="oc-actions">
            <button class="act-btn act-done" onclick="markDone(this)">✓ Selesai</button>
            <button class="act-btn act-cancel">✕</button>
          </div>
        </div>
      </div>
    </div>

  </div>
  <div class="spacer"></div>

</main>

<!-- ══════════════════════════════
     PESANAN (ORDERS)
══════════════════════════════ -->
<main class="page" id="page-orders">

  <div style="padding:16px 16px 0">
    <!-- Filter tabs -->
    <div style="display:flex;gap:6px;overflow-x:auto;padding-bottom:2px;margin-bottom:14px">
      <button class="bdg b-new" style="padding:6px 14px;border-radius:var(--rfull);font-size:12px;cursor:pointer;white-space:nowrap;border:1.5px solid rgba(59,130,246,.2)" onclick="filterOrders(this)">Semua (8)</button>
      <button style="padding:6px 14px;border-radius:var(--rfull);font-size:12px;font-weight:700;cursor:pointer;white-space:nowrap;color:var(--muted);background:var(--surface);border:1.5px solid var(--line)" onclick="filterOrders(this)">Baru (2)</button>
      <button style="padding:6px 14px;border-radius:var(--rfull);font-size:12px;font-weight:700;cursor:pointer;white-space:nowrap;color:var(--muted);background:var(--surface);border:1.5px solid var(--line)" onclick="filterOrders(this)">Selesai (5)</button>
      <button style="padding:6px 14px;border-radius:var(--rfull);font-size:12px;font-weight:700;cursor:pointer;white-space:nowrap;color:var(--muted);background:var(--surface);border:1.5px solid var(--line)" onclick="filterOrders(this)">Batal (1)</button>
    </div>

    <div class="order-card">
      <div class="oc-top">
        <span class="oc-num">#ORD-001 · Ahmad Fauzi</span>
        <span class="bdg b-new">Baru 🔔</span>
      </div>
      <div class="oc-body">
        <div class="oc-items">Nasi Ayam Spesial × 2 · Es Teh Manis × 2</div>
        <div class="oc-foot">
          <span class="oc-price">Rp 40.000</span>
          <div class="oc-actions">
            <button class="act-btn act-done" onclick="markDone(this)">✓ Selesai</button>
            <button class="act-btn act-cancel">✕</button>
          </div>
        </div>
      </div>
    </div>

    <div class="order-card">
      <div class="oc-top">
        <span class="oc-num">#ORD-002 · Budi Santoso</span>
        <span class="bdg b-new">Baru 🔔</span>
      </div>
      <div class="oc-body">
        <div class="oc-items">Ayam Geprek Level 3 × 1 · Pecel Komplit × 1</div>
        <div class="oc-foot">
          <span class="oc-price">Rp 30.000</span>
          <div class="oc-actions">
            <button class="act-btn act-done" onclick="markDone(this)">✓ Selesai</button>
            <button class="act-btn act-cancel">✕</button>
          </div>
        </div>
      </div>
    </div>

    <div class="order-card">
      <div class="oc-top">
        <span class="oc-num">#ORD-003 · Citra Dewi</span>
        <span class="bdg b-done">Selesai ✓</span>
      </div>
      <div class="oc-body">
        <div class="oc-items">Nasi Rendang × 2</div>
        <div class="oc-foot">
          <span class="oc-price">Rp 44.000</span>
          <div style="font-size:11px;color:var(--muted)">09 Mar · 11.20</div>
        </div>
      </div>
    </div>

    <div class="order-card">
      <div class="oc-top">
        <span class="oc-num">#GRP-004 · Group Order</span>
        <span class="bdg b-done">Selesai ✓</span>
      </div>
      <div class="oc-body">
        <div class="oc-items">3 peserta · 7 item · Kode: ORB-7829</div>
        <div class="oc-foot">
          <span class="oc-price">Rp 127.000</span>
          <div style="font-size:11px;color:var(--muted)">09 Mar · 12.00</div>
        </div>
      </div>
    </div>

  </div>
  <div class="load-more"><button class="btn-more">Muat lebih banyak</button></div>

</main>

<!-- ══════════════════════════════
     MENU SAYA
══════════════════════════════ -->
<main class="page" id="page-menu">

  <div class="menu-search-bar">
    <div class="msb">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8"/><path d="m21 21-4.35-4.35"/></svg>
      <input type="text" placeholder="Cari menu…">
    </div>
    <button class="btn-add-menu" onclick="openSheet('add-menu')">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
    </button>
  </div>

  <div class="menu-grid">

    <div class="menu-item-card">
      <div class="mic-img" style="background:#FFF7ED">
        🍜 <span class="mic-status on"></span>
      </div>
      <div class="mic-body">
        <div class="mic-name">Nasi Ayam Spesial</div>
        <div class="mic-price">Rp 15.000</div>
        <div class="mic-actions">
          <button class="mic-btn mic-edit" onclick="openSheet('edit-menu')">✏️ Edit</button>
          <button class="mic-btn mic-del">🗑️</button>
        </div>
      </div>
    </div>

    <div class="menu-item-card">
      <div class="mic-img" style="background:#FEF2F2">
        🌶️ <span class="mic-status on"></span>
      </div>
      <div class="mic-body">
        <div class="mic-name">Ayam Geprek</div>
        <div class="mic-price">Rp 18.000</div>
        <div class="mic-actions">
          <button class="mic-btn mic-edit" onclick="openSheet('edit-menu')">✏️ Edit</button>
          <button class="mic-btn mic-del">🗑️</button>
        </div>
      </div>
    </div>

    <div class="menu-item-card">
      <div class="mic-img" style="background:#FFFBEB">
        🍛 <span class="mic-status on"></span>
      </div>
      <div class="mic-body">
        <div class="mic-name">Nasi Rendang</div>
        <div class="mic-price">Rp 22.000</div>
        <div class="mic-actions">
          <button class="mic-btn mic-edit" onclick="openSheet('edit-menu')">✏️ Edit</button>
          <button class="mic-btn mic-del">🗑️</button>
        </div>
      </div>
    </div>

    <div class="menu-item-card">
      <div class="mic-img" style="background:#F0FDF4">
        🥗 <span class="mic-status on"></span>
      </div>
      <div class="mic-body">
        <div class="mic-name">Pecel Komplit</div>
        <div class="mic-price">Rp 12.000</div>
        <div class="mic-actions">
          <button class="mic-btn mic-edit" onclick="openSheet('edit-menu')">✏️ Edit</button>
          <button class="mic-btn mic-del">🗑️</button>
        </div>
      </div>
    </div>

    <div class="menu-item-card">
      <div class="mic-img" style="background:#EFF6FF">
        🧊 <span class="mic-status on"></span>
      </div>
      <div class="mic-body">
        <div class="mic-name">Es Teh Manis</div>
        <div class="mic-price">Rp 5.000</div>
        <div class="mic-actions">
          <button class="mic-btn mic-edit" onclick="openSheet('edit-menu')">✏️ Edit</button>
          <button class="mic-btn mic-del">🗑️</button>
        </div>
      </div>
    </div>

    <div class="menu-item-card">
      <div class="mic-img" style="background:#FFF1F2">
        🍢 <span class="mic-status off"></span>
      </div>
      <div class="mic-body">
        <div class="mic-name" style="color:var(--muted)">Soto Ayam</div>
        <div class="mic-price" style="color:var(--muted)">Rp 14.000</div>
        <div class="mic-actions">
          <button class="mic-btn mic-edit" onclick="openSheet('edit-menu')">✏️ Edit</button>
          <button class="mic-btn mic-del">🗑️</button>
        </div>
      </div>
    </div>

  </div>
  <div class="load-more"><button class="btn-more">Muat lebih banyak</button></div>

</main>

<!-- ══════════════════════════════
     GROUP ORDER
══════════════════════════════ -->
<main class="page" id="page-go">
  <div class="pg-pad">

    <!-- Active Room -->
    <div class="sec-head" style="margin-bottom:12px"><span class="sec-title">Room Aktif</span></div>

    <div class="go-card">
      <div class="go-header">
        <div>
          <div class="go-code-lbl">Kode Room</div>
          <div class="go-code">ORB-7829</div>
        </div>
        <span class="go-status-pill">3 peserta</span>
      </div>
      <div class="go-body">
        <div class="go-member">
          <div class="go-av" style="background:var(--navy)">A</div>
          <div style="flex:1">
            <div class="go-member-name">Ahmad Fauzi <span style="font-size:10px;color:var(--orange);font-weight:700">Host</span></div>
            <div class="go-member-items">Nasi Ayam × 1 · Es Teh × 2</div>
          </div>
          <div class="go-member-price">Rp 25.000</div>
          <span class="go-member-check">✅</span>
        </div>
        <div class="go-member">
          <div class="go-av" style="background:var(--orange)">B</div>
          <div style="flex:1">
            <div class="go-member-name">Budi Santoso</div>
            <div class="go-member-items">Ayam Geprek × 1</div>
          </div>
          <div class="go-member-price">Rp 18.000</div>
          <span class="go-member-check">✅</span>
        </div>
        <div class="go-member">
          <div class="go-av" style="background:#7C3AED">C</div>
          <div style="flex:1">
            <div class="go-member-name">Citra Dewi</div>
            <div class="go-member-items">Belum memesan…</div>
          </div>
          <div class="go-member-price" style="color:var(--muted)">—</div>
          <span class="go-member-check">⏳</span>
        </div>
      </div>
      <div class="go-foot">
        <div>
          <div class="go-total-lbl">Total Sementara</div>
          <div class="go-total-val">Rp 43.000</div>
        </div>
        <button class="btn-go-rekap">📋 Rekap</button>
      </div>
    </div>

    <!-- Past Rooms -->
    <div class="sec-head" style="margin:16px 0 12px"><span class="sec-title">Riwayat Room</span></div>

    <div class="go-card" style="opacity:.7">
      <div class="go-header" style="background:linear-gradient(135deg,var(--navy),var(--navy2))">
        <div>
          <div class="go-code-lbl">Kode Room</div>
          <div class="go-code">ORB-6611</div>
        </div>
        <span class="go-status-pill" style="background:rgba(34,197,94,.25);color:#4ade80">Selesai</span>
      </div>
      <div class="go-foot">
        <div>
          <div class="go-total-lbl">4 peserta · 8 Mar</div>
          <div class="go-total-val">Rp 127.000</div>
        </div>
        <button class="btn-go-rekap">📋 Lihat</button>
      </div>
    </div>

    <div style="height:14px"></div>
    <button class="btn-new-go" onclick="openSheet('new-go')">
      <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
      Buat Room Baru
    </button>
    <div class="spacer"></div>

  </div>
</main>

<!-- ══════════════════════════════
     PENGATURAN
══════════════════════════════ -->
<main class="page" id="page-settings">
  <div style="padding:14px 16px 0">

    <!-- Status & toggle -->
    <div class="settings-section">
      <div class="ss-head">Status Toko</div>
      <div class="ss-row">
        <div class="ss-icon" style="background:var(--green-bg)">🟢</div>
        <div class="ss-text">
          <div class="ss-label">Toko Buka</div>
          <div class="ss-sub">Pelanggan bisa melihat &amp; memesan</div>
        </div>
        <button class="ss-toggle on" onclick="this.classList.toggle('on')">
          <div class="ss-toggle-thumb"></div>
        </button>
      </div>
      <div class="ss-row">
        <div class="ss-icon" style="background:var(--blue-bg)">🛵</div>
        <div class="ss-text">
          <div class="ss-label">Layanan Delivery</div>
          <div class="ss-sub">Tampilkan tanda delivery di toko</div>
        </div>
        <button class="ss-toggle on" onclick="this.classList.toggle('on')">
          <div class="ss-toggle-thumb"></div>
        </button>
      </div>
    </div>

    <!-- Info Toko -->
    <div class="settings-section">
      <div class="ss-head">Informasi Toko</div>
      <div class="form-wrap">
        <div class="fg">
          <label>Nama Toko</label>
          <input class="finput" value="Warung Bu Sari">
        </div>
        <div class="fg">
          <label>Kategori</label>
          <select class="fselect">
            <option selected>Nasi & Lauk</option>
            <option>Minuman</option>
            <option>Bakso & Soto</option>
            <option>Catering</option>
          </select>
        </div>
        <div class="fg">
          <label>Desa</label>
          <select class="fselect">
            <option selected>Sukamaju</option>
            <option>Mekarsari</option>
            <option>Cibening</option>
          </select>
        </div>
        <div class="fg">
          <label>Deskripsi</label>
          <textarea class="finput">Masakan rumahan yang lezat dan bergizi. Tersedia berbagai lauk pilihan setiap hari.</textarea>
        </div>
        <div class="fg">
          <label>Nomor WhatsApp</label>
          <input class="finput" value="6281234567890" type="tel">
        </div>
      </div>
    </div>

    <!-- Jam Operasional -->
    <div class="settings-section">
      <div class="ss-head">Jam Operasional</div>
      <div class="form-wrap">
        <div class="fg">
          <label>Jam Buka — Tutup</label>
          <div class="time-row">
            <input class="finput" type="time" value="07:00">
            <input class="finput" type="time" value="21:00">
          </div>
        </div>
      </div>
    </div>

    <!-- Media Sosial -->
    <div class="settings-section">
      <div class="ss-head">Media Sosial</div>
      <div class="form-wrap">
        <div class="fg">
          <label>Instagram</label>
          <input class="finput" placeholder="@username">
        </div>
        <div class="fg">
          <label>TikTok</label>
          <input class="finput" placeholder="@username">
        </div>
        <div class="fg">
          <label>Google Maps Link</label>
          <input class="finput" placeholder="https://maps.google.com/…">
        </div>
      </div>
    </div>

    <!-- Foto Toko -->
    <div class="settings-section">
      <div class="ss-head">Foto Toko</div>
      <div style="padding:12px">
        <div style="display:grid;grid-template-columns:1fr 1fr;gap:10px">
          <div>
            <div style="font-size:11px;font-weight:700;color:var(--muted);text-transform:uppercase;letter-spacing:.05em;margin-bottom:6px">Logo</div>
            <div class="upload-box" style="padding:16px">
              <div class="upload-box-icon">🖼️</div>
              <div class="upload-box-text" style="font-size:11px"><strong>Upload</strong><br>PNG/JPG</div>
            </div>
          </div>
          <div>
            <div style="font-size:11px;font-weight:700;color:var(--muted);text-transform:uppercase;letter-spacing:.05em;margin-bottom:6px">Banner</div>
            <div class="upload-box" style="padding:16px">
              <div class="upload-box-icon">🏞️</div>
              <div class="upload-box-text" style="font-size:11px"><strong>Upload</strong><br>16:9</div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Share link -->
    <div class="settings-section">
      <div class="ss-head">Link Toko</div>
      <div class="ss-row clickable">
        <div class="ss-icon" style="background:var(--warm)">🔗</div>
        <div class="ss-text">
          <div class="ss-label">orbfood.app/toko/warung-bu-sari</div>
          <div class="ss-sub">Salin &amp; bagikan ke pelanggan</div>
        </div>
        <div class="ss-row-arrow"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="9 18 15 12 9 6"/></svg></div>
      </div>
    </div>

    <button class="btn-save">💾 Simpan Perubahan</button>
    <div style="height:16px"></div>

  </div>
</main>

<!-- ══ SHEET OVERLAYS ══ -->

<!-- Add/Edit Menu Sheet -->
<div class="overlay" id="overlay-menu" onclick="closeSheet('menu')">
  <div class="sheet">
    <div class="sheet-handle"></div>
    <div class="sheet-title" id="sheet-menu-title">Tambah Menu Baru</div>
    <div class="sheet-sub">Isi detail menu yang akan ditampilkan ke pelanggan</div>
    <div class="sheet-body">
      <div class="fg"><label>Nama Menu *</label><input class="finput" placeholder="Cth: Nasi Ayam Spesial"></div>
      <div class="fg"><label>Harga *</label><input class="finput" placeholder="Rp 0" type="number"></div>
      <div class="fg"><label>Deskripsi</label><textarea class="finput" placeholder="Ceritakan tentang menu ini…"></textarea></div>
      <div class="fg">
        <label>Foto Menu</label>
        <div class="upload-box">
          <div class="upload-box-icon">📸</div>
          <div class="upload-box-text"><strong>Upload foto</strong> menu<br><span style="font-size:11px">PNG/JPG maks 2MB</span></div>
        </div>
      </div>
      <div class="fg">
        <label>Status</label>
        <div style="display:flex;align-items:center;justify-content:space-between;padding:12px 14px;background:var(--bg);border-radius:var(--r12);border:1.5px solid var(--line)">
          <span style="font-size:14px;font-weight:600;color:var(--navy)">Menu Aktif</span>
          <button class="ss-toggle on" onclick="this.classList.toggle('on')"><div class="ss-toggle-thumb"></div></button>
        </div>
      </div>
    </div>
    <div class="sheet-foot">
      <button class="sbtn-secondary" onclick="closeSheet('menu')">Batal</button>
      <button class="sbtn-primary" onclick="closeSheet('menu')">💾 Simpan Menu</button>
    </div>
  </div>
</div>

<!-- New Group Order Sheet -->
<div class="overlay" id="overlay-go" onclick="closeSheet('go')">
  <div class="sheet">
    <div class="sheet-handle"></div>
    <div class="sheet-title">Buat Room Group Order</div>
    <div class="sheet-sub">Room baru akan dibuat dengan kode unik yang bisa dibagikan</div>
    <div class="sheet-body">
      <div class="fg">
        <label>Nama Room (opsional)</label>
        <input class="finput" placeholder="Cth: Makan Siang Kantor">
      </div>
      <div class="fg">
        <label>Batas Peserta</label>
        <select class="fselect">
          <option>Tidak dibatasi</option>
          <option>Maks 5 orang</option>
          <option>Maks 10 orang</option>
          <option>Maks 20 orang</option>
        </select>
      </div>
      <div style="background:var(--warm);border-radius:var(--r12);padding:12px 14px;border:1px solid rgba(249,115,22,.2)">
        <div style="font-size:12px;font-weight:700;color:var(--orange);margin-bottom:4px">📋 Cara kerja Group Order</div>
        <div style="font-size:12px;color:var(--ink);line-height:1.6">Bagikan kode room ke teman. Mereka pilih menu masing-masing. Rekap otomatis tersedia untuk checkout bersama.</div>
      </div>
    </div>
    <div class="sheet-foot">
      <button class="sbtn-secondary" onclick="closeSheet('go')">Batal</button>
      <button class="sbtn-primary" onclick="closeSheet('go')">🚀 Buat Room</button>
    </div>
  </div>
</div>

<!-- ══ BOTTOM NAV ══ -->
<nav class="bnav">
  <button class="nb on" id="n-dashboard" onclick="nav('dashboard')">
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/></svg>
    <span>Dashboard</span>
  </button>
  <button class="nb nb-notif" id="n-orders" onclick="nav('orders')">
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M9 11l3 3L22 4"/><path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"/></svg>
    <span>Pesanan</span>
    <span class="nb-notif-dot"></span>
  </button>
  <button class="nb" id="n-menu" onclick="nav('menu')">
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2z"/><path d="M8 12h8M12 8v8"/></svg>
    <span>Menu</span>
  </button>
  <button class="nb" id="n-go" onclick="nav('go')">
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
    <span>Group</span>
  </button>
  <button class="nb" id="n-settings" onclick="nav('settings')">
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 1 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 1 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 1 1-2.83-2.83l.06-.06A1.65 1.65 0 0 0 4.68 15a1.65 1.65 0 0 0-1.51-1H3a2 2 0 1 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 1 1 2.83-2.83l.06.06A1.65 1.65 0 0 0 9 4.68a1.65 1.65 0 0 0 1-1.51V3a2 2 0 1 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 1 1 2.83 2.83l-.06.06A1.65 1.65 0 0 0 19.4 9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 1 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z"/></svg>
    <span>Pengaturan</span>
  </button>
</nav>

<script>
const PAGES=['dashboard','orders','menu','go','settings'];
const NB_MAP={dashboard:'n-dashboard',orders:'n-orders',menu:'n-menu',go:'n-go',settings:'n-settings'};

function nav(id){
  PAGES.forEach(p=>{
    const e=document.getElementById('page-'+p);
    if(e)e.classList.toggle('active',p===id);
  });
  Object.values(NB_MAP).forEach(n=>{
    const e=document.getElementById(n);
    if(e)e.classList.remove('on');
  });
  const nb=document.getElementById(NB_MAP[id]);
  if(nb)nb.classList.add('on');
  window.scrollTo(0,0);
}

function openSheet(type){
  if(type==='add-menu'||type==='edit-menu'){
    document.getElementById('sheet-menu-title').textContent=type==='add-menu'?'Tambah Menu Baru':'Edit Menu';
    document.getElementById('overlay-menu').classList.add('open');
  }else if(type==='new-go'){
    document.getElementById('overlay-go').classList.add('open');
  }
  document.body.style.overflow='hidden';
}

function closeSheet(type){
  const ovId=type==='menu'?'overlay-menu':'overlay-go';
  const ov=document.getElementById(ovId);
  if(ov)ov.classList.remove('open');
  document.body.style.overflow='';
}

function markDone(btn){
  const card=btn.closest('.order-card');
  const bdg=card.querySelector('.bdg');
  bdg.textContent='Selesai ✓';
  bdg.className='bdg b-done';
  const actions=card.querySelector('.oc-actions');
  if(actions)actions.remove();
  card.style.opacity='.6';
}

function filterOrders(btn){
  btn.closest('div').querySelectorAll('button').forEach(b=>{
    b.className='bdg b-new';
    b.style='padding:6px 14px;border-radius:var(--rfull);font-size:12px;cursor:pointer;white-space:nowrap;border:1.5px solid rgba(59,130,246,.2)';
  });
  btn.style='padding:6px 14px;border-radius:var(--rfull);font-size:12px;font-weight:800;cursor:pointer;white-space:nowrap;background:var(--navy);color:#fff;border:none';
}
</script>
</body>
</html>