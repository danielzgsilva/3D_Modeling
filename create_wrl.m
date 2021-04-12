function create_wrl(fname, coords)
pos = [coords; 1:size(coords,2)];

% scatter plot
X = pos(1,:);
Y = pos(2,:);
Z = pos(3,:);
textCell = arrayfun(@(x,y,z) sprintf('(%3.2f, %3.2f, %3.2f)',x,y,z),X,Y,Z,'un',0);
figure;
scatter3(X,Y,Z);
for ii = 1:numel(X) 
    text(X(ii)+.02, Y(ii)+.02, Z(ii)+.02, textCell{ii},'FontSize',8) 
end

valstring = input('Which coordinates to use for current patch? => ', 's'); %input 1,...,N (#coordinates) in order
valparts = regexp(valstring, '[ ,]', 'split');
coord = str2double(valparts);
num_coord = size(coord, 2);

filename = input('texture file name? (with extension) => ', 's');

cur_texture = imread(filename);
cur_height = size(cur_texture, 1);
cur_width = size(cur_texture, 2);
figure, imshow(cur_texture);
disp('Select texture coordinated in order');
texCoor = zeros(2,0);
for i = 1:num_coord
    [x,y] = ginput(1);
    %plot(x,y,'*');
    texCoor(:, end+1) = [x/cur_width; (cur_height-y)/cur_height]
end

if ~exist('test.txt', 'file')
    fid = fopen('test.txt','w');
    fprintf(fid,'#VRML V2.0 utf8\n\nCollision {\n collide FALSE\n children [\n ]\n }');
    fclose(fid);
end
%delete last two lines
fcontent = fileread('test.txt');
fid = fopen('test.txt','w');
fwrite(fid, regexp(fcontent, '.*(?=\n.*?)', 'match', 'once'));
fclose(fid);
fcontent = fileread('test.txt');
fid = fopen('test.txt','w');
fwrite(fid, regexp(fcontent, '.*(?=\n.*?)', 'match', 'once'));
fclose(fid);
%append a new Shape & add back last two lines
fid = fopen('test.txt','a');
fprintf(fid, '\n Shape {\n  appearance Appearance {\n   texture ImageTexture {\n   url "');
fprintf(fid, filename);
fprintf(fid, '"\n  }  \n  }\n   geometry IndexedFaceSet {\n   coord Coordinate {\n   point [\n');
for i = 1:num_coord
    cur = coord(i);
    fprintf(fid, '     %9.5f %9.5f %9.5f, \n', pos(1,cur),pos(2,cur),pos(3,cur));
end
fprintf(fid, '\n   ]\n   }\n   coordIndex [\n    ');
for i = 1:num_coord
    fprintf(fid, '%i,', i-1);
end
fprintf(fid, '%i,', -1);
fprintf(fid, '\n   ]\n   texCoord TextureCoordinate {\n    point [\n');
for i = 1:num_coord
    fprintf(fid, '     %3.2f %3.2f,\n', texCoor(1,i), texCoor(2,i));
end
fprintf(fid, '\n    ]\n   }\n   texCoordIndex [\n    ');
for i = 1:num_coord
    fprintf(fid, '%i,', i-1);
end
fprintf(fid, '%i,', -1);
fprintf(fid, '\n   ]\n   solid FALSE\n  }\n}');
fprintf(fid, '\n ] \n}');
fclose(fid);
end