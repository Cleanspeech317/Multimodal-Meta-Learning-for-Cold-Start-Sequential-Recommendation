# $1 city  $2 gpu_id  $3 replace

city=$1
gpu_id=$2
replace=$3

up_log_dir=output/$city/0207-exp-fusion/up

if [ ! -d $up_log_dir ]
then
    mkdir -p $up_log_dir
fi

meta_train_yaml_file="--config_files=yamls/pretrain.yaml,yamls/$city/SASRec/meta-train.yaml"

meta_test_yaml_file="--config_files=yamls/pretrain.yaml,yamls/$city/SASRec/meta-test.yaml"

meta_train_log=$up_log_dir/SASRec.meta-train.log

# if [[ ! -f $meta_train_log || "$replace" == "replace" ]]
# then
#     python run_meta_train.py --model=SASRec --dataset=$city $meta_train_yaml_file --gpu_id=$gpu_id --hint="meta $city train" &> $meta_train_log &
# fi
# wait

meta_file=`tail $meta_train_log -n 3 | head -n 1 | awk '{ print $7 }'`

down_log_dir=$up_log_dir/down
if [ ! -d $down_log_dir ]
then
    mkdir -p $down_log_dir
fi

item_emb_gen_yaml_file="--config_files=yamls/pretrain.yaml,yamls/$city/SASRec/item-emb-gen.yaml"
item_emb_gen_log=$up_log_dir/SASRec.item-emb-gen.gr-0.2.log
if [[ ! -f $item_emb_gen_log || "$replace" == "replace" ]]
then
    python run_gen_item_emb.py --generate_rate=0.2 --model=SASRec --dataset=$city $item_emb_gen_yaml_file --model_file=$meta_file --gpu_id=$gpu_id --hint="meta $city train" &> $item_emb_gen_log &
fi
wait

new_meta_file=`tail $item_emb_gen_log -n 3 | head -n 1 | awk '{ print $9 }'`
new_meta_test_log=$down_log_dir/SASRec.meta-test.IEG.gr-0.2.log
if [[ ! -f $new_meta_test_log || "$replace" == "replace" ]]
then
    python run_meta_test.py --model=SASRec --dataset=$city $meta_test_yaml_file --model_file=$new_meta_file --gpu_id=$gpu_id --hint="meta $city test" &> $new_meta_test_log &
fi
wait