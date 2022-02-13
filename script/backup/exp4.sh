# $1 city  $2 city_id  $3 split ratio  $4 up_left  $5 up_right  $6 gpu_id

city=$1
city_id=$2
split_ratio=$3
up_left=$4
up_right=$5
gpu_id=$6

log_dir=output/$city/new_user_$split_ratio/test-up-${up_left}-${up_right}
# log_dir=output/$city/test_user_$split_ratio

if [ ! -d $log_dir ]
then
    mkdir -p $log_dir
fi

base_yaml_file='--config_files=yamls/pretrain.yaml,yamls/SASRec.yaml'
meta_yaml_file='--config_files=yamls/pretrain.yaml,yamls/meta-learing.yaml,yamls/SASRec.yaml'

sasrec_up_log=$log_dir/SASRec.up.log
sasrec_down_log=$log_dir/SASRec.down.log
meta_train_log=$log_dir/meta-train.transformer.log
meta_test_log=$log_dir/meta-test.transformer.log
trans_log=$log_dir/trans.log

python run_recbole.py --dataset=pretrain --model=SASRec $base_yaml_file --val_interval="{'cityid': ['$city_id']}" --data_source=up --time_split_ratio=$split_ratio --up_left=$up_left --up_right=$up_right --epochs=100 --eval_args="{'split': {'LS': 'test_only'}, 'order': 'TO', 'mode': 'full', 'group_by': 'user'}" --gpu_id=$gpu_id --hint="$city up" &> $sasrec_up_log &
sleep 5
# python run_recbole.py --dataset=pretrain --model=SASRec $base_yaml_file --val_interval="{'cityid': ['$city_id']}" --data_source=down --time_split_ratio=$split_ratio --epochs=100 --gpu_id=$gpu_id --hint="$city down" &> $sasrec_down_log &
# sleep 5
python run_meta_train.py --dataset=pretrain --model=SASRec $meta_yaml_file --val_interval="{'cityid': ['$city_id']}" --data_source=up --time_split_ratio=$split_ratio --up_left=$up_left --up_right=$up_right --gpu_id=$gpu_id --meta_epochs=10 --num_local_update=5 --hint="meta $city train" &> $meta_train_log &
wait

meta_file=`tail $meta_train_log -n 3 | head -n 1 | awk '{ print $7 }'`
trans_file=`tail $sasrec_up_log -n 4 | head -n 1 | awk '{ print $11 }'`

python run_meta_test.py --dataset=pretrain --model=SASRec $meta_yaml_file --val_interval="{'cityid': ['$city_id']}" --data_source=down --time_split_ratio=$split_ratio --model_file=$meta_file --item_emb_file=$meta_file --epochs=50 --gpu_id=$gpu_id --hint="meta $city test" &> $meta_test_log &
sleep 5
python run_meta_test.py --dataset=pretrain --model=SASRec $meta_yaml_file --val_interval="{'cityid': ['$city_id']}" --data_source=down --time_split_ratio=$split_ratio --model_file=$trans_file --item_emb_file=$trans_file --epochs=50 --gpu_id=$gpu_id --hint="trans $city" &> $trans_log &
wait
