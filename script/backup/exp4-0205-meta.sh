# $1 city  $2 up_lr  $3 down_lr  $4 gpu_id
city=$1
up_lr=$2
down_lr=$3
gpu_id=$4
up_log_dir=output/$city/0121-exp-$up_lr/up-
down_log_dir=$up_log_dir/down-
meta_test_yaml_file="--config_files=yamls/pretrain.yaml,yamls/$city/img/meta-test.yaml"
meta_train_log=$up_log_dir/img.meta-train.log
meta_test_log=$down_log_dir/img.meta-test.$down_lr.log
meta_file=`tail $meta_train_log -n 3 | head -n 1 | awk '{ print $7 }'`
python run_meta_test.py --learning_rate=$down_lr --model=SASRecFeat --dataset=$city $meta_test_yaml_file --model_file=$meta_file --gpu_id=$gpu_id --hint="meta $city test" &> $meta_test_log &
wait