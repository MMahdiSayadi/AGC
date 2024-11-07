function [o_int, o_bin] = fim(x, s, w, f)
    o_int = zeros(size(x));
    if s == 1 
        o_int = floor(x * 2^f);
        o_int(o_int<0) = o_int(o_int<0) + 2^w;
    elseif s == 0 
        o_int(x>0) = floor(x(x>0)*2^f);
    end 
    o_bin = dec2bin(o_int, w);
end 