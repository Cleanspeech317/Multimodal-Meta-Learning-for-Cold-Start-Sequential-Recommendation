from concurrent.futures import process
import os
import torch
import torch.nn as nn
from torch.utils.data import Dataset, DataLoader, Sampler
from torchvision.models import resnet50
from torchvision.transforms import Compose, Resize, CenterCrop, ToTensor
import numpy as np
from PIL import Image, ImageFile
from tqdm import tqdm
import argparse

ImageFile.LOAD_TRUNCATED_IMAGES = True


def get_item_ids_and_images_path(path):
    file_list = os.listdir(path)
    file_list = [file for file in file_list if not file.startswith('.')]
    item_ids = list(map(lambda name: name.split('.')[0], file_list))
    images_path = list(map(lambda name: os.path.join(path, name), file_list))
    return item_ids, images_path


transform = Compose([
    Resize(224),
    CenterCrop(224),
    lambda image: image.convert("RGB"),
    ToTensor(),
])


def get_image(file_path):
    return transform(Image.open(file_path))


class ImageDataset(Dataset):
    def __init__(self, images_path):
        self.length = len(images_path)
        self.images_path = images_path

    def __getitem__(self, index):
        return get_image(self.images_path[index])

    def __len__(self):
        return self.length


@torch.no_grad()
def convert(images_path, batch_size):
    model = resnet50(pretrained=True)
    model.eval()
    model.fc = nn.Identity()
    # output = model(images)
    # return output
    device = torch.device('cuda')
    dataset = ImageDataset(images_path)
    dataloader = DataLoader(dataset=dataset, batch_size=batch_size, shuffle=False, num_workers=0)
    model.to(device)
    all_output = []
    iter_data = tqdm(dataloader)
    for data in iter_data:
        data = data.to(device)
        output = model(data).cpu()
        all_output.append(output)
    img_emb = torch.cat(all_output, dim=0)
    return img_emb


def main(args):
    item_ids, images_path = [], []
    # for path in ['gif_img']:
    for path in ['img_url', 'img_url2', 'img_url3', 'gif_img', 'lost_url/lost_imgs']:
        iids, img_path = get_item_ids_and_images_path(os.path.join('/home/sankuai/cephfs_panxingyu02', path))
        item_ids += iids
        images_path += img_path
    split_point = np.linspace(0, len(item_ids), args.gpu_num + 1).astype(np.int64)
    item_ids = item_ids[split_point[args.gpu_id]:split_point[args.gpu_id + 1]]
    images_path = images_path[split_point[args.gpu_id]:split_point[args.gpu_id + 1]]
    os.environ["CUDA_VISIBLE_DEVICES"] = str(args.gpu_id)
    img_emb = convert(images_path, batch_size=2048)
    # print(img_emb)
    # print(img_emb.shape, img_emb.mean(), img_emb.std())
    result = {
        'item_id': item_ids,
        'embs': img_emb,
    }
    torch.save(result, f'pth/item_img_emb_{args.gpu_id}.pth')


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--gpu_num', '-n', type=int, default=4, help='number of GPU')
    parser.add_argument('--gpu_id', '-i', type=int, default=0, help='GPU ID')

    args, _ = parser.parse_known_args()
    main(args)
