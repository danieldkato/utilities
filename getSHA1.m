function SHA1 = getSHA1(varargin)

% DOCUMENTATION TABLE OF CONTENTS
% I. OVERVIEW
% II. SYNTAX
% III. REQUIREMENTS
% IV. INPUTS
% V. OUTPUTS


%% I. OVERVIEW
% This function returns the SHA1 hash of the most recent git commit of a
% given file. If no file is specified in the input, it returns the SHA1
% hash of the most recent git commit of the calling script.


%% II. SYNTAX
% SHA1 = getSHA1()
% SHA1 = getSHA1(path)


%% III. REQUIREMENTS
% 1) git, available at https://git-scm.com/.
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


%% IV. INPUTS
% 1) path - path to a file of which the SHA hash of the most recent git
% commit will be returned.

% If no input argument is provided, this function will return the SHA1 hash
% of the most recent git commit of the calling function. 


%% OUTPUTS
% 1) SHA1 - char array containing the SHA1 of the most recent git commit of
% the calling script.


%% TODO
% 1) Check and return some sort of warning if the calling script has
% uncommitted changes. Recording the SHA-1 of the latest commit will be
% misleading if the calling script has uncommitted changes. 

% last updated DDK 2017-07-15


%%
    % Get the name of the function to get the commit for:
    if nargin<1
        ST = dbstack('-completenames');
        path = ST(2).file;
    else
        path = varargin{1};
    end
    
    [pathstr, filename, ext] = fileparts(path);
    
    % cd to the direcory of the calling fucntion:
    old = cd(pathstr);
    
    % Get its SHA1:
    [status, SHA1] = system(strcat(['git log -n 1 --pretty=format:%H -- ', filename, ext]));
    
    if isempty(SHA1)
        SHA1 = 'No commits found for current script.';
    end
    
    % Return to the previous working directory
    cd(old);
    
end