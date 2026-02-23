#!/usr/bin/env python3
import json, pathlib
root = pathlib.Path(__file__).resolve().parents[2]
spec = json.loads((root / 'priv/openapi/capital_openapi.json').read_text())
entries = []
for path, methods in spec.get('paths', {}).items():
    for method in methods.keys():
        entries.append((method.lower(), path))
entries.sort()
lines = [
'defmodule CapitalCom.Generated.Endpoints do',
'  @moduledoc false',
'  @endpoints [',
]
for method, path in entries:
    lines.append(f'    %{{method: :{method}, path: "{path}"}},')
lines += ['  ]', '', '  def all, do: @endpoints', 'end', '']
out = root / 'apps/capital_com/lib/capital_com/generated/endpoints.ex'
out.write_text('\n'.join(lines))
print(f'Generated {out}')
