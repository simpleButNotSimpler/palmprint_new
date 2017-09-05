%% get the rawimage
[path1, name] = uigetfile('data\testimages\raw\*.bmp', 'test');
if ~name
    return
end
raw_test_im = imread(fullfile(name, path1));
raw_test_im = im2double(raw_test_im);

[path2, name] = uigetfile('data\database\raw\*.bmp', 'database');
if ~name
    return
end
raw_db_im = imread(fullfile(name, path2));
raw_db_im = im2double(raw_db_im);


%% direction_code, canny and cleaned image
%parameters
dist_threshold = 6;
error_threshold = 2;
area_threshold = 40;

%test
[imfirstedge, ~] = edgeresponse(raw_test_im);
[imsecondedge, dc_test_im] = edgeresponse(imcomplement(imfirstedge));
[canny_test_im, ~] = cannys(imsecondedge, 0.6, 0.8);
cleaned_test_im = clean_palm(canny_test_im, dist_threshold, error_threshold, area_threshold);

%dc
[imfirstedge, ~] = edgeresponse(raw_db_im);
[imsecondedge, dc_db_im] = edgeresponse(imcomplement(imfirstedge));
[canny_db_im, ~] = cannys(imsecondedge, 0.6, 0.8);
cleaned_db_im = clean_palm(canny_db_im, dist_threshold, error_threshold, area_threshold);

%% alignment
[angle, trans, cf, direction] = test_alignment_one(cleaned_test_im, cleaned_db_im);

if direction
   %raw
   temp = raw_test_im;
   raw_test_im = raw_db_im;
   raw_db_im = temp;
   
   %dc
   temp = dc_test_im;
   dc_test_im = dc_db_im;
   dc_db_im = temp;
   
   %canny
   temp = canny_test_im;
   canny_test_im = canny_db_im;
   canny_db_im = temp;
   
   %cleaned
   temp = cleaned_test_im;
   cleaned_test_im = cleaned_db_im;
   cleaned_db_im = temp;
end

%% transform the original image
% angle = 0;
% trans = [0;0];
RA = imref2d(size(raw_test_im));
dc_imt = imtranslate(raw_test_im, RA, trans');
dc_test_rotated_im = rotateAround(dc_imt, cf(2), cf(1), angle);

%direction code
[temp, ~] = edgeresponse(dc_test_rotated_im);
[~, dc_test_rotated_im] = edgeresponse(imcomplement(temp));

%crop the direction-code image
[row, col, dc_test_cropped_im] = crop_rotation(dc_test_rotated_im);
dc_db_cropped_im = dc_db_im(row(1):row(2), col(1):col(2));

%% display the transformations
subplot(2, 3, 1), imshowpair(cleaned_test_im, cleaned_db_im)
subplot(2, 3, 4), imshowpair(cleaned_test_im, cleaned_db_im)
subplot(2, 3, 2), imshowpair(dc_test_im, dc_db_im)
subplot(2, 3, 5), imshowpair(dc_test_rotated_im, dc_db_im)
subplot(2, 3, 3), imshowpair(dc_test_cropped_im, dc_db_cropped_im)

%% scores
%================= DIRECTION CODE IMAGE =======================
%score original
original = palmcode_angular_diff(dc_test_im, dc_db_im)

%score full rotated
full_rotated = palmcode_angular_diff(dc_test_rotated_im, dc_db_im)

%score cropped rotated
cropped_rotated = palmcode_angular_diff(dc_test_cropped_im, dc_db_cropped_im)

%score palmregion rotated
RA = imref2d(size(canny_test_im));
canny_imt = imtranslate(canny_test_im, RA, trans');
canny_test_im = rotateAround(canny_imt, cf(2), cf(1), angle);

canny_test_im = canny_test_im(row(1):row(2), col(1):col(2));
canny_db_im = canny_db_im(row(1):row(2), col(1):col(2));

dc_palmregion_rotated = palmcode_diff_region_palm(dc_test_cropped_im, dc_db_cropped_im, canny_test_im, canny_db_im)
