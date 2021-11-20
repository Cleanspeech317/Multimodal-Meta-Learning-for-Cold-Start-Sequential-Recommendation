# -*- coding: utf-8 -*-
# @Time   : 2020/7/24 15:57
# @Author : Shanlei Mu
# @Email  : slmu@ruc.edu.cn
# @File   : run_hyper.py
# UPDATE:
# @Time   : 2020/8/20 21:17, 2020/8/29
# @Author : Zihan Lin, Yupeng Hou
# @Email  : linzihan.super@foxmail.com, houyupeng@ruc.edu.cn

import argparse

from recbole.trainer import HyperTuning
from recbole.quick_start import objective_function


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--model', '-m', type=str, default='BPR', help='name of models')
    parser.add_argument('--config_files', type=str, default=None, help='fixed config files')
    parser.add_argument('--params_file', type=str, default=None, help='parameters file')
    parser.add_argument('--output_file', type=str, default='hyper_example.result', help='output file')
    parser.add_argument('--hint', type=str, default='', help='hint for run_hyper')
    args, _ = parser.parse_known_args()

    # plz set algo='exhaustive' to use exhaustive search, in this case, max_evals is auto set
    config_file_list = args.config_files.strip().split(' ') if args.config_files else None
    hp = HyperTuning(objective_function, algo='exhaustive',
                     params_file=args.params_file, fixed_config_file_list=config_file_list)
    hp.run()
    hp.export_result(output_file=args.output_file)
    print('best params: ', hp.best_params)
    print('best result: ')
    result = hp.params2result[hp.params2str(hp.best_params)]
    print(result)
    try:
        from mtjupyter_utils import remind
        message = ' '.join([str(args.model), args.hint]) + '\n'
        message += ' '.join(map(str, result['test_result'].values()))
        remind(message)
    except Exception as e:
        pass


if __name__ == '__main__':
    main()
