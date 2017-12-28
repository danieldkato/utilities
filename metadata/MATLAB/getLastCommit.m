function [warnOut, lastCommit] = getLastCommit(varargin)

% DOCUMENTATION TABLE OF CONTENTS
% I. OVERVIEW
% II. SYNTAX
% III. REQUIREMENTS
% IV. INPUTS
% V. OUTPUTS


%% I. OVERVIEW
% This function returns the SHA1 digest of the most recent git commit of a
% given file. If no file is specified in the input, it returns the SHA1
% digest of the most recent git commit of the calling script.

% Note that this function returns the SHA1 digest of the latest GIT COMMIT
% of the input file, NOT the SHA1 digest of the FILE ITSELF; the SHA1
% digest of the git commit includes additional information like the date,
% time, user, etc.

%% II. SYNTAX
% [warnOut, lastCommit] = getLastCommit()
% [warnOut, lastCommit] = getLastCommit(path)


%% III. REQUIREMENTS
% 1) git, available at https://git-scm.com/.
%
% 2) Operating system configured to recognize `git` as a command. If `git`
% is not automatically recognized as a command after installing on Windows,
% add it to the Path environment variable as follows:
%   a) Under the start menu, right click on 'My Computer' and naivgate to 'Properties'.
%   b) Navigate to the 'Advanced' tab and click on the 'Environment Variables' button.
%   c) In the 'System variables' listbox, select 'Path' and click on the 'Edit' button.
%   d) In the 'Variable value' text field, add the following text:
%      
%      <path\to>\Git\bin\git.exe;<path\to>\Git\cmd;
%       
%      where <path\to> it the absolute path of the directory where the top-level Git folder is located
%
% 3) If running on Linux via ssh, this function requires the MATLAB-git
% toolbox, available at http://www.mathworks.com/matlabcentral/fileexchange/29154-a-thin-matlab-wrapper-for-the-git-source-control-system


%% IV. INPUTS
% 1) path - absolute path to a file of which the SHA hash of the most recent git
% commit will be returned.

% If no input argument is provided, this function will return the SHA1 hash
% of the most recent git commit of the calling function. 


%% OUTPUTS
% 1) warning - char array containing any warnings or errors returned by
% system call to git (e.g., if input file is not under git control or if
% file has uncommitted changes)

% 1) lastCommit - char array containing the SHA1 digest of the most recent
% git commit of the input file. Note that this is the SHA1 digest of the
% latest GIT COMMIT of the input file, NOT the SHA1 digest of the FILE
% ITSELF; the SHA1 digest of the git commit includes additional information
% like the date, time, user, etc.

% last updated DDK 2017-09-08


%% Setup:
warnOut = []; % if there are no warnings, this will be empty
lastCommit = []; % if the SHA1 digest of the latest commit can't be found, this will remain empty

% Get the name of the function to try to find the commit for:
if nargin<1
    ST = dbstack('-completenames');
    path = ST(2).file;
else
    path = varargin{1};
end
[pathstr, filename, ext] = fileparts(path);

% cd to the direcory of the fucntion:
old = cd(pathstr);


%% First check if file is under git control:
if ispc
    [err, out] = system(strcat(['git ls-files --error-unmatch ', filename, ext]));
elseif isunix
    out = evalc(['git ls-files --error-unmatch ' filename ext]);
end
    
% If not, throw a warning and halt execution
if contains(out, 'error:') || contains(out, 'fatal:') 
    warnMsg = out;
    warnOut = warnMsg;
    warning(warnMsg);
    cd(old);
    return
end
    
    
%% If the file is under git cotrol, check if file has any uncommitted changes:
if ispc
    [err, out] = system(strcat(['git diff -- ', filename, ext]));
elseif isunix
    out = evalc(['git diff ' filename ext]);
end
    
if ~isempty(out)
    warnMsg = strcat(['Warning: uncommitted changes detected in ', filename, ext, '. It is advised to commit or stash any changes before proceeding.']);
    warnOut = warnMsg;
    warning(warnMsg);
end


%% If the file is under git control, find the SHA1 digest of the latest commit:
if ispc
    [status, lastCommit] = system(strcat(['git log -n 1 --pretty=format:%H -- ', filename, ext]));
elseif isunix
    header = 'commit';
    out = evalc(['git log -n 1 ' filename ext]);
    lastCommit = out(length(header)+1:length(header)+41);
end

%% Return to the previous working directory
cd(old);
    
    
end