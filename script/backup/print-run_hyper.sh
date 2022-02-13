# $1 model

model=$1

city_list="shanghai hangzhou changsha lanzhou"
for city in $city_list
do
    printf "%-10s" $city
    tail output/$city/0121-exp-down/up-/down-/$model.down.hyper -n 1 | sed -E 's/\)|\]//g' | awk -F',' '{ printf("%.4f %.4f %.4f\t%.4f %.4f %.4f\t", $4, $6, $8, $14, $16, $18) }'
    tail output/$city/0121-exp-down/up-/down-/$model.down.hyper -n 3 | head -n 1
done

