function saveIms(onCluster, depth)

c = const(onCluster, depth);

load(c.nyu, 'images');

for i = 1:size(images,4)
    imwrite(images(:,:,:,i), fullfile(c.workImages, sprintf('%04d.jpg', i)), 'jpg');
end