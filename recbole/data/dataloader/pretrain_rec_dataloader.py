# -*- coding: utf-8 -*-
# @Time    : 2021/10/24 10:00
# @Author  : Yushuo Chen
# @Email   : chenyushuo@ruc.edu.cn

"""
################################################
"""

import numpy as np
import torch

from recbole.data.interaction import Interaction
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
        self.sid_field = dataset.seq_id_field
        self.list_suffix = config['LIST_SUFFIX']
        self.iid_list_field = dataset.iid_field + self.list_suffix
        self.max_item_list_len = config['MAX_ITEM_LIST_LENGTH']
        self.item_list_length_field = config['ITEM_LIST_LENGTH_FIELD']

        self.time_field = config['TIME_FIELD']
        self.time_list_field = self.time_field + self.list_suffix
        self.location_field = config['LOCATION_FIELD']
        self.location_list_field = self.location_field + self.list_suffix
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

        self.data = None
        super().__init__(config, dataset, sampler, shuffle=shuffle)

    def _init_batch_size_and_step(self):
        batch_size = self.config['train_batch_size']
        self.step = batch_size
        self.set_batch_size(batch_size)

    def __iter__(self):
        if self.shuffle:
            self._shuffle()

        seq_ids = self.dataset.inter_feat[self.sid_field].numpy()
        item_sequence = self.dataset.inter_feat[self.iid_list_field]
        item_sequence_length = self.dataset.inter_feat[self.item_list_length_field]

        mask = (torch.rand(item_sequence.shape) < self.mask_ratio) & (item_sequence != 0)
        mask_item_sequence = torch.where(mask, self.mask_token, item_sequence)
        neg_item_sequence = item_sequence.clone()

        mask_segment = item_sequence.clone()
        pos_segment = torch.full_like(item_sequence, self.mask_token)
        neg_segment = torch.full_like(item_sequence, self.mask_token)

        for i, (seq_id, m, seg_length) in enumerate(zip(seq_ids, mask, item_sequence_length)):
            seg_length = int(seg_length)
            mask_num = m.sum().item()
            sample_length = torch.randint(1, 1 + seg_length // 2, (1,)).item() if seg_length >= 2 else 0

            neg_item_ids = self.sampler.sample_by_seq_ids(seq_id, mask_num + sample_length)

            neg_item_sequence[i][m] = neg_item_ids[:mask_num]

            if seg_length >= 2:
                start_id = torch.randint(0, seg_length - sample_length + 1, (1,)).item()
                pos_segment[i][start_id:start_id + sample_length] = mask_segment[i][start_id:start_id + sample_length]
                neg_segment[i][start_id:start_id + sample_length] = neg_item_ids[mask_num:]
                mask_segment[i][start_id:start_id + sample_length] = self.mask_token

        data = {
            self.item_list_length_field: item_sequence_length,
            self.time_list_field: self.dataset.inter_feat[self.time_list_field],
            self.location_list_field: self.dataset.inter_feat[self.location_list_field],
            self.feature_list_field: self.dataset.inter_feat[self.feature_list_field],
            self.mask_field: mask,
            self.mask_iid_list_field: mask_item_sequence,
            self.iid_list_field: item_sequence,
            self.neg_iid_list_field: neg_item_sequence,
            self.mask_segment_field: mask_segment,
            self.pos_segment_field: pos_segment,
            self.neg_segment_field: neg_segment,
        }
        self.data = Interaction(data)

        return self

    @property
    def pr_end(self):
        return len(self.dataset)

    def _shuffle(self):
        self.dataset.shuffle()

    def _next_batch_data(self):
        cur_data = self.data[self.pr:self.pr + self.step]
        self.pr += self.step
        return cur_data
