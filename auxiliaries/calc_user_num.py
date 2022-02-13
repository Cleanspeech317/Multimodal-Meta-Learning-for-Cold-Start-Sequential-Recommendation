import logging
from collections import OrderedDict
from logging import getLogger
import numpy as np
import pandas as pd
import argparse
import torch
import pickle

from recbole.config import Config
from recbole.data import create_dataset
from recbole.utils import init_seed


def main(model=None, dataset=None, config_file_list=None, config_dict=None, saved=True):
    r""" A fast running api, which includes the complete process of
    training and testing a model on a specified dataset

    Args:
        model (str, optional): Model name. Defaults to ``None``.
        dataset (str, optional): Dataset name. Defaults to ``None``.
        config_file_list (list, optional): Config files used to modify experiment parameters. Defaults to ``None``.
        config_dict (dict, optional): Parameters dictionary used to modify experiment parameters. Defaults to ``None``.
        saved (bool, optional): Whether to save the model. Defaults to ``True``.
    """
    # configurations initialization
    config = Config(model=model, dataset=dataset, config_file_list=config_file_list, config_dict=config_dict)
    init_seed(config['seed'], config['reproducibility'])
    # logger initialization
    logging.basicConfig(level=logging.ERROR)

    # dataset filtering
    dataset = create_dataset(config)
    user_num = len(np.unique(dataset.inter_feat[dataset.uid_field].values))

    print(user_num)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--model', '-m', type=str, default='BPR', help='name of models')
    parser.add_argument('--dataset', '-d', type=str, default='ml-100k', help='name of datasets')
    parser.add_argument('--config_files', type=str, default=None, help='config files')
    parser.add_argument('--saved', type=str, default='True', help='saved')
    parser.add_argument('--hint', type=str, default='', help='hint for run_recbole')

    args, _ = parser.parse_known_args()

    config_file_list = args.config_files.strip().split(',') if args.config_files else None
    saved = (args.saved.lower() == 'true')
    result = main(model=args.model, dataset=args.dataset, config_file_list=config_file_list, saved=saved)
