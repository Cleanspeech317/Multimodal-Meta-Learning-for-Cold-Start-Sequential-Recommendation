# $1 args_range  $2 type

args_range=$1
type=$2

city_list="shanghai hangzhou changsha lanzhou"
echo "          R@5    R@10   R@20    M@5    M@10   M@20    N@5    N@10   N@20"
for city in $city_list
do
    printf "%-10s\n" $city
    for args in $args_range
    do
        printf "%-12s" $args
        file=output/$city/0207-exp-fusion/up/down/attention-fusion.meta-test.$type."$args".log
        if [[ -f $file ]]
        then
            tail $file -n 2 | head -n 1 | sed -E 's/\)|\]|\}//g' | awk -F',' '{ printf("%.4f %.4f %.4f  %.4f %.4f %.4f  %.4f %.4f %.4f\n", $2, $4, $6, $8, $10, $12, $14, $16, $18) }'
        else
            echo
        fi
    done
done

