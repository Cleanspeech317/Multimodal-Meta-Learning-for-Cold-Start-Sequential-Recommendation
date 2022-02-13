import argparse
from logging import getLogger
from tqdm import tqdm
import torch
import numpy as np
import pandas as pd
import pickle

from recbole.quick_start import load_data_and_model
from recbole.utils import init_logger, get_model, get_trainer, init_seed, set_color
from recbole.data import create_dataset
from recbole.utils.case_study import full_sort_topk, full_sort_scores

import logging
from logging import getLogger

import torch
import pickle

from recbole.config import Config
from recbole.data import create_dataset, data_preparation, save_split_dataloaders, load_split_dataloaders
from recbole.utils import init_logger, get_model, get_trainer, init_seed, set_color

import copy
from recbole.data.interaction import Interaction, cat_interactions

from collections import OrderedDict
import os


def get_cnt_dict(log):
    with os.popen(f'grep "val_interval" {log}') as f:
        content = f.read()
    city_id = eval(content.split('=')[1])['cityid']
    assert len(city_id) == 1
    city_id = eval(city_id[0])
    
    df = pd.read_csv('dataset/pretrain/pretrain.inter', sep='\t', usecols=['cityid:token', 'user_id:token', 'item_id:token'])
    df = df[df['cityid:token'] == city_id]
    # print(len(df))
    df_cnt = df.groupby('user_id:token').count().reset_index()
    cnt_dict = {
        uid: cnt
        for uid, cnt in zip(df_cnt['user_id:token'].values, df_cnt['item_id:token'].values)
    }
    return cnt_dict


def calc(cnt_dict, log):
    with os.popen(f'tail -n 1 {log}') as f:
        content = f.read()
    result = eval(content.split('test result: ')[1])
    
    # 1-5 6-10 11-20 21-100 101+
    hist = OrderedDict()
    uid_list = list(result.keys())
    metrics = list(result[uid_list[0]].keys())
    hist_key = ['3', '4', '5', '6', '7', '8', '9', '10', '11-20', '21-100', '100+']
    # hist_key = ['4', '5', '6', '7', '8', '9', '10', '11-20', '21-100', '100+']
    for key in hist_key:
        hist[key] = OrderedDict()
        for metric in metrics:
            hist[key][metric] = []
    
    for uid, res in result.items():
        cnt = cnt_dict[int(uid)]
        if 1 <= cnt <= 10:
            key = str(cnt)
        elif 11 <= cnt <= 20:
            key = '11-20'
        elif 21 <= cnt <= 100:
            key = '21-100'
        else:
            key = '100+'
        for metric in metrics:
            hist[key][metric].append(res[metric])

    for key in hist_key:
        if len(hist[key][metrics[0]]) == 0:
            del hist[key]

    return hist
    # for key in hist_key:
    #     print(key, len(hist[key][metrics[0]]))
    #     for metric in metrics:
    #         print('%.4f' % np.mean(hist[key][metric]), end=' ')
    #     print()


def main(args):
    cnt_dict = get_cnt_dict(args.trans_log)
    trans = calc(cnt_dict, args.trans_log)
    meta = calc(cnt_dict, args.meta_log)
    hist_key = list(trans.keys())
    metrics = list(trans[hist_key[0]].keys())
    for key in hist_key:
        print(key, len(trans[key][metrics[0]]))
        print('trans:', end=' ')
        for metric in metrics:
            print('%.4f' % np.mean(trans[key][metric]), end=' ')
        print()
        print('meta:', end=' ')
        for metric in metrics:
            print('%.4f' % np.mean(meta[key][metric]), end=' ')
        print()
        

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--trans_log', '-tl', type=str, default='', help='trans log')
    parser.add_argument('--meta_log', '-ml', type=str, default='', help='meta log')

    args, _ = parser.parse_known_args()

    result = main(args)
    # print(result)
