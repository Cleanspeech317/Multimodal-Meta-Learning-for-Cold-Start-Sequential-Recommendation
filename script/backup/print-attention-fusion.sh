# $1 city  $2 type

city=$1
type=$2

if [[ "$type" == "" ]]
then
    type="meta-test"
fi

file=output/$city/0121-exp/up-/down-/attention-fusion.$type.log
if [ -f $file ]
then
    tail $file -n 4 | head -n 1 | sed -E 's/\)|\]//g' | awk -F',' '{ printf("%.4f %.4f %.4f %.4f %.4f\t", $2, $4, $6, $8, $10) }'
    tail $file -n 2 | head -n 1 | sed -E 's/\)|\]//g' | awk -F',' '{ printf("%.4f %.4f %.4f %.4f %.4f\n", $2, $4, $6, $8, $10) }'
else
    echo ""
fi

# model=$2
# type=$3
# up_lr_list=$4
# down_lr_list=$5

# for j in $up_lr_list
# do
#     echo "up $j"
#     for i in $down_lr_list
#     do
#         echo -n "down $i "
#         file=output/$city/0121-exp-$j/up-/down-/$model.$type.$i.log
#         # file=output/$city/0121-exp-2022-$j/up-/down-/$model.$type.$i.log
#         if [ -f $file ]
#         then
#             tail $file -n 4 | head -n 1 | sed -E 's/\)|\]//g' | awk -F',' '{ printf("%.4f %.4f %.4f %.4f %.4f\t", $2, $4, $6, $8, $10) }'
#             tail $file -n 2 | head -n 1 | sed -E 's/\)|\]//g' | awk -F',' '{ printf("%.4f %.4f %.4f %.4f %.4f\n", $2, $4, $6, $8, $10) }'
#         else
#             echo ""
#         fi
#     done
# done
