function report_palmcode_recog_al()
right_al = zeros(1, 1);
wrong_al = right_al;

%parpool
% parpool(4)

parfor main_counter=1:20
    disp(num2str(main_counter))
    im_prefix = strcat('p', num2str(main_counter), '_*.bmp');
    
    testim = dir(fullfile('data\testimages\direction_code', im_prefix));
    if isempty(testim)
       continue
    end
    
    if numel(testim) ~= 6
        disp('nou la')
    end
    
    %recognition
    for t=1:numel(testim)
       current_im_name = testim(t).name;
        
       %get class (1xN array), same size as error
       [al] = report_score(current_im_name);
       
       %classification
       %min indexes
       [~, al_min_idx] = min(al);
       
       %verdicts
       idx = (al_min_idx == main_counter);
       right_al = right_al + idx;
       wrong_al = wrong_al + ~idx;
       
       if ~idx(1)
          fid = fopen('mismatched_palmcode_recog_al.txt', 'a');
          fprintf(fid, '%10s %3d \n', current_im_name, al_min_idx(1));
          fclose(fid);
       end
       
    end
 end

%write result to file
fid = fopen('report_palmcode_recog_al.txt', 'w');
fprintf(fid, '%s\n', 'DP');
fprintf(fid, '%4d %4d\n', [right_al; wrong_al]);
fclose(fid);

% delete(gcp('nocreate'))
disp('nou fini')
end


function [al] = report_score(im_test_name)
   %image
   
   %test the image against all the database
   folder_cleaned = 'data\database\cleaned';
   al = zeros(100, 1) + inf;
   
   for t=1:100
       db_name = strcat('db', num2str(t),'_*.bmp');
       database_cleaned = dir(fullfile(folder_cleaned, db_name));
       
       %get the score form direct palmcode
       al(t) = aligned_palmcode(im_test_name, database_cleaned);
   end
end