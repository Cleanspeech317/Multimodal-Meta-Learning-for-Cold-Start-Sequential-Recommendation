# $1 city  $2 city_id  $3 split ratio  $4 gpu_id

city=$1
city_id=$2
split_ratio=$3
gpu_id=$4

log_dir=output/$city/new_user_$split_ratio

if [ ! -d $log_dir ]
then
    mkdir -p $log_dir
fi

meta_yaml_file='--config_files=yamls/pretrain.yaml,yamls/meta-learing.yaml,yamls/SASRec.yaml'

meta_train_log=$log_dir/meta-train.transformer.log

if [ ! -d $log_dir/transformer ]
then
    mkdir -p $log_dir/transformer
fi



meta_file=`grep 'meta-\[-1\]' $meta_train_log | awk '{ print $7 }'`
meta_test_log=$log_dir/transformer/meta-test.transformer.-1-global-epoch.log
python run_meta_test.py --dataset=pretrain --model=SASRec $meta_yaml_file --val_interval="{'cityid': ['$city_id']}" --data_source=down --time_split_ratio=$split_ratio --model_file=$meta_file --item_emb_file=$meta_file --epochs=50 --gpu_id=$gpu_id --hint="meta $city test" &> $meta_test_log &
sleep 5


for ((i=0;i<10;i=i+1))
do
    meta_file=`grep "meta-$i" $meta_train_log | awk '{ print $7 }'`
    echo $meta_file
    meta_test_log=$log_dir/transformer/meta-test.transformer.${i}-global-epoch.log
    python run_meta_test.py --dataset=pretrain --model=SASRec $meta_yaml_file --val_interval="{'cityid': ['$city_id']}" --data_source=down --time_split_ratio=$split_ratio --model_file=$meta_file --item_emb_file=$meta_file --epochs=50 --gpu_id=$gpu_id --hint="meta $city test" &> $meta_test_log &
    sleep 5
done
wait
