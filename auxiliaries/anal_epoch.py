import numpy as np
import pandas as pd
import pickle
import argparse
from collections import OrderedDict

pd.set_option('display.max_rows', None)
# {id: {epoch: {metric: value}}}


def get_epoch_result(result):
    uid_list = list(result.keys())
    epoch_list = list(result[uid_list[0]].keys())
    metrics = list(result[uid_list[0]][epoch_list[0]].keys())
    epoch_result = OrderedDict()
    for epoch in epoch_list:
        epoch_result[epoch] = OrderedDict()
        for metric in metrics:
            epoch_result[epoch][metric] = []
    for uid in uid_list:
        for epoch in epoch_list:
            for metric in metrics:
                epoch_result[epoch][metric].append(result[uid][epoch][metric])
    for epoch in epoch_list:
        for metric in metrics:
            epoch_result[epoch][metric] = np.mean(epoch_result[epoch][metric])
    return epoch_result


def main(args):
    with open(args.result_file, 'rb') as f:
        result = pickle.load(f)
    uid_list = list(result.keys())
    epoch_list = list(result[uid_list[0]].keys())
    metrics = list(result[uid_list[0]][epoch_list[0]].keys())
    epoch_result = OrderedDict()
    for epoch in epoch_list:
        epoch_result[epoch] = OrderedDict()
        for metric in metrics:
            epoch_result[epoch][metric] = []
    for uid in uid_list:
        for epoch in epoch_list:
            for metric in metrics:
                epoch_result[epoch][metric].append(result[uid][epoch][metric])
    df_dict = OrderedDict()
    for metric in metrics:
        df_dict[metric] = []
    for epoch in epoch_list:
        for metric in metrics:
            epoch_result[epoch][metric] = np.mean(epoch_result[epoch][metric])
            df_dict[metric].append(epoch_result[epoch][metric])
        # print(epoch, epoch_result[epoch])
    df = pd.DataFrame(df_dict)
    print(df)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--result_file', '-r', type=str, default=None, help='result file')

    args, _ = parser.parse_known_args()
    main(args)
