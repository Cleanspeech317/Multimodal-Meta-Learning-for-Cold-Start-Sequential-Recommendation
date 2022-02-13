import numpy as np
import pandas as pd
import pickle
import argparse
from collections import OrderedDict

pd.set_option('display.max_rows', None)
# {id: {epoch: {metric: value}}}
# mrr@10


def get_no_eval_result(test_result):
    uid_list = list(test_result.keys())
    epoch_list = list(test_result[uid_list[0]].keys())
    metrics = list(test_result[uid_list[0]][epoch_list[0]].keys())
    epoch_result = OrderedDict()
    for epoch in epoch_list:
        epoch_result[epoch] = OrderedDict()
        for metric in metrics:
            epoch_result[epoch][metric] = []
    for uid in uid_list:
        for epoch in epoch_list:
            for metric in metrics:
                epoch_result[epoch][metric].append(test_result[uid][epoch][metric])
    df_dict = OrderedDict()
    for metric in metrics:
        df_dict[metric] = []
    for epoch in epoch_list:
        for metric in metrics:
            epoch_result[epoch][metric] = np.mean(epoch_result[epoch][metric])
            df_dict[metric].append(epoch_result[epoch][metric])
    df = pd.DataFrame(df_dict)
    return df


def get_eval_result(eval_result, test_result):
    uid_list = list(eval_result.keys())
    epoch_list = list(eval_result[uid_list[0]].keys())
    metrics = list(eval_result[uid_list[0]][epoch_list[0]].keys())
    best_epoch = OrderedDict()
    for uid in uid_list:
        best_epoch[uid] = OrderedDict()
        if len(eval_result[uid]) == 0:
            for epoch in epoch_list:
                best_epoch[uid][epoch] = epoch
        else:
            last_best_epoch = None
            for epoch in epoch_list:
                if last_best_epoch is None or eval_result[uid][epoch]['mrr@10'] >= eval_result[uid][last_best_epoch]['mrr@10']:
                    last_best_epoch = epoch
                best_epoch[uid][epoch] = last_best_epoch
    
    epoch_result = OrderedDict()
    for epoch in epoch_list:
        epoch_result[epoch] = OrderedDict()
        for metric in metrics:
            epoch_result[epoch][metric] = []
    for uid in uid_list:
        for epoch in epoch_list:
            for metric in metrics:
                epoch_result[epoch][metric].append(test_result[uid][best_epoch[uid][epoch]][metric])
    df_dict = OrderedDict()
    for metric in metrics:
        df_dict[metric] = []
    for epoch in epoch_list:
        for metric in metrics:
            epoch_result[epoch][metric] = np.mean(epoch_result[epoch][metric])
            df_dict[metric].append(epoch_result[epoch][metric])
    df = pd.DataFrame(df_dict)
    return df


def main(args):
    with open(args.result_file, 'rb') as f:
        eval_result, test_result = pickle.load(f)
    no_eval_df = get_no_eval_result(test_result)
    eval_df = get_eval_result(eval_result, test_result)
    print(no_eval_df)
    print(eval_df)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--result_file', '-r', type=str, default=None, help='result file')

    args, _ = parser.parse_known_args()
    main(args)
