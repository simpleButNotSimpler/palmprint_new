function [angle, trans, cf, direction] = test_alignment_one(moving_im, database)
cf = 0;
direction = 0;

    % get the image image for one person
    fixed_im = database;
    
    if isempty(find(fixed_im, 1))
        return
    end
    
    % datasets
    [y, x] = find(fixed_im);
    M = [x, y];

    [y, x] = find(moving_im);
    D = [x, y];
%tic
    %first way
    [~, T1, ~, angle1, er1, cf1] = icp(D, M, 50, 0.0001, 0);
%toc
%tic
    %second way
    [~, T2, ~, angle2, er2,  cf2] = icp(M, D, 50, 0.0001, 0);
%toc   
    % statistics
     er1_1 = er1(end);
     er2_1 = er2(end);
     
     if er1_1 < er2_1
         direction = 0;
         cf = cf1;
         angle = angle1;
         trans = T1;
     else
         direction = 1;
         cf = cf2;
         angle = angle2;
         trans = T2;
     end


end