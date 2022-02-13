# $1 city  $2 up_interval

city=$1
up_interval=$2

log_dir=output/$city/0112-exp/up-$up_interval

sasrec_up_log=$log_dir/SASRec.up.log
sasrec_down_log=$log_dir/SASRec.down.log
meta_train_log=$log_dir/SASRec.meta-train.log
meta_test_log=$log_dir/SASRec.meta-test.log
trans_log=$log_dir/SASRec.trans.log

echo ' recall@10 mrr@10 ndcg@10 hit@10 precision@10'
echo -n 'SASRec '
tail $sasrec_down_log -n 1 | sed -E 's/\)|\]//g' | awk -F',' '{ printf("%.4f %.4f %.4f %.4f %.4f\n", $2, $4, $6, $8, $10) }'
echo -n 'trans '
tail $trans_log -n 2 | head -n 1 | sed -E 's/\)|\]//g' | awk -F',' '{ printf("%.4f %.4f %.4f %.4f %.4f\n", $2, $4, $6, $8, $10) }'
echo -n 'meta '
tail $meta_test_log -n 2 | head -n 1 | sed -E 's/\)|\]//g' | awk -F',' '{ printf("%.4f %.4f %.4f %.4f %.4f\n", $2, $4, $6, $8, $10) }'


user_num=`grep 'The number of users:' $sasrec_up_log | awk '{ print $5 }'`
item_num=`grep 'The number of items:' $sasrec_up_log | awk '{ print $5 }'`
inter_num=`grep 'The number of inters:' $sasrec_up_log | awk '{ print $5 }'`
user_inter_num=`grep 'Average actions of users:' $sasrec_up_log | awk '{ printf("%.4f", $5) }'`
item_inter_num=`grep 'Average actions of items:' $sasrec_up_log | awk '{ printf("%.4f", $5) }'`
sparsity=`grep 'The sparsity of the dataset:' $sasrec_up_log | awk '{ printf("%.2f%%", $6) }'`
echo Upstream data info
echo "#User #Item #Inter #Inter/User #Inter/Item Sparsity"
echo $user_num $item_num $inter_num $user_inter_num $item_inter_num $sparsity

user_num=`grep 'The number of users:' $sasrec_down_log | awk '{ print $5 }'`
item_num=`grep 'The number of items:' $sasrec_down_log | awk '{ print $5 }'`
inter_num=`grep 'The number of inters:' $sasrec_down_log | awk '{ print $5 }'`
user_inter_num=`grep 'Average actions of users:' $sasrec_down_log | awk '{ printf("%.4f", $5) }'`
item_inter_num=`grep 'Average actions of items:' $sasrec_down_log | awk '{ printf("%.4f", $5) }'`
sparsity=`grep 'The sparsity of the dataset:' $sasrec_down_log | awk '{ printf("%.2f%%", $6) }'`
echo Downstream data info
echo "#User #Item #Inter #Inter/User #Inter/Item Sparsity"
echo $user_num $item_num $inter_num $user_inter_num $item_inter_num $sparsity