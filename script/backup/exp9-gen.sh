# $1 model  $2 city  $3 up_lr_list  $4 down_lr_list  $5 item_neighbour_num_list  $6 gpu_id  $7 type  $8 replace

model=$1
city=$2
up_lr_list=$3
down_lr_list=$4
item_neighbour_num_list=$5
gpu_id=$6
type=$7
replace=$8

for up_lr in $up_lr_list
do
    up_log_dir=output/$city/0121-exp-$up_lr/up-${up_interval}
    down_log_dir=$up_log_dir/down-${down_interval}

    if [ ! -d $up_log_dir ]
    then
        mkdir -p $up_log_dir
    fi

    if [ ! -d $down_log_dir ]
    then
        mkdir -p $down_log_dir
    fi

    meta_train_yaml_file="--config_files=yamls/pretrain.yaml,yamls/$city/$model/meta-train.yaml"
    item_emb_gen_yaml_file="--config_files=yamls/pretrain.yaml,yamls/$city/$model/item-emb-gen.yaml"
    meta_test_yaml_file="--config_files=yamls/pretrain.yaml,yamls/$city/$model/meta-test.yaml"

    meta_train_log=$up_log_dir/$model.meta-train.log

    # if [[ ( "$type" != "trans" ) && ( ! -f $meta_train_log || "$replace" == "replace" ) ]]
    # then
    #     python run_meta_train.py --learning_rate=$up_lr --dataset=$city --model=$model $meta_train_yaml_file --gpu_id=$gpu_id --hint="meta $city train" &> $meta_train_log &
    # fi
    # wait

    origin_meta_file=`tail $meta_train_log -n 3 | head -n 1 | awk '{ print $7 }'`
    for item_neighbour_num in $item_neighbour_num_list
    do
        item_emb_gen_log=$up_log_dir/$model.item-emb-gen.${item_neighbour_num}-neighbour.log
        if [[ ( "$type" != "trans" ) && ( ! -f $item_emb_gen_log || "$replace" == "replace" ) ]]
        then
            python run_gen_item_emb.py --learning_rate=$up_lr --item_neighbour_num=$item_neighbour_num --dataset=$city --model=$model $item_emb_gen_yaml_file --model_file=$origin_meta_file --gpu_id=$gpu_id --hint="meta $city train" &> $item_emb_gen_log &
        fi
        wait

        meta_file=`tail $item_emb_gen_log -n 3 | head -n 1 | awk '{ print $9 }'`

        for down_lr in $down_lr_list
        do
            meta_test_log=$down_log_dir/$model.meta-test.$down_lr.IEG.${item_neighbour_num}-neighbour.log
            if [[ ( "$type" != "trans" ) && ( ! -f $meta_test_log || "$replace" == "replace" ) ]]
            then
                python run_meta_test.py --learning_rate=$down_lr --dataset=$city --model=$model $meta_test_yaml_file --model_file=$meta_file --gpu_id=$gpu_id --hint="meta $city test" &> $meta_test_log &
            fi
            wait
        done
    done
done
