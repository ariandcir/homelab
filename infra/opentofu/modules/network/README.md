# network module

Provider-agnostic interface module for network intent.

## Inputs

- `name`: logical network name
- `cidr`: primary network CIDR
- `subnets`: map of subnet definitions
- `tags`: common tags

## Outputs

- `network_spec`: normalized desired network spec
- `network_id`: logical identifier for cross-module wiring

## Notes

This module intentionally does not create provider resources directly.
