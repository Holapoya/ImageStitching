function k = K(f, center)
    k = [f 0 0; 0 f 0; center(1) center(2) 1];
end