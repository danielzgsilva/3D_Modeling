function texture = extract_texture(img, H, filename, plane, fig)
tform = projective2d(inv(H)');
warped = imwarp(img, tform);
figure(fig) 
imshow(warped);
title(strcat(plane, ': crop and save this texture file'))
imwrite(warped,strcat(plane, '_', filename));
end