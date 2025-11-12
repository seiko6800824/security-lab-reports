# 【Fail2ban自動防御レポート】2025-11-12

## 1. 概要
SSHへの不正アクセスをFail2banが検知し、自動的にブロックしました。（本スクリプトは**読み取りのみ**で設定変更しません）

## 2. BAN対象数
1

## 3. BAN一覧（先頭20件）
[]

## 4. 直近ログ（抜粋）
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

## 5. 対策・考察（メモ）
- 固定IP＋秘密鍵認証で自己BAN防止済
- しきい値（maxretry/findtime/bantime）の再検証を予定
