# Code for MML

This is the resource code for our work.
> Xingyu Pan, Yushuo Chen, Changxin Tian, Zihan Lin, Jinpeng Wang, He Hu and Wayne Xin Zhao. "Multimodal Meta-Learning for Cold Start Sequential Recommendation"

## Overview
We purpose a Multimodal Meta-Learning (denoted as MML) method to introduce multimodal side information of items (e.g., text and image) into the meta-learning process to stably improve the recommendation performance for cold-start users. Specifically, we model a unique sequence for each kind of multimodal information, and purpose a multimodel meta-learner framework to distill the global knowledge from the multimodal information. Meanwhile, we design a cold-start item embedding generator, which apply the multimodal information to warm up the ID embedding of new items. 

<p align="center">
  <img src="model_fig.png" alt="MML structure" width="600">
  <br>
  <b>Figure</b>: Overall Architecture of MML
</p>
