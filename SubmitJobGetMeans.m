function SubmitJobGetMeans()

c = const(1,1);

%Job Details
clear jobString;
jobString = {};
logDir = c.logs;
codeDir = c.code;
nodes = 1;
ppn = 1;
mem = 32; %in gigs
hh = 72; %in hours
notif = false;
minJobs = 1;
maxJobs = 1;
username = 'edmundye';
jobName = 'km';

jobString = cell(1);

for i = 1:1
    jobString{1} = sprintf('getMeans(%d, %d, %d)', 1, 1, 18);
end

pbsRunFunctions(jobName, logDir, codeDir, nodes, ppn, mem, hh, jobString, notif, minJobs, maxJobs, username);