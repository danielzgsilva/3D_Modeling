function [x_vp, y_vp, z_vp, origin, x_ref, y_ref, z_ref, x_dist, y_dist, z_dist] = load_vars(file)
    vars = load(file);
    x_vp = vars.x_vp;
    y_vp = vars.y_vp;
    z_vp = vars.z_vp;
    origin = vars.origin;
    x_ref = vars.x_ref;
    y_ref = vars.y_ref;
    z_ref = vars.z_ref;
    x_dist = vars.x_dist;
    y_dist = vars.y_dist;
    z_dist = vars.z_dist;
end