# ADR 0001: Simple Bloc architecture

## Status

Accepted

## Context

The starter file mixed UI, HTTP calls, credentials, billing arithmetic, and
mutable global state in one widget. The assignment asks for production
judgement, but the codebase is still small enough that a heavy enterprise folder
structure would be harder to review than the product itself.

## Decision

Use a simple feature-first structure:

- `app` for app setup, routes, theme, and environment defaults.
- `core` for API, error handling, money, and local session values.
- `shared` for reusable widgets and UI helpers.
- `features/sms` for the SMS repository, models, Bloc, and screen widgets.

The SMS screen uses `flutter_bloc`. Widgets dispatch user intent as events, the
Bloc owns loading/sending/pagination state, and the repository owns API or mock
data access.

## Alternatives considered

- Riverpod: also a good choice, but Bloc makes event-driven send, retry, and
  pagination flows explicit and easy to test.
- Full Clean Architecture with use cases and data sources: valid for a larger
  codebase, but too much ceremony for this assignment.
- StatefulWidget with repository calls: simpler at first, but it repeats the
  starter file's main problem by letting UI own business flow.

## Consequences

The result is intentionally boring: small files, typed models, one API caller,
one repository, one Bloc, and reusable UI components. It protects tenant
headers, error mapping, and money arithmetic without hiding the app behind
unnecessary layers.
