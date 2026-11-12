const routeNames=["dashboard","prayers","expenses","trading","calendar","analytics","profile","settings","admin"];
let activeCleanup=null;
async function routeTo(name,push=true){
 if(!routeNames.includes(name))name="dashboard";
 if(push&&location.hash.slice(1)!==name)history.pushState({route:name},"",`#${name}`);
 $("#content").innerHTML='<div class="loading"><span class="spinner"></span> Loading…</div>';
 try{
  const response=await fetch(`pages/${name}.html`,{cache:"no-store"});if(!response.ok)throw new Error(`Page request failed (${response.status})`);
  const html=await response.text();if(activeCleanup){activeCleanup();activeCleanup=null;}
  $("#content").innerHTML=html;
  $$("#side-nav a[data-route],.sidebar nav a[data-route]").forEach(a=>a.classList.toggle("active",a.dataset.route===name));
  $("#page-heading").textContent=({dashboard:"Overview",prayers:"Prayer tracker",expenses:"Expenses",trading:"Trading journal",calendar:"Calendar & tasks",analytics:"Analytics",profile:"My profile",settings:"Settings",admin:"Admin dashboard"})[name];
  $("#today-label").textContent=new Date().toLocaleDateString(undefined,{weekday:"long",month:"long",day:"numeric"}).toUpperCase();
  const init=window.pageControllers?.[name];if(init){const cleanup=await init();if(typeof cleanup==="function")activeCleanup=cleanup;}
  $("#sidebar").classList.remove("open");
 }catch(e){$("#content").innerHTML=`<div class="panel error-state"><h2>We couldn't load this page</h2><p>${escapeHTML(e.message)}</p><button class="btn primary" onclick="routeTo('dashboard')">Return to overview</button></div>`;}
}
window.addEventListener("hashchange",()=>routeTo(location.hash.slice(1),false));
window.addEventListener("popstate",()=>routeTo(location.hash.slice(1)||"dashboard",false));
document.addEventListener("click",e=>{const a=e.target.closest('a[href^="#"]');if(a?.dataset.route){e.preventDefault();routeTo(a.dataset.route,true);}});
$("#menu-btn").addEventListener("click",()=>$("#sidebar").classList.toggle("open"));