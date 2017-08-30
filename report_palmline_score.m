function report_palmline_score()

n1 = zeros(1, 8);
n2 = n1;
n3 = n1;
n4 = n1;
total_pos = 0;
total_neg = 0;

idx = 1:8;
error = [0.5 1 1.5 2 2.5 3 3.5 4];

for main_counter=1:185
    
    disp(num2str(main_counter))
    db_prefix = strcat('db', num2str(main_counter));
    im_prefix = strcat('p', num2str(main_counter));    
    
    database = dir(strcat('data\database\cleaned\', db_prefix, '_*.bmp'));
    testim = dir(strcat('data\testimages\cleaned\', im_prefix, '_*.bmp'));
    if isempty(database) || isempty(testim)
       continue
    end
    
    if numel(testim) ~= 5
        disp('nou la')
    end
    
    %positive
    scores = report_score(testim, database);
    
    for sc=1:numel(scores)
        %score = floor(scores(sc)*10);
        score = scores(sc);
        idx_n1 = idx(score <= error);
        idx_n2 = idx(score > error); 
        
        n1(idx_n1) = n1(idx_n1) + 1;
        n2(idx_n2) = n2(idx_n2) + 1;
        
        if score >= 2.5
            disp(testim(sc).name)
        end
    end
    
    total_pos = total_pos + numel(scores);
    
    continue
    
    %negative
    for t=1:185
       if t == main_counter
          continue
       end
       
       
       %load the two sets
       db_prefix = strcat('db', num2str(t));
       database = dir(strcat('data\database\cleaned\', db_prefix, '_*.bmp'));
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
fid = fopen('report_error_with_al.txt', 'w');
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
   %fid = fopen('aligned_data.txt', 'a');
   
   for t=1:im_len    
       current_im = imread(fullfile(testimage(t).folder, testimage(t).name));
       if isempty(find(current_im, 1))
           continue
       end
       
       [~, ~, error, witness, global_idx] = build_alignment_one(current_im, database);
       if ~witness
           idx = [idx, t];
           continue
       end
       
       %score(t) = palmline_score(M, Dicp);   
       score(t) = error;
       
       %name1 = testimage(global_idx).name;
       %name2 = database(global_idx).name;
       
       %write result to file
        %fprintf(fid, '%s %s\n', name1, name2);       
   end
   
   %fclose(fid);
   score(idx) = [];
end

function [M_out, Dicp_out, gloabl_min, witness, global_idx] = build_alignment_one(moving_im, database)
db_len = length(database);
M_out = [];
Dicp_out = [];
witness = 0;

gloabl_min = inf;
global_idx = 1;

for counter=1:db_len
    % get the image image for one person
    fixed_im = imread(fullfile(database(counter).folder, database(counter).name));
    
    if isempty(find(fixed_im, 1))
        continue
    end
    
    witness = 1;
    
    % datasets
    [y, x] = find(fixed_im);
    M = [x, y];

    [y, x] = find(moving_im);
    D = [x, y];
%tic
    %first way
    [~, ~, Dicp1, ~, er1] = icp(D, M, 50, 0.0001, 0);
    M1 = M';
    Dicp1 = Dicp1';
%toc
%tic
    %second way
    [~, ~, Dicp2, ~, er2] = icp(M, D, 50, 0.0001, 0);
    M2 = D';
    Dicp2 = Dicp2';
%toc   
    % statistics
     er1_1 = er1(end);
     er2_1 = er2(end);
     
     if er1_1 < er2_1
         min_er = er1_1;
         M_temp = M1;
         Dicp_temp = Dicp1;
     else
         min_er = er2_1;
         M_temp = M2;
         Dicp_temp = Dicp2;
     end
     
    %global_min
    if min_er < gloabl_min
        gloabl_min = min_er;
        global_idx = counter;
        M_out = M_temp;
        Dicp_out = Dicp_temp;
    end
end


end










