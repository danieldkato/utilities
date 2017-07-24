function struct2txt(S, fid)

% DOCUMENTATION TABLE OF CONTENTS
% I. OVERVIEW
% II. REQUIREMENTS
% III. INPUTS
% IV. OUTPUTS


%% I. OVERVIEW
% This function recursively prints the name and value of every field of a
% MATLAB struct to an open .txt file. The function's recursive nature means
% that it prints the value of every sub-field of any field that is itself a
% structure.

% Each line of the created text file has the format:

% 'structure.field = value;'

% where 'field' may itself have the structure 'structure.field'.


%% II. REQUIREMENTS
% 1) The MATLAB function field2txt(), included below in this .m file.


%% III. INPUTS
% 1) S - structure to print to text.
% 2) fid - file ID of a .txt file opened in 'wt' mode. 


%% IV. OUTPUTS
% This function has no formal return, but saves to secondary storage a .txt
% file specifying the value of every field of the input struct.


%%
     field2txt(inputname(1), S, fid);
end


%%
function field2txt(name, value, fid)

    if ~isstruct(value)
        valueStr = value;
        valueStr = strrep(valueStr, '\', '\\');
        if isnumeric(value) && length(value) == 1
            valueStr = num2str(value);
        elseif isnumeric(value) && length(value) > 1
                disp('ARRAY');
                valueStr = '[';
                for j = 1:length(value)
                    valueStr = [valueStr num2str(value(j)) ' '];
                end
                valueStr = [valueStr(1:end-1) ']'];
        end
        fprintf(fid, strcat([name, ' = ', valueStr, '\n']));
    else
        subFieldNames = fieldnames(value);
        for i = 1:length(subFieldNames)
            subFieldName = strcat([name, '.', subFieldNames{i}]);
            field2txt(subFieldName, value.(subFieldNames{i}), fid);
        end
    end

end