# $1 modal  $2 city  $5 gpu_id  $6 type  $7 replace

modal=$1
city=$2
up_lr_list=$3
down_lr_list=$4
gpu_id=$5
type=$6
replace=$7

if [[ "$modal" == "SASRec" ]]
then
    model=$modal
else
    model="SASRecFeat"
fi

up_log_dir=output/$city/0121-exp/up

if [ ! -d $up_log_dir ]
then
    mkdir -p $up_log_dir
fi

meta_train_yaml_file="--config_files=yamls/pretrain.yaml,yamls/$city/$modal/meta-train.yaml"
pretrain_yaml_file="--config_files=yamls/pretrain.yaml,yamls/$city/$modal/pretrain.yaml"
meta_test_yaml_file="--config_files=yamls/pretrain.yaml,yamls/$city/$modal/meta-test.yaml"
trans_yaml_file="--config_files=yamls/pretrain.yaml,yamls/$city/$modal/trans.yaml"

pretrain_log=$up_log_dir/$modal.up.log
meta_train_log=$up_log_dir/$modal.meta-train.log

if [[ ( "$type" != "trans" ) && ( ! -f $meta_train_log || "$replace" == "replace" ) ]]
then
    python run_meta_train.py --model=$model --dataset=$city $meta_train_yaml_file --gpu_id=$gpu_id --hint="meta $city train" &> $meta_train_log &
fi
sleep 30
if [[ ( "$type" != "meta" ) && ( ! -f $pretrain_log || "$replace" == "replace" ) ]]
then
    python run_recbole.py --model=$model --dataset=$city $pretrain_yaml_file --gpu_id=$gpu_id --hint="$city up" &> $pretrain_log &
fi
wait

meta_file=`tail $meta_train_log -n 3 | head -n 1 | awk '{ print $7 }'`
trans_file=`tail $pretrain_log -n 4 | head -n 1 | awk '{ print $11 }'`

down_log_dir=$up_log_dir/down
if [ ! -d $down_log_dir ]
then
    mkdir -p $down_log_dir
fi
meta_test_log=$down_log_dir/$modal.meta-test.log
trans_log=$down_log_dir/$modal.trans.log

if [[ ( "$type" != "trans" ) && ( ! -f $meta_test_log || "$replace" == "replace" ) ]]
then
    python run_meta_test.py --model=$model --dataset=$city $meta_test_yaml_file --model_file=$meta_file --gpu_id=$gpu_id --hint="meta $city test" &> $meta_test_log &
fi
sleep 30
if [[ ( "$type" != "meta" ) && ( ! -f $trans_log || "$replace" == "replace" ) ]]
then
    python run_meta_test.py --model=$model --dataset=$city $trans_yaml_file --model_file=$trans_file --gpu_id=$gpu_id --hint="trans $city" &> $trans_log &
fi
wait


if [[ "$model" == "SASRec" ]]
then
    item_emb_gen_yaml_file="--config_files=yamls/pretrain.yaml,yamls/$city/$model/item-emb-gen.yaml"
    item_emb_gen_log=$up_log_dir/$model.item-emb-gen.log
    python run_gen_item_emb.py --dataset=$city --model=$model $item_emb_gen_yaml_file --model_file=$meta_file --gpu_id=$gpu_id --hint="meta $city train" &> $item_emb_gen_log &
    
fi