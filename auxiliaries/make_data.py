import pandas as pd
import numpy as np
import os
import argparse


def split_df(df, city_id, ratio=0.8, split_time=None):
    city_df = df[df['cityid:token'] == city_id]
    user_df = city_df[['user_id:token', 'exposure_time:float']].drop_duplicates('user_id:token', keep='first')
    user_df.columns = ['user_id:token', 'first_inter_time:float']
    if split_time is None:
        time_list = user_df['first_inter_time:float'].values
        split_time = time_list[int(len(time_list) * ratio)]
    city_df = pd.merge(city_df, user_df, how='left', on='user_id:token')
    up_df = city_df[city_df['exposure_time:float'] <= split_time]
    down_df = city_df[city_df['first_inter_time:float'] > split_time]
    return up_df, down_df


def filter_by_inter_num(df, user_inter_num):
    user_count_df = df[['user_id:token', 'item_id:token']].groupby('user_id:token').count().reset_index()
    user_count_df = user_count_df[user_count_df['item_id:token'] >= user_inter_num]
    return pd.merge(df, user_count_df[['user_id:token']], on='user_id:token', how='right')


def main():
    df = pd.read_csv('dataset/pretrain/pretrain.inter', sep='\t')
    df = df[['cityid:token', 'user_id:token', 'item_id:token', 'item_type_recommend:token', 'exposure_time:float']]
    city_name_list = ['shanghai', 'hangzhou', 'changsha', 'lanzhou']
    city_id_list = [10, 50, 70, 361]
    split_time = 1631289599
    for city_name, city_id in zip(city_name_list, city_id_list):
        print(city_name)
        up_df, down_df = split_df(df, city_id, split_time=split_time)
        up_df = filter_by_inter_num(up_df, 4)
        down_df = filter_by_inter_num(down_df, 4)
        new_df = pd.concat([up_df, down_df])
        del new_df['first_inter_time:float']
        del new_df['cityid:token']
        print(len(up_df), up_df['user_id:token'].nunique())
        print(len(down_df), down_df['user_id:token'].nunique())
        print(new_df['item_id:token'].nunique())
        # dir_path = f'dataset/{city_name}'
        # file_path = os.path.join(dir_path, f'{city_name}.inter')
        # if not os.path.exists(dir_path):
        #     os.makedirs(dir_path)
        # new_df.to_csv(file_path, sep='\t', index=False)


if __name__ == '__main__':
    main()
