function score = aligned_palmcode(im_test_name, database)
%take one cleaned image and one cleaned database as input, it outputs the minimum palmcode
%difference between the im and the images in the database using alignement
%and the minimum difference of their palmlines
    
%get the best match for im_test in the database
folder = database(1).folder;
im_test = imread(fullfile('data\testimages\cleaned', im_test_name));
global_min_err = inf;
angle = [];
trans = [];
cf = [];
direction = [];
winner_idx = [];

for counter=1:numel(database)
    im_db = imread(fullfile(folder, database(counter).name));
    
    %align the two current images
    [temp_angle, temp_trans, temp_cf, temp_direction, err] = test_alignment_one(im_test, im_db);
    
    %get the best results
    if temp_cf == 0
       continue
    end
    
    if err < global_min_err
        global_min_err = err;
        angle = temp_angle;
        trans = temp_trans;
        cf = temp_cf;
        direction = temp_direction;
        winner_idx = counter;
    end
end

%transform the im test image and get their palmcode diff
db_im_name = database(winner_idx).name;

score = rotated_im_scores(im_test_name, db_im_name, angle, trans, cf, direction);

% score = [dc_full_rot, dc_cr_rot, dc_pr_full_rot, dc_pr_cr_rot, cl_rot, cl_pr];
end

%return the alignement transformation and he direction between two images
function [angle, trans, cf, direction, err] = test_alignment_one(moving_im, fixed_im)
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

%first way
[~, T1, ~, angle1, er1, cf1] = icp(D, M, 50, 0.0001, 0);

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
     err = er1_1;
 else
     direction = 1;
     cf = cf2;
     angle = angle2;
     trans = T2;
     err = er2_1;
 end
end

%scores of the rotated palmcodes
function score = rotated_im_scores(test_im_name, db_im_name, angle, trans, cf, direction)

%actual code
cleaned_test_name = fullfile('data\testimages\cleaned', test_im_name);
cleaned_db_name = fullfile('data\database\cleaned', db_im_name);
% dc_test_name = fullfile('data\testimages\direction_code', test_im_name);
% dc_db_name = fullfile('data\database\direction_code', db_im_name);

if direction
   temp = cleaned_test_name;
   cleaned_test_name = cleaned_db_name;
   cleaned_db_name = temp;
   
%    temp = dc_test_name;
%    dc_test_name = dc_db_name;
%    dc_db_name = temp;
end


cleaned_test_im = imread(cleaned_test_name);
cleaned_db_im = imread(cleaned_db_name);
% dc_test_im = imread(dc_test_name);
% dc_db_im = imread(dc_db_name);


% transform the cleaned images
RA = imref2d(size(cleaned_test_im));
imt = imtranslate(cleaned_test_im, RA, trans');
cleaned_output_im = rotateAround(imt, cf(2), cf(1), angle);

% transform the direction-code images
% RA = imref2d(size(dc_test_im));
% dc_imt = imtranslate(dc_test_im, RA, trans');
% dc_output_im = rotateAround(dc_imt, cf(2), cf(1), angle);
% 
% %crop the direction-code image
% [row, col, dc_cropped_output_im] = crop_rotation(dc_output_im);
% dc_cropped_db_im = dc_db_im(row(1):row(2), col(1):col(2));
% cleaned_cropped_output_im = cleaned_output_im(row(1):row(2), col(1):col(2));
% cleaned_cropped_db_im = cleaned_db_im(row(1):row(2), col(1):col(2));

% scores
%================= DIRECTION CODE IMAGE =======================
% %score full rotated
% dc_full_rot = palmcode_diff(dc_output_im, dc_db_im);
% 
% %score cropped rotated
% dc_cr_rot = palmcode_diff(dc_cropped_output_im, dc_cropped_db_im);
% 
% %score palmregion full rotated
% dc_pr_full_rot = palmcode_diff_region_palm(dc_output_im, dc_db_im, cleaned_output_im, cleaned_db_im);
% 
% %score palmregion cropped rotated
% dc_pr_cr_rot = palmcode_diff_region_palm(dc_cropped_output_im, dc_cropped_db_im, cleaned_cropped_output_im, cleaned_cropped_db_im);


%================= CLEANED IMAGE =======================
%score cleaned rotated
cl_rot = palmcode_diff_bw(cleaned_output_im, cleaned_db_im);

%score palmregion rotated
% cl_pr = palmcode_diff_bw_region_palm(cleaned_output_im, cleaned_db_im, cleaned_output_im, cleaned_db_im);

% score = [dc_full_rot, dc_cr_rot, dc_pr_full_rot, dc_pr_cr_rot, cl_rot, cl_pr];

score = cl_rot;

end