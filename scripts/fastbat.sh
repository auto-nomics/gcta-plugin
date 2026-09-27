set -eu

# Official GCTA-fastBAT 1.95.3 with the official GCTA hg19 gene list and
# the 1000G EUR Phase3 PLINK LD reference.

gcta64 \
  --bfile "/panels/plink_ref/1000G.EUR.QC.${GCTA_CHR}" \
  --chr "$GCTA_CHR" \
  --maf "$GCTA_MAF" \
  --fastBAT "$AUTONOMICS_INPUT0" \
  --fastBAT-gene-list /panels/gene_list/glist-hg19.txt \
  --fastBAT-wind "$GCTA_GENE_FLANK_KB" \
  --fastBAT-ld-cutoff "$GCTA_LD_CUTOFF" \
  --diff-freq "$GCTA_DIFF_FREQ" \
  --thread-num "$GCTA_THREAD_NUM" \
  --out "$AUTONOMICS_WORKDIR/gcta_fastbat" \
  > "$AUTONOMICS_OUTPUT1" 2>&1

test -s "$AUTONOMICS_OUTPUT0"
