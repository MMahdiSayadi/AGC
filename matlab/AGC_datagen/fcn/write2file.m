function write2file(filename, vec)
    fid = fopen(filename, 'w');
    for i = 1: length(vec)
        fprintf(fid, '%s\n', vec(i, :));
    end 
    fclose(fid);
end 