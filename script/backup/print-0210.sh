# $1 args_range  $2 method

args_range=$1
method=$2
type_list="trans meta-test.IEG"
# method="SASRec"
# method="img"
# method="attention-fusion"
# type_list="trans meta-test.without-IEG meta-test.IEG"

city="hangzhou"
echo "          R@5    R@10   R@20    M@5    M@10   M@20    N@5    N@10   N@20"
printf "%-10s\n" $city
for type in $type_list
do
    printf "%s\n" $type
    for args in $args_range
    do
        printf "%-12s" $args
        file=output/$city/0207-exp/up/down/$method.$type.reamined_rate-"$args".log
        if [[ -f $file ]]
        then
            tail $file -n 2 | head -n 1 | sed -E 's/\)|\]|\}//g' | awk -F',' '{ printf("%.4f %.4f %.4f  %.4f %.4f %.4f  %.4f %.4f %.4f\n", $2, $4, $6, $8, $10, $12, $14, $16, $18) }'
        else
            echo
        fi
    done
    printf "%-12s" 1.0
    file=output/$city/0207-exp/up/down/$method.$type.log
    if [[ -f $file ]]
    then
        tail $file -n 2 | head -n 1 | sed -E 's/\)|\]|\}//g' | awk -F',' '{ printf("%.4f %.4f %.4f  %.4f %.4f %.4f  %.4f %.4f %.4f\n", $2, $4, $6, $8, $10, $12, $14, $16, $18) }'
    else
        echo
    fi
done

