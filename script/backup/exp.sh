# $1: city name; $2: city id; $3 gpu id

logdir=output/meta-testing/$1

if [ ! -d $logdir ]
then
    mkdir $logdir
fi

logfile=$logdir/SASRec.log
if [ ! -f $logfile ]
then
    python run_recbole.py --dataset=pretrain --model=SASRec --config_files=yamls/pretrain.yaml,yamls/SASRec.yaml --val_interval="{'cityid': ['$2']}" --gpu_id=$3 --hint="$1 SASRec" &> $logfile
fi

item_emb_file=`tail $logfile -n 4 | head -n 1 | awk '{ print $11 }'`

config_files=yamls/pretrain.yaml,yamls/meta-learing.yaml,yamls/SASRec.yaml

python run_meta_test.py --dataset=pretrain --model=SASRec --config_files=$config_files --task_fields=user_id --val_interval="{'cityid': ['$2']}" --model_file=saved/SASRec-Dec-14-2021_17-44-10.pth --item_emb_file=$item_emb_file --gpu_id=$3 --hint="$1: trans bj" &> $logdir/trans_bj.log
python run_meta_test.py --dataset=pretrain --model=SASRec --config_files=$config_files --task_fields=user_id --val_interval="{'cityid': ['$2']}" --model_file=saved/SASRec-meta-Dec-27-2021_20-29-30.pth --item_emb_file=$item_emb_file --gpu_id=$3 --hint="$1: meta bj" &> $logdir/meta_bj.log
