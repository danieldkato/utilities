function sha1 = get_sha1(path)
% DOCUMENTATION TABLE OF CONTENTS:
% I. OVERVIEW
% II. REQUIREMENTS
% III. INPUTS
% IV. OUTPUTS

% Last updated DDK 2018-01-05


%% I. OVERVIEW:
% This platform-independent function returns the SHA1 checksum of the file
% specified in the input path.


%% II. REQUIREMENTS:

% For LINUX:
% 1) The command-line utility sha1sum. This is usually installed by default.

% For Windows:
% 1) The command-line utility fciv.exe. For downloads and installation
% instructions, see https://support.microsoft.com/en-us/help/841290/availability-and-description-of-the-file-checksum-integrity-verifier-u


%% III. INPUTS:
% 1) path - path to a file


%% IV. OUTPUTS:
% 1) sha1 - 40-element alphanumeric character vector specifying the SHA1
% checksum of the input file. 


%% TODO:
% 1) Throw warnings for any error conditions (e.g., if fciv.exe isn't installed)


%%

if isunix 
    cmd = ['sha1sum ' path];
elseif ispc
    cmd = ['fciv.exe ' path ' -sha1'];
end

[status, cmdout] = system(cmd);

if isunix
    sha1 = cmdout(1:40); % SHA1 checksums are 40 characters long
elseif ispc
    sha1_end = length(cmdout) - length(path) -1;
    sha1_start = sha1_end -40;
    sha1 = cmdout(sha1_start:sha1_end);
end