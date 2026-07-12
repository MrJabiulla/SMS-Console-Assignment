# SMS Console Assignment

A Flutter rebuild of the SMS console using a small, readable Bloc architecture.

## Run

```sh
flutter pub get
flutter run
```

The app uses mock data by default so it can be reviewed without the real backend.

## Configuration

Copy `.env.example` to `.env` and update local runtime configuration:

```env
BASE_URL=https://api.example.com
USE_MOCK_API=true
DEMO_ACCESS_TOKEN=replace-with-runtime-token
DEMO_TENANT_ID=00000000-0000-0000-0000-000000000000
```

`.env` is loaded with `flutter_dotenv` and is ignored by Git. Keep real tokens
out of committed source; for production, access tokens should come from
authentication and secure storage instead of a bundled env asset.

## What Changed

- Replaced widget-owned HTTP and mutable global state with `SmsBloc`.
- Added a repository with mock and API-backed paths.
- Centralized API headers, endpoints, result handling, and error mapping.
- Added typed SMS models instead of `dynamic` at call sites.
- Added fixed-scale `Money` arithmetic so decimal strings are never parsed as
  `double`.
- Added responsive phone/desktop layout, light/dark theme, reusable form, cost,
  empty, error, and loading components.

## Tests

```sh
flutter analyze
flutter test
```

Included tests cover decimal money arithmetic, Bloc loading with masked
recipients, a widget validation failure path, and a skipped golden placeholder
that can be recorded with `flutter test --update-goldens`.

## Deliberately Not Done

- Real token refresh flow. The contract documents it, but this assignment does
  not include an auth backend.
- Platform screenshots are still pending.
- Bulk SMS was not implemented because the required shipped surface is send SMS,
  paginated history, and cost breakdown.

## Next Week

I would add secure storage, token refresh, real integration tests against a mock
HTTP server, recorded goldens for mobile/desktop layouts, and screenshot
evidence for two platforms.
