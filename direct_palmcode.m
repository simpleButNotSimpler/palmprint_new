function score = direct_palmcode(im_test_name, database)
%%take one test image name and one direction_code database as input, it outputs the minimum palmcode
%difference between the im and the images in the database without using alignement

db_len = length(database);
dc_test_im = read_image(fullfile('data\testimages\direction_code', im_test_name));
cleaned_test_im = read_image(fullfile('data\testimages\cleaned', im_test_name));

dc_orig_min = inf;
dc_palmregion_min = inf;
% cleaned_orig_min = inf;

for counter=1:db_len
    % get the image image for one person
    dc_db_im = read_image(fullfile(database(counter).folder, database(counter).name));
    cleaned_db_im = read_image(fullfile('data\database\cleaned', database(counter).name));
    
    if isempty(find(cleaned_db_im, 1))
        continue
    end
    
    %the scores
    score_dc_orig = palmcode_diff(dc_test_im, dc_db_im);
%     score_dc_palm = palmcode_diff_region_palm(dc_test_im, dc_db_im, cleaned_test_im, cleaned_db_im);
    score_cleaned_orig = palmcode_diff_bw(cleaned_test_im, cleaned_db_im);
        
    %update global minimum
    if score_dc_orig < dc_orig_min
        dc_orig_min = score_dc_orig;
    end
    
    if score_dc_palm < dc_palmregion_min
        dc_palmregion_min = score_dc_palm;
    end
    
%     if score_cleaned_orig < cleaned_orig_min
%         cleaned_orig_min = score_cleaned_orig;
%     end
end

% score = [dc_orig_min, dc_palmregion_min, cleaned_orig_min];
score = [dc_orig_min, dc_palmregion_min];

end