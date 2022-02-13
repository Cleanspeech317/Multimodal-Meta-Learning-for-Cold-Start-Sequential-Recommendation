# $1 model  $2 city  $3 city_id  $4 up_interval  $5 down_interval  $6 gpu_id  $7 up_lr

model=$1
city=$2
city_id=$3
up_interval=$4
down_interval=$5
gpu_id=$6
up_lr=$7

# up_log_dir=output/$city/0112-exp/up-${up_interval}
# up_log_dir=output/$city/0119-exp$up_lr/up-${up_interval}
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

base_yaml_file="--config_files=yamls/pretrain.yaml,yamls/$model.yaml"
meta_yaml_file="--config_files=yamls/pretrain.yaml,yamls/meta-learing.yaml,yamls/$model.yaml"

up_log=$up_log_dir/$model.up.log
meta_train_log=$up_log_dir/$model.meta-train.log
down_log=$down_log_dir/$model.down.log

python run_recbole.py --learning_rate=${up_lr}e-3 --dataset=pretrain --model=$model $base_yaml_file --val_interval="{'cityid': ['$city_id']}" --data_source=up --upstream_user_inter_num_interval=$up_interval --learner=sgd --eval_args="{'split': {'LS': 'test_only'}, 'order': 'TO', 'mode': 'full', 'group_by': 'user'}" --epochs=100 --gpu_id=$gpu_id --hint="$city up" &> $up_log &
sleep 10
python run_meta_train.py --learning_rate=${up_lr}e-3 --dataset=pretrain --model=$model $meta_yaml_file --val_interval="{'cityid': ['$city_id']}" --data_source=up --upstream_user_inter_num_interval=$up_interval --local_learner=sgd --meta_epochs=10 --num_local_update=5 --gpu_id=$gpu_id --hint="meta $city train" &> $meta_train_log &
wait

meta_file=`tail $meta_train_log -n 3 | head -n 1 | awk '{ print $7 }'`
trans_file=`tail $up_log -n 4 | head -n 1 | awk '{ print $11 }'`

python run_recbole.py --learning_rate=${up_lr}e-3 --dataset=pretrain --model=$model $base_yaml_file --val_interval="{'cityid': ['$city_id']}" --data_source=down --downstream_user_inter_num_interval=$down_interval --learner=sgd --epochs=100 --gpu_id=$gpu_id --hint="$city down" &> $down_log &
sleep 10

for ((i=1;i<=100;i=i+(i<10?1:10)))
do
    meta_test_log=$down_log_dir/$model.meta-test.$i.log
    trans_log=$down_log_dir/$model.trans.$i.log
    python run_meta_test.py --learning_rate=${i}e-3 --dataset=pretrain --model=$model $meta_yaml_file --val_interval="{'cityid': ['$city_id']}" --data_source=down --downstream_user_inter_num_interval=$down_interval --learner=sgd --model_file=$meta_file --epochs=50 --gpu_id=$gpu_id --hint="meta $city test" &> $meta_test_log &
    sleep 10
    python run_meta_test.py --learning_rate=${i}e-3 --dataset=pretrain --model=$model $meta_yaml_file --val_interval="{'cityid': ['$city_id']}" --data_source=down --downstream_user_inter_num_interval=$down_interval --learner=sgd --model_file=$trans_file --epochs=50 --gpu_id=$gpu_id --hint="trans $city" &> $trans_log &
    wait
done
