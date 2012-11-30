function SubmitJobDPM(onCluster, depth)

c = const(onCluster,depth);
classes = {'cabinet', 'chair', 'table', 'door', 'bottle', 'lamp', 'pillow', 'bed', 'sofa', 'shelves'};


%Job Details
clear jobString;
jobString = {};
logDir = c.logs;
codeDir = c.code;
nodes = 1;
ppn = 1;
mem = 8; %in gigs
hh = 72; %in hours
notif = false;
minJobs = length(classes);
maxJobs = length(classes);
username = 'edmundye';
jobName = 'root';

jobString = cell(length(classes));

for i = 1:length(classes)
    jobString{i} = sprintf('c = const(%d, %d); addpath(genpath(c.code)); pascal(''%s'', %d)', onCluster, depth, classes{i}, 1);
end

pbsRunFunctions(jobName, logDir, codeDir, nodes, ppn, mem, hh, jobString, notif, minJobs, maxJobs, username);