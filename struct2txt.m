function struct2txt(S, fid)
     field2txt(S, inputname(1), fid);
end


%%
function field2txt(data, baseName, fid);
    
    if ~isstruct(data)
        if isnumeric(data)
            data = num2str(data);
        end
        fprintf(fid, strcat([baseName ' = ', data, '\n']));
    else
        
        subFieldNames = fieldnames(data);
        for i = 1:length(subFieldNames)
            extendedName = strcat([baseName, '.', subFieldNames{i}]);
            field2txt(data.(subFieldNames{i}), extendedName, fid);
        end
    end
    

end