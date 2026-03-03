import os
import sys
from dotenv import load_dotenv
from supabase import create_client, Client

load_dotenv()

url: str = os.environ.get("SUPABASE_URL")
key: str = os.environ.get("SUPABASE_ANON_KEY")

if not url or not key:
    print("❌ ERROR: Missing SUPABASE_URL or SUPABASE_ANON_KEY environment variables.")
    print("Please add them to your Railway Service -> Variables tab.")
    # Exit gracefully so it doesn't loop forever in a crash state
    sys.exit(1)

try:
    supabase: Client = create_client(url, key)
except Exception as e:
    print(f"❌ ERROR: Failed to connect to Supabase: {str(e)}")
    sys.exit(1)
