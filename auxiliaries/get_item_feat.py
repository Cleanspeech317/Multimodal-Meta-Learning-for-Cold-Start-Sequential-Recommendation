# @Time   : 2020/7/20
# @Author : Shanlei Mu
# @Email  : slmu@ruc.edu.cn

# UPDATE
# @Time   : 2020/10/3, 2020/10/1
# @Author : Yupeng Hou, Zihan Lin
# @Email  : houyupeng@ruc.edu.cn, zhlin@ruc.edu.cn


import argparse
import torch
import logging
from collections import OrderedDict
from logging import getLogger

import torch
import os
import numpy as np
import pandas as pd
from tqdm import tqdm

from recbole.config import Config
from recbole.data import create_dataset, data_preparation, save_split_dataloaders, load_split_dataloaders, \
    MetaLearningDataLoader
from recbole.data.dataset import MetaSeqDataset, MetaTrainDataset, MetaTestDataset
from recbole.trainer import MetaLearningTrainer, MetaTestTrainer, MetaFusionTrainer
from recbole.utils import init_logger, get_model, get_trainer, init_seed, set_color


def process(model=None, dataset=None, config_file_list=None, config_dict=None, saved=True):
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
    init_logger(config)
    logger = getLogger()

    logger.info(config)

    # dataset filtering
    dataset = create_dataset(config)
    logger.info(dataset)

    if isinstance(config['item_feat_emb'], str):
        config['item_feat_emb'] = [config['item_feat_emb']]
    # item_df = {
    #     'item_id:token': dataset.field2id_token[dataset.iid_field][1:],
    # }
    item_feat_list = []
    for item_emb_file in config['item_feat_emb']:
        item_emb = torch.load(item_emb_file)
        item_feat = torch.zeros((dataset.item_num, item_emb['embs'].size(-1)))
        token2id = dataset.field2token_id[dataset.iid_field]
        for item, emb in zip(item_emb['item_id'], item_emb['embs']):
            if item in token2id:
                item_id = token2id[item]
                item_feat[item_id] = emb
        # item_feat_file = os.path.join(os.path.dirname(item_emb_file), f'{config["dataset"]}-{os.path.basename(item_emb_file)}')
        # print(item_feat_file)
        # torch.save(item_feat, item_feat_file)
        # new_item_feat = np.array([None] * dataset.item_num)
        # for i in tqdm(range(dataset.item_num)):
        #     new_item_feat[i] = ' '.join(map(str, item_feat[i].numpy()))
        # item_df[f"{os.path.basename(item_emb_file).split('_', 1)[1].split('.')[0]}:float_seq"] = new_item_feat[1:]
        item_feat_list.append(item_feat)
    # item_df = pd.DataFrame(item_df)
    # print(item_df.head())
    # item_df.to_csv(f'dataset/{config["dataset"]}/{config["dataset"]}.item', sep='\t', index=False)
    
    item_feat = torch.cat(item_feat_list, dim=-1)
    item_feat_file = os.path.join(os.path.dirname(item_emb_file), f'{config["dataset"]}-item_emb.pth')
    print(item_feat_file)
    print(item_feat.shape)
    torch.save(item_feat, item_feat_file)
    item_feat = item_feat.to(config['device'])
    if config['dist'] == 'dot':
        sim = item_feat @ item_feat.T
    elif config['dist'] == 'cos':
        sim = item_feat @ item_feat.T
        norm = torch.norm(item_feat, p=2, dim=-1)
        norm = torch.maximum(norm, torch.tensor(1e-8, device=config['device']))
        sim = sim / norm / norm.unsqueeze(-1)
    elif config['dist'] == 'L2':
        sim = -torch.norm(item_feat[:, None] - item_feat, p=2, dim=-1)
    sim[0, :] = sim[:, 0] = float('-inf')
    sim.fill_diagonal_(float('-inf'))
    top_sim, index = torch.topk(sim, k=100, dim=-1)
    index = index.cpu()
    item_neighbour_file = os.path.join(os.path.dirname(item_emb_file), f'{config["dataset"]}-{config["dist"]}-neighbour.pth')
    print(index.shape)
    print(index)
    print(item_neighbour_file)
    torch.save(index, item_neighbour_file)


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
    result = process(model=args.model, dataset=args.dataset, config_file_list=config_file_list, saved=saved)
