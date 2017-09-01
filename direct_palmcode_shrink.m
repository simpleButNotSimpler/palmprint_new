function score = direct_palmcode_shrink(im_test_name, database)
%%take one test image name and one direction_code database as input, it outputs the minimum palmcode
%difference between the im and the images in the database without using alignement

db_len = length(database);
dc_test_im_orig = read_image(fullfile('data\testimages\direction_code', im_test_name));

% cleaned_orig_min = inf;
score = [];
shrink_array = [1 2 4 6 8 10 12 14 16 18];

for t=1:10
    shrink = shrink_array(t);
    
    dc_test_im = dc_test_im_orig(shrink:end-(shrink-1), shrink:end-(shrink-1));
    
    dc_orig_min = inf;
    for counter=1:db_len
        % get the image image for one person
        dc_db_im = read_image(fullfile(database(counter).folder, database(counter).name));
        
        %shrink the images
        dc_db_im = dc_db_im(shrink:end-(shrink-1), shrink:end-(shrink-1));

        %the scores
        score_dc_orig = palmcode_diff(dc_test_im, dc_db_im);

        %update global minimum
        if score_dc_orig < dc_orig_min
            dc_orig_min = score_dc_orig;
        end
    end
    score = [score, dc_orig_min];
    
end
end