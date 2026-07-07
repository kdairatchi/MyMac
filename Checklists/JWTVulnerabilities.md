# JWT Vulnerabilities

## How to exploit

1. Set `alg` to `none`:

```
{
  "alg": "none",
  "typ": "JWT"
}
```

2. Swap RS256 → HS256. If the backend blindly reuses the RS256 public key as the HS256 secret, you can forge a valid signature with it.

3. Brute-force a weak HS256 secret — PyJWT sample scripts do this directly against the token.

## Tools

* [jwt-hack](https://github.com/hahwul/jwt-hack)

## Reference

* [Hacking JSON Web Token (JWT)](https://medium.com/101-writeups/hacking-json-web-token-jwt-233fe6c862e6)
