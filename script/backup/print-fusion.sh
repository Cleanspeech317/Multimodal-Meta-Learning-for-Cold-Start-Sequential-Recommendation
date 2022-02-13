# $1 city  $2 weight_list  $3 type

city=$1
weight_list=$2
type=$3


file=output/$city/0121-exp/up-/down-/SASRec.$type.log
echo -ne "SASRec\t"
tail $file -n 4 | head -n 1 | sed -E 's/\)|\]//g' | awk -F',' '{ printf("\t%.4f %.4f %.4f %.4f %.4f\t", $2, $4, $6, $8, $10) }'
tail $file -n 2 | head -n 1 | sed -E 's/\)|\]//g' | awk -F',' '{ printf("\t%.4f %.4f %.4f %.4f %.4f\t", $2, $4, $6, $8, $10) }'
echo

for weight in $weight_list
do
    echo -n "weight $weight"
    file=output/$city/0121-exp/up-/down-/fusion-$weight.$type.log
    if [ -f $file ]
    then
        tail $file -n 4 | head -n 1 | sed -E 's/\)|\]//g' | awk -F',' '{ printf("\t%.4f %.4f %.4f %.4f %.4f\t", $2, $4, $6, $8, $10) }'
        tail $file -n 2 | head -n 1 | sed -E 's/\)|\]//g' | awk -F',' '{ printf("\t%.4f %.4f %.4f %.4f %.4f\t", $2, $4, $6, $8, $10) }'
    fi
    echo ""
done
