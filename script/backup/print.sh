
tail output/meta-testing/$1/SASRec.log -n 1 | sed -E 's/\)|\]//g' | awk -F',' '{ printf("%.4f\t%.4f\t%.4f\t%.4f\t%.4f\n", $2, $4, $6, $8, $10) }'
tail output/meta-testing/$1/trans_bj.log -n 2 | head -n 1 | sed -E 's/\)|\]//g' | awk -F',' '{ printf("%.4f\t%.4f\t%.4f\t%.4f\t%.4f\n", $2, $4, $6, $8, $10) }'
tail output/meta-testing/$1/meta_bj.log -n 2 | head -n 1 | sed -E 's/\)|\]//g' | awk -F',' '{ printf("%.4f\t%.4f\t%.4f\t%.4f\t%.4f\n", $2, $4, $6, $8, $10) }'
