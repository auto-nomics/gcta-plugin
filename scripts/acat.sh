set -eu

# Official GCTA ACAT-V 1.95.3. No LD reference is required; the official
# GCTA hg19 gene list is bound through the family panel set. GCTA writes
# the raw result next to --out; the legacy wrapper moved it onto output
# port 0 the same way.

gcta64 \
  --acat \
  --snp-list "$AUTONOMICS_INPUT0" \
  --gene-list /panels/gene_list/glist-hg19.txt \
  --max-maf "$GCTA_MAX_MAF" \
  --min-mac "$GCTA_MIN_MAC" \
  --wind "$GCTA_GENE_FLANK_KB" \
  --out "$AUTONOMICS_WORKDIR/gcta_acat_raw" \
  > "$AUTONOMICS_OUTPUT1" 2>&1

test -s "$AUTONOMICS_WORKDIR/gcta_acat_raw"
mv "$AUTONOMICS_WORKDIR/gcta_acat_raw" "$AUTONOMICS_OUTPUT0"
