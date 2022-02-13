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


def main(args):
    checkpoint = torch.load(args.model_file)
    config = checkpoint['config']

    init_seed(config['seed'], config['reproducibility'])
    init_logger(config)
    logger = getLogger()

    dataset = create_dataset(config)
    city = dataset.token2id('cityid', args.city)
    dataset.inter_feat = dataset.inter_feat[dataset.inter_feat['cityid'] == city]
    logger.info(dataset)
    
    train_data, valid_data, test_data = data_preparation(config, dataset)

    init_seed(config['seed'], config['reproducibility'])
    model = get_model(config['model'])(config, train_data.dataset).to(config['device'])
    model.load_state_dict(checkpoint['state_dict'])
    model.load_other_parameter(checkpoint.get('other_parameter'))
    
    trainer = get_trainer(config['MODEL_TYPE'], config['model'])(config, model)
    test_result = trainer.evaluate(test_data, load_best_model=False, show_progress=config['show_progress'])
    print(test_result)
    return test_result


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--model_file', '-m', type=str, default='', help='model_file_1')
    parser.add_argument('--city', '-c', type=str, default='1', help='city')

    args, _ = parser.parse_known_args()

    result = main(args)
    # print(result)
