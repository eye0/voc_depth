function normals = getNormals(onCluster, depth)

c = const(onCluster, depth);

try
    load(c.normals);
catch err
    normals = zeros(425, 560, 3, 1449);
    
    for i = 1:c.numImages
        normals(:,:,:,i) = sNormals(i);
    end
    
    save(c.normals, 'normals', '-v7.3');
end