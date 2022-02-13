# $1 model  $2 city  $3 up_interval  $4 down_interval

model=$1
city=$2
up_interval=$3
down_interval=$4

up_log_dir=output/$city/0120-exp/up-${up_interval}
down_log_dir=$up_log_dir/down-${down_interval}

up_log=$up_log_dir/$model.up.log
meta_train_log=$up_log_dir/$model.meta-train.log
down_log=$down_log_dir/$model.down.log
meta_test_log=$down_log_dir/$model.meta-test.log
trans_log=$down_log_dir/$model.trans.log

echo ' recall@10 mrr@10 ndcg@10 hit@10 precision@10'
echo -n "$model "
tail $down_log -n 1 | sed -E 's/\)|\]//g' | awk -F',' '{ printf("%.4f %.4f %.4f %.4f %.4f\n", $2, $4, $6, $8, $10) }'
echo -n 'trans '
tail $trans_log -n 2 | head -n 1 | sed -E 's/\)|\]//g' | awk -F',' '{ printf("%.4f %.4f %.4f %.4f %.4f\n", $2, $4, $6, $8, $10) }'
echo -n 'meta '
tail $meta_test_log -n 2 | head -n 1 | sed -E 's/\)|\]//g' | awk -F',' '{ printf("%.4f %.4f %.4f %.4f %.4f\n", $2, $4, $6, $8, $10) }'


# user_num=`grep 'The number of users:' $up_log | awk '{ print $5 }'`
item_num=`grep 'The number of items:' $up_log | awk '{ print $5 }'`
inter_num=`grep 'The number of inters:' $up_log | awk '{ print $5 }'`
user_inter_num=`grep 'Average actions of users:' $up_log | awk '{ printf("%.4f", $5) }'`
item_inter_num=`grep 'Average actions of items:' $up_log | awk '{ printf("%.4f", $5) }'`
# sparsity=`grep 'The sparsity of the dataset:' $up_log | awk '{ printf("%.2f%%", $6) }'`
user_num=`echo $inter_num $user_inter_num | awk '{ printf("%.0f", 1.0 * $1 / $2) }'`
sparsity=`echo $inter_num $user_num $item_num | awk '{ printf("%.2f%%", 100.0 - 100.0 * $1 / $2 / $3) }'`
echo Upstream data info
echo "#User #Item #Inter #Inter/User #Inter/Item Sparsity"
echo $user_num $item_num $inter_num $user_inter_num $item_inter_num $sparsity

# user_num=`grep 'The number of users:' $down_log | awk '{ print $5 }'`
item_num=`grep 'The number of items:' $down_log | awk '{ print $5 }'`
inter_num=`grep 'The number of inters:' $down_log | awk '{ print $5 }'`
user_inter_num=`grep 'Average actions of users:' $down_log | awk '{ printf("%.4f", $5) }'`
item_inter_num=`grep 'Average actions of items:' $down_log | awk '{ printf("%.4f", $5) }'`
# sparsity=`grep 'The sparsity of the dataset:' $down_log | awk '{ printf("%.2f%%", $6) }'`
user_num=`echo $inter_num $user_inter_num | awk '{ printf("%.0f", 1.0 * $1 / $2) }'`
sparsity=`echo $inter_num $user_num $item_num | awk '{ printf("%.2f%%", 100.0 - 100.0 * $1 / $2 / $3) }'`
echo Downstream data info
echo "#User #Item #Inter #Inter/User #Inter/Item Sparsity"
echo $user_num $item_num $inter_num $user_inter_num $item_inter_num $sparsity
echo