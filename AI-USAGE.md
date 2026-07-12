# AI Usage

I used an AI assistant to help inspect the starter file, identify production
risks, and draft the first implementation shape.

The AI-generated starter was wrong in several important ways: it committed a
live-looking API key, sent bearer credentials over plain HTTP, skipped the
required tenant header, calculated SMS cost locally with `double`, and logged
phone numbers plus message bodies. I replaced that with a small Bloc-based
structure, a shared API caller, typed models, centralized error mapping, and a
fixed-scale money type.

I kept the architecture deliberately simple: no unnecessary use-case folder, no
global mutable app state, and no direct network calls from widgets. The parts I
would defend most carefully are the money model, tenant-aware API headers, and
the decision to use a mock repository by default for the take-home.
