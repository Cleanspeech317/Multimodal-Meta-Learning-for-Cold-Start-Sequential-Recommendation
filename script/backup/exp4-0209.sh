wait 83301
bash exp11-hyper-attention-fusion-meta-IEG.sh shanghai "2e-3 1e-3 5e-4 1e-4 5e-5 1e-5" "[128]" 3 &> /dev/null &
sleep 20
wait 90480
bash exp11-hyper-attention-fusion-trans.sh lanzhou "2e-3 1e-3 5e-4 1e-4 5e-5 1e-5" "[128]" 4 &> /dev/null &
wait 91951
sleep 20
bash exp11-hyper-attention-fusion-trans.sh changsha "2e-3 1e-3 5e-4 1e-4 5e-5 1e-5" "[128]" 5 &> /dev/null &
wait 93084
sleep 20
bash exp11-hyper-attention-fusion-trans.sh hangzhou "2e-3 1e-3 5e-4 1e-4 5e-5 1e-5" "[128]" 6 &> /dev/null &
wait 93876
sleep 20
bash exp11-hyper-attention-fusion-trans.sh shanghai "2e-3 1e-3 5e-4 1e-4 5e-5 1e-5" "[128]" 7 &> /dev/null &
wait

