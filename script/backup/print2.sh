# $1 city  $2 split_ratio

log_dir=output/$1/$2

echo ' recall@10 mrr@10 ndcg@10 hit@10 precision@10'
echo -n 'SASRec '
tail $log_dir/SASRec.complement.log -n 1 | sed -E 's/\)|\]//g' | awk -F',' '{ printf("%.4f %.4f %.4f %.4f %.4f\n", $2, $4, $6, $8, $10) }'
echo -n 'trans '
tail $log_dir/trans.log -n 2 | head -n 1 | sed -E 's/\)|\]//g' | awk -F',' '{ printf("%.4f %.4f %.4f %.4f %.4f\n", $2, $4, $6, $8, $10) }'
echo -n 'meta '
tail $log_dir/meta-test.log -n 2 | head -n 1 | sed -E 's/\)|\]//g' | awk -F',' '{ printf("%.4f %.4f %.4f %.4f %.4f\n", $2, $4, $6, $8, $10) }'

user_num=`grep 'The number of users:' $log_dir/meta-test.log | awk '{ print $5 }'`
item_num=`grep 'The number of items:' $log_dir/meta-test.log | awk '{ print $5 }'`
inter_num=`grep 'The number of inters:' $log_dir/meta-test.log | awk '{ print $5 }'`
user_inter_num=`grep 'Average actions of users:' $log_dir/meta-test.log | awk '{ printf("%.4f", $5) }'`
item_inter_num=`grep 'Average actions of items:' $log_dir/meta-test.log | awk '{ printf("%.4f", $5) }'`
sparsity=`grep 'The sparsity of the dataset:' $log_dir/meta-test.log | awk '{ printf("%.2f%%", $6) }'`
echo "#User #Item #Inter #Inter/User #Inter/Item Sparsity"
echo $user_num $item_num $inter_num $user_inter_num $item_inter_num $sparsity