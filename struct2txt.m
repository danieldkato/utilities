function struct2txt(S, fid)

% DOCUMENTATION TABLE OF CONTENTS
% I. OVERVIEW
% II. REQUIREMENTS
% III. INPUTS
% IV. OUTPUTS


%% I. OVERVIEW
% This function recursively prints the value of every field of a MATLAB
% struct to an open .txt file. The function's recursive nature means that
% it prints the value of every sub-field of any field that is itself a
% structure.

% Each line of the created text file has the format:

% 'structure.field = value;'

% where any instance of 'field' may itself have the structure 'structure.field'.


%% II. REQUIREMENTS
% 1) The MATLAB function field2txt(), included below in this .m file.


%% III. INPUTS
% 1) S - structure to print to text.
% 2) fid - file ID of a .txt file opened in 'wt' mode. 


%% IV. OUTPUTS
% This function has no formal return, but saves to secondary storage a .txt
% file specifying the value of every field of the input struct.


%%
     field2txt(S, inputname(1), fid);
end


%%
function field2txt(data, baseName, fid)
    
    if ~isstruct(data)
        if isnumeric(data)
            data = num2str(data);
        end
        fprintf(fid, strcat([baseName, ' = ', data, '\n']));
    else
        subFieldNames = fieldnames(data);
        for i = 1:length(subFieldNames)
            extendedName = strcat([baseName, '.', subFieldNames{i}]);
            field2txt(data.(subFieldNames{i}), extendedName, fid);
        end
    end

end