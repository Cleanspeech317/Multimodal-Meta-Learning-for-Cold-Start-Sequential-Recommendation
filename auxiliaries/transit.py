# @Time   : 2020/7/20
# @Author : Shanlei Mu
# @Email  : slmu@ruc.edu.cn

# UPDATE
# @Time   : 2020/10/3, 2020/10/1
# @Author : Yupeng Hou, Zihan Lin
# @Email  : houyupeng@ruc.edu.cn, zhlin@ruc.edu.cn


import argparse
from collections import OrderedDict

from recbole.quick_start import run_recbole, load_data_and_model

import logging
from logging import getLogger

import torch
import pickle

from recbole.config import Config
from recbole.data import create_dataset, data_preparation, save_split_dataloaders, load_split_dataloaders
from recbole.utils import init_logger, get_model, get_trainer, init_seed, set_color


def transit(model=None, dataset=None, config_file_list=None, config_dict=None, saved=True):
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

    # dataset splitting
    train_data, valid_data, test_data = data_preparation(config, dataset)

    # model loading and initialization
    init_seed(config['seed'], config['reproducibility'])
    model = get_model(config['model'])(config, train_data.dataset).to(config['device'])

    # load old parameters
    if isinstance(config['model_file'], str):
        checkpoint = torch.load(config['model_file'])
        checkpoint['state_dict'].pop('item_embedding.weight', None)
        checkpoint['state_dict'].pop('item_projection.weight', None)
        checkpoint['state_dict'].pop('item_projection.bias', None)
        checkpoint['state_dict'].pop('item_feat', None)
        state_dict = checkpoint['state_dict']
    elif isinstance(config['model_file'], list):
        if config['model_file_weight']:
            weight = torch.tensor(config['model_file_weight'])
            weight /= weight.sum()
        else:
            weight = None
        state_dict_list = []
        state_dict = OrderedDict()
        for file in config['model_file']:
            checkpoint = torch.load(file)
            checkpoint['state_dict'].pop('item_embedding.weight', None)
            checkpoint['state_dict'].pop('item_projection.weight', None)
            checkpoint['state_dict'].pop('item_projection.bias', None)
            checkpoint['state_dict'].pop('item_feat', None)
            state_dict_list.append(checkpoint['state_dict'])
        for key in state_dict_list[0].keys():
            value = torch.stack([s[key] for s in state_dict_list])
            if weight is None:
                value = value.mean(0)
            else:
                value = (weight.view(-1, *([1] * (value.dim() - 1))).to(value.device) * value).sum(0)
            state_dict[key] = value
    else:
        raise ValueError
    current_state_dict = model.state_dict()
    for name in ['item_embedding.weight', 'item_feat', 'item_projection.weight', 'item_projection.bias']:
        if name in current_state_dict:
            state_dict[name] = current_state_dict[name]
    model.load_state_dict(state_dict)
    
    logger.info(model)

    # trainer loading and initialization
    trainer = get_trainer(config['MODEL_TYPE'], config['model'])(config, model)

    # model training
    best_valid_score, best_valid_result = trainer.fit(
        train_data, valid_data, saved=saved, show_progress=config['show_progress']
    )

    # model evaluation
    test_result = trainer.evaluate(test_data, load_best_model=saved, show_progress=config['show_progress'])

    logger.info(set_color('best valid ', 'yellow') + f': {best_valid_result}')
    logger.info(set_color('test result', 'yellow') + f': {test_result}')

    return {
        'best_valid_score': best_valid_score,
        'valid_score_bigger': config['valid_metric_bigger'],
        'best_valid_result': best_valid_result,
        'test_result': test_result
    }


if __name__ == '__main__':
    try:
        parser = argparse.ArgumentParser()
        parser.add_argument('--model', '-m', type=str, default='BPR', help='name of models')
        parser.add_argument('--dataset', '-d', type=str, default='ml-100k', help='name of datasets')
        parser.add_argument('--config_files', type=str, default=None, help='config files')
        parser.add_argument('--saved', type=str, default='True', help='saved')
        parser.add_argument('--hint', type=str, default='', help='hint for transit')

        args, _ = parser.parse_known_args()

        config_file_list = args.config_files.strip().split(',') if args.config_files else None
        saved = (args.saved.lower() == 'true')
        result = transit(model=args.model, dataset=args.dataset, config_file_list=config_file_list, saved=saved)
        try:
            from mtjupyter_utils import remind
            message = ' '.join([str(args.model), args.hint]) + '\n'
            message += ' '.join(map(str, result['test_result'].values()))
            remind(message)
        except Exception as e:
            pass
    except Exception as err:
        try:
            from mtjupyter_utils import remind
            remind(str(err))
            raise err
        except Exception as e:
            raise err
