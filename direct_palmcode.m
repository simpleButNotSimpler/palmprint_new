function score = direct_palmcode(im_test_name, database)
%%take one test image name and one direction_code database as input, it outputs the minimum palmcode
%difference between the im and the images in the database without using alignement

db_len = length(database);
dc_test_im = read_image(fullfile('data\testimages\direction_code', im_test_name));
canny_test_im = read_image(fullfile('data\testimages\canny', im_test_name));

dc_orig_min = inf;

for counter=1:db_len
    % get the image image for one person
    dc_db_im = read_image(fullfile(database(counter).folder, database(counter).name));
    canny_db_im = read_image(fullfile('data\database\canny', database(counter).name));
    
    if isempty(find(canny_db_im, 1))
        continue
    end
    
    %the scores 
%     score_dc_orig = palmcode_diff_weights(dc_test_im, dc_db_im, canny_test_im, canny_db_im);
    score_dc_orig = palmcode_diff_weights_fused(dc_test_im, dc_db_im, canny_test_im, canny_db_im);
        
    %update global minimum
    if score_dc_orig < dc_orig_min
        dc_orig_min = score_dc_orig;
    end
end

score = dc_orig_min;
end