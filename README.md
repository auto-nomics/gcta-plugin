# gcta plugin

Migrated from the legacy `gcta_container` wrapper
(`crates/node-bundles/nodes-io/src/gcta_container.rs`) in the autonomics
workspace. One directory = one plugin family = one git-able unit: FOUR
node kinds share one image and one panel pair, exactly like the ldsc
pilot but with four `[[nodes]]` entries.

## Provenance

- Image: official GCTA 1.95.3 Linux (released 2026-07-10), AppImage
  extracted at build time (asset sha256
  `441e01715bc12dabb083fe76372432139dff9bb2c073d21d218d15e92580e807`).
  The `Dockerfile` moved verbatim from `containers/gcta/`. MIT for the
  official executable (upstream source is GPL-3.0-or-later).
- Panels:
  - `wjixiang/catalog-plink-ref-1000g-eur-binary` mounted at
    `/panels/plink_ref` (1000G EUR Phase3 PLINK binary reference;
    checksummed staging lives in `test_gcta_containers.sh`)
  - `wjixiang/catalog-gcta-gene-list-hg19` mounted at `/panels/gene_list`
    (official GCTA hg19 gene list)
- Published reference:
  `ghcr.io/auto-nomics/autonomics/gcta@sha256:4cbf8c91376f7b314eebf1dfa02ad44028575991cd3d4c4e81b5324942bec20b`
  (display tag `1.95.3`).

## Layout

- `manifest.toml` — four `[[nodes]]`: `gcta_cojo_select`, `gcta_sblup`,
  `gcta_fastbat`, `gcta_acat` (legacy `_container` suffix stripped)
- `scripts/cojo.sh`, `scripts/sblup.sh`, `scripts/fastbat.sh`,
  `scripts/acat.sh` — one execution script per variant, referenced
  relatively and inlined by the loader at startup
- `Dockerfile`, `test_gcta_containers.sh`, `fixtures/` — image build
  tree moved from `containers/gcta/`. The fixtures (`chr22.ma`,
  `chr22.fastGWA`) were referenced by no live Rust test at migration
  time; they are kept for image smoke/e2e validation.

## Install

```sh
export AUTONOMICS_PLUGIN_ROOT=/mnt/projects/node-plugins
cargo test -p container-plugin --test gcta_migration   # golden parity
```

## Migration parity

The golden test
(`crates/container-plugin/tests/gcta_migration.rs`) compiles each
`[[nodes]]` entry and compares the result against the legacy wrapper's
`container_spec`.

Byte-exact: image reference, output paths + formats, timeout (3600 for
every variant, the legacy `DEFAULT_TIMEOUT_SECS`), artifact_prefix,
network/read-only-rootfs/pull-policy, mount paths, and every env default
(maf 0.01, cojo_p 5e-8, cojo_wind_kb 10000/1000, cojo_collinear 0.9,
diff_freq 0.2, thread_num 1, gene_flank_kb 50/0, ld_cutoff 0.9,
max_maf 0.01, min_mac 20).

Semantic (documented deltas):

1. **Panels are family-wide.** The v0 DSL binds panels per plugin, not
   per node, so every node compiles with both panels. The legacy wrapper
   attached only what each analysis read (plink_ref for
   cojo_select/sblup, both for fastbat, gene_list only for acat). The
   plugin contract is the documented superset — same precedent as
   `ldsc_munge` — and `fastbat` is byte-identical to legacy. Runtime
   consequence: all four kinds now declare both DataBundle bindings, so
   DAGs must bind both panels for any gcta node.
2. **`command` is `["sh"]`, not legacy `["sh", "-c"]`.** The runtime
   materializes the script to a file and inserts it at argv[1]; the
   legacy trailing `-c` only ever served as `$0`. Execution semantics
   are unchanged.
3. **Float rendering is serde_json/ryu, not Rust `format!`.** `5e-8`
   renders `"5e-8"` (identical to the legacy `{:e}`); `1.33e6` renders
   `"1330000.0"` where legacy produced `"1.33e6"` — the same f64 after
   parsing, and GCTA accepts both spellings.
4. **No gzip handling.** Unlike ldsc, the legacy GCTA wrapper never
   decompressed inputs, so the scripts consume `$AUTONOMICS_INPUT0`
   directly.
5. **`artifact_prefix` is family-shared** `/artifacts/gcta_container` on
   all four nodes — that was the legacy `default_prefix()` for every
   variant, so per-kind prefixes would have broken byte parity.
6. **`timeout_secs` and `artifact_prefix` are manifest-fixed** at the
   legacy defaults; the legacy spec made them per-node params, which the
   plugin DSL does not expose.
7. **Validation moved to the param schema.** Legacy `validate_*` ranges
   map to JSON-Schema bounds: chr 1..=22 (required), lambda > 0
   (required, sblup), maf/max_maf in (0, 0.5], cojo_p in (0, 1],
   cojo_collinear in (0, 1), diff_freq in (0, 1], ld_cutoff in (0, 1],
   cojo_wind_kb/gene_flank_kb (cojo/fastbat)/min_mac >= 1,
   thread_num 1..=1024. The sblup window keeps the legacy param name
   `cojo_wind_kb` (default 1000, distinct from cojo_select's 10000).
8. **Kinds dropped the `_container` suffix**; DAG specs referencing the
   old kinds must be regenerated.

Official CLI tokens are preserved verbatim in the scripts: `gcta64` with
`--bfile /panels/plink_ref/1000G.EUR.QC.<chr>`, `--chr`, `--maf`,
`--cojo-file`, `--cojo-slct`, `--cojo-p`, `--cojo-wind`,
`--cojo-collinear`, `--diff-freq`, `--thread-num`, `--cojo-sblup`,
`--fastBAT`, `--fastBAT-gene-list /panels/gene_list/glist-hg19.txt`,
`--fastBAT-wind`, `--fastBAT-ld-cutoff`, `--acat`, `--snp-list`,
`--gene-list`, `--max-maf`, `--min-mac`, `--wind`, `--out`.
