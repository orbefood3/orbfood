<!DOCTYPE html>
<html lang="id">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0, viewport-fit=cover">
<title>OrbFood — Admin</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;500;600;700;800&family=Fraunces:ital,opsz,wght@0,9..144,300;0,9..144,700;1,9..144,400&display=swap" rel="stylesheet">
<style>
:root{
  --bg:#F0F2F5;
  --surface:#FFFFFF;
  --navy:#1C2B3A;
  --navy2:#243447;
  --navy3:#0F1B27;
  --orange:#F97316;
  --orange2:#EA6C0A;
  --warm:#FFF7ED;
  --ink:#2D3748;
  --muted:#8896A4;
  --line:#E4E8ED;
  --green:#22C55E;
  --green-bg:rgba(34,197,94,.1);
  --amber:#F59E0B;
  --amber-bg:rgba(245,158,11,.1);
  --red:#F43F5E;
  --red-bg:rgba(244,63,94,.1);
  --blue:#3B82F6;
  --blue-bg:rgba(59,130,246,.1);
  --purple:#8B5CF6;
  --purple-bg:rgba(139,92,246,.1);
  --f-d:'Fraunces',Georgia,serif;
  --f-b:'Plus Jakarta Sans',sans-serif;
  --r8:8px;--r12:12px;--r16:16px;--r20:20px;--rfull:9999px;
  --sh-sm:0 1px 4px rgba(0,0,0,.06);
  --sh-md:0 4px 20px rgba(0,0,0,.09);
  --sh-lg:0 12px 40px rgba(0,0,0,.13);
  --ease:cubic-bezier(.4,0,.2,1);
}
*,*::before,*::after{box-sizing:border-box;margin:0;padding:0;}
html{-webkit-text-size-adjust:100%;}
body{font-family:var(--f-b);background:var(--bg);color:var(--ink);min-height:100vh;max-width:430px;margin:0 auto;overflow-x:hidden;}
button{font-family:var(--f-b);cursor:pointer;border:none;background:none;}
input,textarea,select{font-family:var(--f-b);}
::-webkit-scrollbar{display:none;}

/* ── TOPBAR ── */
.topbar{
  position:fixed;top:0;left:50%;transform:translateX(-50%);
  width:100%;max-width:430px;z-index:200;
  background:var(--navy3);
  height:56px;
  display:flex;align-items:center;padding:0 18px;gap:12px;
  border-bottom:1px solid rgba(255,255,255,.06);
}
.tbar-left{display:flex;align-items:center;gap:9px;}
.tbar-logo svg{width:26px;height:26px;}
.tbar-logo-name{font-family:var(--f-d);font-weight:700;font-size:18px;color:#fff;letter-spacing:-.02em;}
.tbar-logo-name span{color:var(--orange);}
.tbar-badge{
  padding:3px 8px;border-radius:var(--rfull);
  background:var(--orange);
  font-size:9px;font-weight:800;color:#fff;
  letter-spacing:.04em;text-transform:uppercase;
}
.tbar-right{margin-left:auto;display:flex;gap:8px;align-items:center;}
.tbar-btn{
  width:34px;height:34px;border-radius:var(--rfull);
  background:rgba(255,255,255,.08);
  display:grid;place-items:center;
  position:relative;transition:.2s var(--ease);
}
.tbar-btn:active{background:rgba(255,255,255,.16);}
.tbar-btn svg{width:16px;height:16px;color:rgba(255,255,255,.8);}
.tbar-dot{position:absolute;top:5px;right:5px;width:7px;height:7px;border-radius:var(--rfull);background:var(--orange);border:1.5px solid var(--navy3);}

/* ── PAGES ── */
.page{display:none;padding-top:56px;padding-bottom:calc(68px + env(safe-area-inset-bottom));animation:pin .28s var(--ease) both;}
.page.active{display:block;}
@keyframes pin{from{opacity:0;transform:translateY(7px);}to{opacity:1;transform:translateY(0);}}

/* ── BOTTOM NAV ── */
.bnav{
  position:fixed;bottom:0;left:50%;transform:translateX(-50%);
  width:100%;max-width:430px;
  height:calc(64px + env(safe-area-inset-bottom));
  padding-bottom:env(safe-area-inset-bottom);
  background:var(--navy3);
  border-top:1px solid rgba(255,255,255,.07);
  display:flex;z-index:200;
}
.nb{flex:1;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:3px;color:rgba(255,255,255,.3);transition:.18s var(--ease);}
.nb svg{width:19px;height:19px;stroke-width:1.7;}
.nb span{font-size:9px;font-weight:700;letter-spacing:.03em;text-transform:uppercase;}
.nb.on{color:#fff;}
.nb.on svg{color:var(--orange);}
.nb:active{transform:scale(.88);}
.nb-dot-wrap{position:relative;}
.nb-dot{position:absolute;top:-1px;right:-6px;width:6px;height:6px;border-radius:var(--rfull);background:var(--orange);}

/* ── STATS OVERVIEW ── */
.stats-header{
  background:var(--navy3);
  padding:20px 18px 22px;
  position:relative;overflow:hidden;
}
.stats-header::before{
  content:'';position:absolute;top:-80px;right:-60px;
  width:240px;height:240px;border-radius:var(--rfull);
  background:radial-gradient(circle,rgba(249,115,22,.12),transparent 60%);
  pointer-events:none;
}
.sh-label{font-size:11px;font-weight:700;color:rgba(255,255,255,.4);text-transform:uppercase;letter-spacing:.08em;margin-bottom:4px;}
.sh-title{font-family:var(--f-d);font-size:24px;font-weight:700;color:#fff;margin-bottom:18px;line-height:1.2;}
.sh-title span{color:var(--orange);}
.stats-4{display:grid;grid-template-columns:repeat(2,1fr);gap:8px;}
.sc{
  background:rgba(255,255,255,.07);
  border:1px solid rgba(255,255,255,.08);
  border-radius:var(--r12);
  padding:12px 14px;
  display:flex;align-items:flex-start;gap:10px;
}
.sc-icon{
  width:36px;height:36px;border-radius:var(--r8);
  display:grid;place-items:center;font-size:17px;flex-shrink:0;
}
.sc-body{}
.sc-val{font-family:var(--f-d);font-size:20px;font-weight:700;color:#fff;line-height:1;margin-bottom:2px;}
.sc-lbl{font-size:10px;color:rgba(255,255,255,.45);font-weight:600;}
.sc-change{font-size:10px;font-weight:700;margin-top:3px;}
.sc-change.up{color:#4ade80;}
.sc-change.dn{color:#fb7185;}

/* ── SECTION ── */
.sec{padding:14px 14px 0;}
.sec-head{display:flex;align-items:center;justify-content:space-between;margin-bottom:10px;}
.sec-title{font-size:14px;font-weight:800;color:var(--navy);letter-spacing:-.02em;}
.sec-more{font-size:12px;font-weight:700;color:var(--orange);}
.sec-count{font-size:11px;font-weight:700;color:var(--muted);}

/* ── CARD BASE ── */
.card{
  background:var(--surface);border-radius:var(--r16);
  border:1px solid var(--line);box-shadow:var(--sh-sm);
  overflow:hidden;margin-bottom:10px;
  transition:.15s var(--ease);
}
.card:active{transform:scale(.99);}

/* ── VERIFY CARD ── */
.vcard-head{
  display:flex;align-items:center;gap:11px;
  padding:13px 14px;border-bottom:1px solid var(--line);
}
.vcard-icon{
  width:42px;height:42px;border-radius:var(--r12);
  background:var(--warm);display:grid;place-items:center;
  font-size:22px;flex-shrink:0;
}
.vcard-name{font-size:14px;font-weight:800;color:var(--navy);margin-bottom:1px;}
.vcard-meta{font-size:12px;color:var(--muted);}
.vcard-new{
  margin-left:auto;
  padding:3px 8px;border-radius:var(--rfull);
  background:var(--amber-bg);color:var(--amber);
  font-size:9px;font-weight:800;letter-spacing:.04em;text-transform:uppercase;
  flex-shrink:0;
}
.vcard-body{padding:11px 14px;}
.vcard-detail-row{
  display:flex;gap:6px;flex-wrap:wrap;margin-bottom:11px;
}
.vcard-tag{
  padding:3px 9px;border-radius:var(--rfull);
  background:var(--bg);border:1px solid var(--line);
  font-size:11px;font-weight:600;color:var(--navy);
}
.vcard-actions{display:flex;gap:8px;}
.vbtn{
  flex:1;padding:10px;border-radius:var(--r12);
  font-size:13px;font-weight:800;
  display:flex;align-items:center;justify-content:center;gap:6px;
  transition:.15s var(--ease);
}
.vbtn-approve{background:var(--green-bg);color:#16a34a;border:1.5px solid rgba(34,197,94,.2);}
.vbtn-approve:active{background:var(--green);color:#fff;}
.vbtn-reject{background:var(--red-bg);color:var(--red);border:1.5px solid rgba(244,63,94,.15);}
.vbtn-reject:active{background:var(--red);color:#fff;}

/* ── SHOP ROW ── */
.shop-row{
  display:flex;align-items:center;gap:11px;
  padding:12px 14px;
  border-bottom:1px solid var(--line);
}
.shop-row:last-child{border-bottom:none;}
.shop-icon{
  width:38px;height:38px;border-radius:var(--r8);
  display:grid;place-items:center;font-size:19px;flex-shrink:0;
}
.shop-info{flex:1;min-width:0;}
.shop-name{font-size:13px;font-weight:700;color:var(--navy);margin-bottom:2px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;}
.shop-sub{font-size:11px;color:var(--muted);}
.shop-status{
  padding:3px 8px;border-radius:var(--rfull);
  font-size:9px;font-weight:800;letter-spacing:.03em;text-transform:uppercase;
  flex-shrink:0;
}
.ss-on{background:var(--green-bg);color:#16a34a;}
.ss-off{background:var(--bg);color:var(--muted);border:1px solid var(--line);}
.ss-pend{background:var(--amber-bg);color:var(--amber);}
.shop-more{
  width:28px;height:28px;border-radius:var(--rfull);
  background:var(--bg);display:grid;place-items:center;flex-shrink:0;
}
.shop-more svg{width:14px;height:14px;color:var(--muted);}

/* ── USER ROW ── */
.user-row{
  display:flex;align-items:center;gap:11px;
  padding:12px 14px;border-bottom:1px solid var(--line);
}
.user-row:last-child{border-bottom:none;}
.user-av{
  width:38px;height:38px;border-radius:var(--rfull);
  display:grid;place-items:center;
  font-size:14px;font-weight:800;color:#fff;flex-shrink:0;
}
.user-info{flex:1;min-width:0;}
.user-name{font-size:13px;font-weight:700;color:var(--navy);margin-bottom:1px;}
.user-email{font-size:11px;color:var(--muted);white-space:nowrap;overflow:hidden;text-overflow:ellipsis;}
.role-badge{
  padding:3px 9px;border-radius:var(--rfull);
  font-size:10px;font-weight:800;flex-shrink:0;
}
.rb-user{background:var(--blue-bg);color:var(--blue);}
.rb-shop{background:var(--green-bg);color:#16a34a;}
.rb-admin{background:var(--purple-bg);color:var(--purple);}
.user-action{
  width:28px;height:28px;border-radius:var(--rfull);
  background:var(--bg);display:grid;place-items:center;flex-shrink:0;
}
.user-action svg{width:13px;height:13px;color:var(--muted);}

/* ── VILLAGE ITEM ── */
.village-item{
  display:flex;align-items:center;gap:11px;
  padding:12px 14px;border-bottom:1px solid var(--line);
}
.village-item:last-child{border-bottom:none;}
.village-icon{
  width:36px;height:36px;border-radius:var(--r8);
  background:var(--blue-bg);display:grid;place-items:center;font-size:17px;flex-shrink:0;
}
.village-name{flex:1;font-size:13px;font-weight:700;color:var(--navy);}
.village-count{font-size:11px;color:var(--muted);}
.village-acts{display:flex;gap:5px;}
.vact{
  padding:5px 11px;border-radius:var(--rfull);
  font-size:11px;font-weight:700;transition:.15s;
}
.vact-edit{background:var(--bg);color:var(--navy);border:1px solid var(--line);}
.vact-edit:active{background:var(--navy);color:#fff;}
.vact-del{background:var(--red-bg);color:var(--red);border:1px solid rgba(244,63,94,.15);}
.vact-del:active{background:var(--red);color:#fff;}

/* ── BLOG ITEM ── */
.blog-item{
  display:flex;gap:12px;
  padding:13px 14px;border-bottom:1px solid var(--line);
  align-items:flex-start;
}
.blog-item:last-child{border-bottom:none;}
.blog-thumb{
  width:64px;height:64px;border-radius:var(--r12);
  display:grid;place-items:center;font-size:28px;flex-shrink:0;
}
.blog-info{flex:1;min-width:0;}
.blog-title{font-size:13px;font-weight:700;color:var(--navy);margin-bottom:4px;line-height:1.35;}
.blog-meta{display:flex;align-items:center;gap:6px;flex-wrap:wrap;}
.blog-status{
  padding:2px 8px;border-radius:var(--rfull);
  font-size:9px;font-weight:800;letter-spacing:.04em;text-transform:uppercase;
}
.bs-pub{background:var(--green-bg);color:#16a34a;}
.bs-draft{background:var(--bg);color:var(--muted);border:1px solid var(--line);}
.bs-ann{background:var(--amber-bg);color:var(--amber);}
.blog-date{font-size:11px;color:var(--muted);}
.blog-acts{display:flex;gap:5px;margin-top:8px;}
.bact{
  padding:5px 11px;border-radius:var(--rfull);
  font-size:11px;font-weight:700;transition:.15s;
}
.bact-edit{background:var(--bg);color:var(--navy);border:1px solid var(--line);}
.bact-edit:active{background:var(--navy);color:#fff;}
.bact-del{background:var(--red-bg);color:var(--red);border:1px solid rgba(244,63,94,.15);}
.bact-del:active{background:var(--red);color:#fff;}

/* ── PLATFORM SETTINGS ── */
.ps-card{
  background:var(--surface);border-radius:var(--r16);
  border:1px solid var(--line);box-shadow:var(--sh-sm);
  overflow:hidden;margin-bottom:12px;
}
.ps-head{
  padding:11px 16px;border-bottom:1px solid var(--line);
  font-size:10px;font-weight:800;color:var(--muted);
  text-transform:uppercase;letter-spacing:.07em;
  background:var(--bg);
}
.ps-row{
  display:flex;align-items:center;gap:12px;
  padding:13px 16px;border-bottom:1px solid var(--line);
}
.ps-row:last-child{border-bottom:none;}
.ps-icon{
  width:36px;height:36px;border-radius:var(--r12);
  display:grid;place-items:center;font-size:16px;flex-shrink:0;
}
.ps-text{flex:1;}
.ps-label{font-size:13px;font-weight:700;color:var(--navy);}
.ps-sub{font-size:11px;color:var(--muted);margin-top:1px;}
.ps-toggle{
  width:42px;height:24px;border-radius:var(--rfull);
  background:var(--line);position:relative;flex-shrink:0;
  transition:.25s var(--ease);
}
.ps-toggle.on{background:var(--orange);}
.ps-toggle-thumb{
  width:18px;height:18px;border-radius:var(--rfull);
  background:#fff;position:absolute;top:3px;left:3px;
  transition:.25s var(--ease);box-shadow:0 1px 4px rgba(0,0,0,.15);
}
.ps-toggle.on .ps-toggle-thumb{left:calc(100% - 21px);}
.ps-val{font-size:13px;font-weight:700;color:var(--orange);}
.ps-arrow{
  width:26px;height:26px;border-radius:var(--rfull);
  background:var(--bg);display:grid;place-items:center;flex-shrink:0;
}
.ps-arrow svg{width:13px;height:13px;color:var(--muted);}
.ps-row.clickable{cursor:pointer;transition:.15s;}
.ps-row.clickable:active{background:var(--bg);}

/* ── FORMS ── */
.form-wrap{padding:14px 16px;}
.fg{margin-bottom:13px;}
.fg:last-child{margin-bottom:0;}
.fg label{display:block;font-size:10px;font-weight:800;color:var(--muted);text-transform:uppercase;letter-spacing:.05em;margin-bottom:5px;}
.finput{width:100%;padding:11px 13px;border-radius:var(--r12);border:1.5px solid var(--line);background:#fff;font-size:14px;color:var(--ink);outline:none;transition:.18s var(--ease);}
.finput:focus{border-color:var(--orange);box-shadow:0 0 0 3px rgba(249,115,22,.08);}
.finput::placeholder{color:var(--muted);}
textarea.finput{resize:none;min-height:80px;line-height:1.6;}
.btn-save{
  width:100%;margin-top:14px;padding:14px;
  border-radius:var(--r16);background:var(--orange);color:#fff;
  font-size:14px;font-weight:800;
  display:flex;align-items:center;justify-content:center;gap:8px;
  box-shadow:0 6px 24px rgba(249,115,22,.3);
  transition:.18s var(--ease);
}
.btn-save:active{transform:scale(.98);background:var(--orange2);}
.btn-add-primary{
  display:flex;align-items:center;gap:8px;
  padding:10px 16px;border-radius:var(--rfull);
  background:var(--navy);color:#fff;
  font-size:13px;font-weight:700;
  transition:.15s;box-shadow:var(--sh-sm);
}
.btn-add-primary:active{background:var(--orange);}

/* ── ACTIVITY FEED ── */
.feed-item{
  display:flex;gap:12px;
  padding:11px 14px;border-bottom:1px solid var(--line);
  align-items:flex-start;
}
.feed-item:last-child{border-bottom:none;}
.feed-dot{
  width:8px;height:8px;border-radius:var(--rfull);
  flex-shrink:0;margin-top:5px;
}
.fd-green{background:var(--green);}
.fd-orange{background:var(--orange);}
.fd-blue{background:var(--blue);}
.fd-red{background:var(--red);}
.feed-text{flex:1;}
.feed-main{font-size:13px;color:var(--ink);line-height:1.45;margin-bottom:2px;}
.feed-main strong{color:var(--navy);font-weight:700;}
.feed-time{font-size:11px;color:var(--muted);}

/* ── CHART BARS ── */
.chart-wrap{
  background:var(--surface);border-radius:var(--r16);
  border:1px solid var(--line);box-shadow:var(--sh-sm);
  padding:14px;margin-bottom:10px;
}
.chart-title{font-size:11px;font-weight:800;color:var(--muted);text-transform:uppercase;letter-spacing:.06em;margin-bottom:12px;}
.chart-bars{display:flex;align-items:flex-end;gap:5px;height:72px;}
.cbar-col{flex:1;display:flex;flex-direction:column;align-items:center;gap:3px;}
.cbar{
  width:100%;border-radius:4px 4px 0 0;
  transition:.6s var(--ease);
  animation:bar-up .6s var(--ease) both;
}
.cbar.orange{background:var(--orange);}
.cbar.navy{background:var(--navy);opacity:.4;}
@keyframes bar-up{from{height:0;}to{height:var(--h);}}
.cbar-lbl{font-size:9px;font-weight:700;color:var(--muted);}

/* ── SEARCH BAR ── */
.search-bar{
  display:flex;align-items:center;gap:8px;
  background:var(--bg);border-radius:var(--rfull);
  padding:0 14px;height:40px;
  border:1.5px solid var(--line);
  transition:.2s var(--ease);
  margin:14px 14px 0;
}
.search-bar:focus-within{background:#fff;border-color:var(--orange);box-shadow:0 0 0 3px rgba(249,115,22,.08);}
.search-bar svg{width:14px;height:14px;color:var(--muted);flex-shrink:0;}
.search-bar input{flex:1;border:none;background:transparent;outline:none;font-size:13px;color:var(--ink);}
.search-bar input::placeholder{color:var(--muted);}

/* ── OVERLAY SHEET ── */
.overlay{position:fixed;inset:0;z-index:300;background:rgba(15,27,39,.6);backdrop-filter:blur(5px);opacity:0;pointer-events:none;transition:.25s var(--ease);}
.overlay.open{opacity:1;pointer-events:all;}
.sheet{position:absolute;bottom:0;left:0;right:0;background:var(--surface);border-radius:22px 22px 0 0;max-height:88vh;overflow-y:auto;transform:translateY(100%);transition:.32s cubic-bezier(.32,0,.67,0);}
.overlay.open .sheet{transform:translateY(0);transition:.32s cubic-bezier(.33,1,.68,1);}
.sheet-handle{width:36px;height:4px;border-radius:2px;background:var(--line);margin:12px auto 0;}
.sheet-title{font-family:var(--f-d);font-size:20px;font-weight:700;color:var(--navy);padding:14px 20px 3px;}
.sheet-sub{padding:0 20px 12px;font-size:13px;color:var(--muted);border-bottom:1px solid var(--line);}
.sheet-body{padding:16px 20px;}
.sheet-foot{padding:12px 20px calc(12px + env(safe-area-inset-bottom));border-top:1px solid var(--line);display:flex;gap:10px;}
.sbtn-p{flex:1;padding:13px;border-radius:var(--r12);background:var(--orange);color:#fff;font-size:14px;font-weight:800;transition:.18s;box-shadow:0 4px 16px rgba(249,115,22,.3);}
.sbtn-p:active{transform:scale(.97);}
.sbtn-s{padding:13px 18px;border-radius:var(--r12);border:1.5px solid var(--line);background:var(--surface);color:var(--navy);font-size:14px;font-weight:700;transition:.18s;}
.sbtn-s:active{border-color:var(--navy);}
.sbtn-danger{flex:1;padding:13px;border-radius:var(--r12);background:var(--red-bg);color:var(--red);font-size:14px;font-weight:800;border:1.5px solid rgba(244,63,94,.2);transition:.18s;}
.sbtn-danger:active{background:var(--red);color:#fff;}

/* ── MISC ── */
.spacer{height:12px;}
.load-more{display:flex;justify-content:center;padding:14px;}
.btn-more{padding:8px 20px;border-radius:var(--rfull);border:1.5px solid var(--line);font-size:12px;font-weight:700;color:var(--muted);background:var(--surface);transition:.18s;}
.btn-more:active{border-color:var(--orange);color:var(--orange);}
.inline-add{display:flex;gap:10px;align-items:center;padding:12px 14px 0;}
</style>
</head>
<body>

<!-- ══ TOPBAR ══ -->
<header class="topbar">
  <div class="tbar-left">
    <div class="tbar-logo">
      <svg viewBox="0 0 100 100" fill="none">
        <circle cx="50" cy="50" r="44" stroke="#F97316" stroke-width="8"/>
        <circle cx="50" cy="50" r="31" stroke="rgba(255,255,255,.4)" stroke-width="5"/>
        <ellipse cx="44" cy="43" rx="12" ry="12" fill="rgba(255,255,255,.6)"/>
        <line x1="50" y1="43" x2="50" y2="71" stroke="rgba(255,255,255,.6)" stroke-width="6" stroke-linecap="round"/>
      </svg>
    </div>
    <span class="tbar-logo-name">Orb<span>Food</span></span>
    <span class="tbar-badge">Admin</span>
  </div>
  <div class="tbar-right">
    <button class="tbar-btn" onclick="openSheet('notif')">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 0 1-3.46 0"/></svg>
      <span class="tbar-dot"></span>
    </button>
    <button class="tbar-btn">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
    </button>
  </div>
</header>

<!-- ══════════════════════════════
     STATISTIK
══════════════════════════════ -->
<main class="page active" id="page-stats">

  <div class="stats-header">
    <div class="sh-label">Panel Admin</div>
    <div class="sh-title">Ringkasan<br><span>Platform</span></div>
    <div class="stats-4">
      <div class="sc">
        <div class="sc-icon" style="background:rgba(249,115,22,.15)">👥</div>
        <div class="sc-body">
          <div class="sc-val">1.248</div>
          <div class="sc-lbl">Pengguna</div>
          <div class="sc-change up">↑ 12% minggu ini</div>
        </div>
      </div>
      <div class="sc">
        <div class="sc-icon" style="background:rgba(34,197,94,.15)">🏪</div>
        <div class="sc-body">
          <div class="sc-val">84</div>
          <div class="sc-lbl">Toko Aktif</div>
          <div class="sc-change up">↑ 3 toko baru</div>
        </div>
      </div>
      <div class="sc">
        <div class="sc-icon" style="background:rgba(59,130,246,.15)">🍽️</div>
        <div class="sc-body">
          <div class="sc-val">642</div>
          <div class="sc-lbl">Total Menu</div>
          <div class="sc-change up">↑ 28 menu baru</div>
        </div>
      </div>
      <div class="sc">
        <div class="sc-icon" style="background:rgba(139,92,246,.15)">📋</div>
        <div class="sc-body">
          <div class="sc-val">3.801</div>
          <div class="sc-lbl">Total Pesanan</div>
          <div class="sc-change up">↑ 8% bulan ini</div>
        </div>
      </div>
    </div>
  </div>

  <!-- Growth Chart -->
  <div class="sec">
    <div class="chart-wrap">
      <div class="chart-title">Pesanan per Hari (7 hari)</div>
      <div class="chart-bars">
        <div class="cbar-col"><div class="cbar navy" style="--h:44px;height:44px"></div><span class="cbar-lbl">Sen</span></div>
        <div class="cbar-col"><div class="cbar navy" style="--h:60px;height:60px"></div><span class="cbar-lbl">Sel</span></div>
        <div class="cbar-col"><div class="cbar navy" style="--h:38px;height:38px"></div><span class="cbar-lbl">Rab</span></div>
        <div class="cbar-col"><div class="cbar navy" style="--h:66px;height:66px"></div><span class="cbar-lbl">Kam</span></div>
        <div class="cbar-col"><div class="cbar navy" style="--h:52px;height:52px"></div><span class="cbar-lbl">Jum</span></div>
        <div class="cbar-col"><div class="cbar navy" style="--h:70px;height:70px"></div><span class="cbar-lbl">Sab</span></div>
        <div class="cbar-col"><div class="cbar orange" style="--h:72px;height:72px"></div><span class="cbar-lbl" style="color:var(--orange);font-weight:800">Min</span></div>
      </div>
    </div>

    <!-- Quick platform stats -->
    <div class="card">
      <div style="padding:12px 14px;border-bottom:1px solid var(--line);font-size:10px;font-weight:800;color:var(--muted);text-transform:uppercase;letter-spacing:.07em;background:var(--bg)">Ringkasan Platform</div>
      <div style="display:grid;grid-template-columns:repeat(2,1fr)">
        <div style="padding:13px 14px;border-right:1px solid var(--line);border-bottom:1px solid var(--line)">
          <div style="font-size:11px;color:var(--muted);margin-bottom:3px">Toko Aktif</div>
          <div style="font-family:var(--f-d);font-size:18px;font-weight:700;color:var(--green)">79 / 84</div>
        </div>
        <div style="padding:13px 14px;border-bottom:1px solid var(--line)">
          <div style="font-size:11px;color:var(--muted);margin-bottom:3px">Toko Pending</div>
          <div style="font-family:var(--f-d);font-size:18px;font-weight:700;color:var(--amber)">5</div>
        </div>
        <div style="padding:13px 14px;border-right:1px solid var(--line)">
          <div style="font-size:11px;color:var(--muted);margin-bottom:3px">Tap WA Total</div>
          <div style="font-family:var(--f-d);font-size:18px;font-weight:700;color:var(--navy)">12.480</div>
        </div>
        <div style="padding:13px 14px">
          <div style="font-size:11px;color:var(--muted);margin-bottom:3px">Tap Maps Total</div>
          <div style="font-family:var(--f-d);font-size:18px;font-weight:700;color:var(--navy)">3.201</div>
        </div>
      </div>
    </div>
  </div>

  <!-- Activity Feed -->
  <div class="sec">
    <div class="sec-head"><span class="sec-title">Aktivitas Terbaru</span></div>
    <div class="card">
      <div class="feed-item">
        <div class="feed-dot fd-green"></div>
        <div class="feed-text">
          <div class="feed-main"><strong>Warung Mbok Darmi</strong> berhasil diverifikasi</div>
          <div class="feed-time">5 menit lalu</div>
        </div>
      </div>
      <div class="feed-item">
        <div class="feed-dot fd-orange"></div>
        <div class="feed-text">
          <div class="feed-main">Pengajuan toko baru dari <strong>Kedai Pak Bejo</strong></div>
          <div class="feed-time">23 menit lalu</div>
        </div>
      </div>
      <div class="feed-item">
        <div class="feed-dot fd-blue"></div>
        <div class="feed-text">
          <div class="feed-main"><strong>Ahmad Fauzi</strong> bergabung sebagai pengguna baru</div>
          <div class="feed-time">1 jam lalu</div>
        </div>
      </div>
      <div class="feed-item">
        <div class="feed-dot fd-red"></div>
        <div class="feed-text">
          <div class="feed-main">Toko <strong>Soto Pak Hendra</strong> dinonaktifkan</div>
          <div class="feed-time">2 jam lalu</div>
        </div>
      </div>
      <div class="feed-item">
        <div class="feed-dot fd-blue"></div>
        <div class="feed-text">
          <div class="feed-main">Artikel <strong>"5 Tips UMKM"</strong> dipublikasikan</div>
          <div class="feed-time">3 jam lalu</div>
        </div>
      </div>
    </div>
  </div>
  <div class="spacer"></div>

</main>

<!-- ══════════════════════════════
     VERIFIKASI TOKO
══════════════════════════════ -->
<main class="page" id="page-verify">

  <div class="sec" style="padding-top:14px">
    <div class="sec-head">
      <span class="sec-title">Menunggu Verifikasi</span>
      <span class="sec-count">5 pengajuan</span>
    </div>

    <div class="card" id="vcard-1">
      <div class="vcard-head">
        <div class="vcard-icon">🥘</div>
        <div>
          <div class="vcard-name">Warung Mbok Darmi</div>
          <div class="vcard-meta">Siti Rahayu · siti@gmail.com</div>
        </div>
        <span class="vcard-new">Baru</span>
      </div>
      <div class="vcard-body">
        <div class="vcard-detail-row">
          <span class="vcard-tag">📍 Sukamaju</span>
          <span class="vcard-tag">🍱 Nasi & Lauk</span>
          <span class="vcard-tag">🛵 Delivery</span>
        </div>
        <div class="vcard-actions">
          <button class="vbtn vbtn-approve" onclick="verifyAction('vcard-1','approve')">✓ Setujui</button>
          <button class="vbtn vbtn-reject" onclick="verifyAction('vcard-1','reject')">✕ Tolak</button>
        </div>
      </div>
    </div>

    <div class="card" id="vcard-2">
      <div class="vcard-head">
        <div class="vcard-icon">☕</div>
        <div>
          <div class="vcard-name">Kedai Pak Bejo</div>
          <div class="vcard-meta">Bejo Santoso · bejo@gmail.com</div>
        </div>
        <span class="vcard-new">Baru</span>
      </div>
      <div class="vcard-body">
        <div class="vcard-detail-row">
          <span class="vcard-tag">📍 Mekarsari</span>
          <span class="vcard-tag">☕ Minuman</span>
          <span class="vcard-tag">📦 Pick Up</span>
        </div>
        <div class="vcard-actions">
          <button class="vbtn vbtn-approve" onclick="verifyAction('vcard-2','approve')">✓ Setujui</button>
          <button class="vbtn vbtn-reject" onclick="verifyAction('vcard-2','reject')">✕ Tolak</button>
        </div>
      </div>
    </div>

    <div class="card" id="vcard-3">
      <div class="vcard-head">
        <div class="vcard-icon">🎂</div>
        <div>
          <div class="vcard-name">Dapur Mbak Yuni</div>
          <div class="vcard-meta">Yuniati · yuni@gmail.com</div>
        </div>
        <span class="vcard-new">Baru</span>
      </div>
      <div class="vcard-body">
        <div class="vcard-detail-row">
          <span class="vcard-tag">📍 Cibening</span>
          <span class="vcard-tag">🎂 Kue & Snack</span>
          <span class="vcard-tag">🛵 Delivery</span>
        </div>
        <div class="vcard-actions">
          <button class="vbtn vbtn-approve" onclick="verifyAction('vcard-3','approve')">✓ Setujui</button>
          <button class="vbtn vbtn-reject" onclick="verifyAction('vcard-3','reject')">✕ Tolak</button>
        </div>
      </div>
    </div>

  </div>
  <div class="spacer"></div>

</main>

<!-- ══════════════════════════════
     SEMUA TOKO
══════════════════════════════ -->
<main class="page" id="page-shops">

  <div class="search-bar">
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8"/><path d="m21 21-4.35-4.35"/></svg>
    <input type="text" placeholder="Cari toko…">
  </div>

  <div class="sec" style="padding-top:12px">
    <div class="card">

      <div class="shop-row">
        <div class="shop-icon" style="background:#FFF7ED">🍜</div>
        <div class="shop-info">
          <div class="shop-name">Warung Bu Sari</div>
          <div class="shop-sub">Sukamaju · 142 pesanan</div>
        </div>
        <span class="shop-status ss-on">Aktif</span>
        <button class="shop-more" onclick="openSheet('shop-detail')"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="1"/><circle cx="19" cy="12" r="1"/><circle cx="5" cy="12" r="1"/></svg></button>
      </div>

      <div class="shop-row">
        <div class="shop-icon" style="background:#FFF1F2">🍢</div>
        <div class="shop-info">
          <div class="shop-name">Bakso Pak Hasan</div>
          <div class="shop-sub">Sukamaju · 89 pesanan</div>
        </div>
        <span class="shop-status ss-on">Aktif</span>
        <button class="shop-more" onclick="openSheet('shop-detail')"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="1"/><circle cx="19" cy="12" r="1"/><circle cx="5" cy="12" r="1"/></svg></button>
      </div>

      <div class="shop-row">
        <div class="shop-icon" style="background:#F0FDF4">🍱</div>
        <div class="shop-info">
          <div class="shop-name">Catering Mbak Rina</div>
          <div class="shop-sub">Mekarsari · 34 pesanan</div>
        </div>
        <span class="shop-status ss-off">Nonaktif</span>
        <button class="shop-more" onclick="openSheet('shop-detail')"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="1"/><circle cx="19" cy="12" r="1"/><circle cx="5" cy="12" r="1"/></svg></button>
      </div>

      <div class="shop-row">
        <div class="shop-icon" style="background:#EFF6FF">🥤</div>
        <div class="shop-info">
          <div class="shop-name">Segar Jus Pak Jono</div>
          <div class="shop-sub">Cibening · 57 pesanan</div>
        </div>
        <span class="shop-status ss-on">Aktif</span>
        <button class="shop-more" onclick="openSheet('shop-detail')"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="1"/><circle cx="19" cy="12" r="1"/><circle cx="5" cy="12" r="1"/></svg></button>
      </div>

      <div class="shop-row">
        <div class="shop-icon" style="background:var(--amber-bg)">🥘</div>
        <div class="shop-info">
          <div class="shop-name">Warung Mbok Darmi</div>
          <div class="shop-sub">Sukamaju · Baru bergabung</div>
        </div>
        <span class="shop-status ss-pend">Pending</span>
        <button class="shop-more" onclick="openSheet('shop-detail')"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="1"/><circle cx="19" cy="12" r="1"/><circle cx="5" cy="12" r="1"/></svg></button>
      </div>

    </div>
  </div>
  <div class="load-more"><button class="btn-more">Muat lebih banyak</button></div>

</main>

<!-- ══════════════════════════════
     PENGGUNA
══════════════════════════════ -->
<main class="page" id="page-users">

  <div class="search-bar">
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8"/><path d="m21 21-4.35-4.35"/></svg>
    <input type="text" placeholder="Cari pengguna…">
  </div>

  <div class="sec" style="padding-top:12px">
    <div class="card">

      <div class="user-row">
        <div class="user-av" style="background:var(--orange)">A</div>
        <div class="user-info">
          <div class="user-name">Ahmad Fauzi</div>
          <div class="user-email">ahmad.fauzi@gmail.com</div>
        </div>
        <span class="role-badge rb-user">user</span>
        <button class="user-action" onclick="openSheet('user-detail')"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="1"/><circle cx="19" cy="12" r="1"/><circle cx="5" cy="12" r="1"/></svg></button>
      </div>

      <div class="user-row">
        <div class="user-av" style="background:#16a34a">B</div>
        <div class="user-info">
          <div class="user-name">Bu Sari</div>
          <div class="user-email">sari.warung@gmail.com</div>
        </div>
        <span class="role-badge rb-shop">shop</span>
        <button class="user-action" onclick="openSheet('user-detail')"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="1"/><circle cx="19" cy="12" r="1"/><circle cx="5" cy="12" r="1"/></svg></button>
      </div>

      <div class="user-row">
        <div class="user-av" style="background:var(--purple)">C</div>
        <div class="user-info">
          <div class="user-name">Citra Dewi</div>
          <div class="user-email">citra.d@gmail.com</div>
        </div>
        <span class="role-badge rb-user">user</span>
        <button class="user-action" onclick="openSheet('user-detail')"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="1"/><circle cx="19" cy="12" r="1"/><circle cx="5" cy="12" r="1"/></svg></button>
      </div>

      <div class="user-row">
        <div class="user-av" style="background:var(--blue)">D</div>
        <div class="user-info">
          <div class="user-name">Doni Setiawan</div>
          <div class="user-email">doni.s@gmail.com</div>
        </div>
        <span class="role-badge rb-shop">shop</span>
        <button class="user-action" onclick="openSheet('user-detail')"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="1"/><circle cx="19" cy="12" r="1"/><circle cx="5" cy="12" r="1"/></svg></button>
      </div>

      <div class="user-row">
        <div class="user-av" style="background:var(--navy)">E</div>
        <div class="user-info">
          <div class="user-name">Super Admin</div>
          <div class="user-email">admin@orbfood.app</div>
        </div>
        <span class="role-badge rb-admin">admin</span>
        <button class="user-action" onclick="openSheet('user-detail')"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="1"/><circle cx="19" cy="12" r="1"/><circle cx="5" cy="12" r="1"/></svg></button>
      </div>

    </div>
  </div>
  <div class="load-more"><button class="btn-more">Muat lebih banyak</button></div>

</main>

<!-- ══════════════════════════════
     KONTEN (Desa + Blog)
══════════════════════════════ -->
<main class="page" id="page-content">

  <!-- Villages -->
  <div class="sec" style="padding-top:14px">
    <div class="sec-head">
      <span class="sec-title">Manajemen Desa</span>
      <button class="btn-add-primary" onclick="openSheet('add-village')">
        <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
        Tambah
      </button>
    </div>
    <div class="card">
      <div class="village-item">
        <div class="village-icon">📍</div>
        <div class="village-name">Sukamaju</div>
        <div class="village-count">32 toko</div>
        <div class="village-acts">
          <button class="vact vact-edit">Edit</button>
          <button class="vact vact-del">🗑️</button>
        </div>
      </div>
      <div class="village-item">
        <div class="village-icon">📍</div>
        <div class="village-name">Mekarsari</div>
        <div class="village-count">18 toko</div>
        <div class="village-acts">
          <button class="vact vact-edit">Edit</button>
          <button class="vact vact-del">🗑️</button>
        </div>
      </div>
      <div class="village-item">
        <div class="village-icon">📍</div>
        <div class="village-name">Bojong Lestari</div>
        <div class="village-count">11 toko</div>
        <div class="village-acts">
          <button class="vact vact-edit">Edit</button>
          <button class="vact vact-del">🗑️</button>
        </div>
      </div>
      <div class="village-item">
        <div class="village-icon">📍</div>
        <div class="village-name">Cibening</div>
        <div class="village-count">9 toko</div>
        <div class="village-acts">
          <button class="vact vact-edit">Edit</button>
          <button class="vact vact-del">🗑️</button>
        </div>
      </div>
    </div>
  </div>

  <!-- Blog -->
  <div class="sec">
    <div class="sec-head">
      <span class="sec-title">Blog & Artikel</span>
      <button class="btn-add-primary" onclick="openSheet('add-blog')">
        <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
        Tulis
      </button>
    </div>
    <div class="card">

      <div class="blog-item">
        <div class="blog-thumb" style="background:var(--amber-bg)">📢</div>
        <div class="blog-info">
          <div class="blog-title">OrbFood kini hadir di 12 desa baru!</div>
          <div class="blog-meta">
            <span class="blog-status bs-ann">Pengumuman</span>
            <span class="blog-date">9 Mar 2024</span>
          </div>
          <div class="blog-acts">
            <button class="bact bact-edit" onclick="openSheet('edit-blog')">✏️ Edit</button>
            <button class="bact bact-del">🗑️</button>
          </div>
        </div>
      </div>

      <div class="blog-item">
        <div class="blog-thumb" style="background:#FFF7ED">🍳</div>
        <div class="blog-info">
          <div class="blog-title">5 Tips Memulai Usaha Kuliner dari Rumah</div>
          <div class="blog-meta">
            <span class="blog-status bs-pub">Published</span>
            <span class="blog-date">7 Mar 2024</span>
          </div>
          <div class="blog-acts">
            <button class="bact bact-edit" onclick="openSheet('edit-blog')">✏️ Edit</button>
            <button class="bact bact-del">🗑️</button>
          </div>
        </div>
      </div>

      <div class="blog-item">
        <div class="blog-thumb" style="background:#EFF6FF">🛵</div>
        <div class="blog-info">
          <div class="blog-title">Update: Group Order Kini Lebih Mudah!</div>
          <div class="blog-meta">
            <span class="blog-status bs-pub">Published</span>
            <span class="blog-date">5 Mar 2024</span>
          </div>
          <div class="blog-acts">
            <button class="bact bact-edit" onclick="openSheet('edit-blog')">✏️ Edit</button>
            <button class="bact bact-del">🗑️</button>
          </div>
        </div>
      </div>

      <div class="blog-item">
        <div class="blog-thumb" style="background:var(--bg)">📝</div>
        <div class="blog-info">
          <div class="blog-title">Fitur Baru OrbFood Q2 2024</div>
          <div class="blog-meta">
            <span class="blog-status bs-draft">Draft</span>
            <span class="blog-date">3 Mar 2024</span>
          </div>
          <div class="blog-acts">
            <button class="bact bact-edit" onclick="openSheet('edit-blog')">✏️ Edit</button>
            <button class="bact bact-del">🗑️</button>
          </div>
        </div>
      </div>

    </div>
  </div>
  <div class="spacer"></div>

</main>

<!-- ══════════════════════════════
     PENGATURAN PLATFORM
══════════════════════════════ -->
<main class="page" id="page-platform">
  <div style="padding:14px 14px 0">

    <div class="ps-card">
      <div class="ps-head">Platform</div>
      <div class="ps-row">
        <div class="ps-icon" style="background:var(--warm)">🏷️</div>
        <div class="ps-text"><div class="ps-label">Nama Platform</div><div class="ps-sub">OrbFood</div></div>
        <div class="ps-arrow"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="9 18 15 12 9 6"/></svg></div>
      </div>
      <div class="ps-row">
        <div class="ps-icon" style="background:var(--green-bg)">💬</div>
        <div class="ps-text"><div class="ps-label">WhatsApp Admin</div><div class="ps-sub">6281234567890</div></div>
        <div class="ps-arrow"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="9 18 15 12 9 6"/></svg></div>
      </div>
      <div class="ps-row">
        <div class="ps-icon" style="background:var(--blue-bg)">🕐</div>
        <div class="ps-text"><div class="ps-label">Jam Operasional</div><div class="ps-sub">07:00 — 22:00</div></div>
        <div class="ps-arrow"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="9 18 15 12 9 6"/></svg></div>
      </div>
    </div>

    <div class="ps-card">
      <div class="ps-head">Fitur Platform</div>
      <div class="ps-row">
        <div class="ps-icon" style="background:var(--green-bg)">🟢</div>
        <div class="ps-text"><div class="ps-label">Platform Aktif</div><div class="ps-sub">Pengguna bisa akses platform</div></div>
        <button class="ps-toggle on" onclick="this.classList.toggle('on')"><div class="ps-toggle-thumb"></div></button>
      </div>
      <div class="ps-row">
        <div class="ps-icon" style="background:var(--purple-bg)">👥</div>
        <div class="ps-text"><div class="ps-label">Fitur Group Order</div><div class="ps-sub">Aktifkan group order untuk semua toko</div></div>
        <button class="ps-toggle on" onclick="this.classList.toggle('on')"><div class="ps-toggle-thumb"></div></button>
      </div>
      <div class="ps-row">
        <div class="ps-icon" style="background:var(--amber-bg)">📢</div>
        <div class="ps-text"><div class="ps-label">Banner Pengumuman</div><div class="ps-sub">Tampilkan banner di halaman user</div></div>
        <button class="ps-toggle on" onclick="this.classList.toggle('on')"><div class="ps-toggle-thumb"></div></button>
      </div>
      <div class="ps-row">
        <div class="ps-icon" style="background:var(--blue-bg)">📲</div>
        <div class="ps-text"><div class="ps-label">Prompt Install PWA</div><div class="ps-sub">Tampilkan saran install aplikasi</div></div>
        <button class="ps-toggle on" onclick="this.classList.toggle('on')"><div class="ps-toggle-thumb"></div></button>
      </div>
    </div>

    <div class="ps-card">
      <div class="ps-head">Teks Banner Pengumuman</div>
      <div class="form-wrap">
        <div class="fg">
          <label>Teks Banner</label>
          <textarea class="finput">OrbFood kini hadir di 12 desa baru! Pesan makanan lokal makin mudah.</textarea>
        </div>
      </div>
    </div>

    <div class="ps-card">
      <div class="ps-head">Data & Keamanan</div>
      <div class="ps-row clickable">
        <div class="ps-icon" style="background:var(--red-bg)">🗂️</div>
        <div class="ps-text"><div class="ps-label">Export Data Platform</div><div class="ps-sub">Download CSV semua data</div></div>
        <div class="ps-arrow"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="9 18 15 12 9 6"/></svg></div>
      </div>
      <div class="ps-row clickable">
        <div class="ps-icon" style="background:var(--red-bg)">🔐</div>
        <div class="ps-text"><div class="ps-label">Log Aktivitas Admin</div><div class="ps-sub">Riwayat semua perubahan admin</div></div>
        <div class="ps-arrow"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="9 18 15 12 9 6"/></svg></div>
      </div>
    </div>

    <button class="btn-save">💾 Simpan Pengaturan</button>
    <div style="height:16px"></div>

  </div>
</main>

<!-- ══ SHEETS ══ -->

<!-- Shop Detail Sheet -->
<div class="overlay" id="ov-shop" onclick="closeOv('ov-shop')">
  <div class="sheet">
    <div class="sheet-handle"></div>
    <div class="sheet-title">Detail Toko</div>
    <div class="sheet-sub">Kelola status dan informasi toko</div>
    <div class="sheet-body">
      <div style="display:flex;align-items:center;gap:12px;padding:12px;background:var(--bg);border-radius:var(--r12);margin-bottom:16px">
        <div style="width:48px;height:48px;border-radius:var(--r12);background:var(--warm);display:grid;place-items:center;font-size:24px">🍜</div>
        <div>
          <div style="font-size:15px;font-weight:800;color:var(--navy)">Warung Bu Sari</div>
          <div style="font-size:12px;color:var(--muted)">Sukamaju · 142 pesanan</div>
        </div>
        <span class="shop-status ss-on" style="margin-left:auto">Aktif</span>
      </div>
      <div style="display:flex;align-items:center;justify-content:space-between;padding:12px 14px;background:var(--bg);border-radius:var(--r12);margin-bottom:12px">
        <span style="font-size:14px;font-weight:700;color:var(--navy)">Status Toko</span>
        <button class="ps-toggle on" onclick="this.classList.toggle('on')"><div class="ps-toggle-thumb"></div></button>
      </div>
    </div>
    <div class="sheet-foot">
      <button class="sbtn-danger" onclick="closeOv('ov-shop')">🗑️ Hapus Toko</button>
      <button class="sbtn-s" onclick="closeOv('ov-shop')">Tutup</button>
    </div>
  </div>
</div>

<!-- User Detail Sheet -->
<div class="overlay" id="ov-user" onclick="closeOv('ov-user')">
  <div class="sheet">
    <div class="sheet-handle"></div>
    <div class="sheet-title">Detail Pengguna</div>
    <div class="sheet-sub">Ubah role atau hapus pengguna</div>
    <div class="sheet-body">
      <div style="text-align:center;margin-bottom:20px">
        <div style="width:64px;height:64px;border-radius:var(--rfull);background:var(--orange);display:grid;place-items:center;font-size:26px;font-weight:800;color:#fff;margin:0 auto 10px">A</div>
        <div style="font-size:16px;font-weight:800;color:var(--navy);margin-bottom:2px">Ahmad Fauzi</div>
        <div style="font-size:13px;color:var(--muted)">ahmad.fauzi@gmail.com</div>
      </div>
      <div class="fg"><label>Role Pengguna</label>
        <select class="finput" style="appearance:none">
          <option selected>user</option>
          <option>shop</option>
          <option>admin</option>
        </select>
      </div>
    </div>
    <div class="sheet-foot">
      <button class="sbtn-danger" onclick="closeOv('ov-user')">🗑️ Hapus</button>
      <button class="sbtn-p" onclick="closeOv('ov-user')">💾 Simpan</button>
    </div>
  </div>
</div>

<!-- Add Village Sheet -->
<div class="overlay" id="ov-village" onclick="closeOv('ov-village')">
  <div class="sheet">
    <div class="sheet-handle"></div>
    <div class="sheet-title">Tambah Desa Baru</div>
    <div class="sheet-sub">Desa akan tampil sebagai pilihan filter di halaman user</div>
    <div class="sheet-body">
      <div class="fg"><label>Nama Desa *</label><input class="finput" placeholder="Cth: Bojong Lestari"></div>
      <div class="fg"><label>Kecamatan</label><input class="finput" placeholder="Cth: Kecamatan Rancabungur"></div>
    </div>
    <div class="sheet-foot">
      <button class="sbtn-s" onclick="closeOv('ov-village')">Batal</button>
      <button class="sbtn-p" onclick="closeOv('ov-village')">✓ Tambahkan</button>
    </div>
  </div>
</div>

<!-- Add/Edit Blog Sheet -->
<div class="overlay" id="ov-blog" onclick="closeOv('ov-blog')">
  <div class="sheet">
    <div class="sheet-handle"></div>
    <div class="sheet-title" id="ov-blog-title">Tulis Artikel Baru</div>
    <div class="sheet-sub">Artikel akan tampil di halaman Blog publik</div>
    <div class="sheet-body">
      <div class="fg"><label>Judul Artikel *</label><input class="finput" placeholder="Judul yang menarik…"></div>
      <div class="fg">
        <label>Status</label>
        <select class="finput" style="appearance:none">
          <option>Draft</option>
          <option>Published</option>
          <option>Pengumuman</option>
        </select>
      </div>
      <div class="fg"><label>Kategori</label>
        <select class="finput" style="appearance:none">
          <option>Tips UMKM</option>
          <option>Resep</option>
          <option>Update Platform</option>
          <option>Pengumuman</option>
        </select>
      </div>
      <div class="fg"><label>Isi Artikel</label><textarea class="finput" style="min-height:100px" placeholder="Tulis konten artikel di sini…"></textarea></div>
    </div>
    <div class="sheet-foot">
      <button class="sbtn-s" onclick="closeOv('ov-blog')">Batal</button>
      <button class="sbtn-p" onclick="closeOv('ov-blog')">🚀 Publikasikan</button>
    </div>
  </div>
</div>

<!-- Notif Sheet -->
<div class="overlay" id="ov-notif" onclick="closeOv('ov-notif')">
  <div class="sheet">
    <div class="sheet-handle"></div>
    <div class="sheet-title">Notifikasi</div>
    <div class="sheet-sub">Aktivitas platform terbaru</div>
    <div class="sheet-body" style="padding:0">
      <div class="feed-item" style="padding:14px 20px"><div class="feed-dot fd-orange"></div><div class="feed-text"><div class="feed-main">Pengajuan toko baru dari <strong>Kedai Pak Bejo</strong></div><div class="feed-time">23 menit lalu</div></div></div>
      <div class="feed-item" style="padding:14px 20px"><div class="feed-dot fd-green"></div><div class="feed-text"><div class="feed-main"><strong>Warung Mbok Darmi</strong> berhasil diverifikasi</div><div class="feed-time">1 jam lalu</div></div></div>
      <div class="feed-item" style="padding:14px 20px"><div class="feed-dot fd-blue"></div><div class="feed-text"><div class="feed-main"><strong>Ahmad Fauzi</strong> bergabung</div><div class="feed-time">2 jam lalu</div></div></div>
      <div class="feed-item" style="padding:14px 20px"><div class="feed-dot fd-orange"></div><div class="feed-text"><div class="feed-main">Pengajuan toko baru dari <strong>Dapur Mbak Yuni</strong></div><div class="feed-time">3 jam lalu</div></div></div>
    </div>
    <div class="sheet-foot">
      <button class="sbtn-p" style="background:var(--navy)" onclick="closeOv('ov-notif')">Tutup</button>
    </div>
  </div>
</div>

<!-- ══ BOTTOM NAV ══ -->
<nav class="bnav">
  <button class="nb on" id="n-stats" onclick="nav('stats')">
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/></svg>
    <span>Statistik</span>
  </button>
  <button class="nb nb-dot-wrap" id="n-verify" onclick="nav('verify')">
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M9 11l3 3L22 4"/><path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"/></svg>
    <span>Verifikasi</span>
    <span class="nb-dot"></span>
  </button>
  <button class="nb" id="n-shops" onclick="nav('shops')">
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg>
    <span>Toko</span>
  </button>
  <button class="nb" id="n-users" onclick="nav('users')">
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
    <span>Pengguna</span>
  </button>
  <button class="nb" id="n-content" onclick="nav('content')">
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M14.5 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V7.5L14.5 2z"/><polyline points="14 2 14 8 20 8"/></svg>
    <span>Konten</span>
  </button>
  <button class="nb" id="n-platform" onclick="nav('platform')">
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 1 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 1 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 1 1-2.83-2.83l.06-.06A1.65 1.65 0 0 0 4.68 15a1.65 1.65 0 0 0-1.51-1H3a2 2 0 1 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 1 1 2.83-2.83l.06.06A1.65 1.65 0 0 0 9 4.68a1.65 1.65 0 0 0 1-1.51V3a2 2 0 1 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 1 1 2.83 2.83l-.06.06A1.65 1.65 0 0 0 19.4 9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 1 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z"/></svg>
    <span>Platform</span>
  </button>
</nav>

<script>
const PAGES=['stats','verify','shops','users','content','platform'];
const NB_MAP={stats:'n-stats',verify:'n-verify',shops:'n-shops',users:'n-users',content:'n-content',platform:'n-platform'};

function nav(id){
  PAGES.forEach(p=>{const e=document.getElementById('page-'+p);if(e)e.classList.toggle('active',p===id);});
  Object.values(NB_MAP).forEach(n=>{const e=document.getElementById(n);if(e)e.classList.remove('on');});
  const nb=document.getElementById(NB_MAP[id]);if(nb)nb.classList.add('on');
  window.scrollTo(0,0);
}

const OV_MAP={'shop-detail':'ov-shop','user-detail':'ov-user','add-village':'ov-village','edit-blog':'ov-blog','add-blog':'ov-blog','notif':'ov-notif'};

function openSheet(type){
  if(type==='edit-blog') document.getElementById('ov-blog-title').textContent='Edit Artikel';
  if(type==='add-blog') document.getElementById('ov-blog-title').textContent='Tulis Artikel Baru';
  const ovId=OV_MAP[type];
  if(ovId){document.getElementById(ovId).classList.add('open');document.body.style.overflow='hidden';}
}

function closeOv(id){
  document.getElementById(id).classList.remove('open');
  document.body.style.overflow='';
}

function verifyAction(cardId, action){
  const card=document.getElementById(cardId);
  if(!card) return;
  card.style.transition='all .3s ease';
  card.style.opacity='0';
  card.style.transform='scale(.96)';
  setTimeout(()=>{card.remove();},300);
}
</script>
</body>
</html>