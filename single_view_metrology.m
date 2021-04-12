function single_view_metrology(img_file, saved_pnts, vars_file, ply_file, wrl_file)
img = imread(img_file);

figure(1)
imshow(img); 
axis image;
hold on

if saved_pnts
    % Calculate vanishing points along each axis
    title('Please select 3 lines parallel to the x axis')
    x_vp = get_vanishing_point('red');
    
    title('Please select 3 lines parallel to the y axis')
    y_vp = get_vanishing_point('blue');
    
    title('Please select 3 lines parallel to the z axis')
    z_vp = get_vanishing_point('magenta');
    
    % Choose world origin 
    title('Please select the origin of the world frame');
    [x,y] = myginput(1);
    plot(x,y,'x','LineWidth',2,'Color','yellow', 'MarkerSize', 30);
    origin = [x(1); y(1); 1];
    
    % Choose reference points
    title('Select reference points on the at x, y, and z axis, respectively')
    [x,y] = myginput(3);
    x_ref = [x(1); y(1); 1];
    y_ref = [x(2); y(2); 1];
    z_ref = [x(3); y(3); 1];
    plot(x,y,'x','LineWidth',2,'Color','green', 'MarkerSize', 30);
    title('Origin (Yellow) Ref points (Green) X lines (Red) Y lines (Blue) Z lines (Pink)')
    
    % Get distance between origin and reference points
    % x_dist = pdist([origin'; x_ref'], 'Euclidean')
    % y_dist = pdist([origin'; y_ref'], 'Euclidean')
    % z_dist = pdist([origin'; z_ref'], 'Euclidean')

    x_dist = input('Enter x-reference distance from origin');
    y_dist = input('Enter y-reference distance from origin');
    z_dist = input('Enter z-reference distance from origin');
    
    save(vars_file, 'x_vp', 'y_vp', 'z_vp', 'origin', 'x_ref', 'y_ref', 'z_ref', 'x_dist', 'y_dist', 'z_dist')
else
    [x_vp, y_vp, z_vp, origin, x_ref, y_ref, z_ref, x_dist, y_dist, z_dist] = load_vars(vars_file);
end

% Calculate scaling factors for each axis
x_scale = ((x_vp - x_ref) \ (x_ref - origin))/x_dist;
y_scale = ((y_vp - y_ref) \ (y_ref - origin))/y_dist;
z_scale = ((z_vp - z_ref) \ (z_ref - origin))/z_dist;

% % Build projection matrix
P = [(x_vp*x_scale) (y_vp*y_scale) (z_vp*z_scale) origin];

% Get homography matrices from projection matrix
H_xy = P(:, [1 2 4]);
H_yz = P(:, [2 3 4]);
H_xz = P(:, [1 3 4]);

close(1);
extract_texture(img, H_xy, img_file, 'xy', 2);
extract_texture(img, H_yz, img_file, 'yx', 3);
extract_texture(img, H_xz, img_file, 'xz', 4);

% will hold all 3d points
coords = zeros(3,0);

% define variables for cross ratio calculation
% base point, reference point, reference height
b0 = origin;
t0 = z_ref;
H = z_dist;

% Calculate vanishing line of reference plane
vanishing_line = real(cross(y_vp, x_vp));
length = sqrt(vanishing_line(1)^2 + vanishing_line(2)^2);
vanishing_line = vanishing_line/length;

figure(5)
imshow(img); 
axis image;
hold on
% Continuously use on plane  and between plane measurements to compute 3D points
while 1
    disp('Select a base point or q to quit')
    title('Select a base point or q to quit')
    [x1,y1, inp] = myginput(1);    
    if inp == 'q'        
        break;
    end
    plot(x1,y1,'x','LineWidth',2,'Color','black', 'MarkerSize', 22);
    b = [x1;y1;1];
    
    disp('Select a point to be estimated in 3D or q to quit');
    title('Select a point to be estimated in 3D or q to quit')
    [x2,y2] = myginput(1);
    plot(x2,y2,'x','LineWidth',2,'Color','black', 'MarkerSize', 22);
    r = [x2;y2;1];
    
    % line between selected base point and base point of z reference point
    l1 = real(cross(b0, b));
    % interection v between l1 and vanishing line
    v = real(cross(l1, vanishing_line));
    v = v/v(3);
    
    % line between point v z reference point
    l2 = real(cross(v', t0));
    vert_line = real(cross(r, b));
    
    % point t on line between b and r
    t = real(cross(l2, vert_line));
    t = t/t(3);
    
    % Calculate height of selected point through cross ratio equation
    R = H*norm(r-b)*norm(z_vp'-t)/norm(t'-b)/norm(z_vp-r);
    
    answer = inputdlg('Add this point? (Y/N)', 'Adding',[1 30],{'Y'});
    if char(answer) == 'Y'
        % Calculate planar homology H_z
        H_z = [P(:,1) P(:,2) P(:,3).*R+P(:,4)];
        
        % Compute true X-Y position from u-v image position using H_z
        temp = H_z\r;
        coord = [temp(1)/temp(3); temp(2)/temp(3); R]
        coords(:, end+1) = coord;
        
        % Continuously add 3d points at this same height
        answer = inputdlg('Add more points at this height? (Y/N)', 'Same height adding',[1 30],{'Y'});
        if char(answer) == 'Y'
            while 1
                disp('Click a point at the same height or press q to stop')
                title('Click a point at the same height or press q to stop')
                % get new point for modeling
                [x,y,inp] = ginput(1);    
                if inp == 'q'        
                    break;
                end
                plot(x,y,'x','LineWidth',2,'Color','black', 'MarkerSize', 22);
                next_point = [x;y;1];
                
                % height is given so only need to compute true X-Y position
                H_z = [P(:,1) P(:,2) P(:,3).*R+P(:,4)];
                temp = H_z\next_point;
                coord = [temp(1)/temp(3); temp(2)/temp(3); R]
                coords(:, end+1) = coord;
            end
        end
    end
end

% Set all points in ply model to red to easier viewing
num_points = size(coords, 2);
colors = zeros(3,num_points);
colors(1,:) = 255;

% Create 3D models
create_ply(ply_file, coords, colors);
create_wrl(wrl_file, coords);

end