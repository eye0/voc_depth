function SubmitJobCC()

c = const(1);

%Job Details
clear jobString;
jobString = {};
logDir = c.logs;
codeDir = c.code;
nodes = 1;
ppn = 1;
mem = 2; %in gigs
hh = 72; %in hours
notif = false;
minJobs = 57;
maxJobs = 57;
username = 'edmundye';
jobName = 'cc';

jobString = cell(57);

for i = 1:57
    jobString{i} = sprintf('countClasses(%d, %d)', i, 1);
end

pbsRunFunctions(jobName, logDir, codeDir, nodes, ppn, mem, hh, jobString, notif, minJobs, maxJobs, username);