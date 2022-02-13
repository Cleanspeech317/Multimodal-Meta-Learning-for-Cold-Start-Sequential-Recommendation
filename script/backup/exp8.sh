# $1 model  $2 city  $3 city_id  $4 up_interval  $5 down_interval  $6 gpu_id

model=$1
city=$2
city_id=$3
up_interval=$4
down_interval=$5
gpu_id=$6

up_log_dir=output/$city/0120-exp/up-${up_interval}
down_log_dir=$up_log_dir/down-${down_interval}

if [ ! -d $up_log_dir ]
then
    mkdir -p $up_log_dir
fi
if [ ! -d $down_log_dir ]
then
    mkdir -p $down_log_dir
fi

up_yaml_file="--config_files=yamls/pretrain.yaml,yamls/$model/pretrain.yaml"
meta_train_yaml_file="--config_files=yamls/pretrain.yaml,yamls/$model/meta-train.yaml"
down_yaml_file="--config_files=yamls/pretrain.yaml,yamls/$model/down.yaml"
meta_test_yaml_file="--config_files=yamls/pretrain.yaml,yamls/$model/meta-test.yaml"
trans_yaml_file="--config_files=yamls/pretrain.yaml,yamls/$model/trans.yaml"

up_log=$up_log_dir/$model.up.log
meta_train_log=$up_log_dir/$model.meta-train.log
down_log=$down_log_dir/$model.down.log
meta_test_log=$down_log_dir/$model.meta-test.log
trans_log=$down_log_dir/$model.trans.log

python run_recbole.py --dataset=pretrain --model=$model $up_yaml_file --val_interval="{'cityid': ['$city_id']}" --data_source=up --upstream_user_inter_num_interval=$up_interval --gpu_id=$gpu_id --hint="$city up" &> $up_log &
sleep 10
python run_meta_train.py --dataset=pretrain --model=$model $meta_train_yaml_file --val_interval="{'cityid': ['$city_id']}" --data_source=up --upstream_user_inter_num_interval=$up_interval --gpu_id=$gpu_id --hint="meta $city train" &> $meta_train_log &
wait

meta_file=`tail $meta_train_log -n 3 | head -n 1 | awk '{ print $7 }'`
trans_file=`tail $up_log -n 4 | head -n 1 | awk '{ print $11 }'`

python run_recbole.py --dataset=pretrain --model=$model $down_yaml_file --val_interval="{'cityid': ['$city_id']}" --data_source=down --downstream_user_inter_num_interval=$down_interval --gpu_id=$gpu_id --hint="$city down" &> $down_log &
sleep 10
python run_meta_test.py --dataset=pretrain --model=$model $meta_test_yaml_file --val_interval="{'cityid': ['$city_id']}" --data_source=down --downstream_user_inter_num_interval=$down_interval --model_file=$meta_file --gpu_id=$gpu_id --hint="meta $city test" &> $meta_test_log &
sleep 10
python run_meta_test.py --dataset=pretrain --model=$model $trans_yaml_file --val_interval="{'cityid': ['$city_id']}" --data_source=down --downstream_user_inter_num_interval=$down_interval --model_file=$trans_file --gpu_id=$gpu_id --hint="trans $city" &> $trans_log &
wait
