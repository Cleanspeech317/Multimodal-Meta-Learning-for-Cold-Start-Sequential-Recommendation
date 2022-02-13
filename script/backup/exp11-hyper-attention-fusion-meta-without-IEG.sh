# $1 city  $2 attention_learning_rate_list  $3 mlp_hidden_size_list  $4 gpu_id

city=$1
attention_learning_rate_list=$2
mlp_hidden_size_list=$3
gpu_id=$4

up_log_dir=output/$city/0207-exp-fusion/up
down_log_dir=$up_log_dir/down

meta_test_sasrec_yaml_file="'yamls/pretrain.yaml','yamls/$city/SASRec/meta-test.yaml'"
meta_test_txt_yaml_file="'yamls/pretrain.yaml','yamls/$city/txt/meta-test.yaml'"
meta_test_img_yaml_file="'yamls/pretrain.yaml','yamls/$city/img/meta-test.yaml'"

sasrec_meta_train_log=$up_log_dir/SASRec.meta-train.log
txt_meta_train_log=$up_log_dir/txt.meta-train.log
img_meta_train_log=$up_log_dir/img.meta-train.log

sasrec_meta_file=`tail $sasrec_meta_train_log -n 3 | head -n 1 | awk '{ print $7 }'`
txt_meta_file=`tail $txt_meta_train_log -n 3 | head -n 1 | awk '{ print $7 }'`
img_meta_file=`tail $img_meta_train_log -n 3 | head -n 1 | awk '{ print $7 }'`

meta_test_config_files="[[$meta_test_sasrec_yaml_file,'yamls/$city/meta-attention-without-IEG.yaml'],[$meta_test_txt_yaml_file],[$meta_test_img_yaml_file]]"

fusion_weight="[1,1,1]"
model_list="['SASRec','SASRecFeat','SASRecFeat']"

for attention_learning_rate in $attention_learning_rate_list
do
    for mlp_hidden_size in $mlp_hidden_size_list
    do
        meta_train_log=$up_log_dir/attention-fusion.meta-train.without-IEG.$attention_learning_rate."$mlp_hidden_size".log
        meta_test_log=$down_log_dir/attention-fusion.meta-test.without-IEG.$attention_learning_rate."$mlp_hidden_size".log
        echo $meta_train_log

        python run_attention_fusion_train.py --attention_learning_rate=$attention_learning_rate --mlp_hidden_size="$mlp_hidden_size" --dataset=$city --data_source=up --model_list="$model_list" --config_files="$meta_test_config_files" --model_file="['$sasrec_meta_file','$txt_meta_file','$img_meta_file']" --fusion_weight="$fusion_weight" --gpu_id=$gpu_id --hint="meta attention_fusion_train for $city" &> $meta_train_log &
        wait

        python run_meta_fusion_test.py --attention_learning_rate=$attention_learning_rate --mlp_hidden_size="$mlp_hidden_size" --dataset=$city --model_list="$model_list" --config_files="$meta_test_config_files" --model_file="['$sasrec_meta_file','$txt_meta_file','$img_meta_file']" --gpu_id=$gpu_id --hint="meta $city fusion test" &> $meta_test_log &
        wait
    done
done
