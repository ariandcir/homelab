# dns module

Provider-agnostic interface module for DNS intent.

## Inputs

- `zone`: DNS zone name
- `records`: map of desired records
- `tags`: common tags

## Outputs

- `dns_spec`: normalized desired DNS spec
- `dns_zone_id`: logical identifier for cross-module wiring

## Notes

This module intentionally does not create provider resources directly.
