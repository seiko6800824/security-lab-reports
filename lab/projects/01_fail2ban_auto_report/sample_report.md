# 【自動防御レポート】2025-11-12

## 1. Fail2ban 概要
- Currently banned: 1
- Status file: /home/seiko/lab/logs/2025-11-12/fail2ban_status.txt

## 2. Apache 集計
- GoAccess HTML: /home/seiko/lab/logs/2025-11-12/apache_report.html
- Source log (merged): /home/seiko/lab/logs/2025-11-12/apache_all.log

## 3. 直近Fail2banログ（抜粋）
```
2025-11-12 11:14:45,056 fail2ban.jail           [721]: INFO    Jail 'sshd' uses systemd {}
2025-11-12 11:14:45,503 fail2ban.jail           [721]: INFO    Initiated 'systemd' backend
2025-11-12 11:14:45,513 fail2ban.filter         [721]: INFO      maxLines: 1
2025-11-12 11:14:45,522 fail2ban.filtersystemd  [721]: INFO    [sshd] Added journal match for: '_SYSTEMD_UNIT=sshd.service + _COMM=sshd'
2025-11-12 11:14:45,522 fail2ban.filter         [721]: INFO      maxRetry: 3
2025-11-12 11:14:45,581 fail2ban.filter         [721]: INFO      findtime: 600
2025-11-12 11:14:45,581 fail2ban.actions        [721]: INFO      banTime: 600
2025-11-12 11:14:45,581 fail2ban.filter         [721]: INFO      encoding: UTF-8
2025-11-12 11:14:45,595 fail2ban.jail           [721]: INFO    Jail 'sshd' started
2025-11-12 11:14:46,720 fail2ban.filtersystemd  [721]: INFO    [sshd] Jail is in operation now (process new journal entries)
```

## 4. メモ
- IP固定＋鍵認証で自己BAN防止済み
- しきい値（maxretry/findtime/bantime）要見直し候補
