function [pos, neg, impos] = nyu_data(cls, ~, onCluster, depth)

c = const(onCluster, depth);

load(c.mapping, 'myClass', 'myClassName');
i = find(ismember(myClassName, cls));

if isempty(i)
    error('invalid class name');
end

try
    load(fullfile(c.traindata, strcat(cls, '_train_data.mat')));
catch err
    [labels, instances] = getMappedLabelInstance(onCluster, depth);
    load(c.nyu, 'images');
    load(c.splits);
    numImages = size(images, 4);
    
    pos = [];
    impos = [];
    numpos = 0;
    numimpos = 0;
    dataid = 0;
    
    for j = 1:numImages % for each image
        if isempty(find(trainNdxs==j, 1))
            continue;
        end
        
        imageLabels = labels(:,:,j);
        imageInstances = instances(:,:,j);
        imageSize = size(images(:,:,:,j));
        
        [instanceMasks, instanceLabels] = get_instance_masks(imageLabels,imageInstances);
        
        instanceMasks = instanceMasks(:,:,instanceLabels==i);
        
        if isempty(instanceMasks) % no positives of cls
            continue;
        end
        
        count = size(instanceMasks, 3);
        
        impath = fullfile(c.workImages, sprintf('%04d.jpg', j));
        npath = fullfile(c.normalsFolder, sprintf('%04d.mat', j));
        imbb = zeros(count, 4);
        imbbf = zeros(count, 4);
        
        for k = 1:count
            numpos = numpos + 1;
            dataid = dataid + 1;
            
            [row, col] = find(instanceMasks(:,:,k));
            bbox = [min(col) min(row) max(col) max(row)];
            imbb(k,:) = bbox;
            
            pos(numpos).im = impath;
            pos(numpos).n  = npath;
            pos(numpos).x1 = bbox(1);
            pos(numpos).y1 = bbox(2);
            pos(numpos).x2 = bbox(3);
            pos(numpos).y2 = bbox(4);
            pos(numpos).boxes = bbox;
            pos(numpos).flip = false;
            pos(numpos).trunc = 0;
            pos(numpos).dataids = dataid;
            pos(numpos).sizes = (bbox(3)-bbox(1)+1)*(bbox(4)-bbox(2)+1);
            
            numpos  = numpos + 1;
            dataid  = dataid + 1;
            oldx1   = bbox(1);
            oldx2   = bbox(3);
            bbox(1) = imageSize(2) - oldx2 + 1;
            bbox(3) = imageSize(2) - oldx1 + 1;
            imbbf(k,:) = bbox;
            
            pos(numpos).im = impath;
            pos(numpos).n  = npath;
            pos(numpos).x1 = bbox(1);
            pos(numpos).y1 = bbox(2);
            pos(numpos).x2 = bbox(3);
            pos(numpos).y2 = bbox(4);
            pos(numpos).boxes = bbox;
            pos(numpos).flip = true;
            pos(numpos).trunc = 0;
            pos(numpos).dataids = dataid;
            pos(numpos).sizes = (bbox(3)-bbox(1)+1)*(bbox(4)-bbox(2)+1);
        end
        
        numimpos = numimpos + 1;
        impos(numimpos).im = impath;
        pos(numpos).n = npath;
        impos(numimpos).boxes   = imbb;
        impos(numimpos).dataids = zeros(count, 1);
        impos(numimpos).sizes   = zeros(count, 1);
        impos(numimpos).flip    = false;
        
        for k = 1:count
            dataid = dataid + 1;
            bbox = imbb(k,:);
            
            impos(numimpos).dataids(k) = dataid;
            impos(numimpos).sizes(k) = (bbox(3)-bbox(1)+1)*(bbox(4)-bbox(2)+1);
        end
        
        % Create flipped example
        numimpos = numimpos + 1;
        impos(numimpos).im = impath;
        pos(numpos).n = npath;
        impos(numimpos).boxes = imbbf;
        impos(numimpos).dataids = zeros(count, 1);
        impos(numimpos).sizes = zeros(count, 1);
        impos(numimpos).flip = true;
        
        for k = 1:count
            dataid = dataid + 1;
            bbox = imbbf(k,:);
            
            impos(numimpos).dataids(k) = dataid;
            impos(numimpos).sizes(k)   = (bbox(3)-bbox(1)+1)*(bbox(4)-bbox(2)+1);
        end
    end
    
    neg = [];
    numneg = 0;
    
    for j = 1:numImages % for each image
        if isempty(find(trainNdxs==j, 1))
            continue;
        end
        
        imageLabels = labels(:,:,j);
        imageInstances = instances(:,:,j);
        
        [instanceMasks, instanceLabels] = get_instance_masks(imageLabels,imageInstances);
        
        instanceMasks = instanceMasks(:,:,instanceLabels==i);
        
        if ~isempty(instanceMasks) % exists positives of cls
            continue;
        end
        
        impath = fullfile(c.workImages, sprintf('%04d.jpg', j));
        npath = fullfile(c.normalsFolder, sprintf('%04d.mat', j));
        
        dataid = dataid + 1;
        numneg = numneg + 1;
        neg(numneg).im = impath;
        pos(numpos).n  = npath;
        neg(numneg).flip = false;
        neg(numneg).dataid = dataid;
    end
    
    save(fullfile(c.traindata, strcat(cls, '_train_data.mat')), 'pos', 'neg', 'impos');
end