# AI Usage

I used an AI assistant as a review and implementation partner, not as an
unreviewed code generator.

## What I Used AI For

- Reviewed the starter screen for security, billing, tenant isolation, network,
  and privacy risks.
- Compared the implementation against `API-CONTRACT.md`.
- Drafted first-pass ideas for widgets, tests, documentation, and edge cases.
- Used AI to sanity-check assignment coverage before submission.

## Where The AI Was Wrong

- The starter committed a live-looking API key.
- It sent bearer credentials over plain HTTP.
- It skipped the required `X-Tenant-Id` header.
- It calculated SMS cost with `double`.
- It logged phone numbers and message bodies.
- It mixed UI, HTTP, billing logic, and mutable global state in one widget.

## What I Did Myself

- Finalized the project architecture myself.
- Chose a simple feature-first structure instead of heavy Clean Architecture.
- Separated app setup, core API/error/money/storage code, shared widgets, and
  the SMS feature module.
- Replaced widget-owned business logic with `SmsBloc`.
- Added typed models, repository boundaries, centralized error mapping, and a
  shared API client.
- Added reusable shared UI/helpers: text fields, buttons, snack messages,
  loaders, empty/error views, and responsive page wrapper.
- Added shared constants for colors, strings, assets, text styles, font weights,
  and app enums to avoid scattered hardcoded values.
- Manually finalized the money model, tenant-aware headers, tenant-scoped cache,
  secure token storage boundary, phone validation, and `REVIEW.md` findings.
- Verified the responsive layouts, golden tests, widget failure test, money
  arithmetic test, local cache tenant isolation test, README, ADR, and CI.

## What I Would Defend In Review

- Project architecture and feature boundaries.
- Fixed-scale `Money` model instead of floating point billing.
- Tenant-aware API headers and cache keys.
- Mock repository as the default review path.
- Token refresh, bulk SMS, and real backend integration tests as documented
  future work.
