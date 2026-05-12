# TLS Validation Checklist

> Required by Appendix A.4. Failing any item = practical capped at 50%.
>
> Complete each item after deployment. Replace `[ ]` with `[x]` and add
> a timestamped screenshot path next to it.

**Public URL:** https://kimlaureen.duckdns.org  
**Student:** Kim Schäfer — kimlaureen.schafer@alumni.esade.edu

---

## Checklist

- [x] **Casdoor login flow** — completes from the public URL without `Secure cookie` / `redirect_uri` errors.  
  Screenshot: `casdoor-login.png`

- [ ] **Streaming works** — chat response tokens arrive incrementally (confirms SSE path through Caddy).  
  Screenshot: `chat-streaming.png`

- [ ] **MCP tool call** — at least one MCP tool invoked from chat returns a result (confirms long-lived MCP transport through Caddy).  
  Screenshot: `chat-mcp.png`

- [ ] **File upload** — file uploaded to MinIO from chat works (confirms proxy request size / timeout settings).  
  Screenshot: `file-upload.png`

- [ ] **Port 47000 blocked** — direct connection to `http://<eip>:47000` is refused, not just unreachable by accident.  
  Command output: paste `curl -v --max-time 5 http://<eip>:47000/` below.

  ```
  TODO — paste curl output here
  ```

- [x] **Valid certificate chain** — browser shows no warning; issuer is Let's Encrypt (public CA).  
  Screenshot: `tls-cert.png`

---

## How to capture evidence

```bash
# Negative test from your laptop (replace <eip> with EC2 Elastic IP)
curl -v --max-time 5 http://<eip>:47000/

# Public reachability
curl -sI https://kimlaureen.duckdns.org/

# TLS certificate details
openssl s_client -connect kimlaureen.duckdns.org:443 -servername kimlaureen.duckdns.org </dev/null 2>&1 | grep -E "subject|issuer|Verify return"
```

Screenshots must show your ESADE email **and** the public HTTPS URL in the same frame (browser profile, account menu, or terminal next to the browser).
