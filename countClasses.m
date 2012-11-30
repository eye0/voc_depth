function countClasses(num, onCluster)

c = const(onCluster);

[labels, ~] = getMappedLabelInstance(1);
load(c.mapping);
load(c.splits);

for i = 2*num-1:2*num
    obj = [];
    numTrain = 0;
    numTest = 0;
    images = {};
    
    for j = 1:size(labels, 3)
        imageLabels = labels(:,:,j);
        if ~isempty(find(imageLabels==i, 1))
            images{end+1} = sprintf('%04d.jpg', j);
            if isempty(find(trainNdxs==j, 1))
                numTest = numTest + 1;
            else
                numTrain = numTrain + 1;
            end
        end
    end
    obj.numTrain = numTrain;
    obj.numTest = numTest;
    obj.images = images;
    
    save(fullfile(c.data, 'counts', sprintf('cc_%d.mat', i)), 'obj');
end