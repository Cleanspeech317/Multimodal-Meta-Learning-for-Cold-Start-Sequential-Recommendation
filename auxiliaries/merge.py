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


def merge_struct(struct_a, struct_b):
    topk_a = struct_a['rec.topk']
    topk_b = struct_b['rec.topk']
    merge_topk = topk_a.clone()
    for i in range(len(topk_a)):
        a = topk_a[i].nonzero(as_tuple=False).squeeze(-1)[0]
        b = topk_b[i].nonzero(as_tuple=False).squeeze(-1)[0]
        if a > b:
            merge_topk[i] = topk_b[i]
    merge_struct = copy.deepcopy(struct_a)
    merge_struct.set('rec.topk', merge_topk)
    return merge_struct


def get_struct(checkpoint, train_data, valid_data, test_data):
    config = checkpoint['config']

    init_seed(config['seed'], config['reproducibility'])
    model = get_model(config['model'])(config, train_data.dataset).to(config['device'])
    model.load_state_dict(checkpoint['state_dict'])
    model.load_other_parameter(checkpoint.get('other_parameter'))
    
    trainer = get_trainer(config['MODEL_TYPE'], config['model'])(config, model)
    test_result = trainer.evaluate(test_data, load_best_model=False, show_progress=config['show_progress'])
    print(test_result)
    struct = test_result.struct
    return struct, model, trainer


def full_sort_batch_eval(model_1, model_2, batched_data, tot_item_num, device, alpha=0.5):
    interaction, history_index, positive_u, positive_i = batched_data
    scores_1 = model_1.full_sort_predict(interaction.to(device))
    scores_2 = model_2.full_sort_predict(interaction.to(device))
    # print(scores_1.mean(), scores_2.mean())
    scores = alpha * scores_1 + (1. - alpha) * scores_2
    
    scores = scores.view(-1, tot_item_num)
    scores[:, 0] = -np.inf
    if history_index is not None:
        scores[history_index] = -np.inf
    return interaction, scores, positive_u, positive_i


@torch.no_grad()
def evaluate(eval_data, model_1, model_2, eval_collector, evaluator, device, alpha=0.5, show_progress=False):
    model_1.eval()
    model_2.eval()
    tot_item_num = eval_data.dataset.item_num

    iter_data = (
        tqdm(
            eval_data,
            total=len(eval_data),
            ncols=100,
            desc=set_color(f"Evaluate   ", 'pink'),
        ) if show_progress else eval_data
    )
    for batch_idx, batched_data in enumerate(iter_data):
        interaction, scores, positive_u, positive_i = full_sort_batch_eval(model_1, model_2, batched_data, tot_item_num, device, alpha)
        eval_collector.eval_batch_collect(scores, interaction, positive_u, positive_i)
    struct = eval_collector.get_data_struct()
    result = evaluator.evaluate(struct)

    return result


def main(args):
    checkpoint_1 = torch.load(args.model_file_1)
    config = checkpoint_1['config']

    init_seed(config['seed'], config['reproducibility'])
    init_logger(config)
    logger = getLogger()

    dataset = create_dataset(config)
    logger.info(dataset)
    train_data, valid_data, test_data = data_preparation(config, dataset)

    struct_1, model_1, trainer = get_struct(checkpoint_1, train_data, valid_data, test_data)

    checkpoint_2 = torch.load(args.model_file_2)

    struct_2, model_2, _ = get_struct(checkpoint_2, train_data, valid_data, test_data)
    
    struct = merge_struct(struct_1, struct_2)
    result = trainer.evaluator.evaluate(struct)
    print('merge result:', result)
    
    for a in range(11):
        print(a / 10.0)
        valid_result = evaluate(valid_data, model_1, model_2, trainer.eval_collector, trainer.evaluator, device=config['device'], alpha=a/10.0)
        print('valid_result:', valid_result)
        result = evaluate(test_data, model_1, model_2, trainer.eval_collector, trainer.evaluator, device=config['device'], alpha=a/10.0)
        print('weighted_result: ', result)
    # return result


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--model_file_1', '-m1', type=str, default='', help='model_file_1')
    parser.add_argument('--model_file_2', '-m2', type=str, default='', help='model_file_2')
    parser.add_argument('--alpha', '-a', type=float, default=0.5, help='alpha')

    args, _ = parser.parse_known_args()

    result = main(args)
    # print(result)
