# $1 city  $2 city_id  $3 split ratio  $4 split_time  $5 gpu_id

city=$1
city_id=$2
split_ratio=$3
split_time=$4
gpu_id=$5

log_dir=output/$city/$split_ratio

if [ ! -d $log_dir ]
then
    mkdir -p $log_dir
fi

base_yaml_file='--config_files=yamls/pretrain.yaml,yamls/SASRec.yaml'
meta_yaml_file='--config_files=yamls/pretrain.yaml,yamls/meta-learing.yaml,yamls/SASRec.yaml'

python run_recbole.py --dataset=pretrain --model=SASRec $base_yaml_file --val_interval="{'cityid': ['$city_id'], 'exposure_time': '(-inf,$split_time]'}" --epochs=100 --gpu_id=$gpu_id --hint="$city" &> $log_dir/SASRec.log &
sleep 5
python run_recbole.py --dataset=pretrain --model=SASRec $base_yaml_file --val_interval="{'cityid': ['$city_id'], 'exposure_time': '($split_time,inf)'}" --epochs=100 --gpu_id=$gpu_id --hint="$city complement" &> $log_dir/SASRec.complement.log &
sleep 5
python run_meta_train.py --dataset=pretrain --model=SASRec $meta_yaml_file --val_interval="{'cityid': ['$city_id'], 'exposure_time': '(-inf,$split_time]'}" --gpu_id=$gpu_id --meta_epochs=10 --num_local_update=5 --hint="meta $city train" &> $log_dir/meta-train.log &
wait

meta_file=`tail $log_dir/meta-train.log -n 3 | head -n 1 | awk '{ print $7 }'`
trans_file=`tail $log_dir/SASRec.log -n 4 | head -n 1 | awk '{ print $11 }'`
item_emb_file=`tail $log_dir/SASRec.complement.log -n 4 | head -n 1 | awk '{ print $11 }'`

python run_meta_test.py --dataset=pretrain --model=SASRec $meta_yaml_file --val_interval="{'cityid': ['$city_id'], 'exposure_time': '($split_time,inf)'}" --model_file=$meta_file --item_emb_file=$item_emb_file --epochs=50 --gpu_id=$gpu_id --hint="meta $city test" &> $log_dir/meta-test.log &
sleep 5
python run_meta_test.py --dataset=pretrain --model=SASRec $meta_yaml_file --val_interval="{'cityid': ['$city_id'], 'exposure_time': '($split_time,inf)'}" --model_file=$trans_file --item_emb_file=$item_emb_file --epochs=50 --gpu_id=$gpu_id --hint="trans $city" &> $log_dir/trans.log &
wait
