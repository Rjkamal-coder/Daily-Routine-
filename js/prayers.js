pageControllers.prayers=async()=>{
 const date=$("#prayer-date");date.value=today();const keys=["fajr","dhuhr","asr","maghrib","isha"];let current={};
 const draw=()=>{$("#prayer-list").innerHTML=keys.map(k=>`<div class="prayer-row"><div><strong>${k[0].toUpperCase()+k.slice(1)}</strong><small>Daily prayer</small></div><div class="choice"><button data-key="${k}" data-value="true" class="${current[k]===true?"selected yes":""}">Yes</button><button data-key="${k}" data-value="false" class="${current[k]===false?"selected no":""}">No</button></div></div>`).join("");const count=keys.filter(k=>current[k]===true).length;$("#prayer-percent").textContent=`${count*20}%`;};
 const load=async()=>{const {data,error}=await db.from("prayer_records").select("*").eq("date",date.value).maybeSingle();if(error)throw error;current=data||{};$("#prayer-notes").value=data?.notes||"";draw();};$("#prayer-list").onclick=e=>{const b=e.target.closest("button[data-key]");if(!b)return;current[b.dataset.key]=b.dataset.value==="true";draw();};
 $("#save-prayers").onclick=async()=>{try{const payload={user_id:currentUser.id,date:date.value,...Object.fromEntries(keys.map(k=>[k,current[k]??null])),notes:$("#prayer-notes").value};
 const {data:existing,error:findError}=await db.from("prayer_records").select("id").eq("user_id",currentUser.id).eq("date",date.value).maybeSingle();
 if(findError)throw findError;
 const saved=existing
   ? await db.from("prayer_records").update(payload).eq("id",existing.id)
   : await db.from("prayer_records").insert(payload);
 if(saved.error)throw saved.error;toast("Prayer record saved");await stats();}catch(e){toast(e.message,"error");}};
 const stats=async()=>{const rows=await getRows("prayer_records");const count=arr=>arr.reduce((s,r)=>s+keys.filter(k=>r[k]===true).length,0);$("#prayer-week").textContent=count(rows.filter(r=>r.date>=new Date(Date.now()-6*86400000).toLocaleDateString("en-CA")&&r.date<=today()));$("#prayer-month").textContent=count(monthRows(rows,monthNow()));};date.onchange=()=>load().catch(e=>toast(e.message,"error"));await load();await stats();
};