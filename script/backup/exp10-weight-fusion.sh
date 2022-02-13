# $1 city  $2 SASRec_weight  $3 txt_weight  $4 img_weight  $4 gpu_id

city=$1
sasrec_weight=$2
txt_weight=$3
img_weight=$4
gpu_id=$5

up_log_dir=output/$city/0121-exp/up-
down_log_dir=$up_log_dir/down-

sasrec_yaml_file="'yamls/pretrain.yaml','yamls/$city/SASRec/meta-test.yaml'"
txt_yaml_file="'yamls/pretrain.yaml','yamls/$city/txt/meta-test.yaml'"
img_yaml_file="'yamls/pretrain.yaml','yamls/$city/img/meta-test.yaml'"

sasrec_up_log=$up_log_dir/SASRec.up.log
sasrec_meta_train_log=$up_log_dir/SASRec.meta-train.log

txt_up_log=$up_log_dir/txt.up.log
txt_meta_train_log=$up_log_dir/txt.meta-train.log

img_up_log=$up_log_dir/img.up.log
img_meta_train_log=$up_log_dir/img.meta-train.log

fusion_weight="[${sasrec_weight},${txt_weight},${img_weight}]"

meta_test_log=$down_log_dir/fusion-${fusion_weight}.meta-test.log
trans_log=$down_log_dir/fusion-${fusion_weight}.trans.log

sasrec_meta_file=`tail $sasrec_meta_train_log -n 3 | head -n 1 | awk '{ print $7 }'`
sasrec_trans_file=`tail $sasrec_up_log -n 4 | head -n 1 | awk '{ print $11 }'`

txt_meta_file=`tail $txt_meta_train_log -n 3 | head -n 1 | awk '{ print $7 }'`
txt_trans_file=`tail $txt_up_log -n 4 | head -n 1 | awk '{ print $11 }'`

img_meta_file=`tail $img_meta_train_log -n 3 | head -n 1 | awk '{ print $7 }'`
img_trans_file=`tail $img_up_log -n 4 | head -n 1 | awk '{ print $11 }'`

config_files="[[$sasrec_yaml_file],[$txt_yaml_file],[$img_yaml_file]]"

python run_meta_fusion_test.py --dataset=$city --model_list="['SASRec', 'txt']" --config_files="$config_files" --model_file="['$sasrec_meta_file','$txt_meta_file','$img_meta_file']" --fusion_weight="$fusion_weight" --gpu_id=$gpu_id --hint="meta $city fusion test" &> $meta_test_log &
sleep 10
python run_meta_fusion_test.py --dataset=$city --model_list="['SASRec', 'txt']" --config_files="$config_files" --model_file="['$sasrec_trans_file','$txt_trans_file','$img_trans_file']" --fusion_weight="$fusion_weight" --gpu_id=$gpu_id --hint="trans $city fusion" &> $trans_log &
wait
