function report_palmcode_score_without_al()

n1 = zeros(1, 8);
n2 = n1;
n3 = n1;
n4 = n1;
total_pos = 0;
total_neg = 0;

idx = 1:8;
error = [0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9];

for main_counter=1:185    
    disp(num2str(main_counter))
    db_prefix = strcat('db', num2str(main_counter));
    im_prefix = strcat('p', num2str(main_counter));    
    
    touti = dir(strcat('data\testimages\cleaned\', im_prefix, '_*.bmp'));
    if isempty(touti)
       continue
    end
    
    database = dir(strcat('data\database\direction_code\', db_prefix, '_*.bmp'));
    testim = dir(strcat('data\testimages\direction_code\', im_prefix, '_*.bmp'));
    if isempty(database) || isempty(testim)
       continue
    end
    
    if numel(testim) ~= 5
        disp('nou la')
    end
    
    %positive
    error = [0.2 0.34 0.4 0.5 0.6 0.7 0.8 0.9];
    scores = report_score(testim, database);
    
    for sc=1:numel(scores)
        %score = floor(scores(sc)*10);
        score = scores(sc);
        idx_n1 = idx(score <= error);
        idx_n2 = idx(score > error);
        
        n1(idx_n1) = n1(idx_n1) + 1;
        n2(idx_n2) = n2(idx_n2) + 1;
        
        if score >= 0.8
            disp(testim(sc).name)
        end
    end
    
    total_pos = total_pos + numel(scores);
    
    %negative
    error = [0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9];
    for t=1:185
       if t == main_counter
          continue
       end
       
       touti = dir(strcat('data\testimages\cleaned\', im_prefix, '_*.bmp'));
       if isempty(touti)
          continue
       end
       
       
       %load the two sets
       db_prefix = strcat('db', num2str(t));
       database = dir(strcat('data\database\direction_code\', db_prefix, '_*.bmp'));
       if isempty(database)
          continue
       end
       
       %get score
       scores = report_score(testim, database);
       for sc=1:numel(scores)
           %score = floor(scores(sc)*10);
           score = scores(sc);
           idx_n3 = idx(score <= error);
           idx_n4 = idx(score > error);

           n3(idx_n3) = n3(idx_n3) + 1;
           n4(idx_n4) = n4(idx_n4) + 1;
       end
       
       total_neg = total_neg + numel(scores);
    end
end


%write result to file
output = [n1; n2; n3; n4];
fid = fopen('report_palmcode_without_al.txt', 'w');
fprintf(fid, '%4s %4s %4s %4s\n', 'N1', 'N2', 'N3', 'N4');
fprintf(fid, '%4d %4d %4d %4d\n', output);
fprintf(fid, '\n\n%10s %4d \n%10s %4d\n', 'Total_pos = ', total_pos, 'Total_neg = ', total_neg);
fclose(fid);

disp('nou fini')
end


function score = report_score(testimage, database)
   %run icp on every image
   im_len = length(testimage);
   score = zeros(1, im_len);
   idx = [];
   
   for t=1:im_len    
       test_im = imread(fullfile(testimage(t).folder, testimage(t).name));
       if isempty(find(test_im, 1))
           continue
       end
       
       [~, gloabl_min, witness] = build_alignment_one(test_im, database);
       if ~witness
          idx = [idx, t];
          continue
       end
       
       %score
       score(t) = gloabl_min;   
   end
   
   score(idx) = [];
end

function [winner_idx, gloabl_min, witness] = build_alignment_one(moving_im, database)
db_len = length(database);
witness = 0;
winner_idx = 1;

gloabl_min = inf;

for counter=1:db_len
    % get the image image for one person
    fixed_im = imread(fullfile(database(counter).folder, database(counter).name));
    
    if isempty(find(fixed_im, 1))
        continue
    end
    
    witness = 1;
    
    score = palm_histo_score(moving_im, fixed_im);
    %global_min
    if score < gloabl_min
        winner_idx = counter;
        gloabl_min = score;
    end 
end

end