window.currentUser=null;window.userProfile=null;
async function loadProfile(){
 const {data,error}=await db.from("profiles").select("*").eq("id",currentUser.id).maybeSingle();
 if(error)throw error;
 if(!data){const {data:d,error:e}=await db.from("profiles").insert({id:currentUser.id,display_name:currentUser.user_metadata?.display_name||currentUser.email.split("@")[0],currency:"BDT"}).select().single();if(e)throw e;userProfile=d;}else userProfile=data;
}
async function refreshIdentity(){
 const name=userProfile?.display_name||currentUser.email;
 $("#side-name").textContent=name;$("#side-email").textContent=currentUser.email;
 const avatar=userProfile?.avatar_url||"assets/images/avatar.svg";$("#side-avatar").src=avatar;$("#header-avatar").src=avatar;
 const {data}=await db.rpc("is_admin");$("#admin-nav").classList.toggle("hidden",!data);
}
async function signOut(){const {error}=await db.auth.signOut();if(error)toast(error.message,"error");}
$("#login-form").addEventListener("submit",async e=>{
 e.preventDefault();const b=e.submitter;b.disabled=true;$("#auth-message").textContent="Signing in…";
 const {error}=await db.auth.signInWithPassword({email:$("#login-email").value,password:$("#login-password").value});
 b.disabled=false;$("#auth-message").textContent=error?error.message:"";if(error)toast(error.message,"error");
});
$("#logout-btn").addEventListener("click",signOut);
db.auth.onAuthStateChange((_event,session)=>{setTimeout(()=>handleSession(session),0);});
async function handleSession(session){
 currentUser=session?.user||null;
 if(!currentUser){$("#app").classList.add("hidden");$("#auth-screen").classList.remove("hidden");return;}
 try{await loadProfile();await refreshIdentity();$("#auth-screen").classList.add("hidden");$("#app").classList.remove("hidden");routeTo(location.hash.slice(1)||"dashboard",false);}
 catch(e){toast("Could not load account: "+e.message,"error");}
}
(async()=>{const {data}=await db.auth.getSession();await handleSession(data.session);})();