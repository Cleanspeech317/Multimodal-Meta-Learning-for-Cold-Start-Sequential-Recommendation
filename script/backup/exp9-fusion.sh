# $1 city  $2 SASRec_weight  $3 SASRecFeat_weight  $4 gpu_id

city=$1
sasrec_weight=$2
sasrecfeat_weight=$3
gpu_id=$4

up_log_dir=output/$city/0121-exp/up-${up_interval}
down_log_dir=$up_log_dir/down-${down_interval}

sasrec_yaml_file="'yamls/pretrain.yaml','yamls/$city/SASRec/meta-test.yaml'"
sasrecfeat_yaml_file="'yamls/pretrain.yaml','yamls/$city/SASRecFeat/meta-test.yaml'"

sasrec_up_log=$up_log_dir/SASRec.up.log
sasrec_meta_train_log=$up_log_dir/SASRec.meta-train.log

sasrecfeat_up_log=$up_log_dir/SASRecFeat.up.log
sasrecfeat_meta_train_log=$up_log_dir/SASRecFeat.meta-train.log

meta_test_log=$down_log_dir/fusion-${sasrec_weight}-${sasrecfeat_weight}.meta-test.log
trans_log=$down_log_dir/fusion-${sasrec_weight}-${sasrecfeat_weight}.trans.log

sasrec_meta_file=`tail $sasrec_meta_train_log -n 3 | head -n 1 | awk '{ print $7 }'`
sasrec_trans_file=`tail $sasrec_up_log -n 4 | head -n 1 | awk '{ print $11 }'`

sasrecfeat_meta_file=`tail $sasrecfeat_meta_train_log -n 3 | head -n 1 | awk '{ print $7 }'`
sasrecfeat_trans_file=`tail $sasrecfeat_up_log -n 4 | head -n 1 | awk '{ print $11 }'`

fusion_weight="[${sasrec_weight},${sasrecfeat_weight}]"

python run_meta_fusion_test.py --dataset=$city --model_list="['SASRec', 'SASRecFeat']" --config_files="[[$sasrec_yaml_file],[$sasrecfeat_yaml_file]]" --model_file="['$sasrec_meta_file','$sasrecfeat_meta_file']" --fusion_weight="$fusion_weight" --gpu_id=$gpu_id --hint="meta $city fusion test" &> $meta_test_log &
sleep 10
python run_meta_fusion_test.py --dataset=$city --model_list="['SASRec', 'SASRecFeat']" --config_files="[[$sasrec_yaml_file],[$sasrecfeat_yaml_file]]" --model_file="['$sasrec_trans_file','$sasrecfeat_trans_file']" --fusion_weight="$fusion_weight" --gpu_id=$gpu_id --hint="trans $city fusion" &> $trans_log &
wait
