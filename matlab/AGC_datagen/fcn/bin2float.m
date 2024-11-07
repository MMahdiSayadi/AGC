function o = bin2float(x)
    o = typecast(uint32(bin2dec(x)), 'single');
end 