
## Network Lab Memo

■ 日付：
2025-12-02

■ 今日の目的：
- VirtualBox内のネットワーク構成（NAT / Host-Only / ループバック）を整理する
- ping / curl / ログを使って「どこを通っているか」を確認する

---

■ 1. IPアドレスと役割

[Ubuntu VM 内]

  lo: 127.0.0.1/8
    - Ubuntu 自分自身専用の「内線」
    - アプリ同士が同一マシン内で通信するときに使う

  enp0s3: <VM_NAT_IP>  （NAT）
    - VirtualBox NAT ネットワーク
    - デフォルトゲートウェイ: <NAT_GATEWAY_IP>
    - 役割：
      - VM → インターネット への出口
      - 外から勝手に中へは入って来れない（NAT）

  enp0s8: <VM_HOSTONLY_IP>  （Host-Only）
    - VirtualBox Host-Only ネットワーク
    - ホストPC: <HOSTONLY_GATEWAY_IP>
    - 役割：
      - VM ⇔ ホストPC ⇔ 他のVM の「PCの中だけLAN」
      - インターネットには直接出ない

[ルーティング（ip r の要約）]

  default via <NAT_GATEWAY_IP> dev enp0s3
    → よく分からない宛先はすべて <NAT_GATEWAY_IP> から外へ

  <NET_NAT>/24 dev enp0s3
    → NAT側ネットワークあては同じLANなので直接届く

  <NET_HOSTONLY>/24 dev enp0s8
    → Host-Only側ネットワークあては同じLANなので直接届く

---

■ 2. 疎通確認（ping）

1) NATゲートウェイまで
  ping -c 3 <NAT_GATEWAY_IP>
  → 0% loss / time は 1ms 未満
  → enp0s3 経由で同じ仮想LAN内に到達できている

2) インターネットまで
  ping -c 3 8.8.8.8
  ping -c 3 github.com
  → 0% loss / time は 10〜20ms 程度
  → default route（<NAT_GATEWAY_IP>）を経由してインターネットまで行けている

3) Host-Only（ホストPC）まで
  ping -c 3 <HOSTONLY_GATEWAY_IP>
  → 0% loss / time は 1ms 未満
  → enp0s8 経由で PC 内LAN（<NET_HOSTONLY>/24）が正常

---

■ 3. Webアクセスと HTTP 301

1) 127.0.0.1 へのアクセス

  curl http://127.0.0.1

  → Apache が応答し、HTML の title が
     「301 Moved Permanently」
  → 本文に "The document has moved <a href="https://localhost/">here</a>."
  → HTTP (80番) で来たアクセスを、HTTPS (https://localhost) へ
    リダイレクトしていることが分かる。

2) <VM_HOSTONLY_IP> へのアクセス

  curl http://<VM_HOSTONLY_IP>

  → 同じく「301 Moved Permanently」
  → Apache が 127.0.0.1 だけでなく <VM_HOSTONLY_IP>:80 でも
    リクエストを受け付けていることを確認。

---

■ 4. アクセスログとの対応

[ログの場所]

  ディレクトリ：
    /var/log/apache2

  アクセスログ（vhost用）：
    /var/log/apache2/other_vhosts_access.log

[tail した結果の例]

  sudo tail -n 20 /var/log/apache2/other_vhosts_access.log

  例：
  127.0.0.1:80 127.0.0.1        - - [02/Dec/2025:22:xx:42 +0900] "GET / HTTP/1.1" 301 500 "-" "curl/8.5.0"
  127.0.0.1:80 <VM_HOSTONLY_IP> - - [02/Dec/2025:22:38:12 +0900] "GET / HTTP/1.1" 301 505 "-" "curl/8.5.0"

  解釈：
    - 1列目：サーバ側IP:ポート
        127.0.0.1:80  → Apache が 127.0.0.1 の 80番で受けた
    - 2列目：クライアントIP
        127.0.0.1       → curl http://127.0.0.1 のアクセス
        <VM_HOSTONLY_IP>→ curl http://<VM_HOSTONLY_IP> のアクセス
    - "GET / HTTP/1.1" 301 ...
        → ブラウザに返したステータスコードは 301（Moved Permanently）

---

■ 5. 今日の学び（メモ）

- NAT（<VM_NAT_IP> → <NAT_GATEWAY_IP>）と
  Host-Only（<VM_HOSTONLY_IP> ⇔ <HOSTONLY_GATEWAY_IP>）の
  役割の違いが図でイメージできた。
- デフォルトルート「via <NAT_GATEWAY_IP>」があるからインターネットまで届く。
- 127.0.0.1 は最初からOSが持っている「自分専用の内線IP」で、
  NAT や Host-Only 用には使えない特別アドレス。
- curl で投げたリクエストが、Apache のアクセスログのどの1行に
  記録されるかを自分でたどれた（IP＋ステータスコードで確認できた）。

