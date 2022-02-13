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
    with os.popen(f'grep "val_interval" {repr(log)}') as f:
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
    with os.popen(f'tail -n 1 {repr(log)}') as f:
        content = f.read()
    result = eval(content.split('test result: ')[1])

    hist = OrderedDict()
    uid_list = list(result.keys())
    metrics = list(result[uid_list[0]].keys())
    hist_cmp2func = [
        # (lambda x: 1 <= x <= 10, lambda x: str(x)),
        (lambda x: x <= 20, lambda x: '20-'),
        (lambda x: x <= 30, lambda x: '30-'),
        (lambda x: x <= 40, lambda x: '40-'),
        (lambda x: x <= 50, lambda x: '50-'),
        (lambda x: True, lambda x: 'all'),
        # (lambda x: x > 50, lambda x: '50+'),
        # (lambda x: x > 100, lambda x: '100+'),
    ]
    
    for uid, res in result.items():
        cnt = cnt_dict[int(uid)]
        for cmp, func in hist_cmp2func:
            if cmp(cnt):
                key = func(cnt)
                if key not in hist:
                    hist[key] = OrderedDict()
                    for metric in metrics:
                        hist[key][metric] = []
                for metric in metrics:
                    hist[key][metric].append(res[metric])

    return hist


def main(args):
    trans_log = os.path.join(args.dir4log, args.trans_log)
    meta_log = os.path.join(args.dir4log, args.meta_log)
    cnt_dict = get_cnt_dict(trans_log)
    trans = calc(cnt_dict, trans_log)
    meta = calc(cnt_dict, meta_log)
    hist_key = list(trans.keys())
    metrics = list(trans[hist_key[0]].keys())
    for key in hist_key:
        print('%4s %5s' % (key, len(trans[key][metrics[0]])), end= ' ')
        for metric in metrics:
            trans_res = np.mean(trans[key][metric])
            meta_res = np.mean(meta[key][metric])
            improvment = ((meta_res - trans_res) / trans_res) * 100
            res = '%10.4f%%' % improvment
            if improvment > 0:
                res = '\033[1;31m' + res + '\033[0m'
            print(res, end=' ')
        print()
        # print(key, len(trans[key][metrics[0]]))
        # print('trans:', end=' ')
        # for metric in metrics:
        #     result_str = '%.4f' % np.mean(trans[key][metric])
        #     if np.mean(trans[key][metric]) >= np.mean(meta[key][metric]):
        #         result_str = '\033[1;31m' + result_str + '\033[0m'
        #     print('%s' % result_str, end=' ')
        # print()
        # print('meta:', end=' ')
        # for metric in metrics:
        #     result_str = '%.4f' % np.mean(meta[key][metric])
        #     if np.mean(meta[key][metric]) >= np.mean(trans[key][metric]):
        #         result_str = '\033[1;31m' + result_str + '\033[0m'
        #     print('%s' % result_str, end=' ')
        # print()
        

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--dir4log', '-d', type=str, default='', help='dir for log')
    parser.add_argument('--trans_log', '-tl', type=str, default='SASRec.trans.log', help='trans log')
    parser.add_argument('--meta_log', '-ml', type=str, default='SASRec.meta-test.log', help='meta log')

    args, _ = parser.parse_known_args()

    result = main(args)
    # print(result)
