function SubmitJobSaveNormals()

c = const(1, 1);

%Job Details
clear jobString;
jobString = {};
logDir = c.logs;
codeDir = c.code;
nodes = 1;
ppn = 1;
mem = 4; %in gigs
hh = 72; %in hours
notif = false;
minJobs = 1;
maxJobs = 1;
username = 'edmundye';
jobName = 'save';

jobString = cell(1);

jobString{1} = sprintf('saveNormals(%d)', 1);

pbsRunFunctions(jobName, logDir, codeDir, nodes, ppn, mem, hh, jobString, notif, minJobs, maxJobs, username);