%% get the image
[path1, name] = uigetfile('data\testimages\cleaned\*.bmp', 'test');
if ~name
    return
end
test_im = imread(fullfile(name, path1));

[path2, name] = uigetfile('data\database\cleaned\*.bmp', 'database');
if ~name
    return
end
dbase_im = imread(fullfile(name, path2));

%direction code images
dc_test_im = imread(fullfile('data\testimages\direction_code', path1));
dc_db_im = imread(fullfile('data\database\direction_code', path2));
orig_test_im = imread(fullfile('data\testimages\raw', path1));
orig_test_im = im2double(orig_test_im);
orig_db_im = imread(fullfile('data\database\raw', path2));
orig_db_im = im2double(orig_db_im);

canny_test_im = imread(fullfile('data\testimages\canny', path1));
canny_db_im = imread(fullfile('data\database\canny', path2));

close all
figure, imshowpair(test_im, dbase_im)

%% alignment
[angle, trans, cf, direction] = test_alignment_one(test_im, dbase_im);

if direction
   temp = orig_test_im;
   orig_test_im = orig_db_im;
   orig_db_im = temp; 
    
   temp = test_im;
   test_im = dbase_im;
   dbase_im = temp;
   
   temp = dc_test_im;
   dc_test_im = dc_db_im;
   dc_db_im = temp;
   
   temp = canny_test_im;
   canny_test_im = canny_db_im;
   canny_db_im = temp;
end

%% transform the cleaned images
RA = imref2d(size(test_im));
imt = imtranslate(test_im, RA, trans');
output = rotateAround(imt, cf(2), cf(1), angle);

%% transform the original image
RA = imref2d(size(orig_test_im));
dc_imt = imtranslate(orig_test_im, RA, trans');
orig_rotated_im = rotateAround(dc_imt, cf(2), cf(1), angle);

[restored_orig_im, non_palm_region] = restore_im(orig_rotated_im, orig_db_im); % restore the image

%direction code
[temp, ~] = edgeresponse(restored_orig_im);
[~, dc_output_im] = edgeresponse(imcomplement(temp));
dc_output_im(non_palm_region) = dc_db_im(non_palm_region);

%crop the direction-code image
% [row, col, dc_cropped_output] = crop_rotation(dc_output_im);
% dc_cropped_db_im = dc_db_im(row(1):row(2), col(1):col(2));

%% display the transformations
subplot(2, 3, 1), imshowpair(test_im, dbase_im)
subplot(2, 3, 4), imshowpair(output, dbase_im)
subplot(2, 3, 2), imshowpair(dc_test_im, dc_db_im)
subplot(2, 3, 5), imshowpair(dc_output_im, dc_db_im)
% subplot(2, 3, 3), imshowpair(dc_cropped_output, dc_cropped_db_im)

%% scores
%================= DIRECTION CODE IMAGE =======================
%score original
original = palmcode_diff(dc_test_im, dc_db_im)

%score full rotated
% full_rotated = palmcode_diff(dc_output, dc_db_im)

%score cropped rotated
% cropped_rotated = palmcode_diff(dc_cropped_output, dc_cropped_db_im)

%score cropped rotated
% dc_db_im(non_palm_region) = 180;
restored_score = palmcode_diff(dc_output_im, dc_db_im)

% %score palmregion rotated
% RA = imref2d(size(canny_test_im));
% canny_imt = imtranslate(canny_test_im, RA, trans');
% canny_test_im = rotateAround(canny_imt, cf(2), cf(1), angle);
% 
% canny_test_im = canny_test_im(row(1):row(2), col(1):col(2));
% canny_db_im = canny_db_im(row(1):row(2), col(1):col(2));
% 
% dc_palmregion_rotated = palmcode_diff_region_palm(dc_cropped_output, dc_cropped_db_im, canny_test_im, canny_db_im)
