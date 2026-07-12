# Review: `starter/lib/sms_console.dart`

I would not ship this screen as-is. The biggest risks are not visual polish; they
are credential leakage, tenant isolation, incorrect billing, and poor behavior
when the network or backend does something normal but unhappy. I ordered the
findings roughly by what I would want fixed first.

## Findings

### 1. Hardcoded API key can be extracted from the app

**Severity:** Critical  
**Location:** line 9

**Evidence:** `kApiKey` is a live-looking bearer credential committed directly
in the Flutter source.

**Impact:** Anyone with access to the repository or app bundle can reuse that
credential to send SMS against the business account. That can become direct SMS
cost, abuse, and a customer trust incident.

**Fix:** Remove the key from source, rotate the leaked credential, and use a real
session flow with short-lived access tokens. Store refresh credentials only in
platform secure storage.

### 2. Tenant isolation is declared but not enforced

**Severity:** Critical  
**Location:** lines 10, 48, 73-76, 127

**Evidence:** `kTenantId` exists, but none of the HTTP requests include the
required `X-Tenant-Id` header from the API contract.

**Impact:** Requests may fail with `403`, or tenant-scoped UI state can become
unsafe if the app later supports switching tenants. In a multi-tenant messaging
product, showing one tenant's data under another tenant is a real incident.

**Fix:** Put tenant id in the authenticated session context and add
`X-Tenant-Id` from one shared API client. Clear tenant-scoped state whenever the
active tenant changes.

### 3. Sensitive traffic is sent over plain HTTP

**Severity:** High  
**Location:** line 8

**Evidence:** The base URL is `http://api.formwork.internal`, while every request
sends bearer credentials and SMS data.

**Impact:** Tokens, phone numbers, and message content can be intercepted or
modified on the network.

**Fix:** Configure the API base URL per environment and require HTTPS for any
non-local production-like build.

### 4. Phone number and message body are logged

**Severity:** High  
**Location:** line 69

**Evidence:** The code prints `Sending SMS to $phone: $body`.

**Impact:** Phone numbers and SMS contents can leak into device logs, crash
reports, support tooling, or CI logs. If the message contains an OTP, the log
contains the OTP too.

**Fix:** Remove this log. If logging is needed, log only non-sensitive metadata
such as request id, status, timing, and a masked recipient.

### 5. Billing is calculated locally instead of trusting the API

**Severity:** High  
**Location:** lines 18-23, 80-85

**Evidence:** The send endpoint returns `cost`, but the client ignores it and
uses hardcoded provider rates from `rateFor`.

**Impact:** The UI can show a different amount than the invoice. That is not a
cosmetic bug; it is a billing correctness issue.

**Fix:** Treat the backend as the pricing authority. Parse the `cost` field from
the send response into a typed money value and display that.

### 6. Every SMS is assumed to be one segment

**Severity:** High  
**Location:** line 82

**Evidence:** `segments` is hardcoded to `1`, even though the API returns
`segmentCount`.

**Impact:** Longer messages can span multiple segments, so this undercounts cost
and misrepresents what was sent.

**Fix:** Use the API response's `segmentCount` for display and history. Do not
derive send cost on the client.

### 7. Decimal money is handled as `double`

**Severity:** High  
**Location:** lines 13, 53-56, 83, 85, 122

**Evidence:** Total cost is stored as `double`, and cost rows are cast with
`as double`, but the contract says money is returned as decimal strings and must
not be parsed into floating point.

**Impact:** Small floating-point rounding errors can become real invoice
differences at messaging volume.

**Fix:** Use a decimal or fixed-scale money type. Parse API money strings once in
typed models and format them through a single money formatter.

### 8. Error responses are treated like successful responses

**Severity:** High  
**Location:** lines 46-51, 71-83, 124-134

**Evidence:** The code decodes `res.body` and reads success fields without first
checking `statusCode`, `Retry-After`, or the error payload shape.

**Impact:** `400`, `403`, `429`, `502`, expired token responses, or proxy HTML
can crash the screen or produce misleading UI.

**Fix:** Centralize HTTP handling in a repository/API client. Map known status
codes to typed failures, refresh expired tokens, honor `Retry-After`, and expose
recoverable UI states.

### 9. Cost loading can leave the user stuck on a spinner

**Severity:** Medium  
**Location:** lines 44-60

**Evidence:** `loadCosts` sets `loading = true`, then awaits the request without
`try/catch/finally`. If anything throws before line 60, loading is never reset.

**Impact:** A normal offline or slow-network path can leave the screen stuck
with no explanation or retry.

**Fix:** Use `try/catch/finally`, add request timeouts, and render an error
state with a retry action.

### 10. Async callbacks can call `setState` after disposal

**Severity:** Medium  
**Location:** lines 45, 60, 64, 91, 95

**Evidence:** `loadCosts` and `sendSms` call `setState` after awaits without
checking whether the widget is still mounted.

**Impact:** If the user navigates away while a request is in flight, Flutter can
throw `setState() called after dispose()`.

**Fix:** Move async state into a controller/state notifier that is disposed
safely, or check `mounted` before post-await UI updates.

### 11. The cost endpoint is fetched twice

**Severity:** Medium  
**Location:** lines 44-60 and 124-128

**Evidence:** `initState` calls `loadCosts`, and the `FutureBuilder` creates a
second `http.get` inside `build`.

**Impact:** Rebuilds can trigger extra network calls, inconsistent totals,
flicker, and unnecessary pressure on a rate-limited API.

**Fix:** Fetch through one repository-backed state holder and render the list
from that state. Keep network calls out of `build`.

### 12. The UI expects `recipient` on the cost breakdown endpoint

**Severity:** Medium  
**Location:** lines 133-141

**Evidence:** The UI reads `rows[i]['recipient']`, but
`GET /sms/cost/breakdown` returns provider, total cost, and message count. The
contract explicitly says this endpoint does not return phone numbers.

**Impact:** The row can render `null` or crash depending on runtime behavior. It
also suggests a privacy model the API deliberately avoids.

**Fix:** Show only cost breakdown fields on this screen section. Use
`GET /sms/messages` for paginated message history, where recipients are already
masked.

### 13. Send requests do not include a reference id

**Severity:** Medium  
**Location:** line 77

**Evidence:** The contract includes `referenceId`, but the client sends only
`to` and `body`.

**Impact:** Support, retries, and duplicate-send investigation become harder
because the client has no business-level correlation id.

**Fix:** Generate or accept an idempotent reference id in the send use case and
include it in the typed request model.

### 14. Text controllers are not disposed

**Severity:** Low  
**Location:** lines 32-33

**Evidence:** The state object creates two `TextEditingController`s but has no
`dispose` override.

**Impact:** Repeatedly opening and closing this screen can leak controller
resources.

**Fix:** Override `dispose`, dispose both controllers, then call
`super.dispose()`.

## What I would fix first

My first pass would be security and correctness, not UI polish: remove and
rotate the leaked credential, route all requests through a tenant-aware HTTPS API
client, replace floating-point money with typed decimal money, and build explicit
loading/error/success states around repository responses. Those changes address
the real incidents before improving the screen structure.
