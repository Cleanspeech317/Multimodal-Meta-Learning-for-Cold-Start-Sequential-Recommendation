# $1 modal  $2 city  $3 user_remained_rate  $4 gpu_id  $5 replace

modal=$1
city=$2
user_remained_rate=$3
gpu_id=$4
replace=$5

if [[ "$modal" == "SASRec" ]]
then
    model=$modal
else
    model="SASRecFeat"
fi

up_log_dir=output/$city/0207-exp/up

if [ ! -d $up_log_dir ]
then
    mkdir -p $up_log_dir
fi

meta_train_yaml_file="--config_files=yamls/pretrain.yaml,yamls/$city/$modal/meta-train.yaml"

meta_test_yaml_file="--config_files=yamls/pretrain.yaml,yamls/$city/$modal/meta-test.yaml"

meta_train_log=$up_log_dir/$modal.meta-train.reamined_rate-$user_remained_rate.log

if [[ ! -f $meta_train_log || "$replace" == "replace" ]]
then
    python run_meta_train.py --user_remained_rate=$user_remained_rate --model=$model --dataset=$city $meta_train_yaml_file --gpu_id=$gpu_id --hint="meta $city train" &> $meta_train_log &
fi
wait

meta_file=`tail $meta_train_log -n 3 | head -n 1 | awk '{ print $7 }'`

down_log_dir=$up_log_dir/down
if [ ! -d $down_log_dir ]
then
    mkdir -p $down_log_dir
fi
meta_test_log=$down_log_dir/$modal.meta-test.without-IEG.reamined_rate-$user_remained_rate.log

if [[ ! -f $meta_test_log || "$replace" == "replace" ]]
then
    python run_meta_test.py --model=$model --dataset=$city $meta_test_yaml_file --model_file=$meta_file --gpu_id=$gpu_id --hint="meta $city test" &> $meta_test_log &
fi
wait


if [[ "$model" == "SASRec" ]]
then
    item_emb_gen_yaml_file="--config_files=yamls/pretrain.yaml,yamls/$city/$model/item-emb-gen.yaml"
    item_emb_gen_log=$up_log_dir/$model.item-emb-gen.reamined_rate-$user_remained_rate.log
    if [[ ! -f $item_emb_gen_log || "$replace" == "replace" ]]
    then
        python run_gen_item_emb.py --user_remained_rate=$user_remained_rate --dataset=$city --model=$model $item_emb_gen_yaml_file --model_file=$meta_file --gpu_id=$gpu_id --hint="meta $city train" &> $item_emb_gen_log &
    fi
    wait
    
    new_meta_file=`tail $item_emb_gen_log -n 3 | head -n 1 | awk '{ print $9 }'`
    new_meta_test_log=$down_log_dir/$modal.meta-test.IEG.reamined_rate-$user_remained_rate.log
    if [[ ! -f $new_meta_test_log || "$replace" == "replace" ]]
    then
        python run_meta_test.py --model=$model --dataset=$city $meta_test_yaml_file --model_file=$new_meta_file --gpu_id=$gpu_id --hint="meta $city test" &> $new_meta_test_log &
    fi
    wait
fi
