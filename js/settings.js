pageControllers.settings=async()=>{
 const currency=$("#settings-currency");
 const income=$("#settings-income");
 const incomeCurrency=$("#income-currency-label");
 currency.value=userProfile.currency||"BDT";
 income.value=Number(userProfile.monthly_income||0);
 incomeCurrency.textContent=currency.value;
 $("#settings-theme").onclick=toggleTheme;

 currency.onchange=async()=>{
  try{
   const {data,error}=await db.from("profiles").update({currency:currency.value}).eq("id",currentUser.id).select().single();
   if(error)throw error;
   userProfile=data;
   incomeCurrency.textContent=currency.value;
   toast("Currency preference saved");
  }catch(error){toast(error.message,"error");}
 };

 $("#income-form").onsubmit=async event=>{
  event.preventDefault();
  const amount=Number(income.value);
  if(!Number.isFinite(amount)||amount<0){toast("Enter a valid monthly income amount.","error");return;}
  const button=event.submitter;
  if(button){button.disabled=true;button.textContent="Saving...";}
  try{
   const {data,error}=await db.from("profiles")
    .update({monthly_income:amount})
    .eq("id",currentUser.id)
    .select().single();
   if(error)throw error;
   userProfile=data;
   toast("Monthly income saved successfully");
  }catch(error){toast(error.message,"error");}
  finally{if(button){button.disabled=false;button.textContent="Save monthly income";}}
 };
};