function means = getMeans(onCluster, depth, numClusters)

c = const(onCluster, depth);

% try
%     load(c.normalMeans);
% catch err
    load(c.normals);
    s = subsample(normals, onCluster, depth);
    [~, means] = kmeans(s, numClusters, 'distance', 'cosine');
    for i = 1:size(means, 1);
        means(i,:) = means(i,:)/norm(means(i,:));
    end
    
    save(c.normalMeans, 'means', 's', '-v7.3');
% end

function s = subsample(normals, onCluster, depth)

c = const(onCluster, depth);

s = [];

for i = 1:size(c.numImages)
    n = normals(:,:,:,i);
    imgSize = size(n, 1) * size(n, 2);
    numToSample = ceil(imgSize/3);
    addIndy = random('unid', size(n, 1), numToSample, 1);
    addIndx = random('unid', size(n, 2), numToSample, 1);
    
    for j = 1:numToSample
        add = transpose(squeeze(n(addIndy(j, 1), addIndx(j, 1), :)));
        s = [s; add];
    end
end