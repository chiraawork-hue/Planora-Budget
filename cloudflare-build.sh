#!/usr/bin/env sh
set -eu

: "${SUPABASE_URL:?SUPABASE_URL is required}"
: "${SUPABASE_PUBLISHABLE_KEY:?SUPABASE_PUBLISHABLE_KEY is required}"

cat > config.js <<EOF
window.PLANORA_CONFIG={url:"${SUPABASE_URL}",key:"${SUPABASE_PUBLISHABLE_KEY}"};
EOF

cat > admin/config.js <<EOF
window.PLANORA_CONFIG={url:"${SUPABASE_URL}",key:"${SUPABASE_PUBLISHABLE_KEY}"};
EOF

echo "Planora runtime config created."
