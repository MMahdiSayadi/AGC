function y = float2bin(x)
    y = dec2bin(hex2dec(num2hex(single(x))));
end 