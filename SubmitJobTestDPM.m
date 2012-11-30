function SubmitJobTestDPM()

c = const(1);

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
minJobs = 114;
maxJobs = 114;
username = 'edmundye';
jobName = 'br';

jobString = cell(114);

for i = 1:114
    jobString{i} = sprintf('batchDPM(%d, %d)', i, 1);
end

pbsRunFunctions(jobName, logDir, codeDir, nodes, ppn, mem, hh, jobString, notif, minJobs, maxJobs, username);