# $1 city  $2 model  $3 type  $4 up_lr_list  $5 down_lr_list  $6 generate_rate_list

city=$1
model=$2
type=$3
up_lr_list=$4
down_lr_list=$5
generate_rate_list=$6

# up_lr_list="1e-3 3e-3 5e-3 7e-3 1e-2"
# down_lr_list="1e-3 3e-3 5e-3 7e-3 1e-2"
for j in $up_lr_list
do
    echo "up $j"
    for k in $generate_rate_list
    do
        echo "generate_rate = $k"
        for i in $down_lr_list
        do
            echo -n "down $i "
            file=output/$city/0121-exp-$j/up-/down-/$model.$type.$i.IEG.${k}-rate.log
            # file=output/$city/0121-exp-2022-$j/up-/down-/$model.$type.$i.log
            if [ -f $file ]
            then
                tail $file -n 4 | head -n 1 | sed -E 's/\)|\]//g' | awk -F',' '{ printf("%.4f %.4f %.4f %.4f %.4f\t", $2, $4, $6, $8, $10) }'
                tail $file -n 2 | head -n 1 | sed -E 's/\)|\]//g' | awk -F',' '{ printf("%.4f %.4f %.4f %.4f %.4f\n", $2, $4, $6, $8, $10) }'
            else
                echo ""
            fi
        done
    done
done
