%% get the image
[path1, name] = uigetfile('data\testimages\direction_code\*.bmp', 'test');
if ~name
    return
end
test_im = imread(fullfile(name, path1));

[path2, name] = uigetfile('data\database\direction_code\*.bmp', 'database');
if ~name
    return
end
dbase_im = imread(fullfile(name, path2));
figure, imshowpair(test_im, dbase_im)

%% alignment
test_canny = imread(fullfile('data\testimages\cleaned', path1));
db_canny = imread(fullfile('data\database\cleaned', path2));
new_im = imread(fullfile('data\testimages\raw_testimages', path1));

[angle, trans, cf, direction] = test_alignment_one(test_canny, db_canny);

if direction
   temp = test_im;
   test_im = dbase_im;
   dbase_im = temp;
   new_im = imread(fullfile('data\database\raw_database', path2));
end

figure, imshowpair(test_canny, db_canny)

%% imgray
gray_test = imread(fullfile('data\testimages\raw_testimages', path1));
gray_db = imread(fullfile('data\database\raw_database', path2));

figure, imshowpair(gray_test, gray_db)

%% transformation info (use match_info.txt to get the transformation data)
RA = imref2d(size(new_im));

% transform the image
imt = imtranslate(new_im, RA, trans');
% figure, imshowpair(imt, dbase_im)

% rotation
output = rotateAround(imt, cf(2), cf(1), angle);
figure, imshowpair(output, gray_db)

% %% test the transformation
% output = imrotate(imt, angle);
% figure, imshowpair(output, dbase_im)

%% get the score of the images
[temp, ~] = edgeresponse(output);
[~, direction_code] = edgeresponse(imcomplement(temp));

%%
score1 = palm_histo_score(test_im, dbase_im)

direction_code = direction_code(2:end, 2:end);
dbase_im_out = dbase_im(2:end, 2:end);

center = 64;
pad = 54;

direction_code = direction_code(center-pad:center+pad, center-pad:center+pad);
dbase_im_out = dbase_im_out(center-pad:center+pad, center-pad:center+pad);

figure, imshowpair(direction_code, dbase_im_out)
score2 = palm_histo_score(direction_code, dbase_im_out)
