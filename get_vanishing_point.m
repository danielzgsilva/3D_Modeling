function vp = get_vanishing_point(color)
% get 6 points (2 for each line)
[x,y] = myginput(6);

% display lines on image
plot(x,y,'x','LineWidth',2,'Color',color);
line([x(1) x(2)], [y(1) y(2)], 'LineWidth',2, 'Color',color);
line([x(3) x(4)], [y(3) y(4)], 'LineWidth',2, 'Color',color);
line([x(5) x(6)], [y(5) y(6)], 'LineWidth',2, 'Color',color);

p1 = [x(1) y(1) 1];
p2 = [x(2) y(2) 1];
p3 = [x(3) y(3) 1];
p4 = [x(4) y(4) 1];
p5 = [x(5) y(5) 1];
p6 = [x(6) y(6) 1];

% calculate the 3 parallel lines
lines = [cross(p1,p2); cross(p3,p4); cross(p5,p6)];
n = size(lines, 1);

% To compute the vanishing point (best intersection fit between the 3 lines)
% form the 3x3 "second moment" matrix M as
%         [  a_i*a_i   a_i*b_i     a_i*c_i ]
% M = sum [  a_i*b_i   b_i*b*i     b_i*c_i ]  for i = 1 to n
%         [  a_i*c_i   b_i*c_i     c_i*c_i ]

M = zeros(3,3);
for i=1:n
    l = lines(i, :);
    
    M(1,1) = M(1,1) + l(1)*l(1);
    M(1,2) = M(1,2) + l(1)*l(2);
    M(1,3) = M(1,3) + l(1)*l(3);
    
    M(2,1) = M(2,1) + l(1)*l(2);
    M(2,2) = M(2,2) + l(2)*l(2);
    M(2,3) = M(2,3) + l(2)*l(3);
    
    M(3,1) = M(3,1) + l(1)*l(3);
    M(3,2) = M(3,2) + l(2)*l(3);
    M(3,3) = M(3,3) + l(3)*l(3);
end

% Vanishing point is the eigenvector of M associated with smallest eigenvalue
[vp, ~] = eigs(M,1,'SM');
vp = vp/ vp(3);

end