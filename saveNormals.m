function saveNormals(onCluster)

c = const(onCluster, 1);

load(c.normals);

for i = 1:size(normals,4)
    n = normals(:,:,:,i);
    save(fullfile(c.normalsFolder, sprintf('%04d.mat', i)), 'n');
end