function Y = dampedOsci(p,t)   
Y = exp(-p(1)*t).*(p(2)*cos(p(4)*t)+p(3)*sin(p(4)*t)) + p(5)*t + p(6) ;
end