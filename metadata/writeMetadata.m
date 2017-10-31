function writeMetadata(Metadata,metadata_path)    

% DOCUMENTATION TABLE OF CONTENTS:
% I. OVERVIEW
% II. REQUIREMENTS
% III. INPUTS
% IV. OUTPUTS

% Last updated DDK 2017-10-31


%% I. OVERVIEW:
% This function writes the contents of a MATLAB struct containing analysis
% metadata to a JSON file. This metadtata includes full paths and SHA1
% checksums of all input and output files, analysis parameters, and (where
% possible) git version information about any software dependencies.


%% II. REQUIREMENTS:
% 1) The MATLAB toolbox JSONlab, available at https://www.mathworks.com/matlabcentral/fileexchange/33381-jsonlab--a-toolbox-to-encode-decode-json-files
% 2) The MATLAB function getLastCommit.m, available at https://github.com/danieldkato/utilities/blob/master/getLastCommit.m


%% III. INPUTS:
% 1) Metadata - a MATLAB struct containing analysis metadata. This struct
% must minimally contain the following fields:

%   a) inputs - an array of structs each representing a file that contains
%   some kind of input to the calling function. Each element of `inputs`
%   must minimally include a `path` field stating the absolute path to the
%   input file. 

%   b) outputs - same as `inputs`, but for output files saved by the
%   calling function. 

% While not required, it is best practice for the struct `Metadata` to also
% include a `parameters` field, itself a struct stating any parameters used
% by the analysis. A concise, human-readable `description` field may also
% facilitate quick interpretation of the metadata later on.

% 2) metadata_path - absolute path to the location where the output JSON
% file should be saved. 


%% IV. OUTPUTS:
% This function does not have any formal return, but creates a JSON file
% containing metadata about the analysis performed by the calling function.
% This file minimally includes the following fields:

%   a) inputs - an array of structs each representing a file that contains
%   some kind of input to the calling function. Each element of `inputs`
%   has the following sub-fields:
%       1) path - absolute path to the input file
%       2) sha1 - SHA1 checksum of the input file

%   b) outputs - same as the `inputs` field, but for outputs.

%   c) date - current date

%   d) time - current time. This field is created only if the input
%   `Metadata` struct does not already have one.

%   e) host_name - name of the computer on which the analysis was run. 

% In addition, the output JSON file will include any other fields included
% in the input `Metadata` struct. 


%% TODO: 
% 1) Should probably do some validation on input `Metadata` struct to make
% sure it has necessary fields.


%% Should probably do some validation here:


%% Get SHA1 checksums of input and output files:

io_struct_names = {'inputs','outputs'};

for io = 1:length(io_struct_names)
    
    substruct = io_struct_names{io};
    
    for file = 1:length(Metadata.(substruct))
        [status, cmdout] = system(['sha1sum ' Metadata.(substruct)(file).path]);
        Metadata.(substruct)(file).sha1 = cmdout(1:40);
    end
    
end


%% Try to get latest git commits of software dependencies:

% First, find all of the dependencies of the calling fucntion:
disp('Finding software dependencies...')
dependencies = inmem('-completenames');
disp('... done.');
dependencies = dependencies(cellfun(@(x) ~contains(x,matlabroot), dependencies)); % filter out core MATLAB functions... this would be way too many! (>600)

% Once we have a list of the dependencies of the calling function, try to get the last git commit for each: 
for dependency = 1:length(dependencies)
    clear warn;
    clear last_commit;
    dep_path = dependencies{dependency}; 
    Metadata.dependencies(dependency).path = dep_path;
    [warn, last_commit] = getLastCommit(dep_path);
    
    if ~ismepty(last_commit)
        Metadata.dependencies(dependency).last_commit = last_commit; 
    end
    
    if ~isempty(warn)
        Metadata.dependencies(dependency).warn = warn;
    end
end


%% Get date and time information:
t = now;

% Write date info:
dstr = datestr(t, 'yyyy-mm-dd');
Metadata.date = dstr;

% Write time info only if Metadata doesn't already have one; if the outputs
% take a long time to save, we might want the metadata time to be the time
% that the analysis was started, not completed, in which case it's the
% responsibility of the calling function to set Metadata.time at the
% beginning of the analysis:
if ~isfield(Metadata, 'time')
    tstr = datestr(t, 'HH:MM:SS');
    Metadata.time = tstr;
end


%% Get other misc info:
[err, host_name] = system('hostname');
Metadata.host_name = strtrim(host_name);


%% Write Metadata struct to JSON file:
savejson('',Metadata,metadata_path);






%{
    % (should probably do some validation here)
    
    numLines = length(inputCells)+length(outputCells)+length(paramCells)+2;
    
    %% Reformat all cells of the form {'key', 'value'} as strings of the form " 'key':'value' " :
    
    % Make individual dictionary entries for each input, i.e., strings of
    % the form 
    
    % " 'key1':'value1' "
    
    inputDictEntries = cell(1, length(inputCells));
    for i = 1:length(inputCells)
        inputCells{i}{2} = strrep(inputCells{1}{2}, '\', '\\');
        inputDictEntries{i} = strcat(['''', inputCells{i}{1},''':''', inputCells{i}{2},'''']);
    end 
    
    % Make indiviual dictionary entries for each output:
    outputDictEntries = cell(1, length(outputCells));
    for j = 1:length(outputCells)
        outputCells{j}{2} = strrep(outputCells{j}{2}, '\', '\\');
        outputDictEntries{j} = strcat(['''', outputCells{j}{1},''':''', outputCells{j}{2},'''']);
    end 

    % Make indiviual dictionary entries for each parameter:
    paramDictEntries = cell(1, length(paramCells));
    disp('length parameters = ');
    disp(length(paramCells));
    for k = 1:length(paramCells)
        if isa(paramCells{k}{2}, 'char')
            paramDictEntries{k} = strcat(['''', paramCells{k}{1},''':''', paramCells{k}{2},'''']);
        elseif isnumeric(paramCells{k}{2})
            paramDictEntries{k} = strcat(['''', paramCells{k}{1},''':', num2str(paramCells{k}{2})]);
        end
    end
    disp('length paramEntries = ');
    disp(length(paramDictEntries));
    
    
    
    %% Get the dependencies of the calling function, and, where possible, their versions:
    
    ST = dbstack(1, '-completenames');
    [fList, pList] = matlab.codetools.requiredFilesAndProducts(ST.file);
    fListMax = 50;
    fList = fList(1:min([length(fList), fListMax])); % we can truncate this list; in practice, it tends to turn out to be several hundred
    
    calledFunctions = cell(1, length(fListMax));
    for i = 1:length(fList)
        [fullPath, commit] = getVersion(fList{i});
        fullPath = strrep(fullPath, '\', '\\');
        calledFunctions{i} = strcat([fullPath, ' ' commit]);
    end
    
    %% Write all " 'key':'value' " pairs into a dictionary:
    
    % Create the metaData cell array; each entry in this array will be a
    % line of the metadata file
    line = 1;
    metaData = cell(numLines, 1);
    metaData{line} = strcat([step, '_metadata = \r\n']); line = line + 1;
    
    metaData{line} = strcat(['{''pipeline'':''', pipeline, ''', \r\n']); line = line + 1;
    
    % Write the input dictionary to metaData
    metaData{line} = strcat([' ''inputs'':{', inputDictEntries{1}]);  %opening bracket of the input dictionary
    if length(inputDictEntries) == 1
        metaData{line} = strcat([metaData{line}, '} \r\n']); line = line + 1;
    else
        metaData{line} = strcat([metaData{line}, ', \r\n']);
        line = line + 1;
        for m = 2:length(inputDictEntries)-1
            metaData{line} = strcat(['           ', inputDictEntries{m}, ', \r\n']); line = line + 1;
        end
        metaData{line} = strcat(['           ', inputDictEntries{length(inputDictEntries)}, '}, \r\n']); line = line + 1; %closing bracket of the input dictionary
    end
    
    
    % Write the output dictionary to metaData
    metaData{line} = strcat([' ''outputs'':{', outputDictEntries{1}]); %opening bracket of the output dictionary
    if length(outputDictEntries) < 2
        metaData{line} = strcat([metaData{line}, '} \r\n']); line = line + 1;
    else
        metaData{line} = strcat([metaData{line}, ', \r\n']);
        line = line + 1;
        for n = 2:length(outputDictEntries)-1
            metaData{line} = strcat(['            ', outputDictEntries{n}, ', \r\n']); line = line + 1;
        end    
        metaData{line} = strcat(['            ', outputDictEntries{length(outputDictEntries)}, '}, \r\n']); line = line + 1; %closing bracket of output dictionary
    end
    
    %Write the calling function's dependencies to metaData
    metaData{line} = strcat([' ''dependencies'':[''', calledFunctions{1}, '''']); 
    if length(calledFunctions) < 2
        metaData{line} = strcat([metaData{line}, '} \r\n']); line = line + 1;
    else
        metaData{line} = strcat([metaData{line}, ', \r\n']);
        line = line + 1;
        for q = 2:length(calledFunctions)-1
            metaData{line} = strcat(['                 ''', calledFunctions{q}, ''', \r\n']); line = line + 1;
        end
        metaData{line} = strcat(['                 ''', calledFunctions{length(calledFunctions)}, '''] \r\n']); line = line + 1;
    end
    
    % Write the parameters dictionary to metaData
    if length(paramDictEntries) > 0
        metaData{line} = strcat([' ''parameters'':{', paramDictEntries{1}]); %opening bracket of parameters dictionary
        if length(paramDictEntries) < 2
            metaData{line} = strcat([metaData{line}, '} \r\n']); line = line + 1;
        else
            metaData{line} = strcat([metaData{line}, ', \r\n']);
            line = line + 1;
            for n = 2:length(paramDictEntries)-1
                metaData{line} = strcat(['               ', paramDictEntries{n}, ', \r\n']); line = line + 1;
            end
            metaData{line} = strcat(['               ', paramDictEntries{length(paramDictEntries)}, '}, \r\n']); line = line + 1; %closing bracket of parameters dictionary
        end
    elseif length(paramDictEntries) == 0
        metaData{line} = ' ''parameters'':{}, \r\n'; line = line + 1;%opening bracket of parameters dictionary
    end
    metaData{line} = '} \r\n';
    
    %% Save as output
    
    % Create the file into which metaData will be saved:
    fileID = fopen('meta.txt', 'w');
    
    % Write the metadata into the file:
    for p = 1:length(metaData)
        fprintf(fileID, metaData{p});
    end
    
    fclose(fileID);
%}
end