set -eu

# Official GCTA 1.95.3 --cojo-sblup for one chromosome against the 1000G
# EUR Phase3 PLINK reference. Lambda comes from LDSC/GREML estimates or
# domain knowledge; the legacy wrapper documented the same requirement.

gcta64 \
  --bfile "/panels/plink_ref/1000G.EUR.QC.${GCTA_CHR}" \
  --chr "$GCTA_CHR" \
  --maf "$GCTA_MAF" \
  --cojo-file "$AUTONOMICS_INPUT0" \
  --cojo-sblup "$GCTA_LAMBDA" \
  --cojo-wind "$GCTA_COJO_WIND_KB" \
  --diff-freq "$GCTA_DIFF_FREQ" \
  --thread-num "$GCTA_THREAD_NUM" \
  --out "$AUTONOMICS_WORKDIR/gcta_sblup" \
  > "$AUTONOMICS_OUTPUT1" 2>&1

test -s "$AUTONOMICS_OUTPUT0"
