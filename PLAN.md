# Capital.com Elixir SDK + Strategy Runtime Plan (V1)

## 1) Goal and Scope
Build and release two production-ready Hex packages from one umbrella repo:
- `capital_com`: strict typed Capital.com SDK (full REST + production WebSocket streams).
- `capital_com_strategy`: full strategy runtime (live + paper + replay/backtest) with advanced portfolio risk controls.

This plan is written so an implementation agent can execute it from a fresh context.

## 2) Repository Layout
Use umbrella structure at `/Users/arman/Developer/CapitalCom`:
- `/Users/arman/Developer/CapitalCom/apps/capital_com`
- `/Users/arman/Developer/CapitalCom/apps/capital_com_strategy`
- `/Users/arman/Developer/CapitalCom/apps/capital_com_examples`
- `/Users/arman/Developer/CapitalCom/priv/openapi/capital_openapi.json`
- `/Users/arman/Developer/CapitalCom/tools/openapi_codegen`

## 3) Source of Truth and Constraints
Primary protocol source: Capital.com OpenAPI + API docs.

Key constraints to encode directly:
- REST session tokens (`CST`, `X-SECURITY-TOKEN`) expire after 10 minutes of inactivity.
- `POST /api/v1/session` is limited to 1 request/second per API key.
- Global request limits exist, with stricter pacing for position/order creation.
- Demo-specific limits exist for `POST /positions` and `POST /workingorders`.
- Trading flow returns `dealReference`; final status must be confirmed via `/api/v1/confirms/{dealReference}`.
- WebSocket endpoint is `wss://api-streaming-capital.backend-capital.com/connect`.
- WebSocket requires ping keepalive at least every 10 minutes.
- WebSocket market/OHLC subscriptions are limited to 40 epics.

## 4) Architecture Decisions
- Public SDK API is strict typed (no map-first public API).
- Hybrid generation strategy:
1. Generate low-level endpoint/schema modules from OpenAPI.
2. Implement handwritten high-level service APIs and orchestration.
- Session model: managed process plus explicit session APIs.
- Strategy model: behavior callbacks (no DSL in V1).
- Runtime state: pluggable store behavior with in-memory/ETS default.
- Release topology: two Hex packages with coordinated versions.

## 5) Package Architecture
### `capital_com`
Core modules:
- `CapitalCom.Client`
- `CapitalCom.Session`
- `CapitalCom.Accounts`
- `CapitalCom.Trading`
- `CapitalCom.Positions`
- `CapitalCom.Orders`
- `CapitalCom.Markets`
- `CapitalCom.Prices`
- `CapitalCom.Sentiment`
- `CapitalCom.Watchlists`
- `CapitalCom.General`

Infrastructure modules:
- `CapitalCom.Transport.HTTP`
- `CapitalCom.Transport.WS`
- `CapitalCom.Auth.Encryption`
- `CapitalCom.RateLimiter`
- `CapitalCom.Error`
- `CapitalCom.Generated.*`

### `capital_com_strategy`
Core modules:
- `CapitalComStrategy.Runtime`
- `CapitalComStrategy.Strategy` (behavior)
- `CapitalComStrategy.Engine.Live`
- `CapitalComStrategy.Engine.Paper`
- `CapitalComStrategy.Engine.Replay`
- `CapitalComStrategy.Execution`
- `CapitalComStrategy.Portfolio`
- `CapitalComStrategy.Risk`
- `CapitalComStrategy.Store` behavior (+ adapters)

## 6) Public API Shape
### SDK API style
- Typed request and response structs for all public calls.
- Return convention: `{:ok, typed_struct}` or `{:error, %CapitalCom.Error{}}`.

### Strategy authoring API
User strategy modules implement:
- `init/1`
- `on_market_event/2`
- `on_fill/2`
- `on_risk_event/2`

Runtime modes in V1:
- `:live`
- `:paper`
- `:replay`

## 7) Delivery Phases

### Phase 1: Foundation and Skeleton
Objective:
- Establish umbrella and stable boundaries.

Implementation tasks:
1. Initialize umbrella apps and shared code style/test setup.
2. Add base dependencies (`req`, `finch`, `jason`, websocket client, telemetry libs).
3. Define global config structs and shared error base module.
4. Add minimal supervision trees for both main apps.

Deliverables:
- Compiling umbrella with clear app boundaries.
- Baseline CI/test workflow.

Exit criteria:
- `mix test` baseline passes from clean clone.

### Phase 2: OpenAPI Pinning and Codegen Pipeline
Objective:
- Make endpoint coverage maintainable and reproducible.

Implementation tasks:
1. Pin a known OpenAPI snapshot into `priv/openapi`.
2. Build generator in `tools/openapi_codegen`.
3. Generate low-level endpoint + schema modules into `CapitalCom.Generated.*`.
4. Add CI check to fail on stale generated output.
5. Document generated-vs-handwritten ownership.

Deliverables:
- Deterministic generation command and outputs.

Exit criteria:
- Fresh run of generator produces no diff when repo is up to date.

### Phase 3: REST Core SDK Modules
Objective:
- Implement full REST API surface with strict typed API.

Implementation tasks:
1. Implement client process and shared request pipeline.
2. Implement endpoint families: Session, Accounts, History, Trading, Positions, Orders, Markets, Prices, Sentiment, Watchlists, General.
3. Add request validation for endpoint-specific constraints (e.g. epics max, date formats).
4. Implement typed `dealReference` confirmation helper.

Deliverables:
- Full typed REST coverage.

Exit criteria:
- All REST families have passing mocked integration tests.

### Phase 4: Reliability Layer (Session, Retry, Throttle)
Objective:
- Production-safe behavior under auth churn and rate limits.

Implementation tasks:
1. Implement centralized retry policy with jittered backoff and retry classification.
2. Implement route-aware throttling (`/session`, trading creation routes).
3. Implement token lifecycle manager (refresh-before-expiry + re-auth on 401).
4. Map API/transport failures to structured `CapitalCom.Error` taxonomy.
5. Emit telemetry for request latency, retries, refreshes, throttling.

Deliverables:
- Robust transport/session middleware stack.

Exit criteria:
- 401/429 tests and concurrent-client auth tests pass.

### Phase 5: WebSocket Core
Objective:
- Provide resilient streaming API with typed events.

Implementation tasks:
1. Implement websocket connection process and lifecycle supervision.
2. Implement subscribe/unsubscribe for quote and OHLC streams.
3. Implement heartbeat ping scheduler and timeout handling.
4. Implement reconnect + re-subscribe logic.
5. Handle stream reset behavior when account switches.

Deliverables:
- Stable stream API with subscription handles and typed event decoding.

Exit criteria:
- Disconnect/reconnect and keepalive tests pass.

### Phase 6: Strategy Runtime Core (Live, Paper, Replay)
Objective:
- Execute behavior-based strategies in 3 modes.

Implementation tasks:
1. Implement strategy behavior contract and validation helpers.
2. Build runtime supervisor/event loop.
3. Implement broker adapter interface + Capital.com broker adapter.
4. Implement paper execution engine with fill simulation rules.
5. Implement replay engine using historical candles and deterministic clock.
6. Implement execution state machine: signal -> risk -> order intent -> place -> confirm/fill -> portfolio update.

Deliverables:
- Runnable strategy runtime for live, paper, replay.

Exit criteria:
- Same sample strategy runs in all three modes.

### Phase 7: Advanced Portfolio Risk Engine
Objective:
- Enforce advanced risk constraints before and after execution.

Implementation tasks:
1. Define composable risk policy behavior.
2. Implement policies for max size, gross/net exposure, leverage.
3. Implement advanced policies for drawdown, daily loss, group/correlation exposure caps.
4. Add kill switch and cool-down controls.
5. Record auditable risk decisions/events in runtime state/store.

Deliverables:
- Policy engine with default advanced policy pack.

Exit criteria:
- Breach scenarios deterministically block or halt execution.

### Phase 8: Hardening, Packaging, and Release
Objective:
- Ship two reliable Hex packages.

Implementation tasks:
1. Expand full test matrix (unit/integration/e2e/replay determinism).
2. Add examples app with runnable strategies and mode demos.
3. Write docs: quickstart, architecture, operational guidance, failure modes.
4. Configure Hex metadata and release automation for both packages.
5. Define versioning and compatibility policy.

Deliverables:
- Publish-ready `capital_com` and `capital_com_strategy`.

Exit criteria:
- CI green, docs validated, release dry-run succeeds.

## 8) Testing Strategy
- Unit tests: validation, encryption, throttling, retries, risk policies.
- Integration tests: mocked REST and WebSocket protocol behavior.
- Runtime tests: state machine transitions and store behavior.
- Replay tests: deterministic outcomes for same input/time settings.
- E2E tests: one representative strategy in live-like dry run, paper, and replay modes.

## 9) Non-Functional Requirements
- Reliability: no auth storms, bounded retries, route-aware throttling.
- Maintainability: deterministic generation + clear handwritten boundary.
- Observability: telemetry spans/events for transport/runtime/risk.
- Security: no hardcoded secrets, avoid persistent plaintext credential storage.
- API clarity: strict typed public interfaces and stable error contracts.

## 10) Implementation Defaults
- Elixir 1.17+, OTP 27+.
- HTTP: Req + Finch.
- JSON: Jason.
- WebSocket: supervised websocket client process.
- Internal time normalization: UTC.

## 11) Initial Agent Work Order
1. Create umbrella skeleton and app boundaries.
2. Pin OpenAPI spec and implement deterministic codegen.
3. Implement core transport + session + errors first.
4. Implement full REST service modules.
5. Add retry/throttle/token lifecycle.
6. Implement WebSocket with reconnect and re-subscribe.
7. Build strategy runtime (live/paper/replay).
8. Add advanced risk policy engine.
9. Finish docs, examples, tests, and release automation.

## Sources
- Capital.com API Development Guide: https://capital.com/api-development-guide
- Capital.com OpenAPI Reference: https://open-api.capital.com/
- softwaredevelop/capitalcom: https://github.com/softwaredevelop/capitalcom
- Akinzou/CapitalCom: https://github.com/Akinzou/CapitalCom
- tunga3109/python-capitalcom: https://github.com/tunga3109/python-capitalcom
- gromson/capitalcom: https://github.com/gromson/capitalcom
- AvishekInvincible/CAPITALCOM: https://github.com/AvishekInvincible/CAPITALCOM
