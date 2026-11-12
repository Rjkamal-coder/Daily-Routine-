/* Public browser key only. Never place a service_role/secret key here. */
window.SUPABASE_URL = "https://fjtlkccvholkxewmtthp.supabase.co";
window.SUPABASE_ANON_KEY = "sb_publishable_uyUtDHXkIC68WYzNiHBlmQ_ua9RpsWe";
if (!window.supabase) console.error("Supabase JS library did not load.");
window.db = window.supabase ? window.supabase.createClient(window.SUPABASE_URL, window.SUPABASE_ANON_KEY, {
  auth: { persistSession: true, autoRefreshToken: true, detectSessionInUrl: true }
}) : null;