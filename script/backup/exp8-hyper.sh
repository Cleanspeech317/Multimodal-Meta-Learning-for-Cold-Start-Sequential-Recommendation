# $1 model  $2 city  $3 city_id  $4 up_interval  $5 down_interval  $6 gpu_id

model=$1
city=$2
city_id=$3
up_interval=$4
down_interval=$5
gpu_id=$6

up_lr_list="1 3 5 7 10"
for up_lr in $up_lr_list
do
    up_log_dir=output/$city/0120-exp$up_lr/up-${up_interval}
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
    meta_test_yaml_file="--config_files=yamls/pretrain.yaml,yamls/$model/meta-test.yaml"
    trans_yaml_file="--config_files=yamls/pretrain.yaml,yamls/$model/trans.yaml"

    up_log=$up_log_dir/$model.up.log
    meta_train_log=$up_log_dir/$model.meta-train.log

    python run_recbole.py --learning_rate=${up_lr}e-3 --dataset=pretrain --model=$model $up_yaml_file --val_interval="{'cityid': ['$city_id']}" --data_source=up --upstream_user_inter_num_interval=$up_interval --gpu_id=$gpu_id --hint="$city up" &> $up_log &
    sleep 10
    python run_meta_train.py --learning_rate=${up_lr}e-3 --dataset=pretrain --model=$model $meta_train_yaml_file --val_interval="{'cityid': ['$city_id']}" --data_source=up --upstream_user_inter_num_interval=$up_interval --gpu_id=$gpu_id --hint="meta $city train" &> $meta_train_log &
    wait

    meta_file=`tail $meta_train_log -n 3 | head -n 1 | awk '{ print $7 }'`
    trans_file=`tail $up_log -n 4 | head -n 1 | awk '{ print $11 }'`

    down_lr_list="1 3 5 7 10 30 50 70 100"
    for down_lr in $down_lr_list
    do
        meta_test_log=$down_log_dir/$model.meta-test.$down_lr.log
        trans_log=$down_log_dir/$model.trans.$down_lr.log
        python run_meta_test.py --learning_rate=${down_lr}e-3 --dataset=pretrain --model=$model $meta_test_yaml_file --val_interval="{'cityid': ['$city_id']}" --data_source=down --downstream_user_inter_num_interval=$down_interval --model_file=$meta_file --gpu_id=$gpu_id --hint="meta $city test" &> $meta_test_log &
        sleep 10
        python run_meta_test.py --learning_rate=${down_lr}e-3 --dataset=pretrain --model=$model $trans_yaml_file --val_interval="{'cityid': ['$city_id']}" --data_source=down --downstream_user_inter_num_interval=$down_interval --model_file=$trans_file --gpu_id=$gpu_id --hint="trans $city" &> $trans_log &
        wait
    done
done
