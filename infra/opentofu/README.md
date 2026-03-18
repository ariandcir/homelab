# OpenTofu layout

This directory contains provider-agnostic interfaces and environment compositions.

- `modules/cluster_interface` exposes an interface contract for cluster-adjacent infrastructure.
- `environments/lab` wires module inputs for the home-lab environment.

> TODO: Add concrete provider implementation modules only for providers with stable APIs.
