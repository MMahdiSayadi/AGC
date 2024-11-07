function o = defim(x, s, w, f)
    if s == 1 
        o = x;
        o(o<(2^f)-1) = o(o<(2^f)-1) / 2^f;
        o(o>(2^f)-1) = (o(o>(2^f)-1) - 2^w)/2^f;
    elseif s == 0 
        o = x / 2^f;
    end 
end 