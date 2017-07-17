function SHA1 = getSHA1()

% DOCUMENTATION TABLE OF CONTENTS
% I. OVERVIEW
% II. REQUIREMENTS
% III. INPUTS
% IV. OUTPUTS

%% I. OVERVIEW
% This function returns the SHA1 of the most recent git commit of the
% calling script.


%% REQUIREMENTS
% 1) git, available at https://git-scm.com/.
% 2) Operating system configured to recognize `git` as a command. 


%% INPUTS
% None.


%% OUTPUTS
% 1) SHA1 - char array containing the SHA1 of the most recent git commit of
% the calling script.


%% TODO
% 1) Check and return some sort of warning if the calling script has
% uncommitted changes. Recording the SHA-1 of the latest commit will be
% misleading if the calling script has uncommitted changes. 

% last updated DDK 2017-07-15

%%
    % Get the complete file name of the calling fucntion
    ST = dbstack('-completenames');
    [pathstr, filename, ext] = fileparts(ST(2).file);
    
    % cd to the direcory of the calling fucntion:
    old = cd(pathstr);
    
    % get its SHA1
    [status, SHA1] = system(strcat(['git log -n 1 --pretty=format:%H -- ', filename, ext]));
    
    if isempty(SHA1)
        SHA1 = 'No commits found for current script.';
    end
    
    % return to the previous working directory
    cd(old);
    
end