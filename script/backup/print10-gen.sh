# $1 city  $2 model  $3 type  $4 up_lr_list  $5 down_lr_list  $6 item_neighbour_num_list  $7 generate_rate_list

city=$1
model=$2
type=$3
up_lr_list=$4
down_lr_list=$5
item_neighbour_num_list=$6
generate_rate_list=$7

for up_lr in $up_lr_list
do
    for neighbour_num in $item_neighbour_num_list
    do
        for generate_rate in $generate_rate_list
        do
            echo "up $up_lr, neighbour_num = $neighbour_num, generate_rate = $generate_rate"
            for down_lr in $down_lr_list
            do
                echo -n "down $down_lr "
                file=output/$city/0121-exp-$up_lr/up-/down-/$model.$type.$down_lr.IEGM.${neighbour_num}-neighbour.${generate_rate}-rate.log
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
done
