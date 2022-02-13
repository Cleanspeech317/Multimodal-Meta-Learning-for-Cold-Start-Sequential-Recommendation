# $1 model  $1 city  $2 city_id  $3 up_interval  $4 down_interval  $5 gpu_id

model=$1
city=$2
city_id=$3
up_interval=$4
down_interval=$5
gpu_id=$6

base_yaml_file="--config_files=yamls/pretrain.yaml,yamls/$model.yaml"

echo -n "Upstream User Num in $city"
python calc_user_num.py --dataset=pretrain --model=$model $base_yaml_file --val_interval="{'cityid': ['$city_id']}" --data_source=up --upstream_user_inter_num_interval=$up_interval --eval_args="{'split': {'LS': 'test_only'}, 'order': 'TO', 'mode': 'full', 'group_by': 'user'}" --epochs=100 --gpu_id=$gpu_id
echo -n "Downstream User Num in $city"
python calc_user_num.py --dataset=pretrain --model=$model $base_yaml_file --val_interval="{'cityid': ['$city_id']}" --data_source=down --downstream_user_inter_num_interval=$down_interval --epochs=100 --gpu_id=$gpu_id