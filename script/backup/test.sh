# python run_hyper.py --dataset=shanghai --model=BPR --config_files=yamls/pretrain.yaml,yamls/shanghai/BPR/down.yaml --gpu_id=3 --params_file=hypers/BPR.test &> output/shanghai/0121-exp-down/up-/down-/BPR.down.hyper &
# sleep 30
# python run_hyper.py --dataset=hangzhou --model=BPR --config_files=yamls/pretrain.yaml,yamls/hangzhou/BPR/down.yaml --gpu_id=1 --params_file=hypers/BPR.test &> output/hangzhou/0121-exp-down/up-/down-/BPR.down.hyper &
# sleep 30
# python run_hyper.py --dataset=changsha --model=BPR --config_files=yamls/pretrain.yaml,yamls/changsha/BPR/down.yaml --gpu_id=2 --params_file=hypers/BPR.test &> output/changsha/0121-exp-down/up-/down-/BPR.down.hyper &
# sleep 30
# python run_hyper.py --dataset=lanzhou --model=BPR --config_files=yamls/pretrain.yaml,yamls/lanzhou/BPR/down.yaml --gpu_id=0 --params_file=hypers/BPR.test &> output/lanzhou/0121-exp-down/up-/down-/BPR.down.hyper &
# wait

# python run_hyper.py --dataset=shanghai --model=LightGCN --config_files=yamls/pretrain.yaml,yamls/shanghai/LightGCN/down.yaml --gpu_id=3 --params_file=hypers/LightGCN.test &> output/shanghai/0121-exp-down/up-/down-/LightGCN.down.hyper &
# sleep 30
# python run_hyper.py --dataset=hangzhou --model=LightGCN --config_files=yamls/pretrain.yaml,yamls/hangzhou/LightGCN/down.yaml --gpu_id=1 --params_file=hypers/LightGCN.test &> output/hangzhou/0121-exp-down/up-/down-/LightGCN.down.hyper &
# sleep 30
# python run_hyper.py --dataset=changsha --model=LightGCN --config_files=yamls/pretrain.yaml,yamls/changsha/LightGCN/down.yaml --gpu_id=2 --params_file=hypers/LightGCN.test &> output/changsha/0121-exp-down/up-/down-/LightGCN.down.hyper &
# sleep 30
# python run_hyper.py --dataset=lanzhou --model=LightGCN --config_files=yamls/pretrain.yaml,yamls/lanzhou/LightGCN/down.yaml --gpu_id=0 --params_file=hypers/LightGCN.test &> output/lanzhou/0121-exp-down/up-/down-/LightGCN.down.hyper &
# wait

python run_hyper.py --dataset=shanghai --model=LR --config_files=yamls/pretrain.yaml,yamls/shanghai/LR/down.yaml --gpu_id=3 --params_file=hypers/LR.test &> output/shanghai/0121-exp-down/up-/down-/LR.down.hyper &
sleep 30
python run_hyper.py --dataset=hangzhou --model=LR --config_files=yamls/pretrain.yaml,yamls/hangzhou/LR/down.yaml --gpu_id=1 --params_file=hypers/LR.test &> output/hangzhou/0121-exp-down/up-/down-/LR.down.hyper &
sleep 30
python run_hyper.py --dataset=changsha --model=LR --config_files=yamls/pretrain.yaml,yamls/changsha/LR/down.yaml --gpu_id=2 --params_file=hypers/LR.test &> output/changsha/0121-exp-down/up-/down-/LR.down.hyper &
# sleep 30
# python run_hyper.py --dataset=lanzhou --model=LR --config_files=yamls/pretrain.yaml,yamls/lanzhou/LR/down.yaml --gpu_id=0 --params_file=hypers/LR.test &> output/lanzhou/0121-exp-down/up-/down-/LR.down.hyper &
wait

# python run_hyper.py --dataset=shanghai --model=DIN --config_files=yamls/pretrain.yaml,yamls/shanghai/DIN/down.yaml --gpu_id=3 --params_file=hypers/DIN.test &> output/shanghai/0121-exp-down/up-/down-/DIN.down.hyper &
# sleep 30
# python run_hyper.py --dataset=hangzhou --model=DIN --config_files=yamls/pretrain.yaml,yamls/hangzhou/DIN/down.yaml --gpu_id=1 --params_file=hypers/DIN.test &> output/hangzhou/0121-exp-down/up-/down-/DIN.down.hyper &
# sleep 30
# python run_hyper.py --dataset=changsha --model=DIN --config_files=yamls/pretrain.yaml,yamls/changsha/DIN/down.yaml --gpu_id=2 --params_file=hypers/DIN.test &> output/changsha/0121-exp-down/up-/down-/DIN.down.hyper &
# sleep 30
# python run_hyper.py --dataset=lanzhou --model=DIN --config_files=yamls/pretrain.yaml,yamls/lanzhou/DIN/down.yaml --gpu_id=0 --params_file=hypers/DIN.test &> output/lanzhou/0121-exp-down/up-/down-/DIN.down.hyper &
# wait
