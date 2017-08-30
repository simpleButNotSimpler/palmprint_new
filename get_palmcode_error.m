function score = get_palmcode_error(test_im, dbase_im, path1, path2, thresh, aligned)
    score = palm_histo_score(test_im, dbase_im);
    
    if score <= thresh || ~aligned
        return
    end
    
    %align
    test_canny = imread(fullfile('data\testimages\cleaned', path1));
    db_canny = imread(fullfile('data\database\cleaned', path2));

    [angle, trans, cf, direction] = test_alignment_one(test_canny, db_canny);

    if direction
       dbase_im = test_im;
       test_im = imread(fullfile('data\database\raw_database', path2));
    else
        test_im = imread(fullfile('data\testimages\raw_testimages', path1));
    end
    
    %translation
    translation = trans';
    RA = imref2d(size(test_im));
    imt = imtranslate(test_im, RA, translation);
    
    %rotation
    output = rotateAround(imt, cf(2), cf(1), angle);
    
    %recompute palmcode
    [output, ~] = edgeresponse(output);
    [~, direction_code] = edgeresponse(imcomplement(output));

    %crop
    direction_code = direction_code(2:end, 2:end);
    dbase_im = dbase_im(2:end, 2:end);

    center = 64;
    pad = 40;

    direction_code = direction_code(center-pad:center+pad, center-pad:center+pad);
    dbase_im = dbase_im(center-pad:center+pad, center-pad:center+pad);

    %score
    score = palm_histo_score(direction_code, dbase_im);
end

function [angle, trans, cf, direction] = test_alignment_one(moving_im, fixed_im)
cf = 0;
direction = 0;
    
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