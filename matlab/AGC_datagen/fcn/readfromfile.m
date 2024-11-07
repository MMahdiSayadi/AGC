function vec = readfromfile(filename)
    fid = fopen(filename, 'r');
    line = fgetl(fid);
    str_vector = [];
    while ischar(line)
        str_vector = [str_vector; line];
        line = fgetl(fid); 
    end
    fclose(fid);
    vec = str_vector;
end 