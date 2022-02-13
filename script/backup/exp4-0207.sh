bash exp11-meta.sh txt hangzhou 1 &> /dev/null &
sleep 60
bash exp11-meta.sh SASRec shanghai 7 &> /dev/null &
sleep 60
bash exp11-meta.sh txt shanghai 6 &> /dev/null &
sleep 60
wait 57041
bash exp11-meta.sh img hangzhou 0 &> /dev/null &
sleep 60
bash exp11-meta.sh img shanghai 7 &> /dev/null &

