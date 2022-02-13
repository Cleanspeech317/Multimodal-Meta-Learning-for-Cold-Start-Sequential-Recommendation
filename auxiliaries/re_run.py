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


def get_city_mode(df, col):
    group = df.groupby(by=col)
    mode = {}
    for i, g in tqdm(group):
        m = g['cityid'].mode().values
        if len(m) == 1:
            mode[i] = m[0]
        else:
            mode[i] = list(m)
    return mode


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--model_file', '-m', type=str, default='', help='path of saved models')
    
    args, _ = parser.parse_known_args()
    
    config, model, dataset, train_data, valid_data, test_data = load_data_and_model(args.model_file)
    print(model.attn_mask_weight)
    # config.final_config_dict['load_col']['inter'].append('cityid')
    # dataset = create_dataset(config)
    # print(dataset.inter_feat)
    # user_city_mode = get_city_mode(dataset.inter_feat, 'user_id')
    # item_city_mode = get_city_mode(dataset.inter_feat, 'item_id')
    # with open('saved/city_mode.pth', 'wb') as f:
    #     pickle.dump((user_city_mode, item_city_mode), f)

    with open('saved/city_mode.pth', 'rb') as f:
        user_city_mode, item_city_mode = pickle.load(f)
    
    if test_data.is_sequential:
        uid_list = test_data.dataset.inter_feat['user_id']
        positive_item = test_data.dataset.inter_feat['item_id']
    else:
        uid_list = test_data.uid_list
        positive_item = test_data.uid2positive_item[uid_list]
        positive_item = torch.cat(list(positive_item))
    assert(len(positive_item) == len(uid_list))
    print(len(uid_list))
    topk_score, topk_iid_list = full_sort_topk(uid_list, model, test_data, k=10, device=config['device'])
    topk_score = topk_score.cpu()
    topk_iid_list = topk_iid_list.cpu()
    have_positive_mask = (positive_item.view(-1, 1) == topk_iid_list).any(1)
    print(have_positive_mask.sum() / len(uid_list))
    counter = np.zeros(11, dtype=np.int64)
    print(len(have_positive_mask), have_positive_mask.sum())
    print(len(uid_list[have_positive_mask]))
    # for u, i_list in zip(uid_list[have_positive_mask].numpy(), topk_iid_list[have_positive_mask].numpy()):
    for u, i_list in zip(uid_list.numpy(), topk_iid_list.numpy()):
        user_city = user_city_mode[u]
        cnt = 0
        # print(u, user_city_mode[u])
        for i in i_list:
            item_city = item_city_mode[i]
            if isinstance(item_city, list):
                if isinstance(user_city, list):
                    for uc in user_city:
                        if uc in item_city:
                            cnt += 1
                            break
                else:
                    cnt += (user_city in item_city)
            else:
                cnt += (user_city == item_city)
            # print('\t', i, item_city_mode[i])
        counter[cnt] += 1
        # break
    print(counter)
