# 【自動防御レポート】2025-11-20

## 1. Fail2ban 概要
- Currently banned: 1
- Status file: /home/seiko/lab/logs/2025-11-20/fail2ban_status.txt

## 2. Apache 集計
- GoAccess HTML: /home/seiko/lab/logs/2025-11-20/apache_report.html
- Source log (merged): /home/seiko/lab/logs/2025-11-20/apache_all.log

## 3. 直近Fail2banログ（抜粋）
```
2025-11-20 20:53:43,577 fail2ban.jail           [658]: INFO    Jail 'sshd' uses systemd {}
2025-11-20 20:53:43,854 fail2ban.jail           [658]: INFO    Initiated 'systemd' backend
2025-11-20 20:53:43,855 fail2ban.filter         [658]: INFO      maxLines: 1
2025-11-20 20:53:43,896 fail2ban.filtersystemd  [658]: INFO    [sshd] Added journal match for: '_SYSTEMD_UNIT=sshd.service + _COMM=sshd'
2025-11-20 20:53:43,896 fail2ban.filter         [658]: INFO      maxRetry: 3
2025-11-20 20:53:43,896 fail2ban.filter         [658]: INFO      findtime: 600
2025-11-20 20:53:43,896 fail2ban.actions        [658]: INFO      banTime: 600
2025-11-20 20:53:43,897 fail2ban.filter         [658]: INFO      encoding: UTF-8
2025-11-20 20:53:43,932 fail2ban.jail           [658]: INFO    Jail 'sshd' started
2025-11-20 20:53:45,267 fail2ban.filtersystemd  [658]: INFO    [sshd] Jail is in operation now (process new journal entries)
```

## 4. メモ
- IP固定＋鍵認証で自己BAN防止済み
- しきい値（maxretry/findtime/bantime）要見直し候補
