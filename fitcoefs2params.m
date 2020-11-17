function [k,f] = fitcoefs2params(coefs)
    % parameters
    g = 9.8;
    ra = 0.17;%need to know
    rb = 0.05;
    gamma = coefs(1);
    omega1 = coefs(4);
    M = coefs(6)/g;
    K = M*(omega1^2 + gamma^2);
    k = (ra/rb)^2*K/1000; %kN/m
    f = ra/rb*M*g;
end