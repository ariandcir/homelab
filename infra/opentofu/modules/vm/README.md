# vm module

Provider-agnostic interface module for virtual machine intent.

## Inputs

- `instances`: map of VM definitions
- `tags`: common tags

## Outputs

- `vm_spec`: normalized desired VM spec
- `vm_ids`: logical identifiers keyed by VM name

## Notes

This module intentionally does not create provider resources directly.
