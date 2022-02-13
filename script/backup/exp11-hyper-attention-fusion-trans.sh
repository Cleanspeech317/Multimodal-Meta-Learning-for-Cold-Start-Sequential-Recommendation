# $1 city  $2 attention_learning_rate_list  $3 mlp_hidden_size_list  $4 gpu_id

city=$1
attention_learning_rate_list=$2
mlp_hidden_size_list=$3
gpu_id=$4

up_log_dir=output/$city/0207-exp-fusion/up
down_log_dir=$up_log_dir/down

trans_sasrec_yaml_file="'yamls/pretrain.yaml','yamls/$city/SASRec/trans.yaml'"
trans_txt_yaml_file="'yamls/pretrain.yaml','yamls/$city/txt/trans.yaml'"
trans_img_yaml_file="'yamls/pretrain.yaml','yamls/$city/img/trans.yaml'"

sasrec_pretrain_log=$up_log_dir/SASRec.up.log
txt_pretrain_log=$up_log_dir/txt.up.log
img_pretrain_log=$up_log_dir/img.up.log

sasrec_trans_file=`tail $sasrec_pretrain_log -n 4 | head -n 1 | awk '{ print $11 }'`
txt_trans_file=`tail $txt_pretrain_log -n 4 | head -n 1 | awk '{ print $11 }'`
img_trans_file=`tail $img_pretrain_log -n 4 | head -n 1 | awk '{ print $11 }'`

trans_config_files="[[$trans_sasrec_yaml_file,'yamls/$city/trans-attention.yaml'],[$trans_txt_yaml_file],[$trans_img_yaml_file]]"

fusion_weight="[1,1,1]"
model_list="['SASRec','SASRecFeat','SASRecFeat']"

for attention_learning_rate in $attention_learning_rate_list
do
    for mlp_hidden_size in $mlp_hidden_size_list
    do
        pretrain_log=$up_log_dir/attention-fusion.up.$attention_learning_rate."$mlp_hidden_size".log
        trans_log=$down_log_dir/attention-fusion.trans.$attention_learning_rate."$mlp_hidden_size".log

        python run_attention_fusion_train.py --attention_learning_rate=$attention_learning_rate --mlp_hidden_size="$mlp_hidden_size" --dataset=$city --data_source=up --model_list="$model_list" --config_files="$trans_config_files" --model_file="['$sasrec_trans_file','$txt_trans_file','$img_trans_file']" --fusion_weight="$fusion_weight" --gpu_id=$gpu_id --hint="trans attention fusion train for $city" &> $pretrain_log &
        wait

        python run_meta_fusion_test.py --attention_learning_rate=$attention_learning_rate --mlp_hidden_size="$mlp_hidden_size" --dataset=$city --model_list="$model_list" --config_files="$trans_config_files" --model_file="['$sasrec_trans_file','$txt_trans_file','$img_trans_file']" --gpu_id=$gpu_id --hint="trans $city fusion" &> $trans_log &
        wait
    done
done
