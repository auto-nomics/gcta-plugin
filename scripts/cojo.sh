set -eu

# Official GCTA 1.95.3 --cojo-slct against the chromosome-split 1000G EUR
# Phase3 PLINK reference. All parameters travel as env values rendered by
# the plugin loader; the legacy wrapper built the same argv with Rust
# string formatting. Inputs are consumed as-is (the legacy wrapper never
# decompressed gz inputs for GCTA).

gcta64 \
  --bfile "/panels/plink_ref/1000G.EUR.QC.${GCTA_CHR}" \
  --chr "$GCTA_CHR" \
  --maf "$GCTA_MAF" \
  --cojo-file "$AUTONOMICS_INPUT0" \
  --cojo-slct \
  --cojo-p "$GCTA_COJO_P" \
  --cojo-wind "$GCTA_COJO_WIND_KB" \
  --cojo-collinear "$GCTA_COJO_COLLINEAR" \
  --diff-freq "$GCTA_DIFF_FREQ" \
  --thread-num "$GCTA_THREAD_NUM" \
  --out "$AUTONOMICS_WORKDIR/gcta_cojo" \
  > "$AUTONOMICS_OUTPUT3" 2>&1

test -s "$AUTONOMICS_OUTPUT0"
test -s "$AUTONOMICS_OUTPUT1"
