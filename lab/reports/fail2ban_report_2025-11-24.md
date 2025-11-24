# fail2ban_report_2025-11-24

## 1. 結論
- ApacheのBasic認証失敗（401）を意図的に3回発生させ、fail2banで自動banできた。  
- banの発生は `fail2ban-client status apache-401` と Apacheログで根拠確認できた。  
- 解除（unban）まで一連で実施し、運用フローを自力で再現できた。

## 2. 目的
- Webサーバー上で認証失敗ログ（401）を監視し、一定回数で自動遮断できることを確認する。  
- 「ログ発生 → fail2ban検知 → ban → 根拠確認 → unban」の一連を自分の手で再現する。

## 3. 実施内容（やった順）
1. `/var/www/html/secret401/` を作成し、Basic認証が要求される401環境を準備。  
2. `apache-401` 用 filter と jail を作成して fail2ban に読み込ませた。  
3. ブラウザから誤った認証入力を繰り返し、401を3回発生させた。  
4. status とログから ban 発生を確認し、手動で unban を実施した。  

## 4. 使った設定（要点のみ）
- filter : `/etc/fail2ban/filter.d/apache-401.conf`  
  - access.log の **401行を failregex で検知**する設定  
- jail : `/etc/fail2ban/jail.local`
  - `maxretry=3 / findtime=300 / bantime=600`
  - `logpath=/var/log/apache2/access.log`

## 5. 根拠ログ
### 5-1. Apache access.log（401が3回発生）
xxx.xxx.xxx.xxx - - [24/Nov/2025:13:13:57 +0900] "GET /secret401/ HTTP/1.1" 401 ...
xxx.xxx.xxx.xxx - seiko [24/Nov/2025:13:14:00 +0900] "GET /secret401/ HTTP/1.1" 401 ...
xxx.xxx.xxx.xxx - seiko [24/Nov/2025:13:14:11 +0900] "GET /secret401/ HTTP/1.1" 401 ...


###5-2 fail2ban status（ban発生の確認）
Total failed: 3
Currently banned: 1
Banned IP list: xxx.xxx.xxx.xxx


### 5-3. unban後の確認（解除できた証拠）

$ sudo fail2ban-client set apache-401 unbanip xxx.xxx.xx.x
$ sudo fail2ban-client status apache-401
Status for the jail: apache-401
|- Filter
| |- Currently failed: 0
| |- Total failed: 3
| - File list: /var/log/apache2/access.log - Actions
|- Currently banned: 0
|- Total banned: 1
`- Banned IP list:

## 6. 気づき / 学び
- 401ログを自分で発生させることで、filterが正しく拾えているかを確実に検証できた。  
- `enabled=true` など **jail設定のキー名の正確さが必須**で、誤字があると検知・banが動かない。  
- status とログの両方を確認することで、遮断の根拠説明まで一連でできる。

## 7. 次の改善
- 401だけでなく403など他の失敗パターンも同様の型で監視対象に追加する。  
- maxretry/findtime/bantime を変え、誤検知と強度のバランスを検討する。
