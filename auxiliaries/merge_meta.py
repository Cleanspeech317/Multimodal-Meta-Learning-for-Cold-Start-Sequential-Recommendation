import numpy as np
from collections import OrderedDict
import argparse


def main(args):
    with open(args.log1, 'r') as f:
        bj_str = f.read()
    bj_result = eval(bj_str.split('test result: ')[1])
    list(bj_result.keys())[:10]
    with open(args.log2, 'r') as f:
        sh_str = f.read()
    sh_result = eval(sh_str.split('test result: ')[1])

    assert bj_result.keys() == sh_result.keys()
    
    uid_list = list(bj_result.keys())
    metric_list = list(bj_result[uid_list[0]].keys())

    result = OrderedDict()
    for key in metric_list:
        result[key] = []
    for uid in uid_list:
        if bj_result[uid][metric_list[0]] >= sh_result[uid][metric_list[0]]:
            for key in metric_list:
                result[key].append(bj_result[uid][key])
        else:
            for key in metric_list:
                result[key].append(sh_result[uid][key])
    print(metric_list)
    for key in metric_list:
        print('%.4f' % np.mean(result[key]), end=' ')
    print()


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--log1', '-l1', type=str, default='', help='log1')
    parser.add_argument('--log2', '-l2', type=str, default='', help='log2')

    args, _ = parser.parse_known_args()

    result = main(args)
    # print(result)