# $1 city  $2 city_id  $3 up_interval  $4 gpu_id

city=$1
city_id=$2
up_interval=$3
gpu_id=$4

log_dir=output/$city/0112-exp/up-$up_interval

if [ ! -d $log_dir ]
then
    mkdir -p $log_dir
fi

base_yaml_file='--config_files=yamls/pretrain.yaml,yamls/SASRec.yaml'
meta_yaml_file='--config_files=yamls/pretrain.yaml,yamls/meta-learing.yaml,yamls/SASRec.yaml'

sasrec_up_log=$log_dir/SASRec.up.log
sasrec_down_log=$log_dir/SASRec.down.log
meta_train_log=$log_dir/SASRec.meta-train.log
meta_test_log=$log_dir/SASRec.meta-test.log
trans_log=$log_dir/SASRec.trans.log

python run_recbole.py --dataset=pretrain --model=SASRec $base_yaml_file --val_interval="{'cityid': ['$city_id']}" --data_source=up --upstream_user_inter_num_interval=$up_interval --eval_args="{'split': {'LS': 'test_only'}, 'order': 'TO', 'mode': 'full', 'group_by': 'user'}" --epochs=100 --gpu_id=$gpu_id --hint="$city up" &> $sasrec_up_log &
sleep 10
python run_meta_train.py --dataset=pretrain --model=SASRec $meta_yaml_file --val_interval="{'cityid': ['$city_id']}" --data_source=up --upstream_user_inter_num_interval=$up_interval --meta_epochs=10 --num_local_update=5 --gpu_id=$gpu_id --hint="meta $city train" &> $meta_train_log &
wait

meta_file=`tail $meta_train_log -n 3 | head -n 1 | awk '{ print $7 }'`
trans_file=`tail $sasrec_up_log -n 4 | head -n 1 | awk '{ print $11 }'`

python run_recbole.py --dataset=pretrain --model=SASRec $base_yaml_file --val_interval="{'cityid': ['$city_id']}" --data_source=down --epochs=100 --gpu_id=$gpu_id --hint="$city down" &> $sasrec_down_log &
sleep 10
python run_meta_test.py --dataset=pretrain --model=SASRec $meta_yaml_file --val_interval="{'cityid': ['$city_id']}" --data_source=down --model_file=$meta_file --epochs=50 --gpu_id=$gpu_id --hint="meta $city test" &> $meta_test_log &
sleep 10
python run_meta_test.py --dataset=pretrain --model=SASRec $meta_yaml_file --val_interval="{'cityid': ['$city_id']}" --data_source=down --model_file=$trans_file --epochs=50 --gpu_id=$gpu_id --hint="trans $city" &> $trans_log &
wait
