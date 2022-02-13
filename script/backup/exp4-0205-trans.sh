# $1 city  $2 up_lr  $3 down_lr  $4 gpu_id
city=$1
up_lr=$2
down_lr=$3
gpu_id=$4
# up_log_dir=output/$city/0121-exp-$up_lr/up-
up_log_dir=output/$city/0121-exp/up-
down_log_dir=$up_log_dir/down-
trans_yaml_file="--config_files=yamls/pretrain.yaml,yamls/$city/txt/trans.yaml"
pretrain_log=$up_log_dir/txt.up.log
trans_log=$down_log_dir/txt.trans.$down_lr.log
trans_file=`tail $pretrain_log -n 4 | head -n 1 | awk '{ print $11 }'`
echo "python run_meta_test.py --model=SASRecFeat --dataset=$city $trans_yaml_file --model_file=$trans_file --gpu_id=$gpu_id"
# python run_meta_test.py --learning_rate=$down_lr --model=SASRecFeat --dataset=$city $trans_yaml_file --model_file=$trans_file --gpu_id=$gpu_id --hint="trans $city" &> $trans_log &
wait