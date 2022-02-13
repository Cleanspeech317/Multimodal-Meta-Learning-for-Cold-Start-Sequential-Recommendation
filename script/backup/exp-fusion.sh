# $1 city  $2 city_id  $3 up_interval  $4 down_interval  $5 gpu_id

city=$1
city_id=$2
up_interval=$3
down_interval=$4
gpu_id=$5

# up_log_dir=output/$city/0112-exp/up-${up_interval}
up_log_dir=output/$city/0119-exp/up-${up_interval}
down_log_dir=$up_log_dir/down-${down_interval}

sasrec_yaml_file="'yamls/pretrain.yaml','yamls/meta-learing.yaml','yamls/SASRec.yaml'"
sasrecfeat_yaml_file="'yamls/pretrain.yaml','yamls/meta-learing.yaml','yamls/SASRecFeat.yaml'"

sasrec_up_log=$up_log_dir/SASRec.up.log
sasrec_meta_train_log=$up_log_dir/SASRec.meta-train.log

sasrecfeat_up_log=$up_log_dir/SASRecFeat.up.log
sasrecfeat_meta_train_log=$up_log_dir/SASRecFeat.meta-train.log

meta_test_log=$down_log_dir/fusion-1-9.meta-test.log
trans_log=$down_log_dir/fusion-1-9.trans.log

sasrec_meta_file=`tail $sasrec_meta_train_log -n 3 | head -n 1 | awk '{ print $7 }'`
sasrec_trans_file=`tail $sasrec_up_log -n 4 | head -n 1 | awk '{ print $11 }'`

sasrecfeat_meta_file=`tail $sasrecfeat_meta_train_log -n 3 | head -n 1 | awk '{ print $7 }'`
sasrecfeat_trans_file=`tail $sasrecfeat_up_log -n 4 | head -n 1 | awk '{ print $11 }'`

python run_meta_fusion_test.py --dataset=pretrain --model_list="['SASRec', 'SASRecFeat']" --config_files="[[$sasrec_yaml_file],[$sasrecfeat_yaml_file]]" --val_interval="{'cityid': ['$city_id']}" --data_source=down --downstream_user_inter_num_interval=$down_interval --model_file="['$sasrec_meta_file','$sasrecfeat_meta_file']" --fusion_weight="[0.1,0.9]" --epochs=50 --gpu_id=$gpu_id --hint="meta $city fusion test" &> $meta_test_log &
sleep 10
python run_meta_fusion_test.py --dataset=pretrain --model_list="['SASRec', 'SASRecFeat']" --config_files="[[$sasrec_yaml_file],[$sasrecfeat_yaml_file]]" --val_interval="{'cityid': ['$city_id']}" --data_source=down --downstream_user_inter_num_interval=$down_interval --model_file="['$sasrec_trans_file','$sasrecfeat_trans_file']" --fusion_weight="[0.1,0.9]" --epochs=50 --gpu_id=$gpu_id --hint="trans $city fusion" &> $trans_log &
wait
