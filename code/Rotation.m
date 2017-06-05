function R1 = Rotation(vec1)
    vec1 = vec1 / norm(vec1);
    vec1(isnan(vec1)) = 0;
    R1 = zeros([3 3]);
    R1(1, 2) = -1 * vec1(3);
    R1(1, 3) = vec1(2);
    R1(2, 1) = vec1(3);
    R1(2, 3) = -1 * vec1(1);
    R1(3, 1) = -1 * vec1(2);
    R1(3, 2) = vec1(1);
    R1 = exp(R1);
end