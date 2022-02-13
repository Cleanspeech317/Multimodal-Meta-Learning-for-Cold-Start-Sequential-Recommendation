# $1 city  $2 gpu_id

city=$1
gpu_id=$2

up_log_dir=output/$city/0207-exp/up
down_log_dir=$up_log_dir/down

trans_sasrec_yaml_file="'yamls/pretrain.yaml','yamls/$city/SASRec/trans.yaml'"
trans_txt_yaml_file="'yamls/pretrain.yaml','yamls/$city/txt/trans.yaml'"
trans_img_yaml_file="'yamls/pretrain.yaml','yamls/$city/img/trans.yaml'"

sasrec_pretrain_log=$up_log_dir/SASRec.up.log
txt_pretrain_log=$up_log_dir/txt.up.log
img_pretrain_log=$up_log_dir/img.up.log

pretrain_log=$up_log_dir/attention-fusion.up.log
trans_log=$down_log_dir/attention-fusion.trans.log

sasrec_trans_file=`tail $sasrec_pretrain_log -n 4 | head -n 1 | awk '{ print $11 }'`
txt_trans_file=`tail $txt_pretrain_log -n 4 | head -n 1 | awk '{ print $11 }'`
img_trans_file=`tail $img_pretrain_log -n 4 | head -n 1 | awk '{ print $11 }'`

trans_config_files="[[$trans_sasrec_yaml_file,'yamls/$city/trans-attention.yaml'],[$trans_txt_yaml_file],[$trans_img_yaml_file]]"

fusion_weight="[1,1,1]"
model_list="['SASRec','SASRecFeat','SASRecFeat']"

# python run_attention_fusion_train.py --dataset=$city --data_source=up --model_list="$model_list" --config_files="$trans_config_files" --model_file="['$sasrec_trans_file','$txt_trans_file','$img_trans_file']" --fusion_weight="$fusion_weight" --gpu_id=$gpu_id --hint="trans attention fusion train for $city" &> $pretrain_log &
# wait

python run_meta_fusion_test.py --dataset=$city --model_list="$model_list" --config_files="$trans_config_files" --model_file="['$sasrec_trans_file','$txt_trans_file','$img_trans_file']" --gpu_id=$gpu_id --hint="trans $city fusion" &> $trans_log &
wait
