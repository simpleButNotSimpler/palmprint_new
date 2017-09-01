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
orig_im = imread(fullfile('data\testimages\raw', path1));

figure, imshowpair(test_im, dbase_im)

%% alignment
[angle, trans, cf, direction] = test_alignment_one(test_im, dbase_im);

if direction
   temp = test_im;
   test_im = dbase_im;
   dbase_im = temp;
   
   temp = dc_test_im;
   dc_test_im = dc_db_im;
   dc_db_im = temp;
   
   orig_im = imread(fullfile('data\database\raw', path2));
end


%% transform the cleaned images
RA = imref2d(size(test_im));
imt = imtranslate(test_im, RA, trans');
output = rotateAround(imt, cf(2), cf(1), angle);

%% transform the original image
RA = imref2d(size(orig_im));
dc_imt = imtranslate(orig_im, RA, trans');
dc_output = rotateAround(dc_imt, cf(2), cf(1), angle);

%direction code
[temp, ~] = edgeresponse(dc_output);
[~, dc_output] = edgeresponse(imcomplement(temp));

%crop the direction-code image
[row, col, dc_cropped_output] = crop_rotation(dc_output);
dc_cropped_db_im = dc_db_im(row(1):row(2), col(1):col(2));

%% display the transformations
subplot(2, 3, 1), imshowpair(test_im, dbase_im)
subplot(2, 3, 4), imshowpair(output, dbase_im)
subplot(2, 3, 2), imshowpair(dc_test_im, dc_db_im)
subplot(2, 3, 5), imshowpair(dc_output, dc_db_im)
subplot(2, 3, 3), imshowpair(dc_cropped_output, dc_cropped_db_im)

%% scores
%================= DIRECTION CODE IMAGE =======================
%score original
original = palmcode_diff(dc_test_im, dc_db_im)

%score full rotated
full_rotated = palmcode_diff(dc_output, dc_db_im)

%score cropped rotated
cropped_rotated = palmcode_diff(dc_cropped_output, dc_cropped_db_im)

%score palmregion original
dc_palmregion_original = palmcode_diff_region_palm(dc_test_im, dc_db_im, test_im, dbase_im)

%score palmregion rotated
dc_palmregion_rotated = palmcode_diff_region_palm(dc_test_im, dc_db_im, output, dbase_im)


%================= CLEANED IMAGE =======================
%score cleaned original
cleaned_original = palmcode_diff_bw(test_im, dbase_im)

%score cleaned rotated
cleaned_rotated = palmcode_diff_bw(output, dbase_im)

%score palmregion rotated
cleaned_palmregion_rotated = palmcode_diff_bw_region_palm(output, dbase_im, output, dbase_im)
