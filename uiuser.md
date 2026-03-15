<!DOCTYPE html>
<html lang="id">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0, viewport-fit=cover">
<title>OrbFood</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;500;600;700;800&family=Fraunces:ital,opsz,wght@0,9..144,300;0,9..144,700;1,9..144,400&display=swap" rel="stylesheet">
<style>
:root{
  --bg:#FAFAF8;--surface:#FFFFFF;--orange:#F97316;--orange2:#EA6C0A;
  --warm:#FFF7ED;--navy:#1C2B3A;--ink:#2D3748;--muted:#8896A4;
  --line:#ECEAE6;--green:#22C55E;--red:#F43F5E;--amber:#F59E0B;
  --f-d:'Fraunces',Georgia,serif;--f-b:'Plus Jakarta Sans',sans-serif;
  --r4:4px;--r8:8px;--r12:12px;--r16:16px;--r20:20px;--r24:24px;--rfull:9999px;
  --sh-sm:0 1px 4px rgba(0,0,0,.06);--sh-md:0 4px 20px rgba(0,0,0,.09);
  --sh-lg:0 12px 40px rgba(0,0,0,.13);--sh-o:0 8px 28px rgba(249,115,22,.35);
  --ease:cubic-bezier(.4,0,.2,1);
}
*,*::before,*::after{box-sizing:border-box;margin:0;padding:0;}
html{-webkit-text-size-adjust:100%;scroll-behavior:smooth;}
body{font-family:var(--f-b);background:var(--bg);color:var(--ink);min-height:100vh;max-width:430px;margin:0 auto;overflow-x:hidden;}
button{font-family:var(--f-b);cursor:pointer;border:none;background:none;}
::-webkit-scrollbar{display:none;}

/* ── TOPBAR ── */
.topbar{position:fixed;top:0;left:50%;transform:translateX(-50%);width:100%;max-width:430px;z-index:200;background:rgba(250,250,248,.9);backdrop-filter:blur(20px);border-bottom:1px solid var(--line);height:56px;display:flex;align-items:center;padding:0 16px;gap:12px;}
.logo{display:flex;align-items:center;gap:7px;cursor:pointer;flex-shrink:0;}
.logo svg{width:28px;height:28px;}
.logo-text{font-family:var(--f-d);font-weight:700;font-size:19px;color:var(--navy);letter-spacing:-.02em;}
.logo-text span{color:var(--orange);}
.search-bar{flex:1;display:flex;align-items:center;gap:8px;background:var(--line);border-radius:var(--rfull);padding:0 12px;height:36px;transition:.2s var(--ease);border:1.5px solid transparent;}
.search-bar:focus-within{background:#fff;border-color:var(--orange);box-shadow:0 0 0 3px rgba(249,115,22,.1);}
.search-bar svg{width:14px;height:14px;color:var(--muted);flex-shrink:0;}
.search-bar input{flex:1;border:none;background:transparent;outline:none;font-size:13px;color:var(--ink);}
.search-bar input::placeholder{color:var(--muted);}
.cart-btn{width:36px;height:36px;border-radius:var(--rfull);background:var(--warm);display:grid;place-items:center;position:relative;flex-shrink:0;transition:.2s var(--ease);}
.cart-btn:active{background:var(--orange);}
.cart-btn:active svg{color:#fff;}
.cart-btn svg{width:17px;height:17px;color:var(--navy);transition:.2s;}
.cart-badge{position:absolute;top:-2px;right:-2px;width:16px;height:16px;border-radius:var(--rfull);background:var(--orange);color:#fff;font-size:9px;font-weight:800;display:grid;place-items:center;border:2px solid var(--bg);transition:.25s var(--ease);}
.cart-badge.pop{transform:scale(1.7);}

/* ── PAGES ── */
.page{display:none;padding-top:56px;padding-bottom:calc(72px + env(safe-area-inset-bottom));animation:pin .28s var(--ease) both;}
.page.active{display:block;}
@keyframes pin{from{opacity:0;transform:translateY(8px);}to{opacity:1;transform:translateY(0);}}

/* ── HOME HERO ── */
.hero{padding:22px 20px 18px;background:var(--surface);border-bottom:1px solid var(--line);}
.hero-row{display:flex;align-items:flex-start;justify-content:space-between;margin-bottom:18px;}
.hero-hi{font-size:12px;color:var(--muted);font-weight:500;margin-bottom:4px;}
.hero-title{font-family:var(--f-d);font-size:28px;font-weight:700;color:var(--navy);line-height:1.15;}
.hero-title em{color:var(--orange);font-style:italic;}
.hero-av{width:40px;height:40px;border-radius:var(--rfull);background:linear-gradient(135deg,var(--orange),#fb923c);display:grid;place-items:center;font-weight:800;font-size:15px;color:#fff;flex-shrink:0;margin-top:2px;box-shadow:var(--sh-o);}

/* ── CATS ── */
.cats{display:flex;gap:8px;overflow-x:auto;padding:14px 20px;background:var(--surface);border-bottom:1px solid var(--line);}
.cat{flex-shrink:0;display:flex;align-items:center;gap:5px;padding:7px 13px;border-radius:var(--rfull);font-size:13px;font-weight:600;background:var(--bg);color:var(--muted);border:1.5px solid var(--line);transition:.18s var(--ease);white-space:nowrap;}
.cat.on{background:var(--navy);color:#fff;border-color:var(--navy);}
.cat:active{transform:scale(.95);}

/* ── SECTION HEAD ── */
.sec-head{display:flex;align-items:center;justify-content:space-between;padding:18px 20px 10px;}
.sec-title{font-size:16px;font-weight:800;color:var(--navy);letter-spacing:-.02em;}
.sec-more{font-size:13px;font-weight:700;color:var(--orange);}

/* ── STORE CARDS ── */
.stores-row{display:flex;gap:12px;overflow-x:auto;padding:0 20px 18px;}
.scard{flex-shrink:0;width:150px;border-radius:var(--r16);overflow:hidden;background:var(--surface);border:1px solid var(--line);box-shadow:var(--sh-sm);cursor:pointer;transition:.2s var(--ease);}
.scard:active{transform:scale(.97);}
.scard-banner{height:72px;position:relative;overflow:hidden;display:grid;place-items:center;font-size:32px;}
.scard-st{position:absolute;top:6px;right:6px;padding:2px 7px;border-radius:var(--rfull);font-size:9px;font-weight:800;backdrop-filter:blur(6px);}
.st-open{background:rgba(34,197,94,.9);color:#fff;}
.st-closed{background:rgba(0,0,0,.45);color:rgba(255,255,255,.8);}
.scard-body{padding:9px 11px 11px;}
.scard-name{font-size:13px;font-weight:700;color:var(--navy);white-space:nowrap;overflow:hidden;text-overflow:ellipsis;margin-bottom:2px;}
.scard-meta{font-size:11px;color:var(--muted);}

/* ── MENU GRID ── */
.mgrid{display:grid;grid-template-columns:repeat(2,1fr);gap:11px;padding:0 14px;}
.mcard{background:var(--surface);border-radius:var(--r20);overflow:hidden;border:1px solid var(--line);box-shadow:var(--sh-sm);cursor:pointer;transition:.2s var(--ease);}
.mcard:active{transform:scale(.97);}
.mcard-img{height:128px;position:relative;display:flex;align-items:center;justify-content:center;overflow:hidden;}
.mcard-emoji{font-size:50px;transition:.3s var(--ease);filter:drop-shadow(0 4px 8px rgba(0,0,0,.12));}
.mcard:hover .mcard-emoji{transform:scale(1.08) translateY(-3px);}
.mcard-fav{position:absolute;top:8px;right:8px;width:27px;height:27px;border-radius:var(--rfull);background:rgba(255,255,255,.85);display:grid;place-items:center;font-size:13px;backdrop-filter:blur(4px);transition:.2s;}
.mcard-fav:active{transform:scale(1.35);}
.mcard-tag{position:absolute;top:8px;left:8px;padding:2px 7px;border-radius:var(--rfull);background:var(--orange);color:#fff;font-size:9px;font-weight:800;letter-spacing:.04em;}
.mcard-body{padding:10px 11px 12px;}
.mcard-name{font-size:13px;font-weight:700;color:var(--navy);margin-bottom:2px;line-height:1.3;}
.mcard-shop{font-size:11px;color:var(--muted);margin-bottom:8px;}
.mcard-foot{display:flex;align-items:center;justify-content:space-between;}
.mcard-price{font-family:var(--f-d);font-size:15px;font-weight:700;color:var(--orange);}
.btn-add{width:29px;height:29px;border-radius:var(--rfull);background:var(--navy);color:#fff;display:grid;place-items:center;font-size:20px;font-weight:300;line-height:1;transition:.18s var(--ease);box-shadow:0 3px 10px rgba(28,43,58,.2);}
.btn-add:active{transform:scale(.88);background:var(--orange);}

/* ── CART BAR ── */
.cart-bar{position:fixed;bottom:calc(72px + env(safe-area-inset-bottom) + 10px);left:14px;right:14px;max-width:402px;margin:0 auto;z-index:150;background:var(--navy);border-radius:var(--r16);padding:12px 15px;display:flex;align-items:center;gap:12px;box-shadow:0 8px 32px rgba(28,43,58,.3);cursor:pointer;transition:.25s var(--ease);animation:sul .35s var(--ease) both;}
.cart-bar:active{transform:scale(.98);}
@keyframes sul{from{opacity:0;transform:translateY(16px);}to{opacity:1;transform:translateY(0);}}
.cb-count{min-width:25px;height:25px;border-radius:var(--rfull);background:var(--orange);color:#fff;display:grid;place-items:center;font-size:12px;font-weight:800;flex-shrink:0;}
.cb-label{flex:1;font-size:13px;font-weight:600;color:rgba(255,255,255,.7);}
.cb-total{font-family:var(--f-d);font-size:15px;font-weight:700;color:#fff;}
.cb-arrow{width:26px;height:26px;border-radius:var(--rfull);background:rgba(255,255,255,.1);display:grid;place-items:center;flex-shrink:0;}
.cb-arrow svg{width:14px;height:14px;color:#fff;}

/* ── BOTTOM NAV ── */
.bnav{position:fixed;bottom:0;left:50%;transform:translateX(-50%);width:100%;max-width:430px;height:calc(68px + env(safe-area-inset-bottom));padding-bottom:env(safe-area-inset-bottom);background:rgba(250,250,248,.93);backdrop-filter:blur(20px);border-top:1px solid var(--line);display:flex;z-index:200;}
.nb{flex:1;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:3px;color:var(--muted);transition:.18s var(--ease);}
.nb svg{width:21px;height:21px;stroke-width:1.8;}
.nb span{font-size:10px;font-weight:600;}
.nb.on{color:var(--orange);}
.nb:active{transform:scale(.9);}
.nb-fab{flex:1;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:3px;}
.fab{width:46px;height:46px;border-radius:var(--rfull);background:var(--orange);display:grid;place-items:center;box-shadow:var(--sh-o);transition:.2s;margin-top:-14px;}
.fab svg{width:20px;height:20px;color:#fff;stroke-width:2.2;}
.fab:active{transform:scale(.9);}
.nb-fab span{font-size:10px;font-weight:600;color:var(--orange);}

/* ── STORE PAGE ── */
.store-hero{height:220px;background:linear-gradient(160deg,#1C2B3A,#2D4A6B);position:relative;overflow:hidden;}
.store-hero-emoji{position:absolute;top:50%;left:50%;transform:translate(-50%,-50%);font-size:90px;opacity:.18;}
.store-grd{position:absolute;inset:0;background:linear-gradient(to top,rgba(28,43,58,.95),rgba(28,43,58,.1));}
.store-back{position:absolute;top:calc(56px + 12px);left:16px;width:34px;height:34px;border-radius:var(--rfull);background:rgba(0,0,0,.3);display:grid;place-items:center;backdrop-filter:blur(8px);cursor:pointer;}
.store-back svg{width:17px;height:17px;color:#fff;}
.store-hero-cnt{position:absolute;bottom:0;left:0;right:0;padding:16px 20px 20px;}
.store-name{font-family:var(--f-d);font-size:26px;font-weight:700;color:#fff;margin-bottom:7px;line-height:1.1;}
.store-tags{display:flex;gap:6px;flex-wrap:wrap;}
.store-tag{padding:4px 9px;border-radius:var(--rfull);font-size:11px;font-weight:600;background:rgba(255,255,255,.15);color:rgba(255,255,255,.9);backdrop-filter:blur(6px);}
.store-info-bar{display:flex;background:var(--surface);border-bottom:1px solid var(--line);}
.si{flex:1;padding:14px 8px;text-align:center;border-right:1px solid var(--line);}
.si:last-child{border-right:none;}
.si-val{font-size:14px;font-weight:800;color:var(--navy);margin-bottom:2px;}
.si-lbl{font-size:10px;color:var(--muted);font-weight:600;}
.wa-btn{margin:14px 16px;display:flex;align-items:center;justify-content:center;gap:8px;padding:14px;border-radius:var(--r12);background:#25D366;color:#fff;font-size:14px;font-weight:700;box-shadow:0 4px 16px rgba(37,211,102,.3);transition:.2s;}
.wa-btn:active{transform:scale(.97);}
.wa-btn svg{width:18px;height:18px;}

/* ── SHEET ── */
.overlay{position:fixed;inset:0;z-index:300;background:rgba(28,43,58,.5);backdrop-filter:blur(6px);opacity:0;pointer-events:none;transition:.25s var(--ease);}
.overlay.open{opacity:1;pointer-events:all;}
.sheet{position:absolute;bottom:0;left:0;right:0;background:var(--surface);border-radius:24px 24px 0 0;max-height:92vh;overflow-y:auto;transform:translateY(100%);transition:.32s cubic-bezier(.32,0,.67,0);}
.overlay.open .sheet{transform:translateY(0);transition:.32s cubic-bezier(.33,1,.68,1);}
.sheet-handle{width:36px;height:4px;border-radius:2px;background:var(--line);margin:12px auto 0;}
.sheet-img{height:200px;display:flex;align-items:center;justify-content:center;margin:14px 18px 0;border-radius:var(--r20);font-size:88px;filter:drop-shadow(0 6px 14px rgba(0,0,0,.1));}
.sheet-name{font-family:var(--f-d);font-size:23px;font-weight:700;color:var(--navy);padding:14px 20px 3px;line-height:1.2;}
.sheet-from{padding:0 20px 10px;font-size:13px;color:var(--muted);}
.sheet-desc{padding:0 20px 14px;font-size:14px;color:var(--ink);line-height:1.65;border-bottom:1px solid var(--line);}
.sheet-sec{padding:14px 20px 0;}
.sheet-sec-title{font-size:11px;font-weight:800;color:var(--navy);text-transform:uppercase;letter-spacing:.06em;margin-bottom:9px;}
.opts{display:flex;flex-direction:column;gap:6px;}
.opt{display:flex;align-items:center;gap:12px;padding:11px 14px;border-radius:var(--r12);border:1.5px solid var(--line);background:#fff;cursor:pointer;transition:.15s var(--ease);}
.opt.on{border-color:var(--orange);background:var(--warm);}
.opt-radio{width:18px;height:18px;border-radius:var(--rfull);border:2px solid var(--line);display:grid;place-items:center;flex-shrink:0;transition:.15s;}
.opt.on .opt-radio{border-color:var(--orange);}
.opt.on .opt-radio::after{content:'';width:8px;height:8px;border-radius:var(--rfull);background:var(--orange);}
.opt-name{flex:1;font-size:13px;font-weight:600;color:var(--ink);}
.opt-price{font-size:13px;font-weight:700;color:var(--muted);}
.opt.on .opt-price{color:var(--orange);}
.sheet-note{margin:14px 20px 0;padding:11px 13px;border:1.5px solid var(--line);border-radius:var(--r12);font-size:13px;color:var(--ink);resize:none;width:calc(100% - 40px);min-height:68px;outline:none;transition:.15s;}
.sheet-note:focus{border-color:var(--orange);box-shadow:0 0 0 3px rgba(249,115,22,.08);}
.sheet-foot{position:sticky;bottom:0;background:var(--surface);padding:13px 18px calc(13px + env(safe-area-inset-bottom));border-top:1px solid var(--line);display:flex;align-items:center;gap:12px;margin-top:14px;}
.qty-ctrl{display:flex;align-items:center;gap:10px;background:var(--bg);border-radius:var(--rfull);padding:5px 11px;}
.qbtn{width:26px;height:26px;border-radius:var(--rfull);background:var(--surface);border:1.5px solid var(--line);display:grid;place-items:center;font-size:17px;font-weight:500;color:var(--navy);transition:.15s;}
.qbtn:active{background:var(--navy);color:#fff;border-color:var(--navy);}
.qnum{font-size:15px;font-weight:800;color:var(--navy);min-width:18px;text-align:center;}
.add-btn{flex:1;padding:13px;border-radius:var(--r12);background:var(--orange);color:#fff;font-size:14px;font-weight:800;display:flex;align-items:center;justify-content:center;gap:6px;box-shadow:var(--sh-o);transition:.18s;}
.add-btn:active{transform:scale(.97);background:var(--orange2);}

/* ── CART PAGE ── */
.pg-head{padding:18px 20px 12px;background:var(--surface);border-bottom:1px solid var(--line);}
.pg-title{font-family:var(--f-d);font-size:25px;font-weight:700;color:var(--navy);}
.pg-sub{font-size:13px;color:var(--muted);margin-top:2px;}
.cart-list{background:var(--surface);}
.ci{display:flex;gap:12px;padding:15px 18px;border-bottom:1px solid var(--line);}
.ci-thumb{width:60px;height:60px;border-radius:var(--r12);display:grid;place-items:center;font-size:26px;flex-shrink:0;}
.ci-info{flex:1;}
.ci-name{font-size:14px;font-weight:700;color:var(--navy);margin-bottom:2px;}
.ci-note{font-size:12px;color:var(--muted);margin-bottom:9px;line-height:1.4;}
.ci-row{display:flex;align-items:center;justify-content:space-between;}
.ci-price{font-family:var(--f-d);font-size:15px;font-weight:700;color:var(--orange);}
.cart-sum{padding:15px 18px;background:var(--surface);margin-top:8px;}
.sum-r{display:flex;justify-content:space-between;font-size:14px;color:var(--muted);margin-bottom:9px;}
.sum-r.tot{font-size:16px;font-weight:800;color:var(--navy);padding-top:11px;margin-top:4px;border-top:1.5px solid var(--line);margin-bottom:0;}
.sum-r.tot .sv{color:var(--orange);}
.cart-cta{padding:14px 18px calc(14px + env(safe-area-inset-bottom));}
.co-btn{width:100%;padding:15px;border-radius:var(--r16);font-size:14px;font-weight:800;display:flex;align-items:center;justify-content:center;gap:9px;transition:.18s;}
.co-btn:active{transform:scale(.98);}
.co-wa{background:#25D366;color:#fff;box-shadow:0 4px 20px rgba(37,211,102,.3);}
.co-grp{background:var(--navy);color:#fff;margin-top:9px;box-shadow:var(--sh-md);}

/* ── ORDERS ── */
.olist{padding:8px 0;}
.ocard{margin:0 14px 11px;background:var(--surface);border-radius:var(--r20);border:1px solid var(--line);overflow:hidden;box-shadow:var(--sh-sm);cursor:pointer;transition:.18s;}
.ocard:active{transform:scale(.99);}
.ocard-top{padding:11px 15px;display:flex;align-items:center;justify-content:space-between;border-bottom:1px solid var(--line);}
.onum{font-size:11px;font-weight:700;color:var(--muted);}
.bdg{padding:3px 9px;border-radius:var(--rfull);font-size:10px;font-weight:800;}
.b-ok{background:rgba(34,197,94,.1);color:#16a34a;}
.b-pr{background:rgba(245,158,11,.1);color:#d97706;}
.b-no{background:rgba(244,63,94,.1);color:#e11d48;}
.ocard-body{padding:13px 15px;}
.oshop{font-size:15px;font-weight:800;color:var(--navy);margin-bottom:3px;}
.oitems{font-size:13px;color:var(--muted);margin-bottom:11px;line-height:1.5;}
.ofoot{display:flex;align-items:center;justify-content:space-between;}
.oprice{font-family:var(--f-d);font-size:16px;font-weight:700;color:var(--orange);}
.odate{font-size:11px;color:var(--muted);}

/* ── PROFILE ── */
.prof-banner{background:linear-gradient(145deg,var(--navy),#2D4A6B);padding:28px 20px 30px;position:relative;overflow:hidden;}
.prof-banner::after{content:'';position:absolute;bottom:-40px;right:-40px;width:150px;height:150px;border-radius:var(--rfull);background:radial-gradient(circle,rgba(249,115,22,.22),transparent 70%);}
.prof-av{width:70px;height:70px;border-radius:var(--rfull);background:var(--orange);display:grid;place-items:center;font-family:var(--f-d);font-size:27px;font-weight:700;color:#fff;margin:0 auto 11px;border:3px solid rgba(255,255,255,.2);box-shadow:0 6px 20px rgba(0,0,0,.2);}
.prof-name{font-family:var(--f-d);font-size:21px;font-weight:700;color:#fff;text-align:center;margin-bottom:3px;}
.prof-email{font-size:13px;color:rgba(255,255,255,.55);text-align:center;}
.pmenu-list{padding:14px;}
.pm{display:flex;align-items:center;gap:13px;padding:14px 15px;background:var(--surface);border-radius:var(--r16);margin-bottom:7px;border:1px solid var(--line);cursor:pointer;transition:.15s;box-shadow:var(--sh-sm);}
.pm:active{transform:scale(.98);}
.pm-ic{width:38px;height:38px;border-radius:var(--r12);display:grid;place-items:center;font-size:17px;flex-shrink:0;}
.ic-o{background:var(--warm);}
.ic-n{background:#EEF3F8;}
.ic-g{background:rgba(34,197,94,.1);}
.ic-r{background:rgba(244,63,94,.08);}
.pm-txt{flex:1;}
.pm-lbl{font-size:14px;font-weight:700;color:var(--navy);}
.pm-desc{font-size:12px;color:var(--muted);margin-top:1px;}
.pm.hl{border-color:var(--orange);background:var(--warm);}
.pm.danger .pm-lbl{color:var(--red);}
.pm svg{width:15px;height:15px;color:var(--muted);}

/* ── BLOG ── */
.b-feat{margin:14px 14px 0;height:190px;border-radius:var(--r20);overflow:hidden;position:relative;cursor:pointer;background:linear-gradient(145deg,#1C2B3A,#2D5282);}
.b-feat-grd{position:absolute;inset:0;background:linear-gradient(to top,rgba(28,43,58,.93),rgba(28,43,58,.1));}
.b-feat-emoji{position:absolute;top:50%;left:50%;transform:translate(-50%,-65%);font-size:60px;opacity:.3;}
.b-feat-cnt{position:absolute;bottom:0;left:0;right:0;padding:14px;}
.b-cat{display:inline-block;padding:3px 8px;border-radius:var(--rfull);background:var(--orange);color:#fff;font-size:9px;font-weight:800;letter-spacing:.05em;text-transform:uppercase;margin-bottom:5px;}
.b-feat-title{font-family:var(--f-d);font-size:17px;font-weight:700;color:#fff;line-height:1.25;}
.bcard{display:flex;gap:12px;padding:13px 16px;background:var(--surface);cursor:pointer;transition:.15s;border-bottom:1px solid var(--line);}
.bcard:active{background:var(--bg);}
.bcard-thumb{width:68px;height:68px;border-radius:var(--r12);display:grid;place-items:center;font-size:28px;flex-shrink:0;}
.bcard-title{font-size:14px;font-weight:700;color:var(--navy);line-height:1.35;margin-bottom:5px;}
.bcard-meta{display:flex;gap:6px;font-size:11px;color:var(--muted);}

/* ── MISC ── */
.spacer-sm{height:12px;}
.load-more{display:flex;justify-content:center;padding:18px;}
.btn-more{padding:9px 22px;border-radius:var(--rfull);border:1.5px solid var(--line);font-size:13px;font-weight:700;color:var(--muted);background:var(--surface);transition:.18s;}
.btn-more:active{border-color:var(--orange);color:var(--orange);}

/* ── DEMO ── */
.demo{position:fixed;top:64px;right:0;z-index:500;background:var(--surface);border:1px solid var(--line);border-radius:var(--r12) 0 0 var(--r12);padding:7px 9px;box-shadow:var(--sh-md);}
.demo-t{font-size:9px;font-weight:800;color:var(--muted);text-transform:uppercase;margin-bottom:4px;letter-spacing:.04em;}
.demo-wrap{display:flex;flex-direction:column;gap:3px;}
.db{padding:4px 9px;border-radius:var(--r8);font-size:10px;font-weight:700;color:var(--muted);border:1.5px solid var(--line);background:#fff;transition:.15s;text-align:center;}
.db.on{background:var(--navy);color:#fff;border-color:var(--navy);}
</style>
</head>
<body>

<!-- ╔══════════════════════╗
     ║  TOPBAR              ║
     ╚══════════════════════╝ -->
<header class="topbar">
  <div class="logo" onclick="nav('home')">
    <svg viewBox="0 0 100 100" fill="none">
      <circle cx="50" cy="50" r="44" stroke="#F97316" stroke-width="8"/>
      <circle cx="50" cy="50" r="31" stroke="#1C2B3A" stroke-width="6"/>
      <ellipse cx="44" cy="43" rx="12" ry="12" fill="#1C2B3A"/>
      <line x1="50" y1="43" x2="50" y2="71" stroke="#1C2B3A" stroke-width="6" stroke-linecap="round"/>
    </svg>
    <span class="logo-text">Orb<span>Food</span></span>
  </div>
  <div class="search-bar">
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8"/><path d="m21 21-4.35-4.35"/></svg>
    <input type="text" placeholder="Cari makanan atau toko…">
  </div>
  <button class="cart-btn" onclick="nav('cart')">
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M6 2 3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"/><line x1="3" y1="6" x2="21" y2="6"/><path d="M16 10a4 4 0 0 1-8 0"/></svg>
    <span class="cart-badge" id="cBadge">3</span>
  </button>
</header>

<!-- ╔══════════════════════╗
     ║  HOME                ║
     ╚══════════════════════╝ -->
<main class="page active" id="page-home">

  <div class="hero">
    <div class="hero-row">
      <div>
        <div class="hero-hi">Selamat siang 👋</div>
        <div class="hero-title">Makan apa<br><em>hari ini?</em></div>
      </div>
      <div class="hero-av">A</div>
    </div>
  </div>

  <div class="cats">
    <button class="cat on" onclick="pickCat(this)">🍽️ Semua</button>
    <button class="cat" onclick="pickCat(this)">🍜 Nasi</button>
    <button class="cat" onclick="pickCat(this)">🥤 Minuman</button>
    <button class="cat" onclick="pickCat(this)">🍢 Jajanan</button>
    <button class="cat" onclick="pickCat(this)">🍱 Catering</button>
    <button class="cat" onclick="pickCat(this)">🎂 Kue</button>
  </div>

  <div class="sec-head"><span class="sec-title">Toko Terpopuler</span><span class="sec-more">Semua →</span></div>
  <div class="stores-row">

    <div class="scard" onclick="nav('store')">
      <div class="scard-banner" style="background:linear-gradient(135deg,#1C2B3A,#2D5282)">🍜
        <span class="scard-st st-open">Buka</span>
      </div>
      <div class="scard-body">
        <div class="scard-name">Warung Bu Sari</div>
        <div class="scard-meta">Nasi · Delivery</div>
      </div>
    </div>

    <div class="scard" onclick="nav('store')">
      <div class="scard-banner" style="background:linear-gradient(135deg,#7C3AED,#4C1D95)">🥤
        <span class="scard-st st-open">Buka</span>
      </div>
      <div class="scard-body">
        <div class="scard-name">Segar Jus Jono</div>
        <div class="scard-meta">Minuman · Pick Up</div>
      </div>
    </div>

    <div class="scard" onclick="nav('store')">
      <div class="scard-banner" style="background:linear-gradient(135deg,#DC2626,#7f1d1d)">🍢
        <span class="scard-st st-open">Buka</span>
      </div>
      <div class="scard-body">
        <div class="scard-name">Bakso Pak Hasan</div>
        <div class="scard-meta">Bakso · Delivery</div>
      </div>
    </div>

    <div class="scard" onclick="nav('store')">
      <div class="scard-banner" style="background:linear-gradient(135deg,#059669,#064e3b)">🍱
        <span class="scard-st st-closed">Tutup</span>
      </div>
      <div class="scard-body">
        <div class="scard-name">Catering Mbak Rina</div>
        <div class="scard-meta">Catering · Delivery</div>
      </div>
    </div>

  </div>

  <div class="sec-head"><span class="sec-title">Menu Untukmu ✨</span></div>
  <div class="mgrid">

    <div class="mcard" onclick="openSheet('Nasi Ayam Spesial','🍜','Warung Bu Sari','15000','Nasi putih pulen dengan ayam goreng crispy, lalapan segar, dan sambal cobek. Dijamin bikin kenyang!')">
      <div class="mcard-img" style="background:#FFF7ED">
        <div class="mcard-emoji">🍜</div>
        <button class="mcard-fav" onclick="fav(event,this)">🤍</button>
        <span class="mcard-tag">Terlaris</span>
      </div>
      <div class="mcard-body">
        <div class="mcard-name">Nasi Ayam Spesial</div>
        <div class="mcard-shop">Warung Bu Sari</div>
        <div class="mcard-foot">
          <span class="mcard-price">Rp 15.000</span>
          <button class="btn-add" onclick="addC(event)">+</button>
        </div>
      </div>
    </div>

    <div class="mcard" onclick="openSheet('Jus Alpukat','🥑','Segar Jus Jono','12000','Alpukat pilihan diblender bersama susu segar dan madu. Creamy, dingin, dan menyehatkan.')">
      <div class="mcard-img" style="background:#F0FDF4">
        <div class="mcard-emoji">🥑</div>
        <button class="mcard-fav" onclick="fav(event,this)">❤️</button>
      </div>
      <div class="mcard-body">
        <div class="mcard-name">Jus Alpukat</div>
        <div class="mcard-shop">Segar Jus Jono</div>
        <div class="mcard-foot">
          <span class="mcard-price">Rp 12.000</span>
          <button class="btn-add" onclick="addC(event)">+</button>
        </div>
      </div>
    </div>

    <div class="mcard" onclick="openSheet('Bakso Super','🍢','Bakso Pak Hasan','20000','Bakso urat sapi pilihan dengan kuah kaldu jernih yang gurih. Isi 10 biji + mie + tahu.')">
      <div class="mcard-img" style="background:#FFF1F2">
        <div class="mcard-emoji">🍢</div>
        <button class="mcard-fav" onclick="fav(event,this)">🤍</button>
        <span class="mcard-tag">Baru</span>
      </div>
      <div class="mcard-body">
        <div class="mcard-name">Bakso Super</div>
        <div class="mcard-shop">Bakso Pak Hasan</div>
        <div class="mcard-foot">
          <span class="mcard-price">Rp 20.000</span>
          <button class="btn-add" onclick="addC(event)">+</button>
        </div>
      </div>
    </div>

    <div class="mcard" onclick="openSheet('Ayam Geprek','🌶️','Warung Bu Sari','18000','Ayam goreng crispy dihancurkan dengan sambal bawang yang pedas gurih. Pilih level 1–5.')">
      <div class="mcard-img" style="background:#FEF2F2">
        <div class="mcard-emoji">🌶️</div>
        <button class="mcard-fav" onclick="fav(event,this)">🤍</button>
      </div>
      <div class="mcard-body">
        <div class="mcard-name">Ayam Geprek</div>
        <div class="mcard-shop">Warung Bu Sari</div>
        <div class="mcard-foot">
          <span class="mcard-price">Rp 18.000</span>
          <button class="btn-add" onclick="addC(event)">+</button>
        </div>
      </div>
    </div>

    <div class="mcard" onclick="openSheet('Es Teh Manis','🧊','Segar Jus Jono','5000','Teh celup berkualitas diseduh segar dengan es batu dingin. Murah, segar, selalu ada.')">
      <div class="mcard-img" style="background:#EFF6FF">
        <div class="mcard-emoji">🧊</div>
        <button class="mcard-fav" onclick="fav(event,this)">❤️</button>
      </div>
      <div class="mcard-body">
        <div class="mcard-name">Es Teh Manis</div>
        <div class="mcard-shop">Segar Jus Jono</div>
        <div class="mcard-foot">
          <span class="mcard-price">Rp 5.000</span>
          <button class="btn-add" onclick="addC(event)">+</button>
        </div>
      </div>
    </div>

    <div class="mcard" onclick="openSheet('Nasi Rendang','🍛','Warung Bu Sari','22000','Rendang sapi empuk dimasak hingga kering sempurna. Bumbu meresap, cita rasa Minang autentik.')">
      <div class="mcard-img" style="background:#FFFBEB">
        <div class="mcard-emoji">🍛</div>
        <button class="mcard-fav" onclick="fav(event,this)">🤍</button>
      </div>
      <div class="mcard-body">
        <div class="mcard-name">Nasi Rendang</div>
        <div class="mcard-shop">Warung Bu Sari</div>
        <div class="mcard-foot">
          <span class="mcard-price">Rp 22.000</span>
          <button class="btn-add" onclick="addC(event)">+</button>
        </div>
      </div>
    </div>

  </div>
  <div class="load-more"><button class="btn-more">Tampilkan lebih banyak</button></div>

  <!-- Cart Bar -->
  <div class="cart-bar" id="cartBar" onclick="nav('cart')">
    <div class="cb-count" id="cbCount">3</div>
    <div class="cb-label">3 item di keranjang</div>
    <div class="cb-total">Rp 47.000</div>
    <div class="cb-arrow"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="9 18 15 12 9 6"/></svg></div>
  </div>

</main>

<!-- ╔══════════════════════╗
     ║  STORE               ║
     ╚══════════════════════╝ -->
<main class="page" id="page-store">

  <div class="store-hero">
    <div class="store-hero-emoji">🍜</div>
    <div class="store-grd"></div>
    <button class="store-back" onclick="nav('home')">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="15 18 9 12 15 6"/></svg>
    </button>
    <div class="store-hero-cnt">
      <div class="store-name">Warung Bu Sari</div>
      <div class="store-tags">
        <span class="store-tag">🟢 Buka</span>
        <span class="store-tag">🛵 Delivery</span>
        <span class="store-tag">📍 Sukamaju</span>
      </div>
    </div>
  </div>

  <div class="store-info-bar">
    <div class="si"><div class="si-val">4.8 ★</div><div class="si-lbl">Rating</div></div>
    <div class="si"><div class="si-val">142</div><div class="si-lbl">Pesanan</div></div>
    <div class="si"><div class="si-val">07–21</div><div class="si-lbl">Jam Buka</div></div>
  </div>

  <button class="wa-btn">
    <svg viewBox="0 0 24 24" fill="currentColor" width="18" height="18"><path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 01-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 01-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 012.893 6.994c-.003 5.45-4.437 9.884-9.885 9.884m8.413-18.297A11.815 11.815 0 0012.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 005.683 1.448h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 00-3.48-8.413z"/></svg>
    Chat WhatsApp Toko
  </button>

  <div class="sec-head"><span class="sec-title">Menu Tersedia</span></div>
  <div class="mgrid" style="padding:0 14px">

    <div class="mcard" onclick="openSheet('Nasi Ayam Spesial','🍜','Warung Bu Sari','15000','Nasi putih pulen, ayam goreng crispy, lalapan, sambal cobek.')">
      <div class="mcard-img" style="background:#FFF7ED"><div class="mcard-emoji">🍜</div><button class="mcard-fav" onclick="fav(event,this)">🤍</button></div>
      <div class="mcard-body">
        <div class="mcard-name">Nasi Ayam Spesial</div><div class="mcard-shop">Komplit</div>
        <div class="mcard-foot"><span class="mcard-price">Rp 15.000</span><button class="btn-add" onclick="addC(event)">+</button></div>
      </div>
    </div>

    <div class="mcard" onclick="openSheet('Ayam Geprek','🌶️','Warung Bu Sari','18000','Ayam crispy + sambal bawang. Pilih level pedas.')">
      <div class="mcard-img" style="background:#FEF2F2"><div class="mcard-emoji">🌶️</div><button class="mcard-fav" onclick="fav(event,this)">🤍</button></div>
      <div class="mcard-body">
        <div class="mcard-name">Ayam Geprek</div><div class="mcard-shop">Level 1–5</div>
        <div class="mcard-foot"><span class="mcard-price">Rp 18.000</span><button class="btn-add" onclick="addC(event)">+</button></div>
      </div>
    </div>

    <div class="mcard" onclick="openSheet('Nasi Rendang','🍛','Warung Bu Sari','22000','Rendang sapi empuk, kering sempurna, bumbu meresap.')">
      <div class="mcard-img" style="background:#FFFBEB"><div class="mcard-emoji">🍛</div><button class="mcard-fav" onclick="fav(event,this)">🤍</button></div>
      <div class="mcard-body">
        <div class="mcard-name">Nasi Rendang</div><div class="mcard-shop">Sapi pilihan</div>
        <div class="mcard-foot"><span class="mcard-price">Rp 22.000</span><button class="btn-add" onclick="addC(event)">+</button></div>
      </div>
    </div>

    <div class="mcard" onclick="openSheet('Pecel Komplit','🥗','Warung Bu Sari','12000','Sayur rebus segar + sambal kacang kental. Sehat dan mengenyangkan.')">
      <div class="mcard-img" style="background:#F0FDF4"><div class="mcard-emoji">🥗</div><button class="mcard-fav" onclick="fav(event,this)">🤍</button></div>
      <div class="mcard-body">
        <div class="mcard-name">Pecel Komplit</div><div class="mcard-shop">+ Sambel kacang</div>
        <div class="mcard-foot"><span class="mcard-price">Rp 12.000</span><button class="btn-add" onclick="addC(event)">+</button></div>
      </div>
    </div>

  </div>
  <div class="spacer-sm"></div>

  <div class="cart-bar" onclick="nav('cart')">
    <div class="cb-count">3</div>
    <div class="cb-label">3 item di keranjang</div>
    <div class="cb-total">Rp 47.000</div>
    <div class="cb-arrow"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="9 18 15 12 9 6"/></svg></div>
  </div>

</main>

<!-- ╔══════════════════════╗
     ║  CART                ║
     ╚══════════════════════╝ -->
<main class="page" id="page-cart">
  <div class="pg-head">
    <div class="pg-title">Keranjang 🛒</div>
    <div class="pg-sub">3 item · Warung Bu Sari</div>
  </div>
  <div class="spacer-sm"></div>
  <div class="cart-list">
    <div class="ci">
      <div class="ci-thumb" style="background:#FFF7ED">🍜</div>
      <div class="ci-info">
        <div class="ci-name">Nasi Ayam Spesial</div>
        <div class="ci-note">Pedas sedang · tidak pakai bawang</div>
        <div class="ci-row">
          <span class="ci-price">Rp 15.000</span>
          <div class="qty-ctrl" style="background:var(--bg);border-radius:var(--rfull);display:flex;align-items:center;gap:8px;padding:4px 10px">
            <button class="qbtn" onclick="chQ(this,-1)">−</button>
            <span class="qnum">1</span>
            <button class="qbtn" onclick="chQ(this,1)">+</button>
          </div>
        </div>
      </div>
    </div>
    <div class="ci">
      <div class="ci-thumb" style="background:#FEF2F2">🌶️</div>
      <div class="ci-info">
        <div class="ci-name">Ayam Geprek Level 3</div>
        <div class="ci-note">—</div>
        <div class="ci-row">
          <span class="ci-price">Rp 18.000</span>
          <div class="qty-ctrl" style="background:var(--bg);border-radius:var(--rfull);display:flex;align-items:center;gap:8px;padding:4px 10px">
            <button class="qbtn" onclick="chQ(this,-1)">−</button>
            <span class="qnum">1</span>
            <button class="qbtn" onclick="chQ(this,1)">+</button>
          </div>
        </div>
      </div>
    </div>
    <div class="ci">
      <div class="ci-thumb" style="background:#EFF6FF">🧊</div>
      <div class="ci-info">
        <div class="ci-name">Es Teh Manis</div>
        <div class="ci-note">—</div>
        <div class="ci-row">
          <span class="ci-price">Rp 5.000</span>
          <div class="qty-ctrl" style="background:var(--bg);border-radius:var(--rfull);display:flex;align-items:center;gap:8px;padding:4px 10px">
            <button class="qbtn" onclick="chQ(this,-1)">−</button>
            <span class="qnum">2</span>
            <button class="qbtn" onclick="chQ(this,1)">+</button>
          </div>
        </div>
      </div>
    </div>
  </div>
  <div class="cart-sum">
    <div class="sum-r"><span>Subtotal</span><span>Rp 43.000</span></div>
    <div class="sum-r"><span>Ongkir</span><span>Rp 5.000</span></div>
    <div class="sum-r" style="color:var(--green)"><span>Promo</span><span>− Rp 0</span></div>
    <div class="sum-r tot"><span>Total</span><span class="sv">Rp 48.000</span></div>
  </div>
  <div class="cart-cta">
    <button class="co-btn co-wa">
      <svg width="17" height="17" viewBox="0 0 24 24" fill="currentColor"><path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 01-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 01-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 012.893 6.994c-.003 5.45-4.437 9.884-9.885 9.884m8.413-18.297A11.815 11.815 0 0012.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 005.683 1.448h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 00-3.48-8.413z"/></svg>
      Pesan via WhatsApp
    </button>
    <button class="co-btn co-grp">👥 Group Order</button>
  </div>
</main>

<!-- ╔══════════════════════╗
     ║  ORDERS              ║
     ╚══════════════════════╝ -->
<main class="page" id="page-orders">
  <div class="pg-head">
    <div class="pg-title">Pesananku 📋</div>
    <div class="pg-sub">Riwayat semua transaksi</div>
  </div>
  <div class="olist">
    <div class="ocard">
      <div class="ocard-top"><span class="onum">#ORD-20240309-001</span><span class="bdg b-ok">Selesai ✓</span></div>
      <div class="ocard-body">
        <div class="oshop">Warung Bu Sari</div>
        <div class="oitems">Nasi Ayam Spesial × 1, Ayam Geprek × 1, Es Teh × 2</div>
        <div class="ofoot"><span class="oprice">Rp 48.000</span><span class="odate">9 Mar · 12.30</span></div>
      </div>
    </div>
    <div class="ocard">
      <div class="ocard-top"><span class="onum">#ORD-20240308-003</span><span class="bdg b-pr">Diproses ⏳</span></div>
      <div class="ocard-body">
        <div class="oshop">Bakso Pak Hasan</div>
        <div class="oitems">Bakso Super × 2</div>
        <div class="ofoot"><span class="oprice">Rp 40.000</span><span class="odate">8 Mar · 18.00</span></div>
      </div>
    </div>
    <div class="ocard">
      <div class="ocard-top"><span class="onum">#ORD-20240307-005</span><span class="bdg b-no">Dibatalkan</span></div>
      <div class="ocard-body">
        <div class="oshop">Catering Mbak Rina</div>
        <div class="oitems">Paket Nasi Catering × 5</div>
        <div class="ofoot"><span class="oprice">Rp 125.000</span><span class="odate">7 Mar · 09.15</span></div>
      </div>
    </div>
    <div class="ocard">
      <div class="ocard-top"><span class="onum">#GRP-20240306-002</span><span class="bdg b-ok">Group Order ✓</span></div>
      <div class="ocard-body">
        <div class="oshop">Warung Bu Sari · 3 Peserta</div>
        <div class="oitems">Nasi Rendang, Pecel Komplit, + lainnya</div>
        <div class="ofoot"><span class="oprice">Rp 127.000</span><span class="odate">6 Mar · 11.45</span></div>
      </div>
    </div>
  </div>
</main>

<!-- ╔══════════════════════╗
     ║  PROFILE             ║
     ╚══════════════════════╝ -->
<main class="page" id="page-profile">
  <div class="prof-banner">
    <div class="prof-av">A</div>
    <div class="prof-name">Ahmad Fauzi</div>
    <div class="prof-email">ahmad.fauzi@gmail.com</div>
  </div>
  <div class="pmenu-list">
    <div class="pm" onclick="nav('orders')">
      <div class="pm-ic ic-n">📋</div>
      <div class="pm-txt"><div class="pm-lbl">Riwayat Pesanan</div><div class="pm-desc">Semua transaksimu</div></div>
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="9 18 15 12 9 6"/></svg>
    </div>
    <div class="pm hl">
      <div class="pm-ic ic-o">🏪</div>
      <div class="pm-txt"><div class="pm-lbl" style="color:var(--orange)">Buka Toko</div><div class="pm-desc">Mulai jual makananmu di OrbFood</div></div>
      <svg viewBox="0 0 24 24" fill="none" stroke="var(--orange)" stroke-width="2"><polyline points="9 18 15 12 9 6"/></svg>
    </div>
    <div class="pm">
      <div class="pm-ic ic-g">👥</div>
      <div class="pm-txt"><div class="pm-lbl">Group Order</div><div class="pm-desc">Pesan bareng teman</div></div>
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="9 18 15 12 9 6"/></svg>
    </div>
    <div class="pm">
      <div class="pm-ic ic-n">🔒</div>
      <div class="pm-txt"><div class="pm-lbl">Kebijakan Privasi</div><div class="pm-desc">Cara kami melindungi datamu</div></div>
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="9 18 15 12 9 6"/></svg>
    </div>
    <div class="pm danger">
      <div class="pm-ic ic-r">🚪</div>
      <div class="pm-txt"><div class="pm-lbl">Keluar</div><div class="pm-desc">Logout dari OrbFood</div></div>
      <svg viewBox="0 0 24 24" fill="none" stroke="var(--red)" stroke-width="2"><polyline points="9 18 15 12 9 6"/></svg>
    </div>
  </div>
</main>

<!-- ╔══════════════════════╗
     ║  BLOG                ║
     ╚══════════════════════╝ -->
<main class="page" id="page-blog">
  <div class="pg-head">
    <div class="pg-title">Blog & Tips 📰</div>
    <div class="pg-sub">Resep, berita, dan tips kuliner</div>
  </div>
  <div class="b-feat">
    <div class="b-feat-emoji">📢</div>
    <div class="b-feat-grd"></div>
    <div class="b-feat-cnt">
      <span class="b-cat">Pengumuman</span>
      <div class="b-feat-title">OrbFood kini hadir di 12 desa baru!</div>
    </div>
  </div>
  <div style="padding-top:12px">
    <div class="bcard">
      <div class="bcard-thumb" style="background:#FFF7ED">🍳</div>
      <div><div class="bcard-title">5 Tips Memulai Usaha Kuliner dari Rumah</div><div class="bcard-meta"><span>Tips</span><span>·</span><span>5 mnt</span><span>·</span><span>7 Mar</span></div></div>
    </div>
    <div class="bcard">
      <div class="bcard-thumb" style="background:#EFF6FF">🛵</div>
      <div><div class="bcard-title">Update: Group Order Kini Makin Mudah!</div><div class="bcard-meta"><span>Update</span><span>·</span><span>3 mnt</span><span>·</span><span>5 Mar</span></div></div>
    </div>
    <div class="bcard">
      <div class="bcard-thumb" style="background:#F0FDF4">🥘</div>
      <div><div class="bcard-title">Resep Rahasia Nasi Ayam Bu Sari yang Viral</div><div class="bcard-meta"><span>Resep</span><span>·</span><span>8 mnt</span><span>·</span><span>3 Mar</span></div></div>
    </div>
    <div class="bcard">
      <div class="bcard-thumb" style="background:#FFFBEB">💰</div>
      <div><div class="bcard-title">Cara Tingkatkan Omzet dengan Foto Menu Menarik</div><div class="bcard-meta"><span>Tips</span><span>·</span><span>6 mnt</span><span>·</span><span>1 Mar</span></div></div>
    </div>
  </div>
  <div class="load-more"><button class="btn-more">Muat lebih banyak</button></div>
</main>

<!-- ╔══════════════════════╗
     ║  MENU DETAIL SHEET   ║
     ╚══════════════════════╝ -->
<div class="overlay" id="overlay" onclick="closeSheet(event)">
  <div class="sheet">
    <div class="sheet-handle"></div>
    <div class="sheet-img" id="sImg">🍜</div>
    <div class="sheet-name" id="sName">Nasi Ayam Spesial</div>
    <div class="sheet-from" id="sFrom">Warung Bu Sari</div>
    <div class="sheet-desc" id="sDesc">Deskripsi menu.</div>

    <div class="sheet-sec">
      <div class="sheet-sec-title">Pilihan</div>
      <div class="opts" id="sOpts">
        <div class="opt on" onclick="pickOpt(this)"><div class="opt-radio"></div><span class="opt-name">Biasa</span><span class="opt-price">+Rp 0</span></div>
        <div class="opt" onclick="pickOpt(this)"><div class="opt-radio"></div><span class="opt-name">Ekstra Lauk</span><span class="opt-price">+Rp 3.000</span></div>
        <div class="opt" onclick="pickOpt(this)"><div class="opt-radio"></div><span class="opt-name">Double Porsi</span><span class="opt-price">+Rp 5.000</span></div>
      </div>
    </div>

    <div class="sheet-sec" style="margin-top:14px">
      <div class="sheet-sec-title">Catatan</div>
      <textarea class="sheet-note" placeholder="Misal: tidak pakai bawang, nasi sedikit…"></textarea>
    </div>

    <div class="sheet-foot">
      <div class="qty-ctrl">
        <button class="qbtn" onclick="sQty(-1)">−</button>
        <span class="qnum" id="sQnum">1</span>
        <button class="qbtn" onclick="sQty(1)">+</button>
      </div>
      <button class="add-btn" onclick="confirmAdd()">
        Tambah · <span id="sPriceLabel">Rp 15.000</span>
      </button>
    </div>
  </div>
</div>

<!-- ╔══════════════════════╗
     ║  BOTTOM NAV          ║
     ╚══════════════════════╝ -->
<nav class="bnav">
  <button class="nb on" id="n-home" onclick="nav('home')">
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="m3 9 9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg>
    <span>Beranda</span>
  </button>
  <button class="nb" id="n-blog" onclick="nav('blog')">
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M14.5 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V7.5L14.5 2z"/><polyline points="14 2 14 8 20 8"/></svg>
    <span>Blog</span>
  </button>
  <button class="nb-fab" onclick="nav('cart')">
    <div class="fab">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M6 2 3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"/><line x1="3" y1="6" x2="21" y2="6"/><path d="M16 10a4 4 0 0 1-8 0"/></svg>
    </div>
    <span>Keranjang</span>
  </button>
  <button class="nb" id="n-orders" onclick="nav('orders')">
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M9 11l3 3L22 4"/><path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"/></svg>
    <span>Pesanan</span>
  </button>
  <button class="nb" id="n-profile" onclick="nav('profile')">
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
    <span>Akun</span>
  </button>
</nav>

<!-- Demo switcher -->
<div class="demo">
  <div class="demo-t">Demo</div>
  <div class="demo-wrap">
    <button class="db on" id="d-home" onclick="dNav('home','d-home')">Home</button>
    <button class="db" id="d-store" onclick="dNav('store','d-store')">Toko</button>
    <button class="db" id="d-cart" onclick="dNav('cart','d-cart')">Cart</button>
    <button class="db" id="d-orders" onclick="dNav('orders','d-orders')">Orders</button>
    <button class="db" id="d-profile" onclick="dNav('profile','d-profile')">Profil</button>
    <button class="db" id="d-blog" onclick="dNav('blog','d-blog')">Blog</button>
  </div>
</div>

<script>
const PAGES=['home','store','cart','orders','profile','blog'];
const NB_MAP={home:'n-home',blog:'n-blog',orders:'n-orders',profile:'n-profile'};
let cartCount=3;

function nav(id){
  PAGES.forEach(p=>{const e=document.getElementById('page-'+p);if(e)e.classList.toggle('active',p===id);});
  Object.values(NB_MAP).forEach(n=>{const e=document.getElementById(n);if(e)e.classList.remove('on');});
  if(NB_MAP[id]){const e=document.getElementById(NB_MAP[id]);if(e)e.classList.add('on');}
  window.scrollTo(0,0);
  const cb=document.getElementById('cartBar');
  if(cb)cb.style.display=['cart','profile','blog'].includes(id)?'none':'flex';
}

function dNav(page,btnId){
  nav(page);
  document.querySelectorAll('.db').forEach(b=>b.classList.remove('on'));
  const b=document.getElementById(btnId);if(b)b.classList.add('on');
}

function pickCat(el){document.querySelectorAll('.cats .cat').forEach(c=>c.classList.remove('on'));el.classList.add('on');}

function fav(e,btn){
  e.stopPropagation();
  btn.textContent=btn.textContent==='🤍'?'❤️':'🤍';
  btn.style.transform='scale(1.4)';
  setTimeout(()=>btn.style.transform='',220);
}

function addC(e){
  e.stopPropagation();
  cartCount++;
  const b=document.getElementById('cBadge');
  b.textContent=cartCount;
  b.classList.add('pop');
  setTimeout(()=>b.classList.remove('pop'),260);
}

function chQ(btn,d){
  const n=btn.parentElement.querySelector('.qnum');
  n.textContent=Math.max(0,parseInt(n.textContent)+d);
}

// Sheet
let sQtyVal=1,sBasePrice=15000;

function openSheet(name,emoji,shop,price,desc){
  sBasePrice=parseInt(price);sQtyVal=1;
  document.getElementById('sImg').textContent=emoji;
  document.getElementById('sName').textContent=name;
  document.getElementById('sFrom').textContent=shop;
  document.getElementById('sDesc').textContent=desc;
  document.getElementById('sQnum').textContent=1;
  document.getElementById('sPriceLabel').textContent='Rp '+sBasePrice.toLocaleString('id-ID');
  document.querySelectorAll('#sOpts .opt').forEach((o,i)=>o.classList.toggle('on',i===0));
  document.getElementById('overlay').classList.add('open');
  document.body.style.overflow='hidden';
}

function closeSheet(e){
  if(e.target===document.getElementById('overlay')){
    document.getElementById('overlay').classList.remove('open');
    document.body.style.overflow='';
  }
}

function pickOpt(el){
  el.closest('.opts').querySelectorAll('.opt').forEach(o=>o.classList.remove('on'));
  el.classList.add('on');
}

function sQty(d){
  sQtyVal=Math.max(1,sQtyVal+d);
  document.getElementById('sQnum').textContent=sQtyVal;
  document.getElementById('sPriceLabel').textContent='Rp '+(sBasePrice*sQtyVal).toLocaleString('id-ID');
}

function confirmAdd(){
  document.getElementById('overlay').classList.remove('open');
  document.body.style.overflow='';
  cartCount+=sQtyVal;
  const b=document.getElementById('cBadge');
  b.textContent=cartCount;b.classList.add('pop');
  setTimeout(()=>b.classList.remove('pop'),260);
}
</script>
</body>
</html>