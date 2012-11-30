function [const] = const(onCluster, depth)

if onCluster
    const.code = fullfile('/home','eecs','edmundye','psiCode');
    const.data = fullfile('/work4','edmundye','data');
    const.logs = fullfile(const.data,'logs');
else
    const.code = fullfile('/home','edmund','psiCode');
    const.data = fullfile('/home','edmund','data');
end

const.normals = fullfile(const.data, 'normals.mat');
const.mapping = fullfile(const.data, 'trainClassMapping.mat');
const.splits = fullfile(const.data, 'splits.mat');
const.normalMeans = fullfile(const.data, 'means.mat');
const.numImages = 1449;

if depth
    const.cached = fullfile(const.data, '2012_root_depth');
    const.base = fullfile(const.code, 'NYU_PASCAL_DEPTH');
    const.traindata = fullfile(const.data, 'nyu_data_trunc');
    const.nyu = fullfile(const.data, 'nyu_depth_trunc.mat');
    const.mappedLabel = fullfile(const.data, 'myMappedLabels_trunc.mat');
    const.workImages = fullfile(const.data, 'nyu_images_trunc');
    
    const.normalsFolder = fullfile(const.data, 'nyu_normals');
else
    const.cached = fullfile(const.data, '2012_root_nodepth');
    const.base = fullfile(const.code, 'NYU_PASCAL');
    const.traindata = fullfile(const.data, 'nyu_data')
    const.nyu = fullfile(const.data, 'nyu_depth_v2_labeled.mat');
    const.mappedLabel = fullfile(const.data, 'myMappedLabels.mat');
    const.workImages = fullfile(const.data, 'nyu_images');
end
const.imageFolder = fullfile(const.base, 'VOCdevkit', 'VOC2012', 'Images');