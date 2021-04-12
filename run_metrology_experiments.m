% Example 1
% img_file = 'rubix.jpg';
% single_view_metrology(img_file, false, 'rubix_vars.mat', 'rubix.ply');
% show_ply('rubix.ply');

% Example 2
img_file = 'painting.jpg';
single_view_metrology(img_file, true, 'painting_vars.mat', 'painting.ply', 'painting.wrl');
show_ply('painting.ply');


