# -*- coding: utf-8 -*-
# @Time    : 2021/10/24 10:00
# @Author  : Yushuo Chen
# @Email   : chenyushuo@ruc.edu.cn

"""
################################################
"""

import numpy as np
import torch

from recbole.data.dataloader.abstract_dataloader import AbstractDataLoader


class PretrainRecDataLoader(AbstractDataLoader):
    """

    Args:
        config (Config): The config of dataloader.
        dataset (Dataset): The dataset of dataloader.
        sampler (Sampler): The sampler of dataloader.
        shuffle (bool, optional): Whether the dataloader will be shuffle after a round. Defaults to ``False``.
    """

    def __init__(self, config, dataset, sampler, shuffle=False):
        self.uid_field = dataset.uid_field
        self.iid_field = dataset.iid_field
        self.list_suffix = config['LIST_SUFFIX']
        self.iid_list_field = dataset.iid_field + self.list_suffix
        self.max_item_list_len = config['MAX_ITEM_LIST_LENGTH']
        self.item_list_length_field = config['ITEM_LIST_LENGTH_FIELD']

        self.feature_field = config['feature_field']
        self.feature_list_field = self.feature_field + self.list_suffix

        self.mask_ratio = config['mask_ratio']
        self.mask_token = dataset.item_num
        self.mask_field = config['MASK_FIELD']
        self.mask_prefix = config['MASK_PREFIX']
        self.mask_iid_list_field = self.mask_prefix + self.iid_list_field
        self.neg_prefix = config['NEG_PREFIX']
        self.neg_iid_list_field = self.neg_prefix + self.iid_list_field

        self.mask_segment_field = config['MASK_SEGMENT_FIELD']
        self.pos_segment_field = config['POS_SEGMENT_FIELD']
        self.neg_segment_field = config['NEG_SEGMENT_FIELD']
        super().__init__(config, dataset, sampler, shuffle=shuffle)

    def _init_batch_size_and_step(self):
        batch_size = self.config['train_batch_size']
        self.step = batch_size
        self.set_batch_size(batch_size)

    @property
    def pr_end(self):
        return len(self.dataset)

    def _shuffle(self):
        self.dataset.shuffle()

    def _next_batch_data(self):
        cur_data = self.dataset[self.pr:self.pr + self.step]
        self.pr += self.step

        user_ids = cur_data[self.uid_field]
        item_sequence = cur_data[self.iid_list_field]
        item_sequence_length = cur_data[self.item_list_length_field]
        sequence_shape = item_sequence.shape  # [B L]

        mask = (torch.rand(sequence_shape) < self.mask_ratio) & (item_sequence != 0)
        mask_item_sequence = torch.where(mask, self.mask_token, item_sequence)
        neg_item_sequence = item_sequence.clone()
        for i, m in enumerate(mask):
            neg_item_ids = self.sampler.sample_by_user_ids(
                [user_ids[i].numpy()], item_sequence[i].numpy(), m.sum().numpy()
            )
            neg_item_sequence[i][m] = neg_item_ids
        cur_data[self.mask_field] = mask
        cur_data[self.mask_iid_list_field] = mask_item_sequence
        cur_data[self.neg_iid_list_field] = neg_item_sequence

        mask_segment = item_sequence.clone()
        pos_segment = item_sequence.clone()
        neg_segment = item_sequence.clone()
        for i, (seg, seg_length) in enumerate(zip(mask_segment, item_sequence_length)):
            seg_length = int(seg_length)
            if seg_length >= 2:
                sample_length = int(torch.randint(1, 1 + seg_length // 2, (1,))[0])
                start_id = int(torch.randint(0, seg_length - sample_length + 1, (1,))[0])
                neg_item_ids = self.sampler.sample_by_user_ids(
                    [user_ids[i].numpy()], item_sequence[i].numpy(), sample_length
                )

                mask_segment[i][start_id:start_id + sample_length] = self.mask_token
                pos_segment[i][:start_id] = self.mask_token
                pos_segment[i][start_id + sample_length:seg_length] = self.mask_token
                neg_segment[i][:start_id] = self.mask_token
                neg_segment[i][start_id:start_id + sample_length] = neg_item_ids
                neg_segment[i][start_id + sample_length:seg_length] = self.mask_token

        cur_data[self.mask_segment_field] = mask_segment
        cur_data[self.pos_segment_field] = pos_segment
        cur_data[self.neg_segment_field] = neg_segment

        return cur_data

