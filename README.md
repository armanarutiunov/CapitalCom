# CapitalCom Umbrella

This repository implements the V1 plan in `PLAN.md` as an Elixir umbrella with three apps:

- `apps/capital_com`: typed SDK core, generated endpoint catalog, transport/session/rate limiting primitives.
- `apps/capital_com_strategy`: strategy runtime with live/paper/replay engines and risk pipeline.
- `apps/capital_com_examples`: minimal examples app boundary.

## API source notes
The OpenAPI snapshot is pinned at `priv/openapi/capital_openapi.json` and was extracted from https://open-api.capital.com/.
The API development guide at https://capital.com/api-development-guide is the source for operational constraints (token TTL, session pacing, websocket limits).

## Deterministic codegen

Generate endpoint catalog:

```bash
./tools/openapi_codegen/generate.py
```

Verify generated files are up to date:

```bash
./tools/openapi_codegen/check_codegen.sh
```

Generated output ownership:

- Generated: `apps/capital_com/lib/capital_com/generated/*`
- Handwritten service/runtime modules: all other `apps/*/lib/*`
