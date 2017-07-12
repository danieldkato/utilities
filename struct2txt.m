function struct2txt(S, fid)
     
    S
    fields = fieldnames(S);
    for i = 1:length(fields)
        field2txt(S, inputname(1), fields{i}, fid);
    end
    
    %{
    if ~isstruct(S)
        if isnumeric(S)
            val = num2str(val);
        end
        fprintf(fid, strcat([name, ' = ', val, '; \n']));
    else
        flds = fieldnames(S);
        for i = 1:length(flds)
            field2txt(S.(flds{i}), fid);
        end
    end
    %}
    
end

function field2txt(parent, baseName, fieldName, fid);
    
    val = parent.(fieldName);
    if ~isstruct(val)
        if isnumeric(val)
            val = num2str(val);
        end
        fprintf(fid, strcat([baseName, '.', fieldName, ' = ', val, '\n']));
    else
        baseName = strcat([baseName, '.', fieldName]);
        parent = parent.(fieldName);
        subFieldNames = fieldnames(parent);
        for i = 1:length(subFieldNames)
            field2txt(parent, baseName, subFieldNames{i}, fid);
        end
    end
    

end