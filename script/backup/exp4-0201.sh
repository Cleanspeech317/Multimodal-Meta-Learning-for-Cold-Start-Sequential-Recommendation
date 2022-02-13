# python run_recbole.py --learning_rate=7e-4 --dataset=hangzhou --model=SASRecFeat --config_files=yamls/pretrain.yaml,yamls/hangzhou/img/pretrain.yaml --data_source=up --gpu_id=4 --hint="hangzhou up" &> output/hangzhou/0121-exp-7e-4/up-/img.up.log &
# sleep 60
# python run_meta_train.py --learning_rate=7e-4 --dataset=hangzhou --model=SASRecFeat --config_files=yamls/pretrain.yaml,yamls/hangzhou/img/meta-train.yaml --data_source=up --gpu_id=5 --hint="meta hangzhou train" &> output/hangzhou/0121-exp-7e-4/up-/img.meta-train.log &
# sleep 60

# python run_recbole.py --learning_rate=5e-3 --dataset=hangzhou --model=SASRecFeat --config_files=yamls/pretrain.yaml,yamls/hangzhou/img/pretrain.yaml --data_source=up --gpu_id=6 --hint="hangzhou up" &> output/hangzhou/0121-exp-5e-3/up-/img.up.log &
# sleep 60
# python run_meta_train.py --learning_rate=5e-3 --dataset=hangzhou --model=SASRecFeat --config_files=yamls/pretrain.yaml,yamls/hangzhou/img/meta-train.yaml --data_source=up --gpu_id=7 --hint="meta hangzhou train" &> output/hangzhou/0121-exp-5e-3/up-/img.meta-train.log &
# sleep 60

# wait


meta_file=`tail output/hangzhou/0121-exp-7e-4/up-/img.meta-train.log -n 3 | head -n 1 | awk '{ print $7 }'`
trans_file=`tail output/hangzhou/0121-exp-7e-4/up-/img.up.log -n 4 | head -n 1 | awk '{ print $11 }'`

python run_meta_test.py --learning_rate=1e-2 --model=SASRecFeat --dataset=hangzhou --config_files=yamls/pretrain.yaml,yamls/hangzhou/img/meta-test.yaml --model_file=$meta_file --gpu_id=0 --hint="meta hangzhou test" &> output/hangzhou/0121-exp-7e-4/up-/down-/img.meta-test.1e-2.log &
sleep 60
python run_meta_test.py --learning_rate=1e-2 --model=SASRecFeat --dataset=hangzhou --config_files=yamls/pretrain.yaml,yamls/hangzhou/img/trans.yaml --model_file=$trans_file --gpu_id=1 --hint="trans hangzhou" &> output/hangzhou/0121-exp-7e-4/up-/down-/img.trans.1e-2.log &
sleep 60

python run_meta_test.py --learning_rate=5e-2 --model=SASRecFeat --dataset=hangzhou --config_files=yamls/pretrain.yaml,yamls/hangzhou/img/meta-test.yaml --model_file=$meta_file --gpu_id=2 --hint="meta hangzhou test" &> output/hangzhou/0121-exp-7e-4/up-/down-/img.meta-test.5e-2.log &
sleep 60
python run_meta_test.py --learning_rate=5e-2 --model=SASRecFeat --dataset=hangzhou --config_files=yamls/pretrain.yaml,yamls/hangzhou/img/trans.yaml --model_file=$trans_file --gpu_id=3 --hint="trans hangzhou" &> output/hangzhou/0121-exp-7e-4/up-/down-/img.trans.5e-2.log &
sleep 60

python run_meta_test.py --learning_rate=1e-1 --model=SASRecFeat --dataset=hangzhou --config_files=yamls/pretrain.yaml,yamls/hangzhou/img/meta-test.yaml --model_file=$meta_file --gpu_id=4 --hint="meta hangzhou test" &> output/hangzhou/0121-exp-7e-4/up-/down-/img.meta-test.1e-1.log &
sleep 60
python run_meta_test.py --learning_rate=1e-1 --model=SASRecFeat --dataset=hangzhou --config_files=yamls/pretrain.yaml,yamls/hangzhou/img/trans.yaml --model_file=$trans_file --gpu_id=5 --hint="trans hangzhou" &> output/hangzhou/0121-exp-7e-4/up-/down-/img.trans.1e-1.log &
sleep 60

python run_meta_test.py --learning_rate=5e-1 --model=SASRecFeat --dataset=hangzhou --config_files=yamls/pretrain.yaml,yamls/hangzhou/img/meta-test.yaml --model_file=$meta_file --gpu_id=6 --hint="meta hangzhou test" &> output/hangzhou/0121-exp-7e-4/up-/down-/img.meta-test.5e-1.log &
sleep 60
python run_meta_test.py --learning_rate=5e-1 --model=SASRecFeat --dataset=hangzhou --config_files=yamls/pretrain.yaml,yamls/hangzhou/img/trans.yaml --model_file=$trans_file --gpu_id=7 --hint="trans hangzhou" &> output/hangzhou/0121-exp-7e-4/up-/down-/img.trans.5e-1.log &
sleep 60


# meta_file=`tail output/hangzhou/0121-exp-5e-3/up-/img.meta-train.log -n 3 | head -n 1 | awk '{ print $7 }'`
# trans_file=`tail output/hangzhou/0121-exp-5e-3/up-/img.up.log -n 4 | head -n 1 | awk '{ print $11 }'`

# python run_meta_test.py --learning_rate=1e-2 --model=SASRecFeat --dataset=hangzhou --config_files=yamls/pretrain.yaml,yamls/hangzhou/img/meta-test.yaml --model_file=$meta_file --gpu_id=4 --hint="meta hangzhou test" &> output/hangzhou/0121-exp-5e-3/up-/down-/img.meta-test.1e-2.log &
# sleep 60
# python run_meta_test.py --learning_rate=1e-2 --model=SASRecFeat --dataset=hangzhou --config_files=yamls/pretrain.yaml,yamls/hangzhou/img/trans.yaml --model_file=$trans_file --gpu_id=4 --hint="trans hangzhou" &> output/hangzhou/0121-exp-5e-3/up-/down-/img.trans.1e-2.log &
# sleep 60

# python run_meta_test.py --learning_rate=5e-2 --model=SASRecFeat --dataset=hangzhou --config_files=yamls/pretrain.yaml,yamls/hangzhou/img/meta-test.yaml --model_file=$meta_file --gpu_id=5 --hint="meta hangzhou test" &> output/hangzhou/0121-exp-5e-3/up-/down-/img.meta-test.5e-2.log &
# sleep 60
# python run_meta_test.py --learning_rate=5e-2 --model=SASRecFeat --dataset=hangzhou --config_files=yamls/pretrain.yaml,yamls/hangzhou/img/trans.yaml --model_file=$trans_file --gpu_id=5 --hint="trans hangzhou" &> output/hangzhou/0121-exp-5e-3/up-/down-/img.trans.5e-2.log &
# sleep 60

# python run_meta_test.py --learning_rate=1e-1 --model=SASRecFeat --dataset=hangzhou --config_files=yamls/pretrain.yaml,yamls/hangzhou/img/meta-test.yaml --model_file=$meta_file --gpu_id=6 --hint="meta hangzhou test" &> output/hangzhou/0121-exp-5e-3/up-/down-/img.meta-test.1e-1.log &
# sleep 60
# python run_meta_test.py --learning_rate=1e-1 --model=SASRecFeat --dataset=hangzhou --config_files=yamls/pretrain.yaml,yamls/hangzhou/img/trans.yaml --model_file=$trans_file --gpu_id=6 --hint="trans hangzhou" &> output/hangzhou/0121-exp-5e-3/up-/down-/img.trans.1e-1.log &
# sleep 60

# python run_meta_test.py --learning_rate=5e-1 --model=SASRecFeat --dataset=hangzhou --config_files=yamls/pretrain.yaml,yamls/hangzhou/img/meta-test.yaml --model_file=$meta_file --gpu_id=7 --hint="meta hangzhou test" &> output/hangzhou/0121-exp-5e-3/up-/down-/img.meta-test.5e-1.log &
# sleep 60
# python run_meta_test.py --learning_rate=5e-1 --model=SASRecFeat --dataset=hangzhou --config_files=yamls/pretrain.yaml,yamls/hangzhou/img/trans.yaml --model_file=$trans_file --gpu_id=7 --hint="trans hangzhou" &> output/hangzhou/0121-exp-5e-3/up-/down-/img.trans.5e-1.log &
# sleep 60


wait