# $1 modal  $2 city  $3 gpu_id  $4 replace

modal=$1
city=$2
gpu_id=$3
replace=$4

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

pretrain_yaml_file="--config_files=yamls/pretrain.yaml,yamls/$city/$modal/pretrain.yaml"
trans_yaml_file="--config_files=yamls/pretrain.yaml,yamls/$city/$modal/trans.yaml"

pretrain_log=$up_log_dir/$modal.up.log

if [[ ! -f $pretrain_log || "$replace" == "replace" ]]
then
    python run_recbole.py --model=$model --dataset=$city $pretrain_yaml_file --gpu_id=$gpu_id --hint="$city up" &> $pretrain_log &
fi
wait

trans_file=`tail $pretrain_log -n 4 | head -n 1 | awk '{ print $11 }'`

down_log_dir=$up_log_dir/down
if [ ! -d $down_log_dir ]
then
    mkdir -p $down_log_dir
fi
trans_log=$down_log_dir/$modal.trans.log

if [[ ! -f $trans_log || "$replace" == "replace" ]]
then
    python run_meta_test.py --model=$model --dataset=$city $trans_yaml_file --model_file=$trans_file --gpu_id=$gpu_id --hint="trans $city" &> $trans_log &
fi
wait
