# fail2ban_writeup_2025-11-24

- Basic認証の401環境を作成（/secret401）。
- apache-401 用 filter/jail を作成し fail2ban に読み込み。
- 401を3回発生させ、ban→statusで根拠確認。
- unban まで実施し、一連の運用フローを再現できた。



# fail2ban_writeup_2025-11-24
- apache-401 jail/filter を作成して有効化。
-


### Apache access.log（401が3回発生）
xx.xxx.xxx.xxx - - [24/Nov/2025:13:13:57 +0900] "GET /secret401/ HTTP/1.1" 401 ...
xxx.xxx.xxx.xxx - seiko [24/Nov/2025:13:14:00 +0900] "GET /secret401/ HTTP/1.1" 401 ...
xxx.xxx.xxx.xxx - seiko [24/Nov/2025:13:14:11 +0900] "GET /secret401/ HTTP/1.1" 401 ...


### fail2ban status（ban発生の確認）


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

m
