#!/bin/bash
# Copy portal to the live site repo as /portal/ (inline localStorage SyncStore, noindex). Usage: bash deploy-hosted.sh <site-repo-path>
set -e; SITE="$1"; cd "$(dirname "$0")"
mkdir -p "$SITE/portal"; cp index.html "$SITE/portal/index.html"
python3 - "$SITE/portal/index.html" <<'PY'
import sys,re
p=sys.argv[1];t=open(p).read()
inline='''<script>
  // Hosted portal: SyncStore = localStorage only, inlined (no external file to fail on older iPads)
  var SyncStore = {
    get: function (key) { return new Promise(function (resolve) { try { var raw = localStorage.getItem(key); resolve(raw ? JSON.parse(raw) : null); } catch (e) { resolve(null); } }); },
    set: function (key, data) { try { data._ts = Date.now(); localStorage.setItem(key, JSON.stringify(data)); } catch (e) {} return Promise.resolve(); }
  };
</script>'''
t=re.sub(r'<script src="[./]*sync\.js[^"]*"></script>',inline,t)
t=t.replace('<meta name="viewport"','<meta name="robots" content="noindex, nofollow">\n<meta name="apple-mobile-web-app-capable" content="yes">\n<meta name="viewport"',1)
open(p,'w').write(t)
PY
