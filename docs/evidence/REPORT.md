<!--
  REPORT.md — Final Project evidence file.

  Rules:
  - Keep it ≤ 2 printed pages.
  - All screenshots embedded inline (commit PNGs next to this file).
  - All command outputs pasted as fenced code blocks, captured with `tee`
    (not retyped). Keep timestamps visible.
  - Identity binding: in every screenshot, your ESADE email AND the public
    HTTPS URL must be visible in the same frame (browser tab, terminal
    prompt, or watermark).
  - URL must be reachable until 24 h after the exam day. Down = practical 0.
  - Missing item = -5% on practical, each.

  Replace every `TODO` and remove these HTML comments before submitting.
-->

# Final Project — Evidence Report

## 1. Identity

| Field | Value |
|---|---|
| Student name | Kim Schäfer |
| ESADE email | kimlaureen.schafer@alumni.esade.edu |
| GitHub repo URL | https://github.com/kimlaureen/lobechat-aws (private; `joseporiolrius` invited as collaborator) |
| Latest commit SHA | TODO (`git rev-parse HEAD`) |
| Final tag | TODO (`final-vX.Y.Z`) |

## 2. Public URL

<!-- Grader clicks. If down or HTTP, practical = 0. -->

**[https://kimlaureen.duckdns.org](https://kimlaureen.duckdns.org)**

## 3. Screenshot — LobeChat over HTTPS, logged in

<!--
  Frame must show:
    - browser address bar with padlock + the public HTTPS URL
    - LobeChat home page after Casdoor login
    - your ESADE email visible (browser profile, account menu, or terminal
      next to the browser with the prompt)
  Commit as: lobechat-https.png
-->

![lobechat-https](lobechat-https.png)

*LobeChat at `kimlaureen.duckdns.org` with ESADE email visible in terminal. Certificate: Let's Encrypt, connection secure.*

![tls-cert](tls-cert.png)

## 4. Screenshot — chat working (streaming + MCP)

<!--
  One frame showing:
    - a chat reply that streamed (any model)
    - one MCP tool call result rendered in the same chat
  Commit as: chat-mcp.png
-->

![chat-mcp](chat-mcp.png)

## 5. Screenshot — file upload to MinIO

![file-upload](file-upload.png)

*A PDF upload is visible in the chat and LobeChat responds below it, validating the file upload path through MinIO.*

## 6. Public reachability — `curl -sI https://<host>/`

<!--
  Run from OUTSIDE the EC2 (your laptop). Paste full output.
  Expected: HTTP/2 200 or 302, valid TLS, Set-Cookie with Secure flag if
  Casdoor session was hit.
-->

```
$ curl -sI https://kimlaureen.duckdns.org/
HTTP/2 307 
alt-svc: h3=":443"; ma=2592000
date: Sat, 30 May 2026 13:50:40 GMT
location: /chat
via: 1.1 Caddy
```

## 7. Negative test — port 47000 closed

<!--
  Run from OUTSIDE the EC2 against the EIP. Paste full output.
  Expected: connection refused or timed out.
-->

```
$ curl -v --max-time 5 http://18.202.153.230:47000/
*   Trying 18.202.153.230:47000...
* Connection timed out after 5007 milliseconds
* Closing connection
curl: (28) Connection timed out after 5007 milliseconds
```

## 8. Stack runtime — `docker compose ps`

<!--
  Run on the EC2. Paste full output.
  All required services must show Up (healthy where applicable):
  lobe-chat, casdoor, postgres, minio, qdrant, mcphub, plus your reverse proxy.
-->

```
$ docker compose ps
NAME              IMAGE                               COMMAND                  SERVICE         CREATED       STATUS                 PORTS
caddy             caddy:2-alpine                      "caddy run --config …"   caddy           2 hours ago   Up 35 minutes          0.0.0.0:80->80/tcp, [::]:80->80/tcp, 0.0.0.0:443->443/tcp, [::]:443->443/tcp, 0.0.0.0:9000->9000/tcp, [::]:9000->9000/tcp, 0.0.0.0:47002->47002/tcp, [::]:47002->47002/tcp, 443/udp, 2019/tcp
casdoor           casbin/casdoor:v2.13.0              "/server /bin/sh -c …"   casdoor         2 hours ago   Up 2 hours
hayhooks          deepset/hayhooks:v1.1.0             "hayhooks run --host…"   hayhooks        2 hours ago   Up 2 hours             0.0.0.0:47012->1416/tcp, [::]:47012->1416/tcp
hayhooks-mcp      deepset/hayhooks:v1.1.0             "sh -c 'pip install …"   hayhooks-mcp    2 hours ago   Up 2 hours             1416/tcp, 0.0.0.0:47013->1417/tcp, [::]:47013->1417/tcp
linux-sandbox     lobechat-aws-linux-sandbox:latest   "tail -f /dev/null"      linux-sandbox   2 hours ago   Up 2 hours
lobe-chat         lobehub/lobe-chat-database          "/bin/node /app/star…"   lobe-chat       2 hours ago   Up 2 hours             3210/tcp
mcphub            lobechat-aws-mcphub:latest          "/usr/local/bin/entr…"   mcphub          2 hours ago   Up 36 minutes          0.0.0.0:47008->3000/tcp, [::]:47008->3000/tcp
minio             minio/minio:latest                  "/usr/bin/docker-ent…"   minio           2 hours ago   Up 2 hours (healthy)   9000/tcp
qdrant            qdrant/qdrant:latest                "./entrypoint.sh"        qdrant          2 hours ago   Up 2 hours (healthy)   0.0.0.0:47010->6333/tcp, [::]:47010->6333/tcp, 0.0.0.0:47011->6334/tcp, [::]:47011->6334/tcp
shared-postgres   pgvector/pgvector:pg16              "docker-entrypoint.s…"   postgres        2 hours ago   Up 2 hours (healthy)   0.0.0.0:47003->5432/tcp, [::]:47003->5432/tcp
```
