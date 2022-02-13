# $1 model

model=$1

city_list="shanghai hangzhou changsha lanzhou"
echo "          R@5    R@10   R@20    M@5    M@10   M@20    N@5    N@10   N@20"
for city in $city_list
do
    printf "%-10s" $city
    tail output/$city/0207-exp-fusion/up/down/$model.down.hyper -n 1 | sed -E 's/\)|\]|\}//g' | awk -F',' '{ printf("%.4f %.4f %.4f  %.4f %.4f %.4f  %.4f %.4f %.4f\t", $22, $24, $26, $28, $30, $32, $34, $36, $38) }'
    tail output/$city/0207-exp-fusion/up/down/$model.down.hyper -n 3 | head -n 1 | awk -F'[\\{\\}]' '{ printf("%s\n", $2) }'
done

