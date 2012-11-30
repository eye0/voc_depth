function SubmitJobGetNormals()

c = const(1,1);

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
minJobs = 1;
maxJobs = 1;
username = 'edmundye';
jobName = 'normals';

jobString = cell(1);

for i = 1:1
    jobString{1} = sprintf('getNormals(%d, %d)', 1, 1);
end

pbsRunFunctions(jobName, logDir, codeDir, nodes, ppn, mem, hh, jobString, notif, minJobs, maxJobs, username);