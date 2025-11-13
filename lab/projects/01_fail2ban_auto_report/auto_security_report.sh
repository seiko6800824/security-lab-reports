#!/usr/bin/env bash
set -euo pipefail

SESSION_DATE=$(date +%F)
LAB="$HOME/lab"
WORKDIR="$LAB/logs/$SESSION_DATE"
WRITEUPS="$LAB/writeups"
mkdir -p "$WORKDIR" "$WRITEUPS"

# --- Fail2ban 収集 ---
sudo fail2ban-client status > "$WORKDIR/fail2ban_status.txt" || true
sudo fail2ban-client get sshd banned > "$WORKDIR/banned_ips.txt" 2>/dev/null || true
sudo tail -n 50 /var/log/fail2ban.log > "$WORKDIR/fail2ban_tail.log" 2>/dev/null || true
BAN_COUNT=$(wc -l < "$WORKDIR/banned_ips.txt" 2>/dev/null || echo 0)

# --- Apache 解析（vhosts想定）---
sudo zcat -f /var/log/apache2/other_vhosts_access.log* > "$WORKDIR/apache_all.log" 2>/dev/null || true
if [ -s "$WORKDIR/apache_all.log" ]; then
  goaccess "$WORKDIR/apache_all.log" -o "$WORKDIR/apache_report.html" --log-format=VCOMBINED >/dev/null 2>&1 || true
else
  : > "$WORKDIR/apache_report.html"
fi

# --- Markdown レポート ---
OUT="$WRITEUPS/security_report_${SESSION_DATE}.md"
cat > "$OUT" <<EOM
# 【自動防御レポート】${SESSION_DATE}

## 1. Fail2ban 概要
- Currently banned: ${BAN_COUNT}
- Status file: ${WORKDIR}/fail2ban_status.txt

## 2. Apache 集計
- GoAccess HTML: ${WORKDIR}/apache_report.html
- Source log (merged): ${WORKDIR}/apache_all.log

## 3. 直近Fail2banログ（抜粋）
\`\`\`
$(tail -n 10 "$WORKDIR/fail2ban_tail.log" 2>/dev/null)
\`\`\`

## 4. メモ
- IP固定＋鍵認証で自己BAN防止済み
- しきい値（maxretry/findtime/bantime）要見直し候補
EOM

# --- GitHub push ---
if git -C "$WRITEUPS" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  (
    cd "$WRITEUPS"
    git add "$OUT"
    # 変更があった時だけコミット
    git diff --cached --quiet || git commit -m "Auto security report ${SESSION_DATE}" >/dev/null 2>&1
    # upstream 未設定でも通るように
    git push -u origin main || git push || true
  )
fi

echo "✅ レポート作成＆GitHub送信完了: $OUT"

# === 成功ログを残す ===
LOGFILE="/home/seiko/lab/logs/cron_run.log"
echo "$(date '+%F %T') ✅ Auto security report sent to GitHub" >> "$LOGFILE"
