import torch
import numpy as np


if __name__ == '__main__':
    item_ids = []
    img_embs = []
    for i in range(4):
        file = f'pth/item_img_emb_{i}.pth'
        img_emb_table = torch.load(file)
        item_ids += img_emb_table['item_id']
        img_embs.append(img_emb_table['embs'])

    img_embs = torch.cat(img_embs, dim=0)
    img_emb_table = {
        'item_id': item_ids,
        'embs': img_embs,
    }
    print(len(item_ids), len(img_embs))
    torch.save(img_emb_table, 'pth/item_img_emb.pth')
