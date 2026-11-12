window.$ = (s, root=document) => root.querySelector(s);
window.$$ = (s, root=document) => [...root.querySelectorAll(s)];
window.today = () => new Date().toLocaleDateString("en-CA");
window.monthNow = () => today().slice(0,7);
window.money = (n) => {
 const c=window.userProfile?.currency||"BDT";
 try{return new Intl.NumberFormat(undefined,{style:"currency",currency:c,maximumFractionDigits:2}).format(Number(n||0));}
 catch{return `${c} ${Number(n||0).toFixed(2)}`;}
};
window.toast = (msg,type="success") => {
 const root=$("#toast-root"); if(!root)return;
 const el=document.createElement("div");el.className=`toast ${type}`;el.textContent=msg;root.append(el);setTimeout(()=>el.remove(),3200);
};
window.escapeHTML = s => String(s??"").replace(/[&<>"']/g,c=>({"&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;","'":"&#39;"}[c]));
window.csvDownload = (filename, rows) => {
 const csv=rows.map(r=>r.map(v=>`"${String(v??"").replace(/"/g,'""')}"`).join(",")).join("\r\n");
 const a=document.createElement("a");a.href=URL.createObjectURL(new Blob(["\ufeff"+csv],{type:"text/csv;charset=utf-8"}));a.download=filename;a.click();URL.revokeObjectURL(a.href);
};
window.monthBounds = m => ({start:`${m}-01`,end:`${m}-31`});
window.getRows = async (table, filters=[]) => {
 let q=db.from(table).select("*").order("date",{ascending:false});
 filters.forEach(([k,v])=>q=q.eq(k,v));
 const {data,error}=await q; if(error)throw error;return data||[];
};
window.upsertRow = async (table, row) => {const {data,error}=await db.from(table).upsert(row).select().single();if(error)throw error;return data;};
window.deleteRow = async (table,id) => {if(!confirm("Delete this record? This cannot be undone."))return false;const {error}=await db.from(table).delete().eq("id",id);if(error)throw error;toast("Record deleted");return true;};
window.monthRows = (rows,m) => rows.filter(r=>(r.date||"").startsWith(m));
window.emptyRow = (cols,msg="No records yet")=>`<tr><td colspan="${cols}" class="empty-cell">${escapeHTML(msg)}</td></tr>`;
window.setTheme = theme => {document.documentElement.dataset.theme=theme;localStorage.setItem("daily-theme",theme);};
window.toggleTheme = ()=>setTheme(document.documentElement.dataset.theme==="dark"?"light":"dark");
setTheme(localStorage.getItem("daily-theme")||"light");