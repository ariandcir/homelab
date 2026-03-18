# firewall module

Provider-agnostic interface module for firewall policy intent.

## Inputs

- `name`: logical firewall policy name
- `network_id`: logical network id from the network module
- `rules`: allow/deny rule definitions
- `tags`: common tags

## Outputs

- `firewall_spec`: normalized desired firewall spec
- `firewall_policy_id`: logical identifier for cross-module wiring

## Notes

This module intentionally does not create provider resources directly.
