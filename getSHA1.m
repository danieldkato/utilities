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
% None (beyond those for running MATLAB).


%% INPUTS
% None.


%% OUTPUTS
% 1) SHA1 - char array containing the SHA1 of the most recent git commit of
% the calling script.


%%
    % Get the complete file name of the calling fucntion
    ST = dbstack('-completenames');
    [pathstr, filename, ext] = fileparts(ST(2).file);
    
    % cd to the direcory of the calling fucntion:
    old = cd(pathstr);
    
    % get its SHA1
    [status, SHA1] = system(strcat(['git log -n 1 --pretty=format:%H -- ', filename, ext]));
    
end