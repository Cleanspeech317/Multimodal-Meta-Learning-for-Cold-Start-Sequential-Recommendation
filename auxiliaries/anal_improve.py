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


def get_result(log):
    with os.popen(f'tail {repr(log)} -n 2 | head -n 1') as f:
        content = f.read()
    result = eval(content.split(': ')[1])

    return result


def main(args):
    trans_log = os.path.join(args.dir4log, args.trans_log)
    meta_log = os.path.join(args.dir4log, args.meta_log)
    trans = get_result(trans_log)
    meta = get_result(meta_log)
    metrics = list(trans.keys())
    for metric in metrics:
        trans_res = trans[metric]
        meta_res = meta[metric]
        improvment = ((meta_res - trans_res) / trans_res) * 100
        res = '%10.4f%%' % improvment
        if improvment > 0:
            res = '\033[1;31m' + res + '\033[0m'
        print(res, end=' ')
    print()
        

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--dir4log', '-d', type=str, default='', help='dir for log')
    parser.add_argument('--trans_log', '-tl', type=str, default='SASRec.trans.log', help='trans log')
    parser.add_argument('--meta_log', '-ml', type=str, default='SASRec.meta-test.log', help='meta log')

    args, _ = parser.parse_known_args()

    result = main(args)
    # print(result)
