function out = trainmanytrees3(onCluster)

if onCluster == 1
    pre = '/work4/pulkitag/projClassify';
    data = '/work4/edmundye/data';
else
    pre = '/home/edmund/proj';
    data = '/home/edmund/data';
end

addpath(fullfile(pre, 'color_shape_lbp_new_Ver1'));
addpath(data);

valS = dlmread(fullfile(pre, 'color_shape_lbp_new_Ver1/predictions/valSet/combined.prd'));
valL = dlmread(fullfile(pre, 'color_shape_lbp_new_Ver1/labels/valSet/combined.lbl'));
val2S = dlmread(fullfile(pre, 'color_shape_lbp_new_Ver1/predictions/val2Set/combined.prd'));
val2L = dlmread(fullfile(pre, 'color_shape_lbp_new_Ver1/labels/val2Set/combined.lbl'));
trainS = dlmread(fullfile(pre, 'color_shape_lbp_new_Ver1/predictions/trainSet/combined.prd'));
trainL = dlmread(fullfile(pre, 'color_shape_lbp_new_Ver1/labels/trainSet/combined.lbl'));
testS = dlmread(fullfile(pre, 'color_shape_lbp_new_Ver1/predictions/testSet/combined.prd'));
testL = dlmread(fullfile(pre, 'color_shape_lbp_new_Ver1/labels/testSet/combined.lbl'));

trS = [trainS; valS; val2S];
trL = [trainL; valL; val2L];

current = 1;

% first tree is everything
t = compact(TreeBagger(25, trS, trL, 'method', 'classification'));
save(fullfile(data, strcat('trees/t', int2str(current))), 't');
save(fullfile(data, strcat('trees/s', int2str(current))), 'testS');

current = current + 1;

% next 20 trees are class specific score trees
cor = [];
for i = 1:19
    for j = i+1:20
        cor = [cor; i j];
    end
end

cor = transpose(cor);

for k = 1:20
    ind = cor(1,:)==k | cor(2,:)==k;
    rep = cor;
    rep(rep==k) = 0;
    rix = find(ind);
    [sorted ix] = sort(max(rep(:, rix)));
    rix = rix(ix);
    rix = rix + 20;
    for l = 1:length(ix)
        zeroCols = setdiff(1:210, [k rix(l)]);
        newS = trS;
        newS(:, zeroCols) = 0;
        newTS = testS;
        newTS(:, zeroCols) = 0;
        
        t = compact(TreeBagger(1, newS, trL, 'method', 'classification'));
        
        save(fullfile(data, strcat('trees/t', int2str(current))), 't');
        save(fullfile(data, strcat('trees/s', int2str(current))), 'newTS');
        
        current = current + 1;
    end
end

out = 1;